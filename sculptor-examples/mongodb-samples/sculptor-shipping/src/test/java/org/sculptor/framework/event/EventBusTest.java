package org.sculptor.framework.event;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;

import java.util.concurrent.atomic.AtomicInteger;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.framework.event.Event;
import org.sculptor.framework.event.EventBus;
import org.sculptor.framework.event.EventSubscriber;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;

@RunWith(org.springframework.test.context.junit4.SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class EventBusTest extends AbstractJUnit4SpringContextTests {
    private static final String CHANNEL = "testChannel";
    MyEventHandler handler;
    @Autowired
    @Qualifier("eventBus")
    private EventBus eventBus;

    @Test
    public void publicEventShouldBeRoutedThroughTheBus() {
        eventBus.publish(CHANNEL, new TestEvent("foo"));
        assertNotNull(handler.event);

    }

    @Test
    public void noMoreEventsShouldBeRoutedAfterUnsubscribe() {
        eventBus.publish(CHANNEL, new TestEvent("foo"));
        assertNotNull(handler.event);
        eventBus.unsubscribe(CHANNEL, handler);
        handler.event = null;
        eventBus.publish(CHANNEL, new TestEvent("foo"));
        assertNull(handler.event);
    }

    @Test
    public void TenThousandEventsShouldPass() {
        int noOfEvents = 10000;
        long time = System.currentTimeMillis();
        System.out.println("Start of 10000 events");
        for (int i = 0; i < noOfEvents; i++) {
            eventBus.publish(CHANNEL, new TestEvent("#" + i));
        }
        System.out.println("End of 10000 events, took: " + (System.currentTimeMillis() - time) + " millis.");
        assertEquals(noOfEvents, handler.counter.get());
    }

    @Before
    public void initBusAndHandler() {
        MyEventHandler handler = new MyEventHandler();
        eventBus.subscribe(CHANNEL, handler);
        this.handler = handler;
    }

    @After
    public void cleanUpBusAndHandler() {
        if (handler != null) {
            eventBus.unsubscribe(CHANNEL, handler);
        }
        this.handler = null;
    }

    private static class MyEventHandler implements EventSubscriber {
        Event event;
        AtomicInteger counter = new AtomicInteger();

        @Override
        public void receive(Event event) {
            this.event = event;
            counter.incrementAndGet();
        }
    }

    private static class TestEvent implements Event {
        private static final long serialVersionUID = 1L;

        public TestEvent(String data) {
            this.data = data;
        }

        String data;
    }
}
