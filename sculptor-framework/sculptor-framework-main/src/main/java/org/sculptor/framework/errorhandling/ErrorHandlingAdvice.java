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

import javax.persistence.OptimisticLockException;
import javax.persistence.PersistenceException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.ConcurrencyFailureException;
import org.springframework.dao.DataAccessException;

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
public class ErrorHandlingAdvice extends BasicErrorHandlingAdvice {

    public ErrorHandlingAdvice() {
    }

    public void afterThrowing(Method m, Object[] args, Object target, SQLException e) {
        handleDatabaseAccessException(target, e);
    }

    public void afterThrowing(Method m, Object[] args, Object target, DataAccessException e) {
        handleDatabaseAccessException(target, e);
    }

    public void afterThrowing(Method m, Object[] args, Object target, PersistenceException e) {
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
        Throwable realException = sqlExc;
        if (sqlExc != null) {
            message.append(", Caused by: ");
            message.append(sqlExc.getClass().getName()).append(": ");
            message.append(excMessage(sqlExc));
            if (sqlExc.getNextException() != null) {
                message.append(", Next exception: ");
                message.append(sqlExc.getNextException().getClass().getName()).append(": ");
                message.append(excMessage(sqlExc.getNextException()));
                realException=sqlExc.getNextException();
            }
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

        DatabaseAccessException newException = new DatabaseAccessException(message.toString(), realException);
        newException.setLogged(true);
        throw newException;
    }

    /**
     * Spring exception for Optimistic Locking.
     */
    public void afterThrowing(Method m, Object[] args, Object target, ConcurrencyFailureException e)
            throws OptimisticLockingException {
        handleOptimisticLockingException(target, e);
    }

    /**
     * JPA exception for Optimistic Locking.
     */
    public void afterThrowing(Method m, Object[] args, Object target, OptimisticLockException e)
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
            log.info(logMessage.toString());
        }

        OptimisticLockingException newException = new OptimisticLockingException(excMessage(e));
        newException.setLogged(true);
        throw newException;
    }

}
