/*
 * Copyright 2007 The Fornax Project Team, including the original 
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

package org.sculptor.generator.template.db

import javax.inject.Inject
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class DDLTmpl {

	@Inject private var MysqlDDLTmpl mysqlDDLTmpl
	@Inject private var OracleDDLTmpl oracleDDLTmpl
	@Inject private var CustomDDLTmpl customDDLTmpl

	@Inject extension PropertiesBase propertiesBase

def String ddl(Application it) {
	'''
		«IF dbProduct == "mysql"»
			«mysqlDDLTmpl.ddl(it) »
		«ENDIF»
		«IF dbProduct == "oracle"»
			«oracleDDLTmpl.ddl(it) »
		«ENDIF»
		«IF dbProduct == "postgresql"»
			«oracleDDLTmpl.ddl(it) »
		«ENDIF»
		«IF dbProduct == "custom"»
			«customDDLTmpl.ddl(it) »
		«ENDIF»
	'''
}

}
