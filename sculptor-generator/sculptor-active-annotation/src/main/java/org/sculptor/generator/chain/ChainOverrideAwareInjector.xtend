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
package org.sculptor.generator.chain

import com.google.inject.Guice
import com.google.inject.Injector
import org.sculptor.generator.configuration.ConfigurationProvider
import org.sculptor.generator.configuration.ConfigurationProviderModule

/**
 * Binds specified class(es) to instanc(es) with support for creating chains from override or extension classes.      
 */
class ChainOverrideAwareInjector {

	static def createInjector(Class<?> startClass) {
		createInjector(#[startClass])
	}

	static def Injector createInjector(Class<?>... startClasses) {
		val bootstrapInjector = Guice.createInjector(new ConfigurationProviderModule)
		val configurationProvider = bootstrapInjector.getInstance(typeof(ConfigurationProvider))
		bootstrapInjector.createChildInjector(new ChainOverrideAwareModule(configurationProvider, startClasses))
	}

}
