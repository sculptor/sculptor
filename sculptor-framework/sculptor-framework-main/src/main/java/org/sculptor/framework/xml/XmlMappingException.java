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
package org.sculptor.framework.xml;

import org.sculptor.framework.errorhandling.SystemException;

/**
 * This exception is thrown when XML could not be parsed or validated.
 */
public class XmlMappingException extends SystemException {
    
    private static final long serialVersionUID = -4749448613773403774L;
    
    public static final String ERROR_CODE = XmlMappingException.class.getName();

    public XmlMappingException(String message) {
        super(ERROR_CODE, message);
    }

    public XmlMappingException(String message, Throwable cause) {
        super(ERROR_CODE, message, cause);
    }

}
