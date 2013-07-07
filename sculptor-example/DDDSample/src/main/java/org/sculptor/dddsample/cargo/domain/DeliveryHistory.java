package org.sculptor.dddsample.cargo.domain;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.List;

import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.location.domain.Location;

/**
 *
 * Value object representing DeliveryHistory. This class is responsible for the
 * domain object related business logic for DeliveryHistory. Properties and
 * associations are implemented in the generated base class
 * {@link org.sculptor.dddsample.cargo.domain.DeliveryHistoryBase}.
 */
public class DeliveryHistory extends DeliveryHistoryBase {
    private static final long serialVersionUID = -8943689280929642488L;
    @SuppressWarnings("unchecked")
    public static final DeliveryHistory EMPTY_DELIVERY_HISTORY = new DeliveryHistory(Collections.EMPTY_SET);

    
    /**
     * Default constructor exposed from base class - needed for builder.
     */
    public DeliveryHistory() {
		super();
	}

	public DeliveryHistory(Collection<HandlingEvent> events) {
        getEvents().addAll(events);
    }

    /**
     * @return An <b>unmodifiable</b> list of handling events, ordered by the
     *         time the events occured.
     */
    public List<HandlingEvent> eventsOrderedByCompletionTime() {
        final List<HandlingEvent> eventList = new ArrayList<HandlingEvent>(getEvents());
        Collections.sort(eventList, HandlingEvent.BY_COMPLETION_TIME_COMPARATOR);
        return Collections.unmodifiableList(eventList);
    }

    /**
     * @return The last event of the delivery history, or null is history is
     *         empty.
     */
    public HandlingEvent lastEvent() {
        if (getEvents().isEmpty()) {
            return null;
        } else {
            final List<HandlingEvent> orderedEvents = eventsOrderedByCompletionTime();
            return orderedEvents.get(orderedEvents.size() - 1);
        }
    }

    public StatusCode status() {
        if (lastEvent() == null)
            return StatusCode.NOT_RECEIVED;

        final Type type = lastEvent().getType();

        switch (type) {
        case LOAD:
            return StatusCode.ONBOARD_CARRIER;

        case UNLOAD:
        case RECEIVE:
        case CUSTOMS:
            return StatusCode.IN_PORT;

        case CLAIM:
            return StatusCode.CLAIMED;

        default:
            return null;
        }
    }

    public Location currentLocation() {
        if (status().equals(StatusCode.IN_PORT)) {
            return lastEvent().getLocation();
        } else {
            return null;
        }
    }

    public CarrierMovement currentCarrierMovement() {
        if (status().equals(StatusCode.ONBOARD_CARRIER)) {
            return lastEvent().getCarrierMovement();
        } else {
            return null;
        }
    }
}
