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

package org.sculptor.generator

import sculptormetamodel.NamedElement

class HelperExtensions {

	def static hasHint(NamedElement element, String parameterName) {
		hasHint(element.hint, parameterName)
	}

	def static hasHint(NamedElement element, String parameterName, String separator) {
    	getHint(element.hint, parameterName, separator) != null;
    }

	def static hasHint(String hint, String parameterName) {
		getHint(hint, parameterName) != null
	}

    def static getHint(String hint, String parameterName) {
        getHint(hint, parameterName, ",;")
    }

	/**
	 * Return the hint for the specified parameter retrieved from a list of key/value pairs separated by the given delimiter.
	 * @return the hint if parameter is available or {@code null} if hint / parameter not available
	 */
	def static getHint(String hint, String parameterName, String separator) {
	    if (hint != null && hint.indexOf(parameterName) != -1) {
        	for (split : hint.split("[" + separator.trim + "]")) {
        		val trimmedSplit = split.trim
	            val indexOfEq = trimmedSplit.indexOf("=")
	            if (indexOfEq == -1) {
	                if (trimmedSplit.equals(parameterName)) {
	                    return ""
	                }
	            } else {
	                if (trimmedSplit.substring(0, indexOfEq).trim.equals(parameterName)) {
	                    return trimmedSplit.substring(indexOfEq + 1).trim
	                }
	            }
	        }
        }

        // not found
        null
    }

}