package org.sculptor.generator.template.rest

import sculptormetamodel.Application

import static org.sculptor.generator.ext.Properties.*

import static extension org.sculptor.generator.ext.Helper.*

class RestWebTmpl {

def static String restWeb(Application it) {
	'''
	«IF getBooleanProperty("generate.restWeb.config")»
		«RestWebConfigTmpl::config(it)»
	«ENDIF»
	«IF getBooleanProperty("generate.restWeb.jsp")»
		«RestWebCssTmpl::css(it)»
		«RestWebJspTmpl::jsp(it)»
		«it.getAllResources(false).forEach[RestWebJspTmpl::jsp(it)]»
	«ENDIF»
	'''
}

}
