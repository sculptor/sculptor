/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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

import java.util.HashMap;
import java.util.Map;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.mwe.core.WorkflowInterruptedException;
import org.eclipse.emf.mwe2.language.Mwe2RuntimeModule;
import org.eclipse.emf.mwe2.language.Mwe2StandaloneSetup;
import org.eclipse.emf.mwe2.launch.runtime.Mwe2Runner;
import org.eclipse.xtext.mwe.RuntimeResourceSetInitializer;
import org.sculptor.generator.mwe2.ContextClassLoaderAwareRuntimeResourceSetInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.inject.Guice;
import com.google.inject.Inject;
import com.google.inject.Injector;

public class SculptorGeneratorRunner {

	private static final Logger LOGGER = LoggerFactory.getLogger(SculptorGeneratorRunner.class);

	public static final String WORKFLOW_MODULE = "org.sculptor.generator.SculptorGenerator";

	@Inject
	public Mwe2Runner runner;

	public static boolean run(String modelFile) {
		Injector injector = new Mwe2StandaloneSetup() {
			@Override
			public Injector createInjector() {
				return Guice.createInjector(new Mwe2RuntimeModule() {
					@SuppressWarnings("unused")
					public Class<? extends RuntimeResourceSetInitializer> bindRuntimeResourceSetInitializer() {
						return ContextClassLoaderAwareRuntimeResourceSetInitializer.class;
					}
				});
			}
		}.createInjectorAndDoEMFRegistration();
		SculptorGeneratorRunner runner = injector.getInstance(SculptorGeneratorRunner.class);
		return runner.doRun(modelFile);
	}

	private boolean doRun(String modelFile) {
		boolean success;
		Map<String, String> map = new HashMap<String, String>();
		map.put("modelFile", URI.createFileURI(modelFile).toString());
		try {
			runner.run(WORKFLOW_MODULE, map);
			success = true;
		} catch (Exception e) {
			Throwable cause = e.getCause();
			if (cause instanceof WorkflowInterruptedException || cause instanceof SculptorGeneratorException) {
				LOGGER.error(cause.getMessage());
			} else {
				LOGGER.error("Running workflow failed", e);
			}
			success = false;
		}
		return success;
	}

}