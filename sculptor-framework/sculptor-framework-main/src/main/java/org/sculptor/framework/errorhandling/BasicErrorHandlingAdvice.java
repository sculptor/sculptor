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

import static org.sculptor.framework.errorhandling.ExceptionHelper.excMessage;

import java.lang.reflect.Method;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.aop.ThrowsAdvice;

/**
 * This advice logs exceptions. RuntimeExceptions are caught and new
 * SystemException (subclasses) are thrown.
 * {@link org.sculptor.framework.errorhandling.SystemException}
 * and RuntimeException are logged at error or fatal level.
 * {@link org.sculptor.framework.errorhandling.ApplicationException}
 * is logged at debug level.
 * 
 * @author Patrik Nordwall
 * 
 */
public class BasicErrorHandlingAdvice implements ThrowsAdvice {

    public BasicErrorHandlingAdvice() {
    }

    /**
     * Possibility for subclass to override and map logCodes.
     */
    protected String mapLogCode(String logCode) {
        return logCode;
    }

    public void afterThrowing(Method m, Object[] args, Object target, ValidationException e) {
        if (e.isLogged()) {
            return;
        }
        Logger log = LoggerFactory.getLogger(target.getClass());
        LogMessage message = new LogMessage(mapLogCode(e.getErrorCode()), excMessage(e));
        log.debug(message.toString());
        e.setLogged(true);
    }

    public void afterThrowing(Method m, Object[] args, Object target, SystemException e) {
        if (e.isLogged()) {
            return;
        }
        Logger log = LoggerFactory.getLogger(target.getClass());
        LogMessage message = new LogMessage(mapLogCode(e.getErrorCode()), excMessage(e));
        if (e.isFatal()) {
            log.error(message.toString(), e);
        } else {
            log.error(message.toString(), e);
        }
        e.setLogged(true);
    }

    public void afterThrowing(Method m, Object[] args, Object target, ApplicationException e) {
        if (e.isLogged()) {
            return;
        }
        Logger log = LoggerFactory.getLogger(target.getClass());
        if (log.isDebugEnabled()) {
            LogMessage message = new LogMessage(mapLogCode(e.getErrorCode()), excMessage(e));
            log.debug(message.toString(), e);
            e.setLogged(true);
        }
    }

    public void afterThrowing(Method m, Object[] args, Object target, RuntimeException e) {
        SystemException wrappedSystemException = SystemException.unwrapSystemException(e);
        if (wrappedSystemException == null) {
            Logger log = LoggerFactory.getLogger(target.getClass());
            // null message is useless, e.g. NullPointerException
            String message = excMessage(e);
            LogMessage logMessage = new LogMessage(mapLogCode(UnexpectedRuntimeException.ERROR_CODE), message);
            log.error(logMessage.toString(), e);
            UnexpectedRuntimeException newException = new UnexpectedRuntimeException(message);
            newException.setLogged(true);
            throw newException;
        } else {
            afterThrowing(m, args, target, wrappedSystemException);
        }
    }

    public void afterThrowing(Method m, Object[] args, Object target, OutOfMemoryError e) {
        // OutOfMemoryError is important and therefore handled separatly from
        // other Errors
        handleError(target, e);
    }

    public void afterThrowing(Method m, Object[] args, Object target, Error e) {
        handleError(target, e);
    }

    protected void handleError(Object target, Error e) {
        Logger log = LoggerFactory.getLogger(target.getClass());
        String errorCode = e.getClass().getName();
        String mappedErrorCode = mapLogCode(errorCode);
        LogMessage message = new LogMessage(mappedErrorCode, excMessage(e));
        log.error(message.toString(), e);
    }

}
