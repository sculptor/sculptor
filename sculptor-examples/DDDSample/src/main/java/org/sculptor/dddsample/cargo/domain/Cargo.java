package org.sculptor.dddsample.cargo.domain;

import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import org.apache.commons.lang.Validate;
import org.sculptor.dddsample.location.domain.Location;

/**
 * A Cargo. This is the central class in the domain model, and it is the root of
 * the Cargo-Itinerary-Leg-DeliveryHistory aggregate.
 *
 * A cargo is identified by a unique tracking id, and it always has an origin
 * and a destination. The life cycle of a cargo begins with the booking
 * procedure, when the tracking id is assigned. During a (short) period of time,
 * between booking and initial routing, the cargo has no itinerary.
 *
 * The booking clerk requests a list of possible routes, matching a route
 * specification, and assigns the cargo to one route. An itinerary listing the
 * legs of the route is attached to the cargo.
 *
 * A cargo can be re-routed during transport, on demand of the customer, in
 * which case the destination is changed and a new route is requested. The old
 * itinerary, being a value object, is discarded and a new one is attached.
 *
 * It may also happen that a cargo is accidentally misrouted, which should
 * notify the proper personnel and also trigger a re-routing procedure.
 *
 * The life cycle of a cargo ends when the cargo is claimed by the customer.
 *
 * The cargo aggregate, and the entre domain model, is built to solve the
 * problem of booking and tracking cargo. All important business rules for
 * determining whether or not a cargo is misrouted, what the current status of
 * the cargo is (on board carrier, in port etc), are captured in this aggregate.
 */
@Entity(name = "Cargo")
@Table(name = "CARGO"    , uniqueConstraints = @UniqueConstraint(columnNames={"TRACKINGID"}))
public class Cargo extends CargoBase {
    private static final long serialVersionUID = -4916991786969251821L;

    protected Cargo() {
	}

	public Cargo(TrackingId trackingId, Location origin, Location destination) {
		super(trackingId, origin, destination);
	}

	public DeliveryHistory deliveryHistory() {
		return new DeliveryHistory(getEvents());
	}

	/**
	 * @return itinerary, {@link Itinerary.EMPTY_ITINERARY} when null
	 */
	public Itinerary itinerary() {
		return nullSafe(getItinerary(), Itinerary.EMPTY_ITINERARY);
	}

	/**
	 * @return Last known location of the cargo, or Location.UNKNOWN if the
	 *         delivery history is empty.
	 */
	public Location lastKnownLocation() {
		final HandlingEvent lastEvent = deliveryHistory().lastEvent();
		if (lastEvent != null) {
			return lastEvent.getLocation();
		} else {
			return Location.UNKNOWN;
		}
	}

	/**
	 * @return True if the cargo has arrived at its final destination.
	 */
	public boolean hasArrived() {
		return getDestination().equals(lastKnownLocation());
	}

	/**
	 * Attach a new itinerary to this cargo.
	 *
	 * @param itinerary
	 *            an itinerary. May not be null.
	 */
	public void attachItinerary(final Itinerary itinerary) {
		Validate.notNull(itinerary);

		// Decouple the old itinerary from this cargo
		itinerary().setCargo(null);
		// Couple this cargo and the new itinerary
		setItinerary(itinerary);
		itinerary().setCargo(this);
	}

	/**
	 * Detaches the current itinerary from the cargo.
	 */
	public void detachItinerary() {
		itinerary().setCargo(null);
		setItinerary(null);
	}

	/**
	 * Check if cargo is misdirected.
	 * <p/>
	 * <ul>
	 * <li>A cargo is misdirected if it is in a location that's not in the itinerary.
	 * <li>A cargo with no itinerary can not be misdirected.
	 * <li>A cargo that has received no handling events can not be misdirected.
	 * </ul>
	 *
	 * @return <code>true</code> if the cargo has been misdirected,
	 */
	public boolean isMisdirected() {
		final HandlingEvent lastEvent = deliveryHistory().lastEvent();
		if (lastEvent == null) {
			return false;
		} else {
			return !itinerary().isExpected(lastEvent);
		}
	}

	/**
	 * Does not take into account the possibility of the cargo having been
	 * (errouneously) loaded onto another carrier after it has been unloaded at
	 * the final destination.
	 *
	 * @return True if the cargo has been unloaded at the final destination.
	 */
	public boolean isUnloadedAtDestination() {
		for (HandlingEvent event : deliveryHistory().eventsOrderedByCompletionTime()) {
			if (Type.UNLOAD.equals(event.getType()) && getDestination().equals(event.getLocation())) {
				return true;
			}
		}
		return false;
	}

	// Utility for Null Object Pattern - should be moved out of this class
	private <T> T nullSafe(T actual, T safe) {
		return actual == null ? safe : actual;
	}

}
