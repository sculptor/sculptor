package org.sculptor.dddsample.cargo.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.location.domain.SampleLocations.HELSINKI;
import static org.sculptor.dddsample.location.domain.SampleLocations.HONGKONG;

import java.util.List;

import org.junit.Test;
import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.domain.HandlingEvent;
import org.sculptor.dddsample.cargo.domain.Type;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class TrackingServiceTest extends AbstractDbUnitJpaTests implements TrackingServiceTestBase {

    private TrackingService trackingService;

    @Autowired
    public void setTrackingService(TrackingService trackingService) {
        this.trackingService = trackingService;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testTrack() throws Exception {
        final Cargo cargo = new Cargo(trackingId("FGH"), HONGKONG, HELSINKI);

        // Tested call
        Cargo trackedCargo = trackingService.track(getServiceContext(), trackingId("FGH"));
        assertEquals(cargo, trackedCargo);

        List<HandlingEvent> events = trackedCargo.deliveryHistory().eventsOrderedByCompletionTime();
        assertEquals(2, events.size());

        HandlingEvent handlingEvent = events.get(0);
        assertEquals(Type.RECEIVE, handlingEvent.getType());

        handlingEvent = events.get(1);
        assertEquals(Type.LOAD, handlingEvent.getType());
    }

    @Test(expected=CargoNotFoundException.class)
    public void testTrackThrowingCargoNotFoundException() throws CargoNotFoundException {
        trackingService.track(getServiceContext(), trackingId("ZZZ"));
    }

    @Test
    public void testInspectCargo() throws Exception {
        trackingService.inspectCargo(getServiceContext(), trackingId("FGH"));
    }
}
