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
package org.sculptor.generator.cartridge.builder

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*
import java.io.FileNotFoundException

/**
 * Tests that verify overall generator workflow for projects that have Builder cartridge enabled
 */
class BuilderGeneratorTest extends GeneratorTestBase {

	static val TEST_NAME = "builder"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertFooBuilder() {
		val code = getFileText(TO_GEN_SRC + "/org/sculptor/example/builder/foobar/domain/FooBuilder.java")
		assertContains(code, "package org.sculptor.example.builder.foobar.domain;")
		assertContains(code, "public class FooBuilder {")
	}

	@Test(expected=FileNotFoundException)
	def void assertNoBarBuilder() {
		getFileText(TO_GEN_SRC + "/org/sculptor/example/builder/foobar/domain/BarBuilder.java")
	}

}
