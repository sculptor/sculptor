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

import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.aop.ThrowsAdvice;

/**
 * This advice handles Hibernate Validator specific exceptions.
 * RuntimeExceptions are caught and new SystemException (subclasses) are thrown.
 *
 */
@Deprecated
public class HibernateValidatorErrorHandlingAdvice implements ThrowsAdvice {

    public HibernateValidatorErrorHandlingAdvice() {
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

}
