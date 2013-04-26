package org.sculptor.generator.template

import com.google.inject.Guice
import org.junit.Test
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static org.junit.Assert.*
import org.sculptor.generator.mwe2.UniversalLoadModule
import generator.RootTmplOverride

class TemplateModuleTest {
	
	private static final val Logger LOG = LoggerFactory::getLogger(typeof(TemplateModuleTest))

	val rootTemplate = typeof(RootTmpl)
	val UniversalLoadModule univLoadModule = new UniversalLoadModule(rootTemplate);
	
	@Test
	def void testRootTmplExtensions(){
		val injector = Guice::createInjector(univLoadModule);

		val rootTmplOverrideInst = injector.getInstance(typeof(RootTmpl));
		assertNotNull(rootTmplOverrideInst);
		assertEquals(typeof(RootTmplOverride), rootTmplOverrideInst.^class)
		LOG.info("Found RootTmplOverride: "+ rootTmplOverrideInst);

		var nextTmpl = rootTmplOverrideInst.next
		LOG.info("Found builder extension: "+ nextTmpl);
		assertSame(typeof(org.sculptor.generator.cartridge.builder.RootTmplExtension), nextTmpl.^class)

		nextTmpl = nextTmpl.next
		LOG.info("Found originl extension: "+ nextTmpl);
		assertSame(typeof(org.sculptor.generator.template.RootTmpl), nextTmpl.^class)
		assertNull(nextTmpl.next)
	}
}
