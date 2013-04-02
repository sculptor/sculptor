package org.sculptor.framework.errorhandling;

import java.util.Collections;
import java.util.Set;

import javax.validation.ConstraintViolation;

import org.sculptor.framework.errorhandling.annotation.ApplicationException;

/**
 * Thrown when the bean has violated one or several of its constraints You can
 * get the violation details in getInvalidValues()
 * 
 */
@SuppressWarnings("serial")
@ApplicationException
public class ValidationException extends SystemException {

	public static final String ERROR_CODE = ValidationException.class.getName();

	private String constraintViolationsStr = null;
	private Set<ConstraintViolation<?>> constraintViolations;

	public ValidationException(String message) {
		super(ERROR_CODE, message);
	}

	public ValidationException(String errorCode, String message, Throwable cause) {
		super(errorCode, message, cause);
	}

	public ValidationException(String errorCode, String message) {
		super(errorCode, message);
	}

	public ValidationException(String message,
			Set<? extends ConstraintViolation<?>> constraintViolations) {
		super(ERROR_CODE, message);
		this.constraintViolations = Collections
				.<ConstraintViolation<?>> unmodifiableSet(constraintViolations);
	}

	public void setConstraintViolations(
			Set<? extends ConstraintViolation<?>> constraintViolations) {
		constraintViolationsStr = null;
		this.constraintViolations = Collections
				.<ConstraintViolation<?>> unmodifiableSet(constraintViolations);
	}

	public Set<ConstraintViolation<?>> getConstraintViolations() {
		return constraintViolations;
	}

	@Override
	public String toString() {
		if (constraintViolationsStr == null) {
			StringBuilder sb = new StringBuilder();
			if (constraintViolations != null) {
				for (ConstraintViolation<?> constraintViolation : constraintViolations) {
					sb.append(", ")
							.append(constraintViolation.getPropertyPath())
							.append("=")
							.append(constraintViolation.getInvalidValue());
				}
			}
			constraintViolationsStr = sb.length() > 0 ? sb.substring(2) : "";
		}
		String errorCodeStr = getErrorCode() != null ? "[" + getErrorCode()
				+ "] " : "";
		return errorCodeStr + getMessage() + " (constraint violations: "
				+ constraintViolationsStr + ")";
	}
}