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

import org.sculptor.generator.ext.GeneratorFactory
import org.sculptor.generator.ext.GeneratorFactoryImpl
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
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
import org.sculptor.generator.template.spring.SpringTmpl
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.BasicType

class RootTmpl {
	private static val GeneratorFactory GEN_FACTORY = GeneratorFactoryImpl::getInstance()

	private static val AccessObjectTmpl accessObjectTmpl = GEN_FACTORY.accessObjectTmpl
	private static val BuilderTmpl builderTmpl = GEN_FACTORY.builderTmpl
	private static val ConsumerTmpl consumerTmpl = GEN_FACTORY.consumerTmpl
	private static val DatasourceTmpl datasourceTmpl = GEN_FACTORY.datasourceTmpl
	private static val DbUnitTmpl dbUnitTmpl = GEN_FACTORY.dbUnitTmpl
	private static val DDLTmpl dDLTmpl = GEN_FACTORY.dDLTmpl
	private static val DomainObjectTmpl domainObjectTmpl = GEN_FACTORY.domainObjectTmpl
	private static val ExceptionTmpl exceptionTmpl = GEN_FACTORY.exceptionTmpl
	private static val HibernateTmpl hibernateTmpl = GEN_FACTORY.hibernateTmpl
	private static val JPATmpl jPATmpl = GEN_FACTORY.jPATmpl
	private static val LogConfigTmpl logConfigTmpl = GEN_FACTORY.logConfigTmpl
	private static val ModelDocTmpl modelDocTmpl = GEN_FACTORY.modelDocTmpl
	private static val MongoDbMapperTmpl mongoDbMapperTmpl = GEN_FACTORY.mongoDbMapperTmpl
	private static val RepositoryTmpl repositoryTmpl = GEN_FACTORY.repositoryTmpl
	private static val ResourceTmpl resourceTmpl = GEN_FACTORY.resourceTmpl
	private static val RestWebTmpl restWebTmpl = GEN_FACTORY.restWebTmpl
	private static val ServiceEjbTestTmpl serviceEjbTestTmpl = GEN_FACTORY.serviceEjbTestTmpl
	private static val SpringTmpl springTmpl = GEN_FACTORY.springTmpl
	private static val UMLGraphTmpl uMLGraphTmpl = GEN_FACTORY.uMLGraphTmpl
	extension Properties properties = GEN_FACTORY.properties
	extension Helper helper = GEN_FACTORY.helper
	extension HelperBase helperBase = GEN_FACTORY.helperBase

	private static val serviceTmpl = GEN_FACTORY.serviceTmpl

	def String Root(Application it) {
		'''
		«IF !modules.isEmpty»
			«IF isDomainObjectToBeGenerated()»
				«it.getAllDomainObjects(false).forEach[domainObjectTmpl.domainObject(it)]»
				
				«IF isBuilderToBeGenerated()»
					«it.getAllDomainObjects(false).filter[e | e.needsBuilder()].map[builderTmpl.builder(it)]»    
				«ENDIF»
			«ENDIF»
			«IF isExceptionToBeGenerated()»
				«it.modules.filter[e|!e.external].forEach[exceptionTmpl.applicationExceptions(it)]»
			«ENDIF»
			«IF isRepositoryToBeGenerated()»
				«it.getAllRepositories(false).map[operations].flatten.filter[op | op.delegateToAccessObject && !op.isGenericAccessObject()].map[accessObjectTmpl.command(it)]»
				«it.getAllRepositories(false).forEach[repositoryTmpl.repository(it)]»
				«IF mongoDb()»
					«it.getAllDomainObjects(false).filter(e | e.isPersistent() || e instanceof BasicType).forEach[mongoDbMapperTmpl.mongoDbMapper(it)]»
				«ENDIF»
			«ENDIF»
			«IF isServiceToBeGenerated()»
				«it.getAllServices(false).forEach[serviceTmpl.service(it)]»
			«ENDIF»
			«IF isResourceToBeGenerated()»
				«it.getAllResources(false).forEach[resourceTmpl.resource(it)]»
			«ENDIF»
			«IF isRestWebToBeGenerated() && !it.getAllResources(false).isEmpty»
				«restWebTmpl.restWeb(it)»
			«ENDIF»
			«IF isConsumerToBeGenerated()»
				«it.getAllConsumers(false).forEach[consumerTmpl.consumer(it)]»
			«ENDIF»
			«IF isEmptyDbUnitTestDataToBeGenerated()»
				«dbUnitTmpl.emptyDbunitTestData(it)»
			«ENDIF»
			«IF getDbUnitDataSetFile() != null»
				«dbUnitTmpl.singleDbunitTestData(it)»
			«ENDIF»
			«IF pureEjb3() && isTestToBeGenerated() && !jpa()»
				«serviceEjbTestTmpl.ejbJarXml(it)»
			«ENDIF»
			«IF isSpringToBeGenerated()»
				«springTmpl.spring(it)»
			«ENDIF»
			«IF isDdlToBeGenerated()»
				«dDLTmpl.ddl(it)»
			«ENDIF»
			«IF isDatasourceToBeGenerated()»
				«datasourceTmpl.datasource(it)»
			«ENDIF»
			«IF isLogbackConfigToBeGenerated()»
				«logConfigTmpl.logbackConfig(it)»
			«ENDIF»
			«IF isHibernateToBeGenerated()»
				«hibernateTmpl.hibernate(it)»
			«ENDIF»
			«IF isJpaAnnotationToBeGenerated()»
				«jPATmpl.jpa(it)»
			«ENDIF»
			«IF isUMLToBeGenerated()»
				«uMLGraphTmpl.start(it)»
			«ENDIF»
			«IF isModelDocToBeGenerated()»
				«modelDocTmpl.start(it)»
			«ENDIF»
		«ENDIF»
		'''
	}
}
