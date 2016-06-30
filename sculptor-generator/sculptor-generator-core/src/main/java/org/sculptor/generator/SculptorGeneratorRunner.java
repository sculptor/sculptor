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

import org.eclipse.emf.common.util.URI;
import org.sculptor.generator.SculptorGeneratorResult.Status;
import org.sculptor.generator.util.FileHelper;

import com.google.inject.Injector;

/**
 * Retrieves an instance of the generators internal workflow from the generators
 * guice-configured setup, executes it with the given model + generator
 * properties and returns a {@link SculptorGeneratorResult} instance (holding
 * lists of generated {@link File}s and {@link SculptorGeneratorIssue}
 * instances).
 * 
 * @see SculptorGeneratorSetup#createInjectorAndDoEMFRegistration()
 * @see SculptorGeneratorWorkflow#run(String)
 */
public class SculptorGeneratorRunner {

	public static final SculptorGeneratorResult run(File modelFile, Properties generatorProperties) {
		Injector injector = new SculptorGeneratorSetup().createInjectorAndDoEMFRegistration();
		SculptorGeneratorWorkflow workflow = injector.getInstance(SculptorGeneratorWorkflow.class);
		SculptorGeneratorContext.getGeneratedFiles().clear();
		try {

			// Execute the generators workflow
			boolean success = workflow.run(URI.createFileURI(modelFile.toString()).toString(), generatorProperties);

			// Create a result object holding a list of generated files and
			// issues occurred during code generation
			List<SculptorGeneratorIssue> issues = SculptorGeneratorContext.getIssues();
			List<File> generatedFiles = SculptorGeneratorContext.getGeneratedFiles();
			SculptorGeneratorResult result = new SculptorGeneratorResult((success ? Status.SUCCESS : Status.FAILED),
					issues, generatedFiles);

			// If generation failed then delete any generated files
			if (!success) {
				for (File file : generatedFiles) {
					try {
						FileHelper.deleteFile(file);
					} catch (IOException e) {
						// we can't do anything here
					}
				}
			}
			return result;
		} finally {
			SculptorGeneratorContext.close();
		}
	}

}
