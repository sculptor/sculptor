package org.sculptor.dddsample.cargo.domain;

import java.util.Collections;
import java.util.List;

import javax.persistence.Entity;
import javax.persistence.Table;

import org.apache.commons.lang.Validate;

/**
 *
 * Value object representing Itinerary. This class is responsible for the domain
 * object related business logic for Itinerary. Properties and associations are
 * implemented in the generated base class
 * {@link org.sculptor.dddsample.cargo.domain.ItineraryBase}.
 */
@Entity(name = "Itinerary")
@Table(name = "ITINERARY")
public class Itinerary extends ItineraryBase {
    private static final long serialVersionUID = 1L;
    static final Itinerary EMPTY_ITINERARY = new Itinerary();

	public Itinerary(final List<Leg> legs) {
		Validate.notEmpty(legs);
		Validate.noNullElements(legs);

		super.getLegs().addAll(legs);
	}

	Itinerary() {
	}

	@Override
    public List<Leg> getLegs() {
		return Collections.unmodifiableList(super.getLegs());
	}

	/**
	 * Test if the given handling event is expected when executing this
	 * itinerary.
	 *
	 * @param event
	 *            Event to test.
	 * @return <code>true</code> if the event is expected
	 */
	public boolean isExpected(final HandlingEvent event) {
		if (getLegs().isEmpty()) {
			return true;
		}

		if (event.getType() == Type.RECEIVE) {
			// Check that the first leg's origin is the event's location
			final Leg leg = getLegs().get(0);
			return (leg.getFrom().equals(event.getLocation()));
		}

		if (event.getType() == Type.LOAD) {
			// Check that the there is one leg with same from location and
			// carrier movement
			for (Leg leg : getLegs()) {
				if (leg.getFrom().equals(event.getLocation())
						&& leg.getCarrierMovement().equals(
								event.getCarrierMovement()))
					return true;
			}
			return false;
		}

		if (event.getType() == Type.UNLOAD) {
			// Check that the there is one leg with same to loc and carrier
			// movement
			for (Leg leg : getLegs()) {
				if (leg.getTo().equals(event.getLocation())
						&& leg.getCarrierMovement().equals(
								event.getCarrierMovement()))
					return true;
			}
			return false;
		}

		if (event.getType() == Type.CLAIM) {
			// Check that the last leg's destination is from the event's
			// location
			final Leg leg = getLegs().get(getLegs().size() - 1);
			return (leg.getTo().equals(event.getLocation()));
		}

		// HandlingEvent.Type.CUSTOMS;
		return true;
	}
}
