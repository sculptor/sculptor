package org.sculptor.shipping.statistics.consumer;

import java.util.concurrent.atomic.AtomicInteger;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.sculptor.framework.event.Event;
import org.springframework.stereotype.Component;

/**
 * Implementation of EventCounter.
 */
@Component("eventCounter")
public class EventCounterImpl extends EventCounterImplBase {
    private final Log log = LogFactory.getLog(getClass());
    private final AtomicInteger counter = new AtomicInteger();

    public EventCounterImpl() {
    }

    public void receive(Event event) {
        int current = counter.incrementAndGet();
        log.info(String.format("Number of events: %s", current));
    }
}
