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

import java.util.HashMap;
import java.util.Map;
import java.util.Map.Entry;

import javax.inject.Inject;

/**
 * Conversion of English words to plural and singular. By default words become
 * plural by appending -s. Some algorithmic rules are implemented, such as words
 * ending with -y become -ies plural. To be able to handle special cases it is
 * possible to define the mapping in properties file.
 * 
 */
public class SingularPluralConverter {
	private static Map<String, String> singular2pluralDefinitions;
	private static Map<String, String> plural2singularDefinitions;

	@Inject
	private void init(PropertiesBase propertiesBase) {
		singular2pluralDefinitions = propertiesBase.singular2pluralDefinitions();
		plural2singularDefinitions = new HashMap<String, String>();
		for (Entry<String, String> entry : singular2pluralDefinitions.entrySet()) {
			plural2singularDefinitions.put(entry.getValue(), entry.getKey());
		}
	}

	public String toPlural(String input) {
		if (isEmpty(input)) {
			return input;
		}
		String lookupDef = lookup(input, singular2pluralDefinitions);
		if (lookupDef != null) {
			return lookupDef;
		}
		if (input.endsWith("y")) {
			return chop(input) + "ies";
		}
		if (input.endsWith("ss")) {
			return input + "es";
		}
		if (!input.endsWith("s")) {
			return input + "s";
		}
		return input;
	}

	public String toSingular(String input) {
		if (isEmpty(input)) {
			return input;
		}
		String lookupDef = lookup(input, plural2singularDefinitions);
		if (lookupDef != null) {
			return lookupDef;
		}
		if (input.endsWith("ies")) {
			return chop(input, 3) + "y";
		}
		if (input.endsWith("sses")) {
			return chop(input, 2);
		}
		if (input.endsWith("s") && !input.endsWith("ss")) {
			return chop(input);
		}
		return input;
	}

	private String lookup(String input, Map<String, String> lookupTable) {
		String lookupValue = lookupTable.get(input);
		if (lookupValue == null) {
			lookupValue = lookupTable.get(input.toLowerCase());
		}
		if (lookupValue == null) {
			return null;
		}
		// upper/lower case of first char
		if ((lookupValue.charAt(0) != input.charAt(0)) && (lookupValue.toLowerCase().charAt(0) == input.toLowerCase().charAt(0))) {
			return input.charAt(0) + lookupValue.substring(1);
		}
		return lookupValue;
	}

	private boolean isEmpty(String input) {
		return input == null || input.length() == 0;
	}

	private String chop(String input) {
		return chop(input, 1);
	}

	private static String chop(String input, int length) {
		return input.substring(0, input.length() - length);
	}

}
