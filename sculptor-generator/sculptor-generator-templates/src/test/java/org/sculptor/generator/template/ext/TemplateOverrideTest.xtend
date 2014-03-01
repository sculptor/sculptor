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
package org.sculptor.generator.template.ext

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class TemplateOverrideTest extends GeneratorTestBase {

	static val TEST_NAME = "library"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {

		// Define property with package where override classes will be looked for -> here the class "DomainObjectReferenceTmplOverride"
		System::setProperty("sculptor.defaultOverridesPackage", "org.sculptor.generator.template.ext")
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertOverriddenTemplateInMediaBase() {
		val mediaCode = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/media/domain/MediaBase.java");
		assertContains(mediaCode, 'public void addToEngagements(Engagement engagementElement) {');
	}

	@Test
	def void assertEmbeddedColumnNamesInPersonBase() {
		val personCode = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/person/domain/PersonBase.java");
		assertContains(personCode, 'name = "SSN_NUMBER"');
	}

	@Test
	def void assertDbUnitEmptyDatabaseXml() {
		val dbunit = getFileText(TO_GEN_RESOURCES_TEST + "/dbunit/EmptyDatabase.xml");
		assertNotContains(dbunit, "[]");
	}

}
