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

import java.io.IOException
import java.io.InputStreamReader
import java.util.MissingResourceException
import java.util.Properties
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Implementation of {@link ConfigurationProvider} backed by {@link Properties} instance.
 */
class PropertiesConfigurationProvider implements ConfigurationProvider {

	val static Logger LOG = LoggerFactory.getLogger(typeof(PropertiesConfigurationProvider))

	protected val Properties properties

	new(Properties properties) {
		this.properties = properties
	}

	/**
	 * Loads properties as resource from current threads classloader or this class' classloader.  
	 */
	new(String propertiesResourceName) {
		this(propertiesResourceName, false)
	}

	/**
	 * Loads properties as resource from current threads classloader or this class' classloader.  
	 */
	new(String propertiesResourceName, boolean optional) {
		properties = new Properties

		// Find class loader
		var classLoader = Thread.currentThread().getContextClassLoader()
		if (classLoader !== null) {
			LOG.debug("Loading '{}' from current threads context classloader: {}", propertiesResourceName, classLoader)
		} else {
			classLoader = PropertiesConfigurationProvider.classLoader
			LOG.debug("Loading '{}' from {} classloader: {}", propertiesResourceName,
				typeof(PropertiesConfigurationProvider).name, classLoader)
		}

		// Find resource and load properties from resource
		val resourceURL = classLoader.getResource(propertiesResourceName)
		if (resourceURL === null) {
			if (!optional) {
				throw new MissingResourceException("Properties resource not available: " + propertiesResourceName,
					typeof(PropertiesConfigurationProvider).name, "")
			}
		} else {
			LOG.debug("Loading properties from '{}'", resourceURL)
			try {
				properties.load(new InputStreamReader(resourceURL.openStream(), "UTF-8"))
			} catch (IOException e) {
				throw new MissingResourceException("Can't load properties from: " + propertiesResourceName,
					typeof(PropertiesConfigurationProvider).name, "")
			}
		}
	}

	override keys() {
		properties.stringPropertyNames
	}

	override has(String key) {
		properties.containsKey(key)
	}

	override getString(String key) {
		val value = properties.getProperty(key)
		if (value === null) {
			throw new MissingResourceException("Missing string configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		value
	}

	override getBoolean(String key) {
		val value = properties.getProperty(key)
		if (value === null) {
			throw new MissingResourceException("Missing boolean configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		Boolean.parseBoolean(value)
	}

	override getInt(String key) {
		val value = properties.getProperty(key)
		if (value === null) {
			throw new MissingResourceException("Missing int configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		Integer.parseInt(value)
	}

}
