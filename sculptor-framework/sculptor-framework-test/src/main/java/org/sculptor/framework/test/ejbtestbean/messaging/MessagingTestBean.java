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
package org.sculptor.framework.test.ejbtestbean.messaging;

import javax.annotation.PreDestroy;
import javax.annotation.Resource;
import javax.ejb.Stateless;
import javax.ejb.TransactionManagement;
import javax.ejb.TransactionManagementType;
import javax.jms.ConnectionFactory;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.MessageConsumer;
import javax.jms.Session;
import javax.jms.TemporaryQueue;
import javax.jms.TextMessage;

import org.sculptor.framework.consumer.MessageSender;
import org.sculptor.framework.consumer.MessageSenderImpl;

/**
 * Used by AbstractOpenEJBTest, but can be used directly from application
 * project (test.ejb-jar file) also. The 'openejb.deployments.classpath.include'
 * will cause this EJB to be automatically discovered and deployed when OpenEJB
 * boots up.
 */
@Stateless(name = "MessagingTestBean")
@TransactionManagement(TransactionManagementType.BEAN)
public class MessagingTestBean implements MessagingTestLocal {
    @Resource
    private ConnectionFactory connectionFactory;
    private javax.jms.Connection connection;

    @Override
    public Destination sendMessage(Destination destination, String message) {
        Session jmsSession = null;
        try {
            jmsSession = getJmsConnection().createSession(false, Session.AUTO_ACKNOWLEDGE);
            TextMessage textMessage = jmsSession.createTextMessage(message);
            return sendMessage(destination, textMessage);
        } catch (JMSException e) {
            throw new RuntimeException(e);
        } finally {
            if (jmsSession != null) {
                try {
                    jmsSession.close();
                } catch (Exception ignore) {
                }
            }
        }
    }

    @Override
    public Destination sendMessage(Destination destination, Message message) {
        try {
            Destination replyTo = message.getJMSReplyTo();
            if (replyTo == null) {
                replyTo = createTemporaryQueue();
                message.setJMSReplyTo(replyTo);
            }

            getMessageSender().sendMessage(destination, message);
            return replyTo;
        } catch (JMSException e) {
            throw new RuntimeException(e);
        }
    }

    protected MessageSender getMessageSender() {
        if (getJmsConnection() == null) {
            throw new IllegalStateException("Need JMS connection to be able to send messages.");
        }
        return new MessageSenderImpl(getJmsConnection());
    }

    protected javax.jms.Connection getJmsConnection() {
        try {
            if (connection == null) {
                connection = connectionFactory.createConnection();
                connection.start();
            }
            return connection;
        } catch (JMSException e) {
            throw new RuntimeException(e);
        }
    }

    protected TemporaryQueue createTemporaryQueue() {
        Session jmsSession = null;
        try {
            jmsSession = getJmsConnection().createSession(false, Session.AUTO_ACKNOWLEDGE);
            return jmsSession.createTemporaryQueue();
        } catch (JMSException e) {
            throw new RuntimeException(e);
        } finally {
            if (jmsSession != null) {
                try {
                    jmsSession.close();
                } catch (Exception ignore) {
                }
            }
        }
    }

    @Override
    public Message waitForReply(Destination replyDestination, int timeout) {
        Session jmsSession = null;
        try {
            jmsSession = getJmsConnection().createSession(false, Session.AUTO_ACKNOWLEDGE);
            MessageConsumer consumer = jmsSession.createConsumer(replyDestination);
            Message replyMsg = consumer.receive(timeout);
            return replyMsg;
        } catch (JMSException e) {
            throw new RuntimeException(e);
        } finally {
            if (jmsSession != null) {
                try {
                    jmsSession.close();
                } catch (Exception ignore) {
                }
            }
        }
    }

    @PreDestroy
    public void ejbRemove() {
        try {
            if (connection != null) {
                connection.stop();
                connection.close();
                connection = null;
            }
        } catch (Exception ignore) {
        }
    }

}