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

package org.sculptor.generator.util;

/**
 * Utilities for converting camel case to words, separated with whitespace,
 * underscore or some other character.
 * 
 */
public class CamelCaseConverter {

	public static String camelCaseToWords(String camelCase) {
		return camelCaseToWords(camelCase, ' ');
	}

	public static String camelCaseToUnderscore(String camelCase) {
		return camelCaseToWords(camelCase, '_');
	}

	public static String camelCaseToWords(String camelCase, char separator) {
		// special case if short string
		if (camelCase == null || camelCase.length() <= 2) {
			return camelCase;
		}
		StringBuffer sb = new StringBuffer(camelCase.length() + 3);
		sb.append(camelCase.charAt(0));
		sb.append(camelCase.charAt(1));
		for (int i = 2; i < camelCase.length(); i++) {
			sb.append(camelCase.charAt(i));
			if (camelCase.charAt(i - 2) == separator) {
				continue;
			} else if (Character.isUpperCase(camelCase.charAt(i - 1)) && Character.isLowerCase(camelCase.charAt(i))) {
				sb.insert(sb.length() - 2, separator);
			} else if (Character.isLowerCase(camelCase.charAt(i - 2)) && Character.isUpperCase(camelCase.charAt(i - 1))
					&& Character.isUpperCase(camelCase.charAt(i))) {
				sb.insert(sb.length() - 2, separator);
			}

		}
		// special case if last is upper
		if (Character.isUpperCase(sb.charAt(sb.length() - 1)) && Character.isLowerCase(sb.charAt(sb.length() - 2))) {
			sb.insert(sb.length() - 1, ' ');
		}
		return sb.toString();
	}

}
