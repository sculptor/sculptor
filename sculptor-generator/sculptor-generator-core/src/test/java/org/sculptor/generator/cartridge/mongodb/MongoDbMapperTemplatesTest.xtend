package org.sculptor.generator.cartridge.mongodb

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.generator.GeneratorModelTestFixtures
import org.sculptor.generator.cartridge.mongodb.MongoDbMapperTmpl
import sculptormetamodel.Application
import sculptormetamodel.Module

import static junit.framework.Assert.*

import static extension org.sculptor.generator.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class MongoDbMapperTemplatesTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures
	
	var MongoDbMapperTmpl mongoDbMapperTmpl
	
	@Before
	def void setupExtensions() {
		generatorModelTestFixtures.setupModel("library-mongodb.btdesign", "library-person.btdesign")
		
		mongoDbMapperTmpl = generatorModelTestFixtures.getProvidedObject(typeof(MongoDbMapperTmpl))
	}
	

    def Module mediaModule(Application app) {
        return app.modules.namedElement("media");
    }
	
	@Test
	def void testAppTransformation() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)
		assertEquals(2, app.modules.size)
	}
	
	@Test
	def void testToDataInheritedOneManyAssoc() {
		val app = generatorModelTestFixtures.app
		
		val mediaModule = app.mediaModule
		assertNotNull(mediaModule)
		
		val book = mediaModule.domainObjects.namedElement("Book")
		
		val code = mongoDbMapperTmpl.toData(book)
		assertNotNull(code)
		
        code.assertContainsConsecutiveFragments(#{
            "java.util.List<com.mongodb.DBObject> engagementsData = new java.util.ArrayList<com.mongodb.DBObject>();",
            "for (org.fornax.cartridges.sculptor.examples.library.media.domain.Engagement each : from.getEngagements()) {",
            "engagementsData.add(org.fornax.cartridges.sculptor.examples.library.media.mapper.EngagementMapper.getInstance().toData(each));"
        });

	}

}