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
package org.sculptor.generator.workflow

import java.util.List
import org.junit.Test
import org.sculptor.generator.SculptorGeneratorContext
import org.sculptor.generator.SculptorGeneratorIssue
import org.sculptor.generator.SculptorGeneratorIssue.Severity
import org.sculptor.generator.SculptorGeneratorSetup
import org.sculptor.generator.SculptorGeneratorWorkflow
import org.sculptor.generator.configuration.Configuration
import sculptormetamodel.Application

import static org.junit.Assert.*

class SculptorGeneratorWorkflowTest {

	private val static CONFIG_DIR = "workflow-tests/"

	@Test
	def void assertRunWorkflow() {
		val issues = runWorkflow("valid")
		assertTrue(issues.empty)
	}

	@Test
	def void assertRunWorkflowWarnings() {
		val issues = runWorkflow("warnings")
		assertEquals(8, issues.size)
		issues.forEach [
			assertEquals(Severity.WARNING, severity)
		]
	}

	@Test
	def void assertRunWorkflowSyntaxError() {
		val issues = runWorkflow("syntax")
		assertEquals(1, issues.size)
		assertEquals(Severity.ERROR, issues.get(0).severity)
	}

	@Test
	def void assertRunWorkflowMissing() {
		val issues = runWorkflow("missing")
		assertEquals(1, issues.size)
		assertEquals(Severity.ERROR, issues.get(0).severity)
	}

	@Test
	def void assertRunWorkflowDuplicate() {
		val issues = runWorkflow("duplicate")
		assertEquals(1, issues.size)
		assertEquals(Severity.ERROR, issues.get(0).severity)
	}

	private def List<SculptorGeneratorIssue> runWorkflow(String testName) {

		// Create workflow with disabled code generation step
		val injector = new SculptorGeneratorSetup().createInjectorAndDoEMFRegistration();
		val workflow = new SculptorGeneratorWorkflow() {
			override Object generateCode(Application application) {
				""
			}
		}
		injector.injectMembers(workflow)

		// Read the generator configuration from within the test folder 
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			CONFIG_DIR + testName + "/sculptor-generator.properties")

		SculptorGeneratorContext.getGeneratedFiles().clear()
		try {
			workflow.run("src/test/resources/" + CONFIG_DIR + testName + "/model.btdesign", null)
			SculptorGeneratorContext.issues
		} finally {
			SculptorGeneratorContext.close()
		}
	}

}
