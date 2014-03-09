/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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

import static org.junit.Assert.*;

import org.junit.Before;
import org.junit.Test;

public class PropertiesBaseTest {

	@Before
	public void prepareSystemProperties() {
		System.setProperty(PropertiesBase.PROPERTIES_LOCATION_PROPERTY, "properties/generator.properties");
		System.setProperty(PropertiesBase.COMMON_PROPERTIES_LOCATION_PROPERTY, "properties/common-generator.properties");
	}

	@Before
	public void clearSystemProperties() {
		System.clearProperty(PropertiesBase.PROPERTIES_LOCATION_PROPERTY);
		System.clearProperty(PropertiesBase.COMMON_PROPERTIES_LOCATION_PROPERTY);
	}

	@Test
    public void assertProperties() {
		PropertiesBase propertiesBase = new PropertiesBase();
		propertiesBase.initProperties(true);
		assertEquals("business-tier", propertiesBase.getProperty("project.nature"));
		assertEquals("common1", propertiesBase.getProperty("property1"));
		assertEquals("local2", propertiesBase.getProperty("property2"));
    }

}
