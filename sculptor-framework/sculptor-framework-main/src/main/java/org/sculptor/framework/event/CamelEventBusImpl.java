/*
 * Copyright 2010 The Fornax Project Team, including the original
 * author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.framework.event;

import java.util.HashMap;
import java.util.Map;

import javax.annotation.Resource;

import org.apache.camel.CamelContext;
import org.apache.camel.Consumer;
import org.apache.camel.Endpoint;
import org.apache.camel.Exchange;
import org.apache.camel.ProducerTemplate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

@Component
public class CamelEventBusImpl implements EventBus {
    private static final String DEFAULT_TOPIC_PREFIX = "direct:";

    private final Logger log = LoggerFactory.getLogger(getClass());

    private final Map<EventListener, Consumer> listeners = new HashMap<EventListener, Consumer>();

    @Resource(name = "producerTemplate")
    private ProducerTemplate producer;

    @Autowired
    private CamelContext camelContext;

    private final boolean propagateException;

    public CamelEventBusImpl() {
        this.propagateException = false;
    }

    public CamelEventBusImpl(boolean propagateException) {
        this.propagateException = propagateException;
    }

    public boolean publish(String toTopic, Event event) {
        try {
            producer.sendBody(prefixed(toTopic), event);
            return true;
        } catch (RuntimeException e) {
            if (propagateException) {
                throw e;
            } else {
                log.warn(String.format("Exception when publishing event %s to topic %s", event, toTopic));
            }
            return false;
        }
    }

    public boolean subscribe(String toTopic, final EventSubscriber subscriber) {
        try {
            Endpoint endpoint = camelContext.getEndpoint(prefixed(toTopic));
            Consumer consumer = endpoint.createConsumer(new org.apache.camel.Processor() {
                public void process(Exchange exchange) throws Exception {
                    Event event = (Event) exchange.getIn().getBody();
                    subscriber.receive(event);
                }
            });
            camelContext.addService(consumer);
            synchronized (listeners) {
                listeners.put(new EventListener(toTopic, subscriber), consumer);
            }
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
        return true;
    }

    public boolean unsubscribe(String toTopic, EventSubscriber subscriber) {
        try {
            EventListener eventListener = new EventListener(toTopic, subscriber);
            Consumer consumer = null;
            synchronized (listeners) {
                consumer = listeners.get(eventListener);
                listeners.remove(eventListener);
            }
            if (consumer != null) {
                consumer.stop();
            }
        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
        return true;
    }

    protected String prefixed(String topic) {
        if (topic.contains(":")) {
            return topic;
        } else {
            return DEFAULT_TOPIC_PREFIX + topic;
        }
    }

}