package org.sculptor.generator

import java.io.File
import java.io.IOException

import static extension org.sculptor.generator.GeneratorTestExtensions.*

/**
 * Base class for tests that execute the Sculptor workflow
 */
class GeneratorWorkflowTestBase {

	private val static XTEND_TEMPLATE_OUTPUT_DEFAULT_DIR = "target/xtend-templates/sculptor";

	/**
      * This is the directory where xtend template output will be generated to
      */
	@Property
	protected var File templateOutputDir

	new() {
		this(XTEND_TEMPLATE_OUTPUT_DEFAULT_DIR)
	}

	new(String templateOutputDirPath) {
		templateOutputDir = new File(templateOutputDirPath)
	}

	protected def String getFileText(String filePath) throws IOException {
		val f = new File(templateOutputDir, filePath)
		f.text
	}

	protected static def void runSculptorWorkflow(String propertiesFileLocation, String modelFile) {
		System::setProperty("sculptor.generatorPropertiesLocation", propertiesFileLocation);

		SculptorGeneratorRunner::run(modelFile)
	}
}
