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

import java.io.File;
import java.io.IOException;
import java.util.List;
import java.util.Properties;

import org.sculptor.generator.util.FileHelper;
import org.sculptor.generator.workflow.SculptorGeneratorWorkflow;

import com.google.inject.Injector;

/**
 * Retrieves an instance of the generators internal workflow from the generators
 * guice-configured setup, executes it and returns the list of generated
 * {@link File}s or <code>null</code> on error.
 * 
 * @see SculptorGeneratorSetup#createInjectorAndDoEMFRegistration()
 * @see SculptorGeneratorWorkflow#run(String)
 */
public class SculptorGeneratorRunner {

	public static final List<File> run(String modelURI, Properties generatorProperties) {
		Injector injector = new SculptorGeneratorSetup().createInjectorAndDoEMFRegistration();
		SculptorGeneratorWorkflow workflow = injector.getInstance(SculptorGeneratorWorkflow.class);
		SculptorGeneratorContext.getGeneratedFiles().clear();
		try {
			boolean success = workflow.run(modelURI, generatorProperties);
			List<File> generatedFiles = SculptorGeneratorContext.getGeneratedFiles();
			if (success) {
				return generatedFiles;
			}

			// If generation failed then delete any generated files
			for (File file : generatedFiles) {
				try {
					FileHelper.deleteFile(file);
				} catch (IOException e) {
					// we can't do anything here
				}
			}
		} finally {
			SculptorGeneratorContext.close();
		}
		return null;
	}

}
