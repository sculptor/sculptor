package org.sculptor.generator.template.rest

import org.sculptor.generator.ext.GeneratorFactory
import org.sculptor.generator.ext.GeneratorFactoryImpl
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import sculptormetamodel.Application

import static org.sculptor.generator.template.rest.RestWebTmpl.*

class RestWebTmpl {
	private static val GeneratorFactory GEN_FACTORY = GeneratorFactoryImpl::getInstance()

	extension Helper helper = GEN_FACTORY.helper
	extension Properties properties = GEN_FACTORY.properties
	private static val RestWebConfigTmpl restWebConfigTmpl = GEN_FACTORY.restWebConfigTmpl
	private static val RestWebCssTmpl restWebCssTmpl = GEN_FACTORY.restWebCssTmpl
	private static val RestWebJspTmpl restWebJspTmpl = GEN_FACTORY.restWebJspTmpl

def String restWeb(Application it) {
	'''
	«IF getBooleanProperty("generate.restWeb.config")»
		«restWebConfigTmpl.config(it)»
	«ENDIF»
	«IF getBooleanProperty("generate.restWeb.jsp")»
		«restWebCssTmpl.css(it)»
		«restWebJspTmpl.jsp(it)»
		«it.getAllResources(false).map[restWebJspTmpl.jsp(it)].join()»
	«ENDIF»
	'''
}

}
