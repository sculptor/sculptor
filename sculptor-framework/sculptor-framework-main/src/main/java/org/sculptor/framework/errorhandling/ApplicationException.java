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

package org.sculptor.framework.errorhandling;

import java.io.Serializable;
import java.text.MessageFormat;

/**
 * Application exceptions are used for errors that the program is designed to
 * take care of, i.e. recoverable errors at the level of the application.
 * <p>
 * Typical examples:
 * <ul>
 * <li>Validation errors due to bad user input</li>
 * <li>Request to fetch an entity, but there is no entity with specified id.</li>
 * </ul>
 *
 * @author Patrik Nordwall
 *
 */
public class ApplicationException extends Exception {

    private static final long serialVersionUID = 1596208156393065408L;

    private final String errorCode;
    private boolean logged;
    private boolean fatal;
    private Serializable[] messageParameters = null;

    /**
     * @param errorCode
     *            Well defined error code for the error type. Used in logs and
     *            for translation to user messages.
     * @param message
     *            Technical message. Used for debugging purpose, not intended
     *            for end users.
     */
    public ApplicationException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
    }

    /**
     * @param errorCode
     *            Well defined error code for the error type. Used in logs and
     *            for translation to user messages.
     * @param message
     *            Technical message. Used for debugging purpose, not intended
     *            for end users.
     * @param messageParameters
     *            Array of message parameters. Usually used as parameters for generating
     *            i18n messages from errorCode.
     */
    public ApplicationException(String errorCode, String message, Serializable... messageParameters) {
        super(message);
        this.errorCode = errorCode;
        this.messageParameters = messageParameters;
    }

    /**
     * @param errorCode
     *            Well defined error code for the error type. Used in logs and
     *            for translation to user messages.
     * @param message
     *            Technical message. Used for debugging purpose, not intended
     *            for end users.
     * @param cause
     *            Original cause of the exception, use with caution since
     *            clients must include the class of the cause also (e.g. a
     *            vendor specific database exception should not be exposed to
     *            clients).
     */
    public ApplicationException(String errorCode, String message, Throwable cause) {
        super(message, cause);
        this.errorCode = errorCode;
    }

    /**
     * @param errorCode
     *            Well defined error code for the error type. Used in logs and
     *            for translation to user messages.
     * @param message
     *            Technical message. Used for debugging purpose, not intended
     *            for end users.
     * @param cause
     *            Original cause of the exception, use with caution since
     *            clients must include the class of the cause also (e.g. a
     *            vendor specific database exception should not be exposed to
     *            clients).
     * @param messageParameters
     *            Array of message parameters. Usually used as parameters for generating
     *            i18n messages from errorCode.
     */
    public ApplicationException(String errorCode, String message, Throwable cause, Serializable... messageParameters) {
        super(message, cause);
        this.errorCode = errorCode;
        this.messageParameters = messageParameters;
    }

    /**
     * This flag indicates that the error is of fatal charcter and needs special
     * attention, such as an alert in surveilance montoring.
     */
    public boolean isFatal() {
        return fatal;
    }

    /**
     * @see #isFatal()
     */
    public void setFatal(boolean fatal) {
        this.fatal = fatal;
    }

    /**
     * This flag indicates that the exception has been logged. Used to avoid
     * duplicate logging of the same error.
     */
    public boolean isLogged() {
        return logged;
    }

    /**
     * @see #isLogged()
     */
    public void setLogged(boolean logged) {
        this.logged = logged;
    }

    /**
     * Well defined error code for the error type. Used in logs and for
     * translation to user messages.
     */
    public String getErrorCode() {
        return errorCode;
    }

    /**
     * This method returns an array that contains objects that can be converted
     * to String objects and inserted into the error message.
     *
     * @return Array of parameters to message - null if not defined
     */
    public Serializable[] getMessageParameters() {
        return messageParameters;
    }

    public void setMessageParameters(Serializable[] messageParameters) {
        this.messageParameters = messageParameters;
    }

    /**
     * Returns the error message string of this throwable object.
     * <p>
     *
     * Overrides the method in {@link Throwable} to allow for parameter
     * insertion. If parameter insertion fails though, the message is returned
     * without parameters inserted into the message String.
     *
     * @return the error message string of this exception
     */
    public String getMessage() {
        if (messageParameters != null) {
            try {
                return MessageFormat.format(super.getMessage(), (Object[]) getMessageParameters());
            } catch (Throwable t) {
                return super.getMessage();
            }
        } else {
            return super.getMessage();
        }
    }

    /**
     * Returns a string representation of this exception instance, on the form:
     * <code>ClassName[errorCode]:Message</code>
     *
     * @return the string representation
     */
    public String toString() {
        return getClass().getName() + "[" + getErrorCode() + "]:" + getMessage();
    }

}
