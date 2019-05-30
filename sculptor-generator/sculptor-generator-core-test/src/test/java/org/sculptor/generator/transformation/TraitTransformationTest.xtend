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
package org.sculptor.generator.transformation

import com.google.inject.Provider
import org.eclipse.xtext.testing.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
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
import sculptormetamodel.Entity
import sculptormetamodel.Trait

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class TraitTransformationTest extends XtextTest {

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
		testFileNoSerializer("generator-tests/trait/trait.btdesign")
		modelRoot as DslModel
	}

	@Test
	def void assertApplication() {
		assertEquals("DtoApp", app.name)
		assertEquals(1, app.modules.size())
	}

	private def module() {
		return app.modules.namedElement("catalog")
	}

	@Test
	def void assertProduct() {
		val product = module.domainObjects.namedElement("Product") as Trait

		assertOneAndOnlyOne(product.attributes, "title")
		assertOneAndOnlyOne(product.operations, "price", "priceFactor", "getTitle", "setTitle")

		val price = product.operations.namedElement("price")
		assertSame(product, price.getDomainObject())

		val priceFactor = product.operations.namedElement("priceFactor")
		assertTrue(priceFactor.isAbstract())

		val getTitle = product.operations.namedElement("getTitle")
		assertEquals("public", getTitle.getVisibility())
		assertSame(product, getTitle.getDomainObject())
		assertEquals("String", getTitle.getType())
	}

	@Test
	def void assertProductMixin() {
		val movie = module.domainObjects.namedElement("Movie") as Entity

		assertOneAndOnlyOne(movie.attributes, "title", "urlIMDB", "playLength")
		assertOneAndOnlyOne(movie.operations, "price", "priceFactor")

		val title = movie.attributes.namedElement("title")
		assertEquals("trait=Product", title.hint)

		val price = movie.operations.namedElement("price")
		assertEquals("trait=Product", price.hint)
		assertFalse(price.isAbstract())
		assertSame(movie, price.getDomainObject())

		val priceFactor = movie.operations.namedElement("priceFactor")
		assertEquals("trait=Product", price.hint)
		assertTrue(priceFactor.isAbstract())

		assertTrue(movie.gapClass)
	}

	@Test
	def void shouldRecognizeExistingPropertiesAndOperations() {
		val qwerty = module.domainObjects.namedElement("Qwerty") as Entity
		assertOneAndOnlyOne(qwerty.attributes, "qqq", "www", "eee", "ddd")
		assertOneAndOnlyOne(qwerty.operations, "getAaa", "spellCheck", "somethingElse")
	}

	@Test
	def void shouldMixinSeveralTraitsInOrder() {
		val abc = module.domainObjects.namedElement("Abc") as Entity
		assertOneAndOnlyOne(abc.attributes, "aaa", "bbb", "ccc", "ddd", "eee")
		assertOneAndOnlyOne(abc.operations, "aha", "boom", "caboom", "ding", "eeh")

		assertEquals("Bcd", abc.traits.get(0).name)
		assertEquals("Cde", abc.traits.get(1).name)

		val aha = abc.operations.namedElement("aha")
		assertNull(aha.hint)

		val boom = abc.operations.namedElement("boom")
		assertNull(boom.hint)

		val caboom = abc.operations.namedElement("caboom")
		assertEquals("trait=Bcd", caboom.hint)

		val ding = abc.operations.namedElement("ding")
		assertEquals("trait=Cde", ding.hint)

		val eeh = abc.operations.namedElement("eeh")
		assertEquals("trait=Cde", eeh.hint)
	}

	@Test
	def void shouldAssignGapFromOperations() {
		val e1 = module.domainObjects.namedElement("Ent1")
		assertTrue(e1.gapClass)

		val e2 = module.domainObjects.namedElement("Ent2")
		assertFalse(e2.gapClass)
	}

	@Test
	def void shouldAssignGapFromTraitOperations() {
		val e3 = module.domainObjects.namedElement("Ent3")
		assertFalse(e3.gapClass)

		val e4 = module.domainObjects.namedElement("Ent4")
		assertTrue(e4.gapClass)
	}

}