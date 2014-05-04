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
package org.sculptor.generator.configuration;

/**
 * Abstraction for get and set configuration values.
 */
public interface MutableConfigurationProvider extends ConfigurationProvider {

	/** Sets a new configuration value as a string. */
	void setString(String key, String value);

	/** Sets a new configuration value as a boolean. */
	void setBoolean(String key, boolean value);

	/** Sets a new configuration value as an integer. */
	void setInt(String key, int value);

	/** Remove a configuration value */
	void remove(String key);

}
