package org.sculptor.generator.template.rest

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class RestWebTmpl {

def static String restWeb(Application it) {
	'''
	«IF getBooleanProperty("generate.restWeb.config")»
		«RestWebConfig::config(it)»
	«ENDIF»
	«IF getBooleanProperty("generate.restWeb.jsp")»
		«RestWebCss::css(it)»
		«RestWebJsp::jsp(it)»
		«it.getAllResources(false).forEach[RestWebJsp::jsp(it)]»
	«ENDIF»
	'''
}

}
