package org.sculptor.generator.template.rest

import org.sculptor.generator.ext.GeneratorFactory
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import sculptormetamodel.Application

import static org.sculptor.generator.template.rest.RestWebTmpl.*

class RestWebTmpl {
	extension Helper helper = GeneratorFactory::helper
	extension Properties properties = GeneratorFactory::properties
	private static val RestWebConfigTmpl restWebConfigTmpl = GeneratorFactory::restWebConfigTmpl
	private static val RestWebCssTmpl restWebCssTmpl = GeneratorFactory::restWebCssTmpl
	private static val RestWebJspTmpl restWebJspTmpl = GeneratorFactory::restWebJspTmpl

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
