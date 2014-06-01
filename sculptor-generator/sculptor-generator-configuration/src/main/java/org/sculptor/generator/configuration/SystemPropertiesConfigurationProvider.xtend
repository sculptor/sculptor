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
package org.sculptor.generator.configuration

import java.util.MissingResourceException

/**
 * Implementation of {@link ConfigurationProvider} backed by {@link System} properties.
 */
class SystemPropertiesConfigurationProvider implements ConfigurationProvider {

	override keys() {
		System.properties.stringPropertyNames
	}

	override has(String key) {
		System.properties.containsKey(key)
	}

	override getString(String key) {
		val value = System.properties.getProperty(key)
		if (value == null) {
			throw new MissingResourceException("Missing string configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		value
	}

	override getBoolean(String key) {
		val value = System.properties.getProperty(key)
		if (value == null) {
			throw new MissingResourceException("Missing boolean configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		Boolean.parseBoolean(value)
	}

	override getInt(String key) {
		val value = System.properties.getProperty(key)
		if (value == null) {
			throw new MissingResourceException("Missing int configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		Integer.parseInt(value)
	}

}
