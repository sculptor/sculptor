package org.sculptor.dddsample.cargo.domain;

import static org.junit.Assert.assertEquals;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;

import java.util.List;

import javax.persistence.Query;

import org.joda.time.DateTime;
import org.junit.Test;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;
import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.dddsample.location.domain.LocationRepository;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

public class HandlingEventRepositoryTest extends AbstractDbUnitJpaTests {

    private HandlingEventRepository handlingEventRepository;
    private CargoRepository cargoRepository;
    private LocationRepository locationRepository;

    @Autowired
    public void setHandlingEventRepository(HandlingEventRepository handlingEventRepository) {
        this.handlingEventRepository = handlingEventRepository;
    }

    @Autowired
    public void setCargoRepository(CargoRepository cargoRepository) {
        this.cargoRepository = cargoRepository;
    }

    @Autowired
    public void setLocationRepository(LocationRepository locationRepository) {
        this.locationRepository = locationRepository;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testSave() throws LocationNotFoundException, CargoNotFoundException {
        Location location = locationRepository.find(new UnLocode("SESTO"));

        Cargo cargo = cargoRepository.find(trackingId("XYZ"));
        DateTime completionTime = new DateTime(10);
        DateTime registrationTime = new DateTime(20);
        HandlingEvent event = new HandlingEvent(cargo, completionTime, registrationTime, Type.CLAIM, location, null);

        event = handlingEventRepository.save(event);
        assertEquals(event, getHandlingEventForEventByNativeQuery(event));
    }

    /**
     * need to lookup Cargo within the same transaction,
     * hsqldb 2.x doesn't support read uncommitted
     */
    private HandlingEvent getHandlingEventForEventByNativeQuery(HandlingEvent event) {
        flush();
        getEntityManager().clear();
        Query query = getEntityManager().createNativeQuery("select * from HandlingEvent where id =" + event.getId(), HandlingEvent.class);
        return (HandlingEvent) query.getSingleResult();
    }

    public void testFindEventsForCargo() throws Exception {
        List<HandlingEvent> handlingEvents = handlingEventRepository.findEventsForCargo(trackingId("XYZ"));
        assertEquals(12, handlingEvents.size());
    }

}