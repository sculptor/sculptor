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

package org.sculptor.framework.validation;

import java.util.HashSet;
import java.util.Set;

import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;
import javax.validation.ConstraintViolation;
import javax.validation.ConstraintViolationException;
import javax.validation.Validation;
import javax.validation.Validator;

/**
 * Simple support for bean validation api in jpa 1.0 environments.
 *
 * @author Oliver Ringel
 *
 */
public class ValidationEventListener {

    @PrePersist
    @PreUpdate
    public void validate(Object entity) {
        Validator validator = Validation.buildDefaultValidatorFactory().getValidator();
        final Set<ConstraintViolation<Object>> constraintViolations = validator.validate(entity);
        if (constraintViolations.size() > 0) {
            Set<ConstraintViolation<?>> propagatedViolations = new HashSet<ConstraintViolation<?>>();
            for (ConstraintViolation<?> violation : constraintViolations) {
                propagatedViolations.add(violation);
            }
            throw new ConstraintViolationException(
                    "validation failed for entity " + entity.getClass().getSimpleName(),
                    propagatedViolations);
        }
    }
}
