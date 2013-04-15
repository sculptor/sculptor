package org.sculptor.generator.template

import com.google.inject.Guice
import generator.template.RootTmplOverride
import org.junit.Test
import org.sculptor.generator.cartridge.builder.RootTmplExtension
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static org.junit.Assert.*
import org.sculptor.generator.mwe2.UniversalLoadModule

class TemplateModuleTest {
	
	private static final val Logger LOG = LoggerFactory::getLogger(typeof(TemplateModuleTest))

	val rootTemplate = typeof(RootTmpl)
	val UniversalLoadModule univLoadModule = new UniversalLoadModule(rootTemplate);
	
	@Test
	def void testRootTmplExtensions(){
		val injector = Guice::createInjector(univLoadModule);
		val rootTmpl = injector.getInstance(rootTemplate);

		val rootTmplOverride = injector.getInstance(typeof(RootTmplOverride));
		assertNotNull(rootTmplOverride);
		LOG.info("Found RootTmplOverride: "+ rootTmplOverride);
		
		val rootTmpl = injector.getInstance(typeof(RootTmpl));
		assertNotNull(rootTmpl);
		LOG.info("Found RootTmpl: "+ rootTmpl);

		val rootTmplExtension = injector.getInstance(typeof(RootTmplExtension));
		LOG.info("Found extension: "+ rootTmplExtension);
		assertSame(rootTmplExtension, rootTmplOverride.next)
		assertSame(rootTmpl, rootTmplExtension.next)
		assertNull(rootTmpl.next)		
	}
}
