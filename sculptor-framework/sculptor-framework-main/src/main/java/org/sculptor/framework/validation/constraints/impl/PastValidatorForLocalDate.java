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
package org.sculptor.framework.validation.constraints.impl;

import java.util.Date;

import javax.validation.ConstraintValidator;
import javax.validation.ConstraintValidatorContext;
import javax.validation.constraints.Past;

import org.joda.time.LocalDate;


/**
 * adds support for Joda-Time to the past validator
 *
 */
public class PastValidatorForLocalDate implements ConstraintValidator<Past, LocalDate> {

    public void initialize(Past constraintAnnotation) {
    }

    public boolean isValid(LocalDate value, ConstraintValidatorContext constraintValidatorContext) {
        //null values are valid
        if ( value == null ) {
            return true;
        }
        return (value).isBefore(new LocalDate(new Date()));
    }
}