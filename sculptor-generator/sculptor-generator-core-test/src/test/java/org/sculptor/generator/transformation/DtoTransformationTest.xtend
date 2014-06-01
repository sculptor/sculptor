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
package org.sculptor.generator.transformation

import com.google.inject.Provider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.generator.chain.ChainOverrideAwareInjector
import org.sculptor.generator.configuration.Configuration
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import sculptormetamodel.Application
import sculptormetamodel.Module

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class DtoTransformationTest extends XtextTest {

	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app

	@Before
	def void setupDslModel() {

		// Activate cartridge 'test' with transformation extensions 
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			"generator-tests/transformation/sculptor-generator.properties")

		val injector = ChainOverrideAwareInjector.createInjector(#[typeof(DslTransformation), typeof(Transformation)])
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app

		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)

		val transformation = transformationProvider.get
		app = transformation.modify(app)
	}

	def getDomainModel() {
		testFileNoSerializer("generator-tests/dto/model.btdesign")
		modelRoot as DslModel
	}

	def Module module() {
		app.modules.namedElement('media')
	}

	@Test
	def void assertApplication() {
		assertEquals("DtoApp", app.name)
	}

	@Test
	def void assertModules() {
		val modules = app.modules
		assertNotNull(modules)
		assertOneAndOnlyOne(modules, "media")
	}

	@Test
	def void assertLibraryDto() {
		val library = module.domainObjects.namedElement("LibraryDto")
		assertNotNull(library)

		assertOneAndOnlyOneWithoutFilter(library.attributes, "id", "name")
		assertOneAndOnlyOne(library.references, "media", "rating")

		val name = library.attributes.namedElement("name")
		assertNotNull(name)
		assertTrue(name.naturalKey)
		assertFalse(name.changeable)

		val id = library.attributes.namedElement("id")
		assertNotNull(id)
		assertTrue(id.changeable)
	}

	@Test
	def void assertLibraryDtoService() {
		val libraryWs = module.services.namedElement("LibraryDtoService")
		assertNotNull(libraryWs)

		assertTrue(libraryWs.webService)
		assertOneAndOnlyOne(libraryWs.operations, "findByName", "save", "findById", "findAll", "delete")
	}

}
