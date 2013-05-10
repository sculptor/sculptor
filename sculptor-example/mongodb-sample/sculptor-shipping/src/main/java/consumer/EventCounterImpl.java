package consumer;

import org.sculptor.framework.event.Event;
import org.springframework.stereotype.Component;

/**
 * Implementation of EventCounter.
 */
@Component("eventCounter")
public class EventCounterImpl extends EventCounterImplBase {

	public EventCounterImpl() {
	}

	public void receive(Event event) {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("EventCounter not implemented");
	}

}
