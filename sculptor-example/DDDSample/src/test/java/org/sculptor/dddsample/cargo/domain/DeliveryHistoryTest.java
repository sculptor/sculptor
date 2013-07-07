package org.sculptor.dddsample.cargo.domain;

import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.location.domain.SampleLocations.HAMBURG;
import static org.sculptor.dddsample.location.domain.SampleLocations.HONGKONG;
import static org.sculptor.dddsample.location.domain.SampleLocations.NEWYORK;

import java.util.Arrays;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import junit.framework.TestCase;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;

public class DeliveryHistoryTest extends TestCase {

    private final Cargo cargo = new Cargo(trackingId("XYZ"), HONGKONG, NEWYORK);

    public void testEvensOrderedByTimeOccured() throws Exception {

        DateTimeFormatter df = DateTimeFormat.forPattern("yyyy-MM-dd");

        CarrierMovement carrierMovement = new CarrierMovement(new CarrierMovementId("CAR_001"), HONGKONG, NEWYORK);
        HandlingEvent he1 = new HandlingEvent(cargo, df.parseDateTime("2010-01-03"), new DateTime(), Type.RECEIVE,
                NEWYORK, null);
        HandlingEvent he2 = new HandlingEvent(cargo, df.parseDateTime("2010-01-01"), new DateTime(), Type.LOAD,
                NEWYORK, carrierMovement);
        HandlingEvent he3 = new HandlingEvent(cargo, df.parseDateTime("2010-01-04"), new DateTime(), Type.CLAIM,
                HONGKONG, null);
        HandlingEvent he4 = new HandlingEvent(cargo, df.parseDateTime("2010-01-02"), new DateTime(), Type.UNLOAD,
                HONGKONG, carrierMovement);
        DeliveryHistory dh = new DeliveryHistory(Arrays.asList(he1, he2, he3, he4));

        List<HandlingEvent> orderEvents = dh.eventsOrderedByCompletionTime();
        assertEquals(4, orderEvents.size());
        assertSame(he2, orderEvents.get(0));
        assertSame(he4, orderEvents.get(1));
        assertSame(he1, orderEvents.get(2));
        assertSame(he3, orderEvents.get(3));
    }

    public void testCargoStatusFromLastHandlingEvent() {
        Set<HandlingEvent> events = new HashSet<HandlingEvent>();
        DeliveryHistory deliveryHistory = new DeliveryHistory(events);

        assertEquals(StatusCode.NOT_RECEIVED, deliveryHistory.status());

        events.add(new HandlingEvent(cargo, new DateTime(10), new DateTime(11), Type.RECEIVE, HAMBURG, null));
        deliveryHistory = new DeliveryHistory(events);
        assertEquals(StatusCode.IN_PORT, deliveryHistory.status());

        CarrierMovement carrierMovement = new CarrierMovement(new CarrierMovementId("ABC"), HAMBURG, HAMBURG);
        events.add(new HandlingEvent(cargo, new DateTime(20), new DateTime(21), Type.LOAD, HAMBURG, carrierMovement));
        deliveryHistory = new DeliveryHistory(events);
        assertEquals(StatusCode.ONBOARD_CARRIER, deliveryHistory.status());

        events.add(new HandlingEvent(cargo, new DateTime(30), new DateTime(31), Type.UNLOAD, HAMBURG, carrierMovement));
        deliveryHistory = new DeliveryHistory(events);
        assertEquals(StatusCode.IN_PORT, deliveryHistory.status());

        events.add(new HandlingEvent(cargo, new DateTime(40), new DateTime(41), Type.CLAIM, HAMBURG, null));
        deliveryHistory = new DeliveryHistory(events);
        assertEquals(StatusCode.CLAIMED, deliveryHistory.status());
    }

    public void testCurrentLocation() throws Exception {
        Set<HandlingEvent> events = new HashSet<HandlingEvent>();
        DeliveryHistory deliveryHistory = new DeliveryHistory(events);

        assertNull(deliveryHistory.currentLocation());

        events.add(new HandlingEvent(cargo, new DateTime(10), new DateTime(11), Type.RECEIVE, HAMBURG, null));
        deliveryHistory = new DeliveryHistory(events);
        assertEquals(HAMBURG, deliveryHistory.currentLocation());

        CarrierMovement carrierMovement = new CarrierMovement(new CarrierMovementId("ABC"), HAMBURG, HAMBURG);
        events.add(new HandlingEvent(cargo, new DateTime(20), new DateTime(21), Type.LOAD, HAMBURG, carrierMovement));
        deliveryHistory = new DeliveryHistory(events);
        assertNull(deliveryHistory.currentLocation());
    }

}
