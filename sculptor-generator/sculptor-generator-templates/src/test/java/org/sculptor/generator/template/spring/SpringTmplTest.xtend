/*
 * Copyright 2019 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.spring

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class SpringTmplTest extends GeneratorTestBase {

	static val TEST_NAME = "spring"

	new() {
		super(TEST_NAME)
	}

	@BeforeAll
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertContextPropertyPlaceholder() {
		val text = getFileText(TO_GEN_RESOURCES + "/applicationContext.xml")
		assertContains(text,
			'<context:property-placeholder location="classpath:/generated-spring.properties, classpath:/spring.properties"/>')
		assertNotContains(text, 'PropertyPlaceholderConfigurer')
		assertNotContains(text, 'PropertySourcesPlaceholderConfigurer')
	}

	@Test
	def void assertTestContextPropertyPlaceholder() {
		val text = getFileText(TO_GEN_RESOURCES_TEST + "/applicationContext-test.xml")
		assertContains(text,
			'<context:property-placeholder location="classpath:/generated-spring.properties, classpath:/spring-test.properties"/>')
		assertNotContains(text, 'PropertyPlaceholderConfigurer')
		assertNotContains(text, 'PropertySourcesPlaceholderConfigurer')
	}

}
