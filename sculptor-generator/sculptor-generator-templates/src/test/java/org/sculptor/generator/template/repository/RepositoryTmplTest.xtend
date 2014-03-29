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
package org.sculptor.generator.template.repository

import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.junit.BeforeClass
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class RepositoryTmplTest extends GeneratorTestBase /* XtextTest */ {

// @FIXME use this code after #112 is fixed

//	@Inject
//	var GeneratorModelTestFixtures generatorModelTestFixtures
//
//	var RepositoryTmpl repositoryTmpl
//
//	@Before
//	def void setup() {
//		generatorModelTestFixtures.setupModel("generator-tests/repository/model.btdesign")
//
//		repositoryTmpl = generatorModelTestFixtures.getProvidedObject(typeof(RepositoryTmpl))
//	}
//
//	@Test
//	def void assertMapRepositoryOperation() {
//		val module = generatorModelTestFixtures.app.modules.namedElement("app")
//		assertNotNull(module)
//
//		val repository = module.domainObjects.namedElement("FooBars").repository
//		assertNotNull(repository)
//
//		val code = repositoryTmpl.interfaceRepositoryMethod(repository.operations.get(0))
//		assertNotNull(code)
//		assertContains(code, 'public Map<Foo, Bar> allFooBars();')
//	}

	static val TEST_NAME = "repository"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertMapRepositoryOperation() {
		val repository = getFileText(TO_GEN_SRC + "/org/sculptor/example/app/domain/FooBarRepository.java")
		assertContains(repository, 'public Map<Foo, Bar> allFooBars();')
	}

}
