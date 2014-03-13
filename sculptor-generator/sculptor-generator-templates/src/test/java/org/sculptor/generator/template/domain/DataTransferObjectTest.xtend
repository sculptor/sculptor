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
package org.sculptor.generator.template.domain

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class DataTransferObjectTest extends GeneratorTestBase {

	static val TEST_NAME = "dto"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertXmlAnnotations() {
		val code = getFileText(TO_GEN_SRC + "/org/dto/media/serviceapi/LibraryDto.java");
		assertContains(code, '@XmlRootElement(name = "Library")');
		assertContainsConsecutiveFragments(code, #['@XmlElementWrapper(name = "media")', '@XmlElement(name = "media")'])
	}

	@Test
	def void assertExtends() {
		val code = getFileText(TO_GEN_SRC + "/org/dto/media/serviceapi/LibraryDto.java");
		assertContains(code, 'public class LibraryDto extends Object');
	}

}
