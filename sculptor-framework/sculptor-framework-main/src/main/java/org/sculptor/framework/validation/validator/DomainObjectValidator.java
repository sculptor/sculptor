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

package org.sculptor.framework.validation.validator;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import javax.validation.ConstraintViolation;
import javax.validation.Validation;
import javax.validation.Validator;
import javax.validation.ValidatorFactory;

import org.sculptor.framework.errorhandling.ValidationException;

/**
 * Convenience class for bean validation.
 * 
 * @author Oliver Ringel
 * 
 */
public class DomainObjectValidator<T> {

	private Validator validator;

	/**
	 * Constructor
	 */
	public DomainObjectValidator() {
		ValidatorFactory factory = Validation.buildDefaultValidatorFactory();
		validator = factory.getValidator();
	}

	public Set<ConstraintViolation<T>> getConstraintViolations(T domainObject,
			Class<?>... groups) {
		return validator.validate(domainObject, groups);
	}

	public Map<String, ConstraintViolation<T>> getConstraintViolationsAsMap(
			T domainObject, Class<?>... groups) {
		return getConstraintViolationsAsMap(validator.validate(domainObject,
				groups));
	}

	public Set<ConstraintViolation<T>> getConstraintViolations(T domainObject,
			String propertyName, Class<?>... groups) {
		return validator.validateProperty(domainObject, propertyName, groups);
	}

	public Set<ConstraintViolation<T>> getConstraintViolations(
			Class<T> domainObject, String propertyName, Object value,
			Class<?>... groups) {
		return validator.validateValue(domainObject, propertyName, value,
				groups);
	}

	public void validate(T domainObject, Class<?>... groups) {
		Set<ConstraintViolation<T>> constraintViolations = validator.validate(
				domainObject, groups);
		if (constraintViolations != null && constraintViolations.size() > 0) {
			throw new ValidationException("", constraintViolations);
		}
	}

	public void validateProperty(T domainObject, String propertyName,
			Class<?>... groups) {
		Set<ConstraintViolation<T>> constraintViolations = validator
				.validateProperty(domainObject, propertyName, groups);
		if (constraintViolations != null && constraintViolations.size() > 0) {
			throw new ValidationException("", constraintViolations);
		}
	}

	public void validateValue(Class<T> domainObject, String propertyName,
			Object value, Class<?>... groups) {
		Set<ConstraintViolation<T>> constraintViolations = validator
				.validateValue(domainObject, propertyName, value, groups);
		if (constraintViolations != null && constraintViolations.size() > 0) {
			throw new ValidationException("", constraintViolations);
		}
	}

	/**
	 * Handling constrain violations as map
	 * 
	 * @param bean
	 *            bean to validate
	 * @return map containing invalid properties
	 */
	private Map<String, ConstraintViolation<T>> getConstraintViolationsAsMap(
			Set<ConstraintViolation<T>> violations) {
		Map<String, ConstraintViolation<T>> constraintViolationsMap = new HashMap<String, ConstraintViolation<T>>();
		for (ConstraintViolation<T> constraintViolation : violations) {
			constraintViolationsMap.put(constraintViolation.getPropertyPath()
					.toString(), constraintViolation);
		}
		return constraintViolationsMap;
	}
}