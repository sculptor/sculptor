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

import java.lang.reflect.Method;
import java.sql.SQLException;

import javax.ejb.EJBException;
import javax.interceptor.AroundInvoke;
import javax.interceptor.InvocationContext;
import javax.persistence.OptimisticLockException;
import javax.persistence.PersistenceException;
import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;

import org.hibernate.HibernateException;
import org.hibernate.StaleObjectStateException;
import org.hibernate.StaleStateException;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * This advice logs exceptions. RuntimeExceptions are caught and new
 * SystemException (subclasses) are thrown.
 * {@link org.sculptor.framework.errorhandling.SystemException}
 * and RuntimeException are logged at error or fatal level.
 * {@link org.sculptor.framework.errorhandling.ApplicationException}
 * is logged at debug level.
 * <p>
 * The reason for separating the interceptor in this class and
 * ErrorHandlingInterceptor2 is that ErrorHandlingInterceptor2 is independent of
 * Hibernate, while this also covers Hibernate specific exceptions.
 *
 * @author Patrik Nordwall
 *
 */
public class ErrorHandlingInterceptor extends ErrorHandlingInterceptor2 {

    public ErrorHandlingInterceptor() {
    }

    @Override
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
        } catch (StaleObjectStateException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (StaleStateException e) {
            afterThrowing(context.getMethod(), context.getParameters(), context.getTarget(), e);
            throw e;
        } catch (HibernateException e) {
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
     * handles Hibernate validation exception
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

    public void afterThrowing(Method m, Object[] args, Object target, HibernateException e) {
        handleDatabaseAccessException(target, e);
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

}
