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

import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ApplicationContextAware;
import org.springframework.integration.MessageRejectedException;
import org.springframework.integration.channel.PublishSubscribeChannel;
import org.springframework.messaging.Message;
import org.springframework.messaging.MessageDeliveryException;
import org.springframework.messaging.MessageHandler;
import org.springframework.messaging.MessageHandlingException;
import org.springframework.messaging.support.GenericMessage;
import org.springframework.stereotype.Component;

@Component
public class SpringIntegrationEventBusImpl implements EventBus, ApplicationContextAware {
    private ApplicationContext ctx;
    private final Map<EventListener, MessageHandler> listeners = new HashMap<EventListener, MessageHandler>();

    @Override
    public boolean publish(String topic, Event event) {
        PublishSubscribeChannel intChannel = getChannel(topic);
        GenericMessage<Object> intMessage = new GenericMessage<Object>(event);
        intChannel.send(intMessage);
        return true;
    }

    @Override
    public boolean subscribe(String topic, final EventSubscriber subscriber) {
        PublishSubscribeChannel intChannel = getChannel(topic);
        MessageHandler messageHandler = new MessageHandler() {

            @Override
            public void handleMessage(Message<?> message) throws MessageRejectedException, MessageHandlingException,
                    MessageDeliveryException {
                subscriber.receive((Event) message.getPayload());

            }
        };
        EventListener eventListener = new EventListener(topic, subscriber);
        boolean success = intChannel.subscribe(messageHandler);
        if (success) {
            synchronized (listeners) {
                listeners.put(eventListener, messageHandler);
            }
        }
        return success;
    }

    @Override
    public boolean unsubscribe(String topic, EventSubscriber subscriber) {
        PublishSubscribeChannel intChannel = getChannel(topic);
        EventListener eventListener = new EventListener(topic, subscriber);
        MessageHandler messageHandler = null;
        boolean success = true;
        synchronized (listeners) {
            messageHandler = listeners.get(eventListener);
            listeners.remove(eventListener);
        }
        if (messageHandler != null) {
            success = intChannel.unsubscribe(messageHandler);
        }

        return success;
    }

    @Override
    public void setApplicationContext(ApplicationContext applicationContext) throws BeansException {
        ctx = applicationContext;

    }

    private PublishSubscribeChannel getChannel(String topic) {
        return (PublishSubscribeChannel) ctx.getBean(topic);
    }

}
