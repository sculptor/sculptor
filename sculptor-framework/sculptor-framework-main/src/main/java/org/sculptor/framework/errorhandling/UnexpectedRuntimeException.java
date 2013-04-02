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
 * RuntimeExceptions such unexpected {@link java.lang.IllegalArgumentException}
 * are caught and wrapped by this exception.
 * 
 */
public class UnexpectedRuntimeException extends SystemException {

    private static final long serialVersionUID = 8966485625275552709L;

    /**
     * The errorCode is the same as the fully qualified classname of this
     * exception.
     */
    public static final String ERROR_CODE = UnexpectedRuntimeException.class.getName();

    public UnexpectedRuntimeException(RuntimeException e) {
        this(e.getMessage(), e);
    }

    /**
     * @param message
     *            Technical message. Used for debugging purpose, not intended
     *            for end users.
     */
    public UnexpectedRuntimeException(String message) {
        this(message, null);
    }

    /**
     * @param message
     *            Technical message. Used for debugging purpose, not intended
     *            for end users.
     * @param cause
     *            Original cause of the exception, use with caution since
     *            clients must include the class of the cause also (e.g. a
     *            vendor specific database exception should not be exposed to
     *            clients).
     */
    public UnexpectedRuntimeException(String message, Throwable cause) {
        super(ERROR_CODE, message, cause);
    }

}
