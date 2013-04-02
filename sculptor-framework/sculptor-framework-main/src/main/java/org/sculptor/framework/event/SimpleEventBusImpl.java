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
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;

@Component
public class SimpleEventBusImpl implements EventBus {

    private final Logger log = LoggerFactory.getLogger(getClass());
    private final List<EventListener> listeners = new CopyOnWriteArrayList<EventListener>();
    private Map<String, String> routes = new HashMap<String, String>();
    private final boolean propagateException;

    public SimpleEventBusImpl() {
        this.propagateException = false;
    }

    public SimpleEventBusImpl(boolean propagateException) {
        this.propagateException = propagateException;
    }

    public boolean publish(String topic, Event event) {
        String outChannel = routes.get(topic);
        if (outChannel == null) {
            outChannel = topic;
        }
        boolean allOk = true;
        for (EventListener each : listeners) {
            if (each.isInterestedIn(outChannel)) {
                allOk = notify(each, event) && allOk;
            }
        }
        return allOk;
    }

    protected boolean notify(EventListener listener, Event event) {
        try {
            listener.subscriber.receive(event);
            return true;
        } catch (RuntimeException e) {
            if (propagateException) {
                throw e;
            } else {
                log.warn("Exception from EventListener {} when receiving {}", listener, event);
            }
            return false;
        }
    }

    public boolean subscribe(String topic, EventSubscriber subscriber) {
        listeners.add(new EventListener(topic, subscriber));
        return true;
    }

    public boolean unsubscribe(String topic, EventSubscriber subscriber) {
        listeners.remove(new EventListener(topic, subscriber));
        return true;
    }

    protected Map<String, String> getRoutes() {
        return routes;
    }

    public void setRoutes(Map<String, String> routes) {
        this.routes = routes;
    }

}
