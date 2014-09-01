package org.sculptor.dddsample.cargo.domain;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.assertTrue;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.location.domain.SampleLocations.HELSINKI;
import static org.sculptor.dddsample.location.domain.SampleLocations.HONGKONG;
import static org.sculptor.dddsample.location.domain.SampleLocations.MELBOURNE;
import static org.sculptor.dddsample.location.domain.SampleLocations.STOCKHOLM;

import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.List;
import java.util.TimeZone;

import javax.persistence.Query;

import org.joda.time.DateTime;
import org.junit.Test;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;
import org.sculptor.dddsample.carrier.domain.CarrierMovementRepository;
import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.dddsample.location.domain.LocationRepository;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

public class CargoRepositoryTest extends AbstractDbUnitJpaTests {
    private CargoRepository cargoRepository;
    private LocationRepository locationRepository;
    private CarrierMovementRepository carrierMovementRepository;

    @Autowired
    public void setCargoRepository(CargoRepository cargoRepository) {
        this.cargoRepository = cargoRepository;
    }

    @Autowired
    public void setLocationRepository(LocationRepository locationRepository) {
        this.locationRepository = locationRepository;
    }

    @Autowired
    public void setCarrierMovementRepository(CarrierMovementRepository carrierMovementRepository) {
        this.carrierMovementRepository = carrierMovementRepository;
    }

    private static final Timestamp base;
    static {
        try {
            SimpleDateFormat utcSimpleDateFormat = new SimpleDateFormat("yyyy-MM-dd") {
                {
                    // set the calendar to use UTC
                    calendar = Calendar.getInstance(TimeZone.getTimeZone("UTC"));
                    calendar.setLenient(false);
                }
            };

            Date date = utcSimpleDateFormat.parse("2008-01-01");
            base = new Timestamp(date.getTime());
        } catch (ParseException e) {
            throw new RuntimeException(e);
        }
    }

    private static Timestamp ts(int hours) {
        return new Timestamp(base.getTime() + 1000L * 60 * 60 * hours);
    }

    public static DateTime offset(int hours) {
        return new DateTime(new Date(ts(hours).getTime()));
    }

    @Override
    protected String[] getCompositeDataSetFiles() {
        return new String[] {"dbunit/TestData.xml","dbunit/ExtraCargo.xml" };
    }

    @Test
    public void testFindByCargoIdExtra() throws Exception {
        Cargo cargo = cargoRepository.find(trackingId("JJJ"), true);
        assertEquals(Long.valueOf(6), cargo.getOrigin().getId());
        assertEquals(Long.valueOf(2), cargo.getDestination().getId());
    }
    
    @Test
    public void testFindByCargoId() throws Exception {
        Cargo cargo = cargoRepository.find(trackingId("FGH"), true);
        assertEquals(HONGKONG, cargo.getOrigin());
        assertEquals(HELSINKI, cargo.getDestination());

        DeliveryHistory dh = cargo.deliveryHistory();
        assertNotNull(dh);

        List<HandlingEvent> events = dh.eventsOrderedByCompletionTime();
        assertEquals(2, events.size());

        HandlingEvent firstEvent = events.get(0);
        assertHandlingEvent(cargo, firstEvent, Type.RECEIVE, HONGKONG, 100, 160, null);

        HandlingEvent secondEvent = events.get(1);
        CarrierMovement expectedCm = new CarrierMovement(new CarrierMovementId("CAR_010"), HONGKONG, MELBOURNE);
        assertHandlingEvent(cargo, secondEvent, Type.LOAD, HONGKONG, 150, 110, expectedCm);

        List<Leg> legs = cargo.itinerary().getLegs();
        assertEquals(3, legs.size());

        Leg firstLeg = legs.get(0);
        assertLeg(firstLeg, "CAR_010", HONGKONG, MELBOURNE);

        Leg secondLeg = legs.get(1);
        assertLeg(secondLeg, "CAR_011", MELBOURNE, STOCKHOLM);

        Leg thirdLeg = legs.get(2);
        assertLeg(thirdLeg, "CAR_011", STOCKHOLM, HELSINKI);
    }

    private void assertHandlingEvent(Cargo cargo, HandlingEvent event, Type expectedEventType,
            Location expectedLocation, int completionTimeMs, int registrationTimeMs,
            CarrierMovement expectedCarrierMovement) {
        assertEquals(expectedEventType, event.getType());
        assertEquals(expectedLocation, event.getLocation());

        DateTime expectedCompletionTime = offset(completionTimeMs);
        assertEquals(expectedCompletionTime, event.getCompletionTime());

        DateTime expectedRegistrationTime = offset(registrationTimeMs);
        assertEquals(expectedRegistrationTime, event.getRegistrationTime());

        if (expectedCarrierMovement == null) {
            assertNull(event.getCarrierMovement());
        } else {
            assertEquals(expectedCarrierMovement, event.getCarrierMovement());
        }
        assertEquals(cargo, event.getCargo());
    }

