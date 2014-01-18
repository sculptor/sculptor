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

import com.google.inject.Guice
import com.google.inject.Injector
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
import org.sculptor.generator.chain.ChainOverrideAwareModule
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.Entity
import sculptormetamodel.Trait

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class TraitTransformationTest extends XtextTest {
	
	extension Properties properties

	extension Helper helper

	extension HelperBase helperBase

	extension DbHelper dbHelper
	
	extension DbHelperBase dbHelperBase
	
	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app

	@Before
	def void setupDslModel() {
		val uniLoadModule = new ChainOverrideAwareModule(#[typeof(DslTransformation), typeof(Transformation)])
		val Injector injector = Guice::createInjector(uniLoadModule)
		properties = injector.getInstance(typeof(Properties))
		helper = injector.getInstance(typeof(Helper))
		helperBase = injector.getInstance(typeof(HelperBase))
		dbHelper = injector.getInstance(typeof(DbHelper))
		dbHelperBase = injector.getInstance(typeof(DbHelperBase))
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app
		
		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)
		
		val transformation = transformationProvider.get
		app = transformation.modify(app)

	}

	def  getDomainModel() {
		
		testFileNoSerializer("generator-tests/trait/trait.btdesign")
		val dslModel = modelRoot as DslModel
		
		dslModel
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

        assertOneAndOnlyOne(product.getAttributes(), "title");
        assertOneAndOnlyOne(product.getOperations(), "price", "priceFactor", "getTitle", "setTitle");

        val price = product.operations.namedElement("price")
        assertSame(product, price.getDomainObject());

        val priceFactor = product.operations.namedElement("priceFactor")
        assertTrue(priceFactor.isAbstract());

        val getTitle = product.operations.namedElement("getTitle")
        assertEquals("public", getTitle.getVisibility());
        assertSame(product, getTitle.getDomainObject());
        assertEquals("String", getTitle.getType());
    }

    @Test
    def void assertProductMixin() {
        val movie = module.domainObjects.namedElement("Movie") as Entity

        assertOneAndOnlyOne(movie.getAttributes(), "title", "urlIMDB", "playLength")
        assertOneAndOnlyOne(movie.getOperations(), "price", "priceFactor")

        val title = movie.attributes.namedElement("title")
        assertEquals("trait=Product", title.getHint())

        val price = movie.operations.namedElement("price")
        assertEquals("trait=Product", price.getHint());
        assertFalse(price.isAbstract());
        assertSame(movie, price.getDomainObject());

        val priceFactor = movie.operations.namedElement("priceFactor")
        assertEquals("trait=Product", price.getHint());
        assertTrue(priceFactor.isAbstract());

        assertTrue(movie.isGapClass());
    }

    @Test
    def void shouldRecognizeExistingPropertiesAndOperations() {
        val qwerty = module.domainObjects.namedElement("Qwerty") as Entity
        assertOneAndOnlyOne(qwerty.getAttributes(), "qqq", "www", "eee", "ddd");
        assertOneAndOnlyOne(qwerty.getOperations(), "getAaa", "spellCheck", "somethingElse");
    }

    @Test
    def void shouldMixinSeveralTraitsInOrder() {
        val abc = module.domainObjects.namedElement("Abc") as Entity
        assertOneAndOnlyOne(abc.getAttributes(), "aaa", "bbb", "ccc", "ddd", "eee");
        assertOneAndOnlyOne(abc.getOperations(), "aha", "boom", "caboom", "ding", "eeh");

        assertEquals("Bcd", abc.traits.get(0).name);
        assertEquals("Cde", abc.traits.get(1).name);

        val aha = abc.operations.namedElement("aha");
        assertNull(aha.getHint());

        val boom = abc.operations.namedElement("boom");
        assertNull(boom.getHint());

        val caboom = abc.operations.namedElement("caboom");
        assertEquals("trait=Bcd", caboom.getHint());

        val ding = abc.operations.namedElement("ding");
        assertEquals("trait=Cde", ding.getHint());

        val eeh = abc.operations.namedElement("eeh");
        assertEquals("trait=Cde", eeh.getHint());
    }

    @Test
    def void shouldAssignGapFromOperations() {
        val e1 = module.domainObjects.namedElement("Ent1");
        assertTrue(e1.isGapClass());

        val e2 = module.domainObjects.namedElement("Ent2");
        assertFalse(e2.isGapClass());
    }

    @Test
    def void shouldAssignGapFromTraitOperations() {
        val e3 = module.domainObjects.namedElement("Ent3")
        assertFalse(e3.isGapClass());

        val e4 = module.domainObjects.namedElement("Ent4");
        assertTrue(e4.isGapClass());
    }

}