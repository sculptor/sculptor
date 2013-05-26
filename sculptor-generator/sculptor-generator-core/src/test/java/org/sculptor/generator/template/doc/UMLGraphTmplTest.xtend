package org.sculptor.generator.template.doc

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.generator.GeneratorModelTestFixtures
import org.sculptor.generator.ext.UmlGraphHelper
import org.slf4j.LoggerFactory
import sculptormetamodel.Application
import sculptormetamodel.Module

import static junit.framework.Assert.*

import static extension org.sculptor.generator.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class UMLGraphTmplTest extends XtextTest {
	
	static val LOG = LoggerFactory::getLogger(typeof(UMLGraphTmplTest))


	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures
	
	var extension UmlGraphHelper umlGraphHelper

	var UMLGraphTmpl umlGraphTmpl
	
	@Before
	def void setupExtensions() {
		generatorModelTestFixtures.setupModel("generator-tests/doc/model.btdesign")
		
		umlGraphTmpl = generatorModelTestFixtures.getProvidedObject(typeof(UMLGraphTmpl))
		umlGraphHelper = generatorModelTestFixtures.getProvidedObject(typeof(UmlGraphHelper))
	}
	
	def Module coreModule(Application app) {
        return app.modules.namedElement("core");
    }
	
	@Test
	def void assertModel() {
		val app = generatorModelTestFixtures.app
		
		assertEquals(2, app.modules.size())
	}
	@Test
	def void testEntityDot() {
		val app = generatorModelTestFixtures.app
		
		val code = umlGraphTmpl.startContent(app, app.visibleModules().toSet, 0, "entity")
		assertNotNull(code)

		LOG.info(code)
        code.assertContainsConsecutiveFragments(#{
            '''edge [arrowhead = "none"]''',
            '''edge [arrowtail="none" arrowhead = "open" headlabel="" taillabel="" labeldistance="2.0" labelangle="-30"]'''
        });

	}


}
