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
package org.sculptor.generator;

import org.sculptor.dsl.SculptordslRuntimeModule;
import org.sculptor.dsl.SculptordslStandaloneSetup;
import org.sculptor.generator.chain.ChainOverrideAwareModule;
import org.sculptor.generator.configuration.ConfigurationProvider;
import org.sculptor.generator.configuration.ConfigurationProviderModule;
import org.sculptor.generator.transform.DslTransformation;
import org.sculptor.generator.transform.Transformation;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Module;

/**
 * This class provides the initialization support for Sculptors Xtext-based
 * generator DSL, configuration providers and template chain-overriding.
 * <p>
 * <b>Use {@link #createInjectorAndDoEMFRegistration()} to create the Guice
 * injector! Otherwise EMF is not aware of Sculptors DSL.</b>
 */
public class SculptorGeneratorSetup extends SculptordslStandaloneSetup {

	@Override
	public Injector createInjector() {
		Injector configurationInjector = Guice.createInjector(new ConfigurationProviderModule());
		ConfigurationProvider configurationProvider = configurationInjector.getInstance(ConfigurationProvider.class);
		try {
			/*
			 * Starting with Xtext 2.9+ we can't use a child injector here
			 * anymore - details available in Xtext forum
			 * https://www.eclipse.org/forums/index.php/t/1078751/
			 */
			return Guice.createInjector(new ConfigurationProviderModule(), (Module) new SculptordslRuntimeModule(),
					new ChainOverrideAwareModule(configurationProvider, DslTransformation.class, Transformation.class,
							Class.forName("org.sculptor.generator.template.RootTmpl")));
		} catch (ClassNotFoundException e) {
			throw new RuntimeException("Emergency - 'RootTmpl' not available on classpath");
		}
	}

}
