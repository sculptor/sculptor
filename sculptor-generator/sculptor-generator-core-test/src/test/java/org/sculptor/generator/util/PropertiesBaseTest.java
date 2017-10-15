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

import static org.junit.Assert.assertEquals;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.sculptor.generator.chain.ChainOverrideAwareInjector;
import org.sculptor.generator.configuration.ConfigurationProvider;
import org.sculptor.generator.configuration.ConfigurationProviderModule;

public class PropertiesBaseTest {

	@Before
	public void prepareSystemProperties() {
		System.setProperty(ConfigurationProviderModule.PROPERTIES_LOCATION_PROPERTY, "properties/generator.properties");
		System.setProperty(ConfigurationProviderModule.COMMON_PROPERTIES_LOCATION_PROPERTY, "properties/common-generator.properties");
	}

	@After
	public void clearSystemProperties() {
		System.clearProperty(ConfigurationProviderModule.PROPERTIES_LOCATION_PROPERTY);
		System.clearProperty(ConfigurationProviderModule.COMMON_PROPERTIES_LOCATION_PROPERTY);
	}

	@Test
    public void assertProperties() {
		ConfigurationProvider configuration = ChainOverrideAwareInjector.createInjector(PropertiesBase.class).getInstance(
				ConfigurationProvider.class);
		assertEquals("business-tier", configuration.getString("project.nature"));

		// common
		assertEquals("common1", configuration.getString("property1"));
		assertEquals("local2", configuration.getString("property2"));

		// derived defaults
		assertEquals("org.joda.time.LocalDate", configuration.getString("javaType.Date"));
    }

}
