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

package org.sculptor.generator.template

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*
import org.sculptor.generator.template.domain.DomainObjectTmpl

class RootTmpl {

def static String Root(Application it) {
	'''
	«IF !modules.isEmpty»
		«IF isDomainObjectToBeGenerated()»
		    «it.getAllDomainObjects(false).forEach[DomainObjectTmpl::domainObject(it)]»
		    
		    «IF isBuilderToBeGenerated()»
			    «it.getAllDomainObjects(false).filter[e | e.needsBuilder()].forEach[BuilderTmpl::builder(it)]»    
		    «ENDIF»
		«ENDIF»
		«IF isExceptionToBeGenerated()»
		    «it.modules.filter[e|!e.external].forEach[ExceptionTmpl::applicationExceptions(it)]»
		«ENDIF»
		«IF isRepositoryToBeGenerated()»
		    «it.getAllRepositories(false).map[operations].filter[op | op.delegateToAccessObject && !op.isGenericAccessObject()].forEach[AccessObjectTmpl::command(it)]»
		    «it.getAllRepositories(false).forEach[RepositoryTmpl::repository(it)]»
		    «IF mongoDb()»
		    	«it.getAllDomainObjects(false).filter(e | e.isPersistent() || e.metaType == BasicType).forEach[MongoDbMapperTmpl::mongoDbMapper(it)]»
		    «ENDIF»
		«ENDIF»
		«IF isServiceToBeGenerated()»
		    «it.getAllServices(false).forEach[ServiceTmpl::service(it)]»
		«ENDIF»
		«IF isResourceToBeGenerated()»
		    «it.getAllResources(false).forEach[ResourceTmpl::resource(it)]»
		«ENDIF»
		«IF isRestWebToBeGenerated() && !getAllResources(false).isEmpty»
			«RestWebTmpl::restWeb(it)»
		«ENDIF»
		«IF isConsumerToBeGenerated()»
		    «it.getAllConsumers(false).forEach[ConsumerTmpl::consumer(it)]»
		«ENDIF»
		«IF isEmptyDbUnitTestDataToBeGenerated()»
			«DbUnitTmpl::emptyDbunitTestData(it)»
		«ENDIF»
		«IF getDbUnitDataSetFile() != null»
			«DbUnitTmpl::singleDbunitTestData(it)»
		«ENDIF»
		«IF pureEjb3() && isTestToBeGenerated() && !jpa()»
			«ServiceEjbTestTmpl::ejbJarXml(it)»
		«ENDIF»
		«IF isSpringToBeGenerated()»
		    «SpringTmpl::spring(it)»
		«ENDIF»
		«IF isDdlToBeGenerated()»
		    «DDLTmpl::ddl(it)»
		«ENDIF»
		«IF isDatasourceToBeGenerated()»
		    «DatasourceTmpl::datasource(it)»
		«ENDIF»
		«IF isLogbackConfigToBeGenerated()»
		    «LogConfigTmpl::logbackConfig(it)»
		«ENDIF»
		«IF isHibernateToBeGenerated()»
		    «HibernateTmpl::hibernate(it)»
		«ENDIF»
		«IF isJpaAnnotationToBeGenerated()»
		    «JPATmpl::jpa(it)»
		«ENDIF»
		«IF isUMLToBeGenerated()»
			«UMLGraphTmpl::start(it)»
		«ENDIF»
		«IF isModelDocToBeGenerated()»
			«ModelDocTmpl::start(it)»
		«ENDIF»
	«ENDIF»
	'''
}


}
