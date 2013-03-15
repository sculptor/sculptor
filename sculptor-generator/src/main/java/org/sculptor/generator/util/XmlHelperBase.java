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

import sculptormetamodel.Application;

/**
 * Utilities for code generation. It is used from oAW templates via oAW
 * extensions.
 * 
 */
public class XmlHelperBase {

	private static final String IGNORE_PREFIX = "xml";

	public String toXmlName(String s) {
		s = removePrefix(s);
		StringBuffer sb = new StringBuffer();
		for (int i = 0; i < s.length(); i++) {
			char c = s.charAt(i);
			if (i != 0 && Character.isUpperCase(c)) {
				sb.append("-");
			}
			sb.append(Character.toLowerCase(c));
		}
		return sb.toString();
	}

	private String removePrefix(String s) {
		if (s.length() <= IGNORE_PREFIX.length()) {
			return s;
		}
		if (s.toLowerCase().startsWith(IGNORE_PREFIX.toLowerCase())) {
			return s.substring(IGNORE_PREFIX.length());
		}
		return s;
	}

	public String schemaUrl(Application app) {
		String[] packs = app.getBasePackage().split("\\.");
		String host;
		if (packs.length < 2) {
			// stange package name, use app name instead
			host = app.getName().toLowerCase() + ".org";
		} else {
			host = packs[1] + "." + packs[0];
		}

		String url = "http://www." + host + "/" + app.getName().toLowerCase();
		return url;
	}
}
