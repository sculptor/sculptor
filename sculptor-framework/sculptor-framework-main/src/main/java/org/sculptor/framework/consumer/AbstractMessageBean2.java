/*
 * Copyright 2007 The Fornax Project Team, including the original
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

import javax.annotation.Resource;
import javax.ejb.MessageDrivenContext;
import javax.jms.Connection;
import javax.jms.Destination;
import javax.jms.JMSException;
import javax.jms.Message;
import javax.jms.TextMessage;

import org.sculptor.framework.errorhandling.ApplicationException;
import org.sculptor.framework.errorhandling.InvalidMessageException;
import org.sculptor.framework.errorhandling.LogMessage;
import org.sculptor.framework.errorhandling.MessageException;
import org.sculptor.framework.errorhandling.ServiceContext;
import org.sculptor.framework.errorhandling.ServiceContextFactory;
import org.sculptor.framework.errorhandling.ServiceContextStore;
import org.sculptor.framework.errorhandling.SystemException;
import org.sculptor.framework.errorhandling.UnexpectedRuntimeException;
import org.sculptor.framework.errorhandling.ValidationException;
import org.sculptor.framework.xml.XmlMappingException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * This is a base class for Pure EJB3 implementation of a Consumer. Subclass
 * must override the {@link #consume(String)} method.
 * <p>
 * Some error handling is done by this class. Exceptions to indicate an invalid
 * message can be thrown by subclass. See:
 * http://www.enterpriseintegrationpatterns.com/InvalidMessageChannel.html Note
 * that invalid message channel is not the same as dead letter channel. Invalid
 * messages are for example those that can't be parsed or contain some data that
 * doesn't fulfill the message contract (schema etc). Invalid messages are sent
 * to an invalid message queue. The transaction is committed, to avoid returning
 * it back to the receive queue again. This means that validation to detect
 * invalid message must be done before and modifications of persistent objects.
 * Subclass may define invalid message exceptions by overriding
 * {@link #isInvalidMessageException(Exception)}.
 */
public abstract class AbstractMessageBean2 {

    private final Logger log = LoggerFactory.getLogger(getClass());

    @Resource
    private MessageDrivenContext mdbContext;

    public AbstractMessageBean2() {
    }

    protected Logger getLog() {
        return log;
    }

    public void onMessage(Message msg) {
        if (!checkSupportedMessageTypes(msg)) {
            return;
        }

        try {
            ServiceContext serviceContext = createServiceContext();
            serviceContext.setProperty("jms", Boolean.TRUE);
            boolean redelivered = isJmsRedelivered(msg);
            serviceContext.setProperty("jmsRedelivered", redelivered);
            serviceContext.setProperty("jmsMessageID", getJMSMessageID(msg));
            ServiceContextStore.set(serviceContext);

            String reply = consume(serviceContext, getMessageText(msg));
            sendReply(msg, reply);
        } catch (RuntimeException e) {
            handleRuntimeException(msg, e);
        } catch (ApplicationException e) {
            if (isInvalidMessageException(e)) {
                handleInvalidMessageException(msg, e);
            } else {
                handleApplicationException(e);
            }
        }
    }

    protected void handleRuntimeException(Message msg, RuntimeException e) {
        SystemException excToUse = SystemException.unwrapSystemException(e);
        if (excToUse == null) {
            excToUse = new UnexpectedRuntimeException(e.getMessage());
        }
        if (isInvalidMessageException(excToUse)) {
            handleInvalidMessageException(msg, excToUse);
        } else {
            // re-throw which will cause rollback
            throw e;
        }
    }

    protected void handleInvalidMessageException(Message msg, SystemException e) {
        if (!e.isLogged()) {
            log.error((new LogMessage(e)).toString(), e);
            e.setLogged(true);
        }
        sendToInvalidMessageQueue(msg);
        String invalidMessageReply = formatInvalidMessageReply(e, msg);
        sendReply(msg, invalidMessageReply);
    }

    protected void handleInvalidMessageException(Message msg, ApplicationException e) {
        if (!e.isLogged()) {
            log.error((new LogMessage(e)).toString(), e);
            e.setLogged(true);
        }
        sendToInvalidMessageQueue(msg);
        String invalidMessageReply = formatInvalidMessageReply(e, msg);
        sendReply(msg, invalidMessageReply);
    }

    protected void handleApplicationException(ApplicationException e) {
        if (log.isDebugEnabled() && !e.isLogged()) {
            LogMessage logMessage = new LogMessage(e);
            log.debug(logMessage.toString(), e);
            e.setLogged(true);
        }
        mdbContext.setRollbackOnly();
    }

    protected boolean isJmsRedelivered(Message msg) {

        try {
            return msg.getJMSRedelivered();
        } catch (JMSException e) {
            return false;
        }
    }

    protected String getJMSMessageID(Message msg) {
        try {
            return msg.getJMSMessageID();
        } catch (JMSException e) {
            return null;
        }
    }

