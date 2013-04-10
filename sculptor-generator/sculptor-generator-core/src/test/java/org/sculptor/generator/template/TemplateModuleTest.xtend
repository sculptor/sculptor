package org.sculptor.generator.template

import com.google.inject.Guice
import org.junit.Test
import org.sculptor.generator.template.domain.builder.RootTmplExtension
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
		
		val rootTmpl = injector.getInstance(typeof(RootTmpl));
		assertNotNull(rootTmpl);
		LOG.info("Found RootTmpl: "+ rootTmpl);
		
		val rootTmplExtension = injector.getInstance(typeof(RootTmplExtension));
		LOG.info("Found extension: "+ rootTmplExtension);
		
		assertSame(rootTmpl, rootTmplExtension.next)
		assertNull(rootTmpl.next)
		
	}
}