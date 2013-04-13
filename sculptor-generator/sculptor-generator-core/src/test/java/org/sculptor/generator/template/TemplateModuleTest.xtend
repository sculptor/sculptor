package org.sculptor.generator.template

import com.google.inject.Guice
import generator.template.RootTmplOverride
import org.junit.Test
import org.sculptor.generator.cartridge.builder.template.RootTmplExtension
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static org.junit.Assert.*

class TemplateModuleTest {
	
	private static final val Logger LOG = LoggerFactory::getLogger(typeof(TemplateModuleTest))

	val TemplateModule templateModule = new TemplateModule()
	
	@Test
	def void testRootTmplExtensions(){
		val injector = Guice::createInjector(templateModule);
		
		templateModule.chainGeneratorExtensions(injector)

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