package org.sculptor.generator

import org.eclipse.xtext.junit4.InjectWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.junit.runner.RunWith
import org.sculptor.dsl.sculptordsl.DslModel
import org.junit.Test
import static org.junit.Assert.*
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.sculptor.dsl.sculptordsl.DslApplication
import com.google.inject.Provider
import org.sculptor.generator.transform.DslTransformation
import com.google.inject.Injector
import com.google.inject.Guice
import org.sculptor.generator.transform.DslTransformationModule
import org.sculptor.generator.ext.Helper
import org.eclipse.emf.common.util.URI

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class DslTransformationTest extends XtextTest{
	
	extension Helper helper

	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider

	@Before
	def void setupDslModel() {
		val Injector injector = Guice::createInjector(new DslTransformationModule)
		helper = injector.getInstance(typeof(Helper))
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))

		model = getDomainModel().app
	}

	@Test
	def testTransformDslModel() {
		val transformation = dslTransformProvider.get
		val app = transformation.transform(model)
		
		assertEquals(2, app.modules.size)
	}

	def  getDomainModel() {
		
        val URI uri = URI::createURI(resourceRoot + "/" + "model-test.btdesign");
        loadModel(resourceSet, uri, getRootObjectType(uri)) as DslModel;
	}

}