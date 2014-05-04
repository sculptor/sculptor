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

import java.util.Properties

/**
 * Mutable implementation of {@link PropertiesConfigurationProvider}.
 */
class MutablePropertiesConfigurationProvider extends PropertiesConfigurationProvider implements MutableConfigurationProvider {

	public new(Properties properties) {
		super(properties)
	}

	/**
	 * Loads properties as resource from current threads classloader or this class' classloader.  
	 */
	public new(String propertiesResourceName) {
		super(propertiesResourceName)
	}

	/**
	 * Loads properties as resource from current threads classloader or this class' classloader.  
	 */
	public new(String propertiesResourceName, boolean optional) {
		super(propertiesResourceName, optional)
	}

	override setString(String key, String value) {
		properties.setProperty(key, value)
	}

	override setBoolean(String key, boolean value) {
		properties.setProperty(key, Boolean.toString(value))
	}

	override setInt(String key, int value) {
		properties.setProperty(key, Integer.toString(value))
	}

	override remove(String key) {
		properties.remove(key)
	}

}
