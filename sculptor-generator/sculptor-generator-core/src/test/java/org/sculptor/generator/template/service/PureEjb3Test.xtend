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

package org.sculptor.generator.template.service

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.GeneratorTestBase

import static org.sculptor.generator.GeneratorTestExtensions.*

class PureEjb3Test extends GeneratorTestBase {

	static val TEST_NAME = "helloworld"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		System::setProperty("project.nature", "business-tier, pure-ejb3")
		System::setProperty("jpa.provider", "hibernate")
		System::setProperty("generate.test", "true")
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertTestServiceBean() {
		val bean = getFileText(TO_SRC + "/org/sculptor/example/helloworld/milkyway/serviceimpl/PlanetServiceBean.java");
		assertContains(bean, '@Stateless(name = "planetService")');
	}
	
}