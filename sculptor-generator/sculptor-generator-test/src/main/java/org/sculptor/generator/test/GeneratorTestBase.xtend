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
package org.sculptor.generator.test

import java.io.File
import java.io.IOException
import java.util.List
import java.util.Properties
import org.eclipse.xtend.lib.annotations.Accessors
import org.sculptor.generator.SculptorGeneratorException
import org.sculptor.generator.SculptorGeneratorResult.Status
import org.sculptor.generator.SculptorGeneratorRunner
import org.sculptor.generator.configuration.Configuration
import org.slf4j.LoggerFactory

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

/**
 * Base class for tests that execute the Sculptor generator.
 */
abstract class GeneratorTestBase {

	val static LOG = LoggerFactory.getLogger(GeneratorTestBase)

	private val static CONFIG_DIR = "generator-tests/"
	private val static OUTPUT_DIR = "target/sculptor-generator-tests/"

	protected val static TO_SRC = "/src/main/java"
	protected val static TO_RESOURCES = "/src/main/resources"
	protected val static TO_GEN_SRC = "/src/generated/java"
	protected val static TO_GEN_RESOURCES = "/src/generated/resources"
	protected val static TO_SRC_TEST = "/src/test/java"
	protected val static TO_RESOURCES_TEST = "/src/test/resources"
	protected val static TO_GEN_SRC_TEST = "/src/test/generated/java"
	protected val static TO_GEN_RESOURCES_TEST = "/src/test/generated/resources"
	protected val static TO_WEBROOT = "/src/main/webapp"
	protected val static TO_DOC = "/src/site"

	/**
      * This is the directory where xtend template output will be generated to
      */
    @Accessors(PUBLIC_GETTER)
	private var File outputDir

	new(String testName) {
		outputDir = new File(OUTPUT_DIR, testName)
	}

	protected def String getFileText(String filePath) throws IOException {
		val f = new File(outputDir, filePath)
		f.text
	}

	protected static def List<File> runGenerator(String testName) {
		deleteDirectory(new File(OUTPUT_DIR, testName))

		// Read the generator configuration from within the test folder 
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			CONFIG_DIR + testName + "/sculptor-generator.properties")

		// Prepare properties with the ouput slot paths for the code generator 
		val generatorProperties = new Properties();
		generatorProperties.setProperty("outputSlot.path.TO_SRC", OUTPUT_DIR + testName + TO_SRC)
		generatorProperties.setProperty("outputSlot.path.TO_RESOURCES", OUTPUT_DIR + testName + TO_RESOURCES)
		generatorProperties.setProperty("outputSlot.path.TO_GEN_SRC", OUTPUT_DIR + testName + TO_GEN_SRC)
		generatorProperties.setProperty("outputSlot.path.TO_GEN_RESOURCES", OUTPUT_DIR + testName + TO_GEN_RESOURCES)
		generatorProperties.setProperty("outputSlot.path.TO_SRC_TEST", OUTPUT_DIR + testName + TO_SRC_TEST)
		generatorProperties.setProperty("outputSlot.path.TO_RESOURCES_TEST", OUTPUT_DIR + testName + TO_RESOURCES_TEST)
		generatorProperties.setProperty("outputSlot.path.TO_GEN_SRC_TEST", OUTPUT_DIR + testName + TO_GEN_SRC_TEST)
		generatorProperties.setProperty("outputSlot.path.TO_GEN_RESOURCES_TEST",
			OUTPUT_DIR + testName + TO_GEN_RESOURCES_TEST)
		generatorProperties.setProperty("outputSlot.path.TO_WEBROOT", OUTPUT_DIR + testName + TO_WEBROOT)
		generatorProperties.setProperty("outputSlot.path.TO_DOC", OUTPUT_DIR + testName + TO_DOC)

		// Run generator and return list of generated files
		val result = SculptorGeneratorRunner.run(
			new File("src/test/resources/" + CONFIG_DIR + testName + "/model.btdesign"), generatorProperties)

		// Log all issues occured during workflow execution
		for (issue : result.getIssues()) {
			switch (issue.getSeverity()) {
				case ERROR :
					if (issue.getThrowable() != null) {
						LOG.error(issue.getMessage(), issue.getThrowable())
					} else {
						LOG.error(issue.getMessage())
					}
				case WARNING :
					LOG.warn(issue.getMessage())
				case INFO :
					LOG.info(issue.getMessage())
			}
		}
		if (result.status != Status.SUCCESS) {
			throw new SculptorGeneratorException("Code generation failed")
		}
		result.generatedFiles
	}

	private static def void deleteDirectory(File directory) {
		if (directory.exists) {
			directory.listFiles?.forEach[f | if (f.directory) deleteDirectory(f) else f.delete ]
			directory.delete
		}
	}

}
