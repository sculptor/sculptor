package org.sculptor.dddsample.cargo.domain;

import java.util.Comparator;

import javax.persistence.Entity;
import javax.persistence.Table;

import org.joda.time.DateTime;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.location.domain.Location;


/**
 *
 * Value object representing HandlingEvent.
 * This class is responsible for the domain object related
 * business logic for HandlingEvent. Properties and associations are
 * implemented in the generated base class {@link org.sculptor.dddsample.cargo.domain.HandlingEventBase}.
 */
@Entity(name = "HandlingEvent")
@Table(name = "HANDLINGEVENT")
public class HandlingEvent extends HandlingEventBase {

    private static final long serialVersionUID = 1047447112680586596L;
    /**
     * Comparator used to be able to sort HandlingEvents according to their completion time
     */
    public static final Comparator<HandlingEvent> BY_COMPLETION_TIME_COMPARATOR = new Comparator<HandlingEvent>() {
      public int compare(final HandlingEvent o1, final HandlingEvent o2) {
        return o1.getCompletionTime().compareTo(o2.getCompletionTime());
      }
    };

    protected HandlingEvent() {
    }

    public HandlingEvent(Cargo cargo, DateTime completionTime,
            DateTime registrationTime, Type type,
        Location location, CarrierMovement carrierMovement) {
        super(completionTime, registrationTime, type, carrierMovement,
            location, cargo);

        validateType();
    }

    HandlingEvent(DateTime completionTime,
            DateTime registrationTime,
            org.sculptor.dddsample.cargo.domain.Type type,
            CarrierMovement carrierMovement, Location location, Cargo cargo) {
        this(cargo, completionTime, registrationTime, type, location, carrierMovement);
    }

    /**
     * Validate that the event type is compatible with the carrier movement value.
     * <p/>
     * Only certain types of events may be associated with a carrier movement.
     */
    private void validateType() {
      if (getType().isCarrierMovementRequired() && getCarrierMovement() == null) {
        throw new IllegalArgumentException("Carrier movement is required for event type " + getType());
      }
      if (!getType().isCarrierMovementRequired() && getCarrierMovement() != null) {
        throw new IllegalArgumentException("Carrier movement is not allowed with event type " + getType());
      }
    }
}
