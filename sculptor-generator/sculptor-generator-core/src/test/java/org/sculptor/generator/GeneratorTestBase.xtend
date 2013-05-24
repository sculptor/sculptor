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
package org.sculptor.generator

import java.io.File
import java.io.IOException

import static extension org.sculptor.generator.GeneratorTestExtensions.*

/**
 * Base class for tests that execute the Sculptor generator.
 */
abstract class GeneratorTestBase {

	private val static CONFIG_DIR = "generator-tests/";
	private val static OUTPUT_DIR = "target/sculptor-generator-tests/";

	/**
      * This is the directory where xtend template output will be generated to
      */
	@Property
	var File outputDir

	new(String testName) {
		outputDir = new File(OUTPUT_DIR, testName)
	}

	protected def String getFileText(String filePath) throws IOException {
		val f = new File(outputDir, filePath)
		f.text
	}

	protected static def void runGenerator(String testName) {
		System::setProperty("sculptor.generatorPropertiesLocation",
			CONFIG_DIR + testName + "/sculptor-generator.properties");

		System::setProperty("outputSlot.path.TO_SRC", OUTPUT_DIR + testName + "/src/main/java");
		System::setProperty("outputSlot.path.TO_RESOURCES", OUTPUT_DIR + testName + "/src/main/resources");
		System::setProperty("outputSlot.path.TO_GEN_SRC", OUTPUT_DIR + testName + "/src/generated/java");
		System::setProperty("outputSlot.path.TO_GEN_RESOURCES", OUTPUT_DIR + testName + "/src/generated/resources");
		System::setProperty("outputSlot.path.TO_WEBROOT", OUTPUT_DIR + testName + "/src/main/webapp");
		System::setProperty("outputSlot.path.TO_SRC_TEST", OUTPUT_DIR + testName + "/src/test/java");
		System::setProperty("outputSlot.path.TO_RESOURCES_TEST", OUTPUT_DIR + testName + "/src/test/resources");
		System::setProperty("outputSlot.path.TO_GEN_SRC_TEST", OUTPUT_DIR + testName + "/src/test/generated/java");
		System::setProperty("outputSlot.path.TO_GEN_RESOURCES_TEST",
			OUTPUT_DIR + testName + "/src/test/generated/resources");

		// Abort on invalid generated Java code
		System::setProperty("java.codeformatter.error.abort", "true");

		if (!SculptorGeneratorRunner::run("src/test/resources/" + CONFIG_DIR + testName + "/model.btdesign")) {
			throw new RuntimeException("Code generation failed")
		}
	}

}
