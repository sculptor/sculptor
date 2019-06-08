/*
 * Copyright 2015 The Sculptor Project Team, including the original 
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
class ServiceTmplTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures

	var ServiceTmpl serviceTmpl

	@Before
	def void setup() {
		generatorModelTestFixtures.setupInjector(typeof(ServiceTmpl))
		generatorModelTestFixtures.setupModel("generator-tests/library/model.btdesign", "generator-tests/library/model-person.btdesign")

		serviceTmpl = generatorModelTestFixtures.getProvidedObject(typeof(ServiceTmpl))
	}

	@Test
	def void assertDelegateServices() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("media")
		assertNotNull(module)

		val service = module.services.namedElement("MediaCharacterService")
		assertNotNull(service)

		val code = serviceTmpl.delegateServices(service)
		assertNotNull(code)
		assertContains(code, "private org.sculptor.example.library.media.serviceapi.LibraryService libraryService;")
	}

	@Test
	def void assertDelegateRepositories() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("media")
		assertNotNull(module)

		val service = module.services.namedElement("MediaCharacterService")
		assertNotNull(service)

		val code = serviceTmpl.delegateRepositories(service)
		assertNotNull(code)
		assertContains(code, "private org.sculptor.example.library.media.domain.LibraryRepository libraryRepository;")
	}

}
