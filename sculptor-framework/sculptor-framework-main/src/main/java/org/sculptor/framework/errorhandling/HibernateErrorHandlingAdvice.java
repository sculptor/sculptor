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
import static org.sculptor.framework.errorhandling.ExceptionHelper.isJmsContext;
import static org.sculptor.framework.errorhandling.ExceptionHelper.isJmsRedelivered;

import java.lang.reflect.Method;
import java.sql.SQLException;

import javax.validation.ConstraintViolationException;

import org.hibernate.HibernateException;
import org.hibernate.StaleObjectStateException;
import org.hibernate.StaleStateException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.aop.ThrowsAdvice;

/**
 * This advice handles Hibernate specific exceptions. RuntimeExceptions are
 * caught and new SystemException (subclasses) are thrown.
 * 
 * @author Patrik Nordwall
 * 
 */
@Deprecated
public class HibernateErrorHandlingAdvice implements ThrowsAdvice {

    public HibernateErrorHandlingAdvice() {
    }

    /**
     * Possibility for subclass to override and map logCodes.
     */
    protected String mapLogCode(String logCode) {
        return logCode;
    }

    /**
     * handles Hibernate validation exception
     */
    public void afterThrowing(Method m, Object[] args, Object target, ConstraintViolationException e) {
        Logger log = LoggerFactory.getLogger(target.getClass());
        LogMessage message = new LogMessage(mapLogCode(ValidationException.ERROR_CODE), excMessage(e));
        log.debug("{}", message);
        ValidationException newException = new ValidationException(e.getMessage());
        newException.setLogged(true);
        newException.setConstraintViolations(e.getConstraintViolations());
        throw newException;
    }

    public void afterThrowing(Method m, Object[] args, Object target, HibernateException e) {
        handleDatabaseAccessException(target, e);
    }

    protected void handleDatabaseAccessException(Object target, Exception e) {
        Logger log = LoggerFactory.getLogger(target.getClass());

        // often the wrapped SQLException contains the interesting piece of
        // information
        StringBuilder message = new StringBuilder();
        message.append(e.getClass().getName()).append(": ");
        message.append(excMessage(e));
        SQLException sqlExc = ExceptionHelper.unwrapSQLException(e);
        if (sqlExc != null) {
            message.append(", Caused by: ");
            message.append(sqlExc.getClass().getName()).append(": ");
            message.append(excMessage(sqlExc));
        }

        if (isJmsContext() && !isJmsRedelivered()) {
            LogMessage logMessage = new LogMessage(mapLogCode(DatabaseAccessException.ERROR_CODE), message
                    .toString());
            log.info("{}", logMessage);
        } else {
            LogMessage logMmessage = new LogMessage(mapLogCode(DatabaseAccessException.ERROR_CODE), message
                    .toString());
            log.error(logMmessage.toString(), e);
        }

        DatabaseAccessException newException = new DatabaseAccessException(message.toString());
        newException.setLogged(true);
        throw newException;
    }

    /**
     * Hibernate exception for Optimistic Locking.
     */
    public void afterThrowing(Method m, Object[] args, Object target, StaleStateException e)
            throws OptimisticLockingException {
        handleOptimisticLockingException(target, e);
    }

    /**
     * Hibernate exception for Optimistic Locking.
     */
    public void afterThrowing(Method m, Object[] args, Object target, StaleObjectStateException e)
            throws OptimisticLockingException {
        handleOptimisticLockingException(target, e);
    }

    private void handleOptimisticLockingException(Object target, Exception e) throws OptimisticLockingException {
        Logger log = LoggerFactory.getLogger(target.getClass());

        if (isJmsContext() && isJmsRedelivered()) {
            LogMessage logMessage = new LogMessage(mapLogCode(OptimisticLockingException.ERROR_CODE),
                    excMessage(e));
            log.error(logMessage.toString(), e);
        } else {
            LogMessage logMessage = new LogMessage(mapLogCode(OptimisticLockingException.ERROR_CODE),
                    excMessage(e));
            log.info("{}", logMessage);
        }

        OptimisticLockingException newException = new OptimisticLockingException(excMessage(e));
        newException.setLogged(true);
        throw newException;
    }

}
