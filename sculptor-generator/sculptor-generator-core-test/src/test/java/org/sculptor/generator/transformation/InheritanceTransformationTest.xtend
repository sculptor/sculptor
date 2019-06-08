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
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.dsl.tests.SculptordslInjectorProvider
import org.sculptor.generator.chain.ChainOverrideAwareInjector
import org.sculptor.generator.configuration.Configuration
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import sculptormetamodel.Application
import sculptormetamodel.DiscriminatorType
import sculptormetamodel.InheritanceType
import sculptormetamodel.Module

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(SculptordslInjectorProvider))
class InheritanceTransformationTest extends XtextTest {

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
		testFileNoSerializer("generator-tests/inheritance/model.btdesign")
		modelRoot as DslModel
	}

	private def Module module(int number) {
		app.modules.namedElement("module" + number)
	}

	@Test
	def void assertApplication() {
		assertEquals("InheritanceTest", app.name)
		assertOneAndOnlyOne(app.modules, "module1", "module2", "module3", "module4")
	}

	@Test
	def void assertPerson1() {
		val person = module(1).domainObjects.namedElement("Person1")
		assertNotNull(person)
		assertNull(person.inheritance)
		assertNull(person.discriminatorColumnValue)
	}

	@Test
	def void assertMedia1() {
		val media = module(1).domainObjects.namedElement("Media1")
		assertNotNull(media)
		assertNotNull(media.inheritance)
		assertEquals(InheritanceType.JOINED, media.inheritance.type)
		assertNull(media.inheritance.discriminatorColumnName)
		assertNull(media.inheritance.discriminatorColumnLength)
		assertEquals(DiscriminatorType.STRING, media.inheritance.discriminatorType)
	}

	@Test
	def void assertBook1() {
		val book = module(1).domainObjects.namedElement("Book1")
		assertNotNull(book)
		assertNull(book.inheritance)
		assertNull(book.discriminatorColumnValue)
	}

	@Test
	def void assertMedia2() {
		val media = module(2).domainObjects.namedElement("Media2")
		assertNotNull(media)
		assertNotNull(media.inheritance)
		assertEquals(InheritanceType.SINGLE_TABLE, media.inheritance.type)
		assertNull(media.inheritance.discriminatorColumnName)
		assertEquals(DiscriminatorType.STRING, media.inheritance.discriminatorType)
		assertNull(media.inheritance.discriminatorColumnLength)
	}

	@Test
	def void assertMovie2() {
		val movie = module(2).domainObjects.namedElement("Movie2")
		assertNotNull(movie)
		assertEquals("M2", movie.discriminatorColumnValue)
	}

	@Test
	def void assertMedia3() {
		val media = module(3).domainObjects.namedElement("Media3")
		assertNotNull(media)
		assertNotNull(media.inheritance)
		assertEquals(InheritanceType.SINGLE_TABLE, media.inheritance.type)
		assertEquals("MEDIA_TYPE", media.inheritance.discriminatorColumnName)
		assertEquals(DiscriminatorType.CHAR, media.inheritance.discriminatorType)
		assertNull(media.inheritance.discriminatorColumnLength)
	}

	@Test
	def void assertMovie3() {
		val movie = module(3).domainObjects.namedElement("Movie3")
		assertNotNull(movie)
		assertEquals("M", movie.discriminatorColumnValue)
	}

	@Test
	def void assertBook4() {
		val book = module(4).domainObjects.namedElement("Book4")
		assertNotNull(book)
		assertEquals("B4", book.discriminatorColumnValue)
		assertNull(book.inheritance)
	}

}
