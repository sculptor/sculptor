package org.sculptor.dddsample.cargo.domain;

import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.location.domain.SampleLocations.GOTHENBURG;
import static org.sculptor.dddsample.location.domain.SampleLocations.HANGZOU;
import static org.sculptor.dddsample.location.domain.SampleLocations.HELSINKI;
import static org.sculptor.dddsample.location.domain.SampleLocations.NEWYORK;
import static org.sculptor.dddsample.location.domain.SampleLocations.ROTTERDAM;
import static org.sculptor.dddsample.location.domain.SampleLocations.SHANGHAI;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import junit.framework.TestCase;

import org.joda.time.DateTime;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;

public class ItineraryTest extends TestCase {
    private final CarrierMovement abc = new CarrierMovement(new CarrierMovementId("ABC"), SHANGHAI, ROTTERDAM);
    private final CarrierMovement def = new CarrierMovement(new CarrierMovementId("DEF"), ROTTERDAM, GOTHENBURG);
    private final CarrierMovement ghi = new CarrierMovement(new CarrierMovementId("GHI"), ROTTERDAM, NEWYORK);
    private final CarrierMovement jkl = new CarrierMovement(new CarrierMovementId("JKL"), SHANGHAI, HELSINKI);

    public void testCargoOnTrack() throws Exception {

        Cargo cargo = new Cargo(trackingId("CARGO1"), SHANGHAI, GOTHENBURG);

        Itinerary itinerary = new Itinerary(Arrays.asList(new Leg(new CarrierMovement(new CarrierMovementId("ABC"),
                SHANGHAI, ROTTERDAM), SHANGHAI, ROTTERDAM), new Leg(new CarrierMovement(new CarrierMovementId("DEF"),
                ROTTERDAM, GOTHENBURG), ROTTERDAM, GOTHENBURG)));

        // Happy path
        HandlingEvent event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.RECEIVE, SHANGHAI,
                null);
        assertTrue(itinerary.isExpected(event));

        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.LOAD, SHANGHAI, abc);
        assertTrue(itinerary.isExpected(event));

        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.UNLOAD, ROTTERDAM, abc);
        assertTrue(itinerary.isExpected(event));

        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.LOAD, ROTTERDAM, def);
        assertTrue(itinerary.isExpected(event));

        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.UNLOAD, GOTHENBURG, def);
        assertTrue(itinerary.isExpected(event));

        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.CLAIM, GOTHENBURG, null);
        assertTrue(itinerary.isExpected(event));

        // Customs event changes nothing
        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.CUSTOMS, GOTHENBURG, null);
        assertTrue(itinerary.isExpected(event));

        // Received at the wrong location
        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.RECEIVE, HANGZOU, null);
        assertFalse(itinerary.isExpected(event));

        // Loaded to onto the wrong ship, correct location
        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.LOAD, ROTTERDAM, ghi);
        assertFalse(itinerary.isExpected(event));

        // Unloaded from the wrong ship in the wrong location
        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.UNLOAD, HELSINKI, jkl);
        assertFalse(itinerary.isExpected(event));

        event = new HandlingEvent(cargo, new DateTime(), new DateTime(), Type.CLAIM, ROTTERDAM, null);
        assertFalse(itinerary.isExpected(event));

    }

    public void testNextExpectedEvent() throws Exception {

    }

    public void testCreateItinerary() throws Exception {
        try {
            new Itinerary(new ArrayList<Leg>());
            fail("An empty itinerary is not OK");
        } catch (IllegalArgumentException iae) {
            // Expected
        }

        try {
            List<Leg> legs = null;
            new Itinerary(legs);
            fail("Null itinerary is not OK");
        } catch (IllegalArgumentException iae) {
            //Expected
        }
    }

}