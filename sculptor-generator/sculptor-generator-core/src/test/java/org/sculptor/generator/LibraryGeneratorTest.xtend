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

import org.junit.BeforeClass
import org.junit.Test

import static org.sculptor.generator.GeneratorTestExtensions.*
import org.sculptor.generator.GeneratorTestBase

class LibraryGeneratorTest extends GeneratorTestBase {

	static val TEST_NAME = "library"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		System::setProperty("sculptor.defaultOverridesPackage", "org.sculptor.generator.library")
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertEmbeddedColumnNamesInPersonBase() {
		val personCode = getFileText("src/generated/java/org/sculptor/example/library/person/domain/PersonBase.java");
		assertContains(personCode, "name = \"SSN_NUMBER\"");
	}

	@Test
	def void assertDbUnitEmptyDatabaseXml() {
		val dbunit = getFileText("src/test/generated/resources/dbunit/EmptyDatabase.xml");
		assertNotContains(dbunit, "[]");
	}

}
