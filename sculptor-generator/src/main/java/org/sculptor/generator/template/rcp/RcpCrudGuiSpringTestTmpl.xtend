/*
 * Copyright 2008 The Fornax Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.generator.template.rcp

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class RcpCrudGuiSpringTestTmpl {



def static String springTest(GuiApplication it) {
	'''
	«applicationContextTest(it)»
	'''
} 

def static String applicationContextTest(GuiApplication it) {
	'''
	'''
	fileOutput("applicationContext-test.xml", 'TO_GEN_RESOURCES_TEST', '''
	«RcpCrudGuiSpring::headerWithMoreNamespaces(it)»
	<import resource="RichObject-all.xml"/>

	«RcpCrudGuiSpring::annotationScanStub(it)»
	«IF isServiceContextToBeGenerated()»
			«RcpCrudGuiSpring::serviceContextFactoryBean(it)»
		«ENDIF»
		
		<import resource="more-test.xml"/>
		
		«RcpCrudGuiSpring::springPropertyConfig(it)»
		
	</beans>
	'''
	)
	'''
	'''
}



}
