/*
 * Copyright 2014 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License")
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

import com.google.inject.AbstractModule

import static com.google.inject.name.Names.*

/**
 * Technical properties to customize the code generation are defined in
 * <code>default-sculptor-generator.properties</code> and may be overridden in
 * <code>common-sculptor-generator.properties</code>,
 * <code>sculptor-generator.properties</code> or in Java system properties (in this order).
 * These properties are available via this class.
 * <p>
 * The locations of these property files can be defined with the following
 * system properties.
 * <ul>
 * <li><code>sculptor.generatorPropertiesLocation</code> - default
 * <code>generator/sculptor-generator.properties</code></li>
 * <li><code>sculptor.commonGeneratorPropertiesLocation</code> - common
 * <code>common-sculptor-generator.properties</code></li>
 * <li><code>sculptor.defaultGeneratorPropertiesLocation</code> - default
 * <code>default-sculptor-generator.properties</code></li>
 * </ul>
 * 
 * <strong>These property files are retrieved as classpath resources from the
 * current threads context classloader.</strong>.
 */
class ConfigurationProviderModule extends AbstractModule implements Configuration {

	/**
	 * Prepares the binding for 
	 */
	override protected configure() {

		// Prepare configuration providers
		val mutableDefaultProperties = new MutablePropertiesConfigurationProvider(
			System.getProperty(DEFAULT_PROPERTIES_LOCATION_PROPERTY, DEFAULT_DEFAULT_PROPERTIES_LOCATION))
		val optionalCommonProperties = new PropertiesConfigurationProvider(
			System.getProperty(COMMON_PROPERTIES_LOCATION_PROPERTY, DEFAULT_COMMON_PROPERTIES_LOCATION), true)
		val optionalProperties = new PropertiesConfigurationProvider(
			System.getProperty(PROPERTIES_LOCATION_PROPERTY, DEFAULT_PROPERTIES_LOCATION), true)
		val compositeConfiguration = new CompositeConfigurationProvider(new SystemPropertiesConfigurationProvider,
			optionalProperties, optionalCommonProperties, mutableDefaultProperties)

		// Prepare bindings
		binder.bind(typeof(ConfigurationProvider)).toInstance(compositeConfiguration)
		binder.bind(typeof(MutableConfigurationProvider)).annotatedWith(named("Mutable Defaults")).toInstance(
			mutableDefaultProperties)
	}

}