    @Test(expected=CargoNotFoundException.class)
    public void testFindByCargoIdUnknownId() throws CargoNotFoundException {
        cargoRepository.find(trackingId("UNKNOWN"));
    }

    private void assertLeg(Leg firstLeg, String cmId, Location expectedFrom, Location expectedTo) {
        assertEquals(new CarrierMovementId(cmId), firstLeg.getCarrierMovement().getCarrierMovementId());
        assertEquals(expectedFrom, firstLeg.getFrom());
        assertEquals(expectedTo, firstLeg.getTo());
    }

    @Test
    public void testSave() throws LocationNotFoundException {
        TrackingId trackingId = trackingId("AAA");
        Location origin = locationRepository.find(STOCKHOLM.getUnLocode());
        Location destination = locationRepository.find(MELBOURNE.getUnLocode());

        Cargo cargo = new Cargo(trackingId, origin, destination);
        cargoRepository.save(cargo);

        assertEquals(cargo, getCargoForTrackingIdByNativeQuery(trackingId));
    }

    /**
     * need to lookup Cargo within the same transaction, hsqldb 2.x doesn't
     * support read uncommitted
     */
    private Cargo getCargoForTrackingIdByNativeQuery(TrackingId trackingId) {
        flush();
        getEntityManager().clear();
        Query query = getEntityManager().createNativeQuery(
                "select * from Cargo where TRACKINGID = '" + trackingId.getIdentifier() + "'", Cargo.class);
        return (Cargo) query.getSingleResult();
    }

    @Test
    public void testDeleteOrphanedItinerary() throws Exception {
        Cargo cargo = cargoRepository.find(trackingId("FGH"));

        int countBefore = countRowsInTable(Itinerary.class);

        // Repository is responsible for deleting orphaned, detached itineraries
        cargoRepository.detachItineray(cargo);

        int countAfter = countRowsInTable(Itinerary.class);
        assertEquals(countBefore - 1, countAfter);
    }

    @Test
    public void testReplaceItinerary() throws Exception {
        Cargo cargo = cargoRepository.find(trackingId("FGH"));
        Long oldItineraryId = cargo.itinerary().getId();

        assertEquals(1, countRowsInTable(Itinerary.class, "where id = " + oldItineraryId));

        CarrierMovement cm = carrierMovementRepository.find(new CarrierMovementId("CAR_006"));
        Location legFrom = locationRepository.find(new UnLocode("FIHEL"));
        Location legTo = locationRepository.find(new UnLocode("DEHAM"));
        Itinerary newItinerary = new Itinerary(Arrays.asList(new Leg(cm, legFrom, legTo)));

        cargoRepository.detachItineray(cargo);
        cargo.attachItinerary(newItinerary);

        cargo = cargoRepository.save(cargo);

        // Old itinerary should be deleted
        assertEquals(0, countRowsInTable(Itinerary.class, "where id = " + oldItineraryId));

        // New itinerary should be cascade-saved
        Long newItineraryId = cargo.itinerary().getId();

        assertEquals(1, countRowsInTable(Itinerary.class, "where id = " + newItineraryId));
    }

    @Test
    public void testSaveShouldNotCascadeToHandlingEvents() throws Exception {
        Cargo cargo = cargoRepository.find(trackingId("FGH"), true);
        int eventCount = cargo.deliveryHistory().eventsOrderedByCompletionTime().size();

        Location origin = locationRepository.find(STOCKHOLM.getUnLocode());

        HandlingEvent event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.RECEIVE, origin, null);
        assertFalse(cargo.deliveryHistory().eventsOrderedByCompletionTime().contains(event));

        cargo.getEvents().addAll(Arrays.asList(event));
        assertTrue(cargo.deliveryHistory().eventsOrderedByCompletionTime().contains(event));

        // Save cargo, and then re-load it - should not pick
        // up the added event,
        // as it was never cascade-saved

        cargo = cargoRepository.save(cargo);

        getEntityManager().refresh(cargo);
        // cargo = cargoRepository.find(cargo.getTrackingId(), true);
        assertFalse(cargo.deliveryHistory().eventsOrderedByCompletionTime().contains(event));
        assertEquals(eventCount, cargo.deliveryHistory().eventsOrderedByCompletionTime().size());
    }

    @Test
    public void testFindAll() {
        List<Cargo> all = cargoRepository.findAll();
        assertNotNull(all);
        assertEquals(7, all.size());
    }

    @Test
    public void testNextTrackingId() {
        TrackingId trackingId = cargoRepository.nextTrackingId();
        assertNotNull(trackingId);

        TrackingId trackingId2 = cargoRepository.nextTrackingId();
        assertNotNull(trackingId2);
        assertFalse(trackingId.equals(trackingId2));
    }

}