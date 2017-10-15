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

import java.util.Arrays
import java.util.Collection
import java.util.HashSet
import java.util.List
import java.util.MissingResourceException
import java.util.concurrent.CopyOnWriteArrayList

/**
 * Implementation of {@link ConfigurationProvider} backed multiple providers.
 * <p>
 * The first provider (in order) that has a key set is used to return the corresponding value.
 */
class CompositeConfigurationProvider implements ConfigurationProvider {

	val List<ConfigurationProvider> providers

	public new(ConfigurationProvider... providers) {
		this(Arrays.asList(providers))
	}

	public new(Collection<ConfigurationProvider> providers) {
		this.providers = new CopyOnWriteArrayList<ConfigurationProvider>(providers)
	}

	override keys() {
		val compositeKeys = new HashSet<String>
		providers.forEach[compositeKeys.addAll(keys)]
		compositeKeys
	}

	override has(String key) {
		providers.filter[has(key)].size > 0
	}

	override getString(String key) {
		val provider = getFirstProviderWithKey(key)
		if (provider === null) {
			throw new MissingResourceException("Missing string configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		provider.getString(key)
	}

	override getBoolean(String key) {
		val provider = getFirstProviderWithKey(key)
		if (provider === null) {
			throw new MissingResourceException("Missing boolean configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		provider.getBoolean(key)
	}

	override getInt(String key) {
		val provider = getFirstProviderWithKey(key)
		if (provider === null) {
			throw new MissingResourceException("Missing int configuration '" + key + "'",
				"CompositeConfigurationProvider", key)
		}
		provider.getInt(key)
	}

	private def getFirstProviderWithKey(String key) {
		val providersWithKey = providers.filter[has(key)]
		if (providersWithKey.size == 0) {
			return null
		}
		providersWithKey.get(0)
	}

}
