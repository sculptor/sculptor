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

package org.sculptor.framework.util;

import org.junit.jupiter.api.Test;

import java.io.Serializable;
import java.util.HashMap;
import java.util.Map;

import static org.junit.jupiter.api.Assertions.*;

public class EnumHelperTest {

	@Test
	public void testToEnum() {
		assertEquals(Country.SWEDEN, EnumHelper.toEnum(Country.class, "SE"));
		assertEquals(Gender.FEMALE, EnumHelper.toEnum(Gender.class, 1));
	}

	@Test
	public void testToData() {
		assertEquals("SE", EnumHelper.toData(Country.SWEDEN));
		assertEquals(1, EnumHelper.toData(Gender.FEMALE));
	}

	@Test
	public void testIsIdentifierAttributeOfTypeString() {
		assertTrue(EnumHelper.isIdentifierAttributeOfTypeString(Country.class));
		assertFalse(EnumHelper.isIdentifierAttributeOfTypeString(Gender.class));
	}

	enum Country implements Serializable {
		SWEDEN("SE", "SWE", 752), NORWAY("NO", "NOR", 578), DENMARK("DK", "DNK", 208), US("US", "USA", 840);

		private static Map<String, Country> identifierMap = new HashMap<String, Country>();
		static {
			for (Country value : Country.values()) {
				identifierMap.put(value.getAlpha2(), value);
			}
		}

		private String alpha2;
		private String alpha3;
		private int numeric;

		private Country(String alpha2, String alpha3, int numeric) {
			this.alpha2 = alpha2;
			this.alpha3 = alpha3;
			this.numeric = numeric;
		}

		public static Country fromAlpha2(String alpha2) {
			Country result = identifierMap.get(alpha2);
			if (result == null) {
				throw new IllegalArgumentException("No Country for alpha2: " + alpha2);
			}
			return result;
		}

		public static Country toEnum(Object key) {
			if (!(key instanceof String)) {
				throw new IllegalArgumentException("key is not of type String");
			}
			return fromAlpha2((String) key);
		}

		public Object toData() {
			return getAlpha2();
		}

		public String getAlpha2() {
			return alpha2;
		};

		public String getAlpha3() {
			return alpha3;
		};

		public int getNumeric() {
			return numeric;
		};

		public String getName() {
			return name();
		}
	}

	enum Gender implements Serializable {
		FEMALE(1), MALE(2);

		private static Map<Integer, Gender> identifierMap = new HashMap<Integer, Gender>();
		static {
			for (Gender value : Gender.values()) {
				identifierMap.put(value.getValue(), value);
			}
		}

		private Integer value;

		private Gender(Integer value) {
			this.value = value;
		}

		public static Gender fromValue(Integer value) {
			Gender result = identifierMap.get(value);
			if (result == null) {
				throw new IllegalArgumentException("No Gender for value: " + value);
			}
			return result;
		}

		public static Gender toEnum(Object key) {
			if (!(key instanceof Integer)) {
				throw new IllegalArgumentException("key is not of type Integer");
			}
			return fromValue((Integer) key);
		}

		public Object toData() {
			return getValue();
		}

		public Integer getValue() {
			return value;
		};

		public String getName() {
			return name();
		}
	}

}
