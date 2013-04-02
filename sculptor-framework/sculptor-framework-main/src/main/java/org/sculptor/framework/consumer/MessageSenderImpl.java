/*
 * Copyright 2009 The Fornax Project Team, including the original
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
package org.sculptor.framework.consumer;

import javax.jms.Connection;
import javax.jms.DeliveryMode;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageProducer;
import javax.jms.Session;
import javax.jms.TextMessage;

/**
 * Implementation of sending JMS messages.
 * The connection, including its lifecycle is provided
 * by the client.
 *
 */
public class MessageSenderImpl implements MessageSender {

    private final Connection connection;
    private int deliveryMode = DeliveryMode.PERSISTENT;
    private int acknowledgeMode = Session.AUTO_ACKNOWLEDGE;

    public MessageSenderImpl(Connection connection) {
        this.connection = connection;
    }

    public void sendMessage(Destination destination, Message message) {
        Session session = null;
        MessageProducer sender = null;
        try {
            session = connection.createSession(false, acknowledgeMode);
            sender = session.createProducer(destination);
            sender.setDeliveryMode(deliveryMode);
            sender.send(message);
        } catch (JMSException e) {
            throw new RuntimeException(e);
        } finally {
            close(session, sender);
        }
    }

    public void sendMessage(Destination destination, String message, String correlationId) {
        Session session = null;
        MessageProducer sender = null;
        try {
            session = connection.createSession(false, acknowledgeMode);
            sender = session.createProducer(destination);
            sender.setDeliveryMode(deliveryMode);
            TextMessage textMessage = session.createTextMessage(message);
            if (correlationId != null) {
                textMessage.setJMSCorrelationID(correlationId);
            }
            sender.send(textMessage);

        } catch (JMSException e) {
            throw new RuntimeException(e);
        } finally {
            close(session, sender);
        }
    }

    private void close(Session session, MessageProducer sender) {
        if (sender != null) {
            try {
                sender.close();
            } catch (Exception ignore) {
            }
        }
        if (session != null) {
            try {
                session.close();
            } catch (Exception ignore) {
            }
        }
    }

    public int getDeliveryMode() {
        return deliveryMode;
    }

    public void setDeliveryMode(int deliveryMode) {
        this.deliveryMode = deliveryMode;
    }

    public int getAcknowledgeMode() {
        return acknowledgeMode;
    }

    public void setAcknowledgeMode(int acknowledgeMode) {
        this.acknowledgeMode = acknowledgeMode;
    }

}
