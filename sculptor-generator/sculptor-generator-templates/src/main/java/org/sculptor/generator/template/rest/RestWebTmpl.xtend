package org.sculptor.generator.template.rest

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import sculptormetamodel.Application
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class RestWebTmpl {

	@Inject private var RestWebConfigTmpl restWebConfigTmpl
	@Inject private var RestWebCssTmpl restWebCssTmpl
	@Inject private var RestWebJspTmpl restWebJspTmpl

	@Inject extension Helper helper
	@Inject extension Properties properties

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
