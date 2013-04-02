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

/**
 * This class is intended to be used as parameter when logging. The purpose is
 * to format (toString) the log message, which consists of error code and free
 * text technical message.
 * 
 * @author Patrik Nordwall
 */
public class LogMessage {
    private String errorCode;
    private String message;
    private ServiceContext serviceContext;

    /**
     * @param errorCode
     *            Well defined error code for the error type.
     * @param message
     *            Technical message. Used for debugging purpose, not intended
     *            for
     * @param serviceContext
     *            Contains user information etc.
     */
    public LogMessage(ServiceContext serviceContext, String errorCode, String message) {
        this.serviceContext = serviceContext;
        this.errorCode = errorCode;
        this.message = message;
    }

    /**
     * ServiceContext will be picked from {@link ServiceContextStore}
     * 
     * @see #LogMessage(ServiceContext, String, String)
     */
    public LogMessage(String errorCode, String message) {
        this(ServiceContextStore.get(), errorCode, message);
    }

    public LogMessage(ServiceContext serviceContext, SystemException e) {
        this(serviceContext, e.getErrorCode(), e.getMessage());
    }

    /**
     * ServiceContext will be picked from {@link ServiceContextStore}
     * 
     * @see #LogMessage(ServiceContext, SystemException)
     */
    public LogMessage(SystemException e) {
        this(ServiceContextStore.get(), e.getErrorCode(), e.getMessage());
    }

    public LogMessage(ServiceContext serviceContext, ApplicationException e) {
        this(serviceContext, e.getErrorCode(), e.getMessage());
    }

    /**
     * ServiceContext will be picked from {@link ServiceContextStore}
     * 
     * @see #LogMessage(ServiceContext, ApplicationException)
     */
    public LogMessage(ApplicationException e) {
        this(ServiceContextStore.get(), e.getErrorCode(), e.getMessage());
    }

    public ServiceContext getServiceContext() {
        return serviceContext;
    }

    /**
     * Well defined error code for the error type.
     */
    public String getErrorCode() {
        return errorCode;
    }

    /**
     * Technical message. Used for debugging purpose, not intended for end
     * users.
     */
    public String getMessage() {
        return message;
    }

    /**
     * Formats the log message.
     */
    public String toString() {
        StringBuffer sb = new StringBuffer();
        sb.append("[").append(errorCode).append("] ");
        if (serviceContext != null) {
            sb.append(serviceContext).append(" ");
        }
        sb.append(" : ").append(message);
        return sb.toString();
    }

}
