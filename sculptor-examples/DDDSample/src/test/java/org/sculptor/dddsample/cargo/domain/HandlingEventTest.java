package org.sculptor.dddsample.cargo.domain;

import static java.util.Arrays.asList;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.cargo.domain.Type.CLAIM;
import static org.sculptor.dddsample.cargo.domain.Type.CUSTOMS;
import static org.sculptor.dddsample.cargo.domain.Type.LOAD;
import static org.sculptor.dddsample.cargo.domain.Type.RECEIVE;
import static org.sculptor.dddsample.cargo.domain.Type.UNLOAD;
import static org.sculptor.dddsample.cargo.domain.Type.valueOf;
import static org.sculptor.dddsample.location.domain.SampleLocations.CHICAGO;
import static org.sculptor.dddsample.location.domain.SampleLocations.HAMBURG;
import static org.sculptor.dddsample.location.domain.SampleLocations.HELSINKI;
import static org.sculptor.dddsample.location.domain.SampleLocations.HONGKONG;
import static org.sculptor.dddsample.location.domain.SampleLocations.NEWYORK;
import junit.framework.TestCase;

import org.joda.time.DateTime;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;

public class HandlingEventTest extends TestCase {
    private final Cargo cargo = new Cargo(trackingId("XYZ"), HONGKONG, NEWYORK);

    public void testNewWithCarrierMovement() throws Exception {
        CarrierMovement carrierMovement = new CarrierMovement(new CarrierMovementId("C01"), HONGKONG, NEWYORK);

        HandlingEvent e1 = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.LOAD, HONGKONG,
                carrierMovement);
        assertEquals(HONGKONG, e1.getLocation());

        HandlingEvent e2 = new HandlingEvent(cargo, new DateTime(), new DateTime(), UNLOAD, NEWYORK, carrierMovement);
        assertEquals(NEWYORK, e2.getLocation());

        // These event types prohibit a carrier movement association
        for (Type type : asList(CLAIM, RECEIVE, CUSTOMS)) {
            try {
                new HandlingEvent(cargo, new DateTime(), new DateTime(), type, HONGKONG, carrierMovement);
                fail("Handling event type " + type + " prohibits carrier movement");
            } catch (IllegalArgumentException expected) {
            }
        }

        // These event types requires a carrier movement association
        for (Type type : asList(LOAD, UNLOAD)) {
            try {
                new HandlingEvent(cargo, new DateTime(), new DateTime(), type, HONGKONG, null);
                fail("Handling event type " + type + " requires carrier movement");
            } catch (IllegalArgumentException expected) {
            }
        }
    }

    public void testNewWithLocation() throws Exception {
        HandlingEvent e1 = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.CLAIM, HELSINKI, null);
        assertEquals(HELSINKI, e1.getLocation());
    }

    public void testCurrentLocationLoadEvent() throws Exception {
        CarrierMovementId carrierMovementId = new CarrierMovementId("CAR_001");
        CarrierMovement cm = new CarrierMovement(carrierMovementId, CHICAGO, HAMBURG);

        HandlingEvent ev = new HandlingEvent(cargo, new DateTime(), new DateTime(), LOAD, CHICAGO, cm);

        assertEquals(CHICAGO, ev.getLocation());
    }

    public void testCurrentLocationUnloadEvent() throws Exception {
        CarrierMovementId carrierMovementId = new CarrierMovementId("CAR_001");
        CarrierMovement cm = new CarrierMovement(carrierMovementId, CHICAGO, HAMBURG);

        HandlingEvent ev = new HandlingEvent(cargo, new DateTime(), new DateTime(), UNLOAD, HAMBURG, cm);

        assertEquals(HAMBURG, ev.getLocation());
    }

    public void testCurrentLocationReceivedEvent() throws Exception {
        HandlingEvent ev = new HandlingEvent(cargo, new DateTime(), new DateTime(), RECEIVE, CHICAGO, null);

        assertEquals(CHICAGO, ev.getLocation());
    }

    public void testCurrentLocationClaimedEvent() throws Exception {
        HandlingEvent ev = new HandlingEvent(cargo, new DateTime(), new DateTime(), CLAIM, CHICAGO, null);

        assertEquals(CHICAGO, ev.getLocation());
    }

    public void testParseType() throws Exception {
        assertEquals(CLAIM, valueOf("CLAIM"));
        assertEquals(LOAD, valueOf("LOAD"));
        assertEquals(UNLOAD, valueOf("UNLOAD"));
        assertEquals(RECEIVE, valueOf("RECEIVE"));
    }

    public void testParseTypeIllegal() throws Exception {
        try {
            valueOf("NOT_A_HANDLING_EVENT_TYPE");
            assertTrue("Expected IllegaArgumentException to be thrown", false);
        } catch (IllegalArgumentException e) {
            // All's well
        }
    }

    public void testEqualsAndSameAs() throws Exception {
        DateTime timeOccured = new DateTime();
        DateTime timeRegistered = new DateTime();
        CarrierMovementId carrierMovementId = new CarrierMovementId("CAR_001");
        CarrierMovement cm = new CarrierMovement(carrierMovementId, CHICAGO, HAMBURG);

        HandlingEvent ev1 = new HandlingEvent(cargo, timeOccured, timeRegistered, LOAD, CHICAGO, cm);
        HandlingEvent ev2 = new HandlingEvent(cargo, timeOccured, timeRegistered, LOAD, CHICAGO, cm);

        // Two handling events are not equal() even if all non-uuid fields are identical
        assertFalse(ev1.equals(ev2));
        assertFalse(ev2.equals(ev1));

        assertTrue(ev1.equals(ev1));

        assertFalse(ev2.equals(null));
        assertFalse(ev2.equals(new Object()));
    }

}
