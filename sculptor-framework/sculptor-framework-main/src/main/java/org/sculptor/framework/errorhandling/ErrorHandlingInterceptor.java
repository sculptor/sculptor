/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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

import javax.ejb.EJBException;
import javax.interceptor.AroundInvoke;
import javax.interceptor.InvocationContext;
import javax.persistence.OptimisticLockException;
import javax.persistence.PersistenceException;
import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * This interceptor logs exceptions.
 * <p>
 * RuntimeExceptions are caught and new {@link SystemException} (subclasses) are
 * thrown. {@link SystemException} and RuntimeException are logged at error or
 * fatal level. {@link ApplicationException} is logged at debug level.
 * 
 * @author Patrik Nordwall
 */
public class ErrorHandlingInterceptor {

    public ErrorHandlingInterceptor() {
    }

    @AroundInvoke
    public Object invoke(InvocationContext context) throws Exception {
        try {
            try {
                return context.proceed();
            } catch (EJBException ejbExc) {
                if (ejbExc.getCause() != null && ejbExc.getCause() instanceof RuntimeException) {
                    throw (RuntimeException) ejbExc.getCause();
                } else {
                    throw ejbExc;
                }
            }
        } catch (EJBException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (SystemException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (ApplicationException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (ConstraintViolationException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (SQLException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (OptimisticLockException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (PersistenceException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (RuntimeException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (Error e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        }
    }

    /**
     * Handles validation exception
     */
    public void afterThrowing(Method m, Object[] args, Object target, ConstraintViolationException e) {

        Logger log = LoggerFactory.getLogger(target.getClass());

        StringBuilder logText = new StringBuilder(excMessage(e));
        if (e.getConstraintViolations() != null && e.getConstraintViolations().size() > 0) {
            for (ConstraintViolation<?> each : e.getConstraintViolations()) {
                logText.append(" : ").append(each.getPropertyPath()).append(" ");
                logText.append("'").append(each.getMessage()).append("'");
                logText.append(" ");
                logText.append(each.getPropertyPath()).append("=");
                logText.append(each.getInvalidValue());
            }
            // TODO: find better solution
            logText.append(" rootBean=").append(e.getConstraintViolations().iterator().next().getRootBean());
        }

        if (isJmsContext()) {
            LogMessage message = new LogMessage(mapLogCode(mapLogCode(ValidationException.ERROR_CODE)),
                    logText.toString());
            log.error("{}", message);
        } else {
            LogMessage message = new LogMessage(mapLogCode(ValidationException.ERROR_CODE), logText.toString());
            log.debug("{}", message);
        }

        ValidationException newException = new ValidationException(excMessage(e));
        newException.setLogged(true);
        newException.setConstraintViolations(e.getConstraintViolations());
        throw newException;
    }

    /**
     * Possibility for subclass to override and map logCodes.
     */
    protected String mapLogCode(String logCode) {
        return logCode;
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

    public void afterThrowing(Method m, Object[] args, Object target, SQLException e) {
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
        if (sqlExc != null) {
            message.append(", Caused by: ");
            message.append(sqlExc.getClass().getName()).append(": ");
            message.append(excMessage(sqlExc));
        }

        if (isJmsContext() && !isJmsRedelivered()) {
            LogMessage logMessage = new LogMessage(mapLogCode(DatabaseAccessException.ERROR_CODE), message.toString());
            log.info("{}", logMessage);
        } else {
            LogMessage logMmessage = new LogMessage(mapLogCode(DatabaseAccessException.ERROR_CODE), message.toString());
            log.error(logMmessage.toString(), e);
        }

        DatabaseAccessException newException = new DatabaseAccessException(message.toString());
        newException.setLogged(true);
        throw newException;
    }

    /**
     * JPA exception for Optimistic Locking.
     */
    public void afterThrowing(Method m, Object[] args, Object target, OptimisticLockException e)
            throws OptimisticLockingException {
        handleOptimisticLockingException(target, e);
    }

    protected void handleOptimisticLockingException(Object target, Exception e) throws OptimisticLockingException {
        Logger log = LoggerFactory.getLogger(target.getClass());

        if (isJmsContext() && isJmsRedelivered()) {
            LogMessage logMessage = new LogMessage(mapLogCode(OptimisticLockingException.ERROR_CODE), excMessage(e));
            log.error(logMessage.toString(), e);
        } else {
            LogMessage logMessage = new LogMessage(mapLogCode(OptimisticLockingException.ERROR_CODE), excMessage(e));
            log.info("{}", logMessage);
        }

        OptimisticLockingException newException = new OptimisticLockingException(excMessage(e));
        newException.setLogged(true);
        throw newException;
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
