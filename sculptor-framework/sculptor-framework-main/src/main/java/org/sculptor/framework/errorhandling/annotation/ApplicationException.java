package org.sculptor.framework.errorhandling.annotation;

import static java.lang.annotation.ElementType.TYPE;
import static java.lang.annotation.RetentionPolicy.RUNTIME;

import java.lang.annotation.Retention;
import java.lang.annotation.Target;


/**
 * Marks an exception as ApplicationException.
 *
 */
@Target(value=TYPE)
@Retention(value=RUNTIME)
public @interface ApplicationException {
}