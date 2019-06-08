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

import javax.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.tests.SculptordslInjectorProvider
import org.sculptor.generator.test.GeneratorModelTestFixtures

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(SculptordslInjectorProvider))
class RepositoryTmplTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures

	var RepositoryTmpl repositoryTmpl

	@Before
	def void setup() {
		generatorModelTestFixtures.setupInjector(typeof(RepositoryTmpl))
		generatorModelTestFixtures.setupModel("generator-tests/repository/model.btdesign")

		repositoryTmpl = generatorModelTestFixtures.getProvidedObject(typeof(RepositoryTmpl))
	}

	@Test
	def void assertMapRepositoryOperation() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("foobars")
		assertNotNull(module)

		val repository = module.domainObjects.namedElement("FooBar").repository
		assertNotNull(repository)

		val code = repositoryTmpl.interfaceRepositoryMethod(repository.operations.get(0))
		assertNotNull(code)
		assertContains(code, 'java.util.Map<org.sculptor.example.foobars.domain.Foo, org.sculptor.example.foobars.domain.Bar> allFooBars()')
	}

}