    /**
     * Subclass may override to define invalid message exceptions. Default is
     * {@link org.sculptor.framework.errorhandling.InvalidMessageException}
     * ,
     * {@link org.sculptor.framework.errorhandling.XmlMappingException}
     * and
     * {@link org.sculptor.framework.errorhandling.ValidationException}
     */
    protected boolean isInvalidMessageException(Exception e) {
        return (e instanceof InvalidMessageException || e instanceof XmlMappingException || e instanceof ValidationException);
    }

    protected String formatInvalidMessageReply(ApplicationException e, Message msg) {
        return formatInvalidMessageReply(e.getErrorCode(), e.getMessage(), msg);
    }

    protected String formatInvalidMessageReply(SystemException e, Message msg) {
        return formatInvalidMessageReply(e.getErrorCode(), e.getMessage(), msg);
    }

    protected String formatInvalidMessageReply(String errorCode, String excMessage, Message msg) {
        StringBuilder result = new StringBuilder();
        result.append(errorCode);
        result.append("\n");
        result.append(excMessage);
        result.append(getMessageText(msg));
        return result.toString();
    }

    public String consume(ServiceContext ctx, String textMessage) throws ApplicationException {
        return consume(textMessage);
    }

    /**
     * @param textMessage
     *            the incoming text message
     * @return the reply, return null if there is no reply
     */
    public abstract String consume(String textMessage) throws ApplicationException;

    /**
     * Only TextMessages are supported by default. Subclass may override, but
     * then {@link #getMessageText(Message)} must also be implemented to support
     * other message types.
     */
    protected boolean checkSupportedMessageTypes(Message msg) {
        if (msg instanceof TextMessage) {
            return true;
        } else {
            try {
                log.error("Unsupported message type: " + msg.getJMSType());
            } catch (JMSException ignore) {
            }
            sendToInvalidMessageQueue(msg);
            return false;
        }
    }

    protected String getMessageText(Message msg) throws MessageException {
        try {
            if (msg instanceof TextMessage) {
                return ((TextMessage) msg).getText();
            } else {
                throw new IllegalArgumentException("Unsupported message type: " + msg.getJMSType());
            }
        } catch (JMSException e) {
            throw new MessageException("Failure when getting text from JMS message: " + e.getMessage(), e);
        }
    }

    protected ServiceContext createServiceContext() {
        ServiceContext defaultCtx = ServiceContextFactory.createServiceContext(getMessageConsumerBeanId());
        return new ServiceContext(getMessageConsumerBeanId(), defaultCtx.getSessionId(), defaultCtx.getApplicationId(),
                defaultCtx.getRoles());
    }

    protected String getMessageConsumerBeanId() {
        return getClass().getSimpleName();
    }

    protected MessageSender getMessageSender() {
        if (getJmsConnection() == null) {
            throw new IllegalStateException("Need JMS connection to be able to send messages.");
        }
        return new MessageSenderImpl(getJmsConnection());
    }

    protected void sendToInvalidMessageQueue(javax.jms.Message msg) {
        if (getJmsConnection() == null || getInvalidMessageQueue() == null) {
            getLog().info(
                    "No JmsConnection or queue, message that was not sent to InvalidMessageQueue:\n"
                            + safeGetMessageText(msg));
            return;
        }
        String messageText = "";
        try {
            messageText = getMessageText(msg);
            getMessageSender().sendMessage(getInvalidMessageQueue(), messageText, getJMSMessageID(msg));
        } catch (Exception e) {
            getLog().error("Can't send to InvalidMessageQueue: " + e.getMessage(), e);
            getLog().info("Message that was not sent to InvalidMessageQueue:\n" + messageText);
        } finally {
            closeConnection();
        }
    }

    private String safeGetMessageText(Message msg) {
        try {
            return getMessageText(msg);
        } catch (Exception e) {
            return "";
        }
    }

    protected void sendReply(javax.jms.Message msg, String reply)
            throws org.sculptor.framework.errorhandling.MessageException {
        try {
            if (reply == null) {
                reply = defaultOkReply();
            }
            Destination replyTo = msg.getJMSReplyTo();
            if (replyTo != null && getJmsConnection() != null) {
                getMessageSender().sendMessage(replyTo, reply, getJMSMessageID(msg));
            }
        } catch (javax.jms.JMSException e) {
            throw new org.sculptor.framework.errorhandling.MessageException(
                    "Failure when sending repy: " + reply + "\n" + e.getMessage(), e);
        } finally {
            closeConnection();
        }
    }

    protected String defaultOkReply() {
        return "OK";
    }

    /**
     * Subclass need to implement this to be able to send messages, such as
     * reply and send to invalid message queue.
     */
    protected Connection getJmsConnection() {
        return null;
    }

    /**
     * Subclass need to implement this to be able to send messages, such as
     * reply and send to invalid message queue.
     */
    protected void closeConnection() {
    }

    /**
     * Subclass need to implement this to be able to send to invalid message
     * queue. You could override {@link #sendToInvalidMessageQueue} to implement
     * some other error handling for invalid messages.
     */
    protected Destination getInvalidMessageQueue() {
        return null;
    }

}
