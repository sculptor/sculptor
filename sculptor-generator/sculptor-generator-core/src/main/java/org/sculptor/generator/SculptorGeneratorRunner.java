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

import org.sculptor.generator.workflow.SculptorGeneratorWorkflow;

import com.google.inject.Injector;

/**
 * Retrieves an instance of the generators internal workflow from the generators
 * guice-configured setup and executes it.
 * 
 * @see SculptorGeneratorSetup#createInjectorAndDoEMFRegistration()
 * @see SculptorGeneratorWorkflow#run(String)
 */
public class SculptorGeneratorRunner {

	public static final boolean run(String modelURI) {
		Injector injector = new SculptorGeneratorSetup().createInjectorAndDoEMFRegistration();
		SculptorGeneratorWorkflow workflow = injector.getInstance(SculptorGeneratorWorkflow.class);
		return workflow.run(modelURI);
	}

}
