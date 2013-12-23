package org.sculptor.shipping.statistics.consumer;

import java.util.concurrent.atomic.AtomicInteger;

import org.sculptor.framework.event.Event;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

/**
 * Implementation of EventCounter.
 */
@Component("eventCounter")
public class EventCounterImpl extends EventCounterImplBase {

	private static final Logger LOG = LoggerFactory.getLogger(EventCounterImpl.class);

	private final AtomicInteger counter = new AtomicInteger();

	public EventCounterImpl() {
	}

	public void receive(Event event) {
		int current = counter.incrementAndGet();
		LOG.info("Number of events: {}", current);
	}

}
