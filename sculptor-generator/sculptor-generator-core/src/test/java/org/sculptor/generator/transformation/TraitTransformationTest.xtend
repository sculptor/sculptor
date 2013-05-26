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
import sculptormetamodel.Module

import static org.junit.Assert.*

import static extension org.sculptor.generator.GeneratorTestExtensions.*
import sculptormetamodel.Trait
import sculptormetamodel.DomainObjectOperation

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
        return app.modules.namedElement("catalog") as Module
    }

    @Test
    def void assertProduct() {
        val product = module.domainObjects.namedElement("Product") as Trait

        assertOneAndOnlyOne(product.getAttributes(), "title");
        assertOneAndOnlyOne(product.getOperations(), "price", "priceFactor", "getTitle", "setTitle");

        val price = product.operations.namedElement("price") as DomainObjectOperation
        assertSame(product, price.getDomainObject());

        val priceFactor = product.operations.namedElement("priceFactor") as DomainObjectOperation;
        assertTrue(priceFactor.isAbstract());

        val getTitle = product.operations.namedElement("getTitle") as DomainObjectOperation;
        assertEquals("public", getTitle.getVisibility());
        assertSame(product, getTitle.getDomainObject());
        assertEquals("String", getTitle.getType());
    }
}