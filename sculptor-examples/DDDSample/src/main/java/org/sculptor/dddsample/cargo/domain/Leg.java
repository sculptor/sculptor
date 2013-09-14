package org.sculptor.dddsample.cargo.domain;

import javax.persistence.Entity;
import javax.persistence.Table;

import org.apache.commons.lang.Validate;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.location.domain.Location;

/**
 * An itinerary consists of one or more legs.
 */
@Entity(name = "Leg")
@Table(name = "LEG")
public class Leg extends LegBase {
    private static final long serialVersionUID = 1L;

    protected Leg() {
    }

    public Leg(CarrierMovement carrierMovement, Location from, Location to) {
        super(carrierMovement, from, to);
        Validate.noNullElements(new Object[]{carrierMovement, from, to});
    }
}
