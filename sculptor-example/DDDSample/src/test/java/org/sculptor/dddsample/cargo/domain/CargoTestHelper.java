package org.sculptor.dddsample.cargo.domain;

import java.util.Collection;

import org.sculptor.dddsample.location.domain.Location;

/**
 * For easy testdata creation.
 * 
 */
public class CargoTestHelper {

    public static Cargo createCargoWithDeliveryHistory(TrackingId trackingId, Location origin, Location destination,
            Collection<HandlingEvent> events) {

        final Cargo cargo = new Cargo(trackingId, origin, destination);
        cargo.getEvents().addAll(events);

        return cargo;
    }

}
