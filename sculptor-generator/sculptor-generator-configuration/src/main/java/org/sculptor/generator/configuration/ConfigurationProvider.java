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

import java.util.Set;

/**
 * Abstraction for get configuration values.
 */
public interface ConfigurationProvider {

	/** Returns a list of all defined keys */
	Set<String> keys();

	/** Returns true if there's a configuration value set for the given key */
	boolean has(String key);

	/** Returns the given configuration value as a string. */
	String getString(String key);

	/** Returns the given configuration value as a boolean. */
	boolean getBoolean(String key);

	/** Returns the given configuration value as an integer. */
	int getInt(String key);

}
