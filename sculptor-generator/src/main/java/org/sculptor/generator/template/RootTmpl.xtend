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

import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.template.common.LogConfigTmpl
import org.sculptor.generator.template.consumer.ConsumerTmpl
import org.sculptor.generator.template.db.DDLTmpl
import org.sculptor.generator.template.db.DatasourceTmpl
import org.sculptor.generator.template.db.DbUnitTmpl
import org.sculptor.generator.template.doc.ModelDocTmpl
import org.sculptor.generator.template.doc.UMLGraphTmpl
import org.sculptor.generator.template.domain.BuilderTmpl
import org.sculptor.generator.template.domain.DomainObjectTmpl
import org.sculptor.generator.template.jpa.HibernateTmpl
import org.sculptor.generator.template.jpa.JPATmpl
import org.sculptor.generator.template.mongodb.MongoDbMapperTmpl
import org.sculptor.generator.template.repository.AccessObjectTmpl
import org.sculptor.generator.template.repository.RepositoryTmpl
import org.sculptor.generator.template.rest.ResourceTmpl
import org.sculptor.generator.template.rest.RestWebTmpl
import org.sculptor.generator.template.service.ServiceEjbTestTmpl
import org.sculptor.generator.template.service.ServiceTmpl
import org.sculptor.generator.template.spring.SpringTmpl
import sculptormetamodel.Application
import sculptormetamodel.BasicType

import static org.sculptor.generator.ext.Properties.*

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*

class RootTmpl {

def static String Root(Application it) {
	'''
	«IF !modules.isEmpty»
		«IF isDomainObjectToBeGenerated()»
			«it.getAllDomainObjects(false).forEach[DomainObjectTmpl::domainObject(it)]»
			
			«IF isBuilderToBeGenerated()»
				«it.getAllDomainObjects(false).filter[e | e.needsBuilder()].map[BuilderTmpl::builder(it)]»    
			«ENDIF»
		«ENDIF»
		«IF isExceptionToBeGenerated()»
			«it.modules.filter[e|!e.external].forEach[ExceptionTmpl::applicationExceptions(it)]»
		«ENDIF»
		«IF isRepositoryToBeGenerated()»
			«it.getAllRepositories(false).map[operations].flatten.filter[op | op.delegateToAccessObject && !op.isGenericAccessObject()].map[AccessObjectTmpl::command(it)]»
			«it.getAllRepositories(false).forEach[RepositoryTmpl::repository(it)]»
			«IF mongoDb()»
				«it.getAllDomainObjects(false).filter(e | e.isPersistent() || e.metaType == typeof(BasicType)).forEach[MongoDbMapperTmpl::mongoDbMapper(it)]»
			«ENDIF»
		«ENDIF»
		«IF isServiceToBeGenerated()»
			«it.getAllServices(false).forEach[ServiceTmpl::service(it)]»
		«ENDIF»
		«IF isResourceToBeGenerated()»
			«it.getAllResources(false).forEach[ResourceTmpl::resource(it)]»
		«ENDIF»
		«IF isRestWebToBeGenerated() && !it.getAllResources(false).isEmpty»
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
