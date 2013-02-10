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

package org.sculptor.dsl.validation;

/**
 * Constants for validation errors.
 * <p>
 * These constants are needed for Quick Fixes 
 */
public class IssueCodes {

	protected static final String ISSUE_CODE_PREFIX = "org.sculptor.dsl.validation.issue.";

	public static final String CAPITALIZED_NAME = ISSUE_CODE_PREFIX + "capitalized_name";
	public static final String UNCAPITALIZED_NAME = ISSUE_CODE_PREFIX + "uncapitalized_name";

}
