/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.jpa

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.DomainObject

@ChainOverridable
class JPATmpl {

	@Inject var EclipseLinkTmpl eclipseLinkTmpl
	@Inject var DataNucleusTmpl dataNucleusTmpl
	@Inject var OpenJpaTmpl openJpaTmpl
	@Inject var PropertiesBase propBase

	@Inject extension DbHelper dbHelper
	@Inject extension Helper helper

	@Inject extension Properties properties
	@Inject extension HelperBase helperBase

def String jpa(Application it) {
	'''
	«IF getEntityManagerFactoryType() == 'static'»
		«persistenceUnitXmlFile(it)»
	«ENDIF»
	«IF isJpaProviderEclipseLink()»
		«eclipseLinkTmpl.eclipseLink(it)»
	«ENDIF»
	«IF isJpaProviderDataNucleus()»
		«dataNucleusTmpl.dataNucleus(it)»
	«ENDIF»
	«IF isJpaProviderOpenJpa()»
		«openJpaTmpl.openJpa(it)»
	«ENDIF»
	«IF isTestToBeGenerated() && !pureEjb3() && getEntityManagerFactoryTestType() == 'static'»
		«persistenceUnitXmlFileTest(it)»
	«ENDIF»
	'''
}


/* ###################################################################### */
/* JPA PersistenceUnit configuration                                      */
/* ###################################################################### */
def String persistenceUnitXmlFile(Application it) {
	fileOutput(persistenceXml(), OutputSlot.TO_GEN_RESOURCES, '''
	«persistenceUnitHeader(it)»
		«FOR unitName : modules.filter(e|!e.external).map(e|e.persistenceUnit).toSet()»
			«persistenceUnitContent(it, unitName)»
		«ENDFOR»
	</persistence>
	'''
	)
}

def String persistenceUnitHeader(Application it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<persistence xmlns="http://java.sun.com/xml/ns/persistence"
				 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				 xsi:schemaLocation="http://java.sun.com/xml/ns/persistence http://java.sun.com/xml/ns/persistence/persistence_2_0.xsd"
				 version="2.0">
	'''
}

def String persistenceUnitContent(Application it, String unitName) {
	'''
	<persistence-unit name="«unitName»" «IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")»transaction-type="JTA"«ELSE»transaction-type="RESOURCE_LOCAL"«ENDIF»>
		<description>JPA configuration for «name» «IF !it.isDefaultPersistenceUnitName(unitName)»«unitName»«ENDIF»</description>
		<provider>«jpaProviderClass»</provider>
		«persistenceUnitDataSource(it, unitName)»
		<!-- annotated classes -->
		«persistenceUnitAnnotatedClasses(it, unitName)»
		«persistenceUnitExcludeUnlistedClasses(it, unitName)»
		«persistenceUnitSharedCacheMode(it)»
		«persistenceUnitValidationMode(it)»
		<!-- properties -->
		«persistenceUnitProperties(it, unitName)»
		<!-- add additional configuration by overriding "JPATmpl.persistenceUnitAdditions(Application)" -->
		«persistenceUnitAdditions(it, unitName)»
	</persistence-unit>
	'''
}

/* extension point for additional configuration of the PersistenceUnit */
def String persistenceUnitAdditions(Application it, String unitName) {
	'''
	'''
}

def String persistenceUnitAnnotatedClasses(Application it, String unitName) {
	'''
	«IF isJpaProviderEclipseLink()»
		<mapping-file>«it.getResourceDir("META-INF") + "orm.xml"»</mapping-file>
	«ENDIF»
	«it.getAllDomainObjects().filter(d | d.module.persistenceUnit == unitName).map[persistenceUnitAnnotatedClasses(it)].join()»
	'''
}

def String persistenceUnitAnnotatedClasses(DomainObject it) {
	'''
	«IF it.hasOwnDatabaseRepresentation()»
		<class>«getDomainPackage()».«name»</class>
	«ENDIF»
	«IF it.isEmbeddable()»
		<class>«getDomainPackage()».«name»</class>
	«ENDIF»
	«/* seems that openjpa needs also the mappedsuperclasses in persistence.xml */
	»«IF isJpaProviderOpenJpa()»
		«IF gapClass»
			<class>«getDomainPackage()».«name»Base</class>
		«ENDIF»
	«ENDIF»
	'''
}

def String persistenceUnitExcludeUnlistedClasses(Application it, String unitName) {
	'''
	<exclude-unlisted-classes>true</exclude-unlisted-classes>
	'''
}

def String persistenceUnitDataSource(Application it, String unitName) {
	/* TODO: add additional support for jta */
	/* Invoke old dataSourceName() for backwards compatibility reasons */
	val dataSourceName = if (it.isDefaultPersistenceUnitName(unitName)) it.dataSourceName() else it.dataSourceName(unitName)
	'''
	«IF isEar()»
		«IF applicationServer() == "jboss"»
			<jta-data-source>java:/jdbc/«dataSourceName»</jta-data-source>
		«ELSE»
			«IF !isSpringDataSourceSupportToBeGenerated()»
				<jta-data-source>java:comp/env/jdbc/«dataSourceName»</jta-data-source>
			«ENDIF»
		«ENDIF»
	«ELSEIF isWar()»
		«IF applicationServer() == "appengine"»
		«ELSEIF applicationServer() == "jboss"»
			<non-jta-data-source>java:/jdbc/«dataSourceName»</non-jta-data-source>
		«ELSE»
			«IF !isSpringDataSourceSupportToBeGenerated()»
				<non-jta-data-source>java:comp/env/jdbc/«dataSourceName»</non-jta-data-source>
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def String persistenceUnitSharedCacheMode(Application it) {
	'''
	<shared-cache-mode>ENABLE_SELECTIVE</shared-cache-mode>
	'''
}

def String persistenceUnitValidationMode(Application it) {
	'''
 	<validation-mode>CALLBACK</validation-mode>
	'''
}

def String persistenceUnitProperties(Application it, String unitName) {
	var propertyList=new java.util.Properties();
	'''
	<properties>
		«IF isJpaProviderHibernate()»
			«persistenceUnitPropertiesHibernate(it, unitName, propertyList)»
		«ELSEIF isJpaProviderEclipseLink()»
			«persistenceUnitPropertiesEclipseLink(it, unitName, propertyList)»
		«ELSEIF isJpaProviderDataNucleus()»
			«persistenceUnitPropertiesDataNucleus(it, unitName, propertyList)»
		«ELSEIF isJpaProviderAppEngine()»
			«persistenceUnitPropertiesAppEngine(it, unitName, propertyList)»
		«ELSEIF isJpaProviderOpenJpa()»
			«persistenceUnitPropertiesOpenJpa(it, unitName, propertyList)»
		«ENDIF»
		«printProperties("persistenceUnit", propertyList)»
		«persistenceUnitAdditionalProperties(it, unitName)»
	</properties>
	'''
}

def String persistenceUnitAdditionalProperties(Application it, String unitName) {
	'''
		<!-- add additional configuration properties by overriding "JPATmpl.persistenceUnitAdditionalProperties(Application it,String unitName)" -->
	'''
}

/* ########################################################################## */
/* PERSISTENCE UNIT PROPERTIES                                                */
/* ########################################################################## */
def void persistenceUnitPropertiesHibernate(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('hibernate.dialect', propBase.getHibernateDialect());
	propertyList.put('query.substitutions', 'true 1, false 0');
	// for testing only
	if (propBase.getDbProduct() == "hsqldb-inmemory") {
		propertyList.put('hibernate.show_sql', 'false');
		propertyList.put('hibernate.hbm2ddl.auto', 'create-drop');
	}
	persistenceUnitCachePropertiesHibernate(it, unitName, propertyList);
	persistenceUnitTransactionPropertiesHibernate(it, unitName, propertyList);
}

def void persistenceUnitPropertiesEclipseLink(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('eclipselink.weaving', 'static');
	propertyList.put('eclipselink.target-database', getEclipseLinkTargetDatabase(propBase.dbProduct));
	if (isEar() && applicationServer() == "jboss") {
		propertyList.put('eclipselink.target-server', 'JBoss');
	}
	// need this to create sequence table IF dbProduct == "hsqldb-inmemory"
	// TODO: find better solution, maybe put sequence table generation to ddl script
	propertyList.put('eclipselink.ddl-generation', 'create-tables');
	propertyList.put('eclipselink.ddl-generation.output-mode', 'database');
	// ENDIF
	persistenceUnitCachePropertiesEclipseLink(it, unitName, propertyList);
	persistenceUnitTransactionPropertiesEclipseLink(it, unitName, propertyList);
}

def void persistenceUnitPropertiesDataNucleus(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('datanucleus.storeManagerType', 'rdbms');
	propertyList.put('datanucleus.ConnectionFactoryName', 'java:comp/env/jdbc/' + it.dataSourceName(unitName));
	if (propBase.dbProduct == 'hsqldb-inmemory') {
		propertyList.put('datanucleus.autoCreateSchema', 'true');
	}
	persistenceUnitCachePropertiesDataNucleus(it, unitName, propertyList);
	persistenceUnitTransactionPropertiesDataNucleus(it, unitName, propertyList);
}

def void persistenceUnitPropertiesAppEngine(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('datanucleus.NontransactionalRead', 'true');
	propertyList.put('datanucleus.NontransactionalWrite', 'true');
	propertyList.put('datanucleus.ConnectionURL', 'appengine');
	propertyList.put('datanucleus.singletonEMFForName', 'true');
	propertyList.put('datanucleus.appengine.datastoreReadConsistency', 'EVENTUAL');
	propertyList.put('javax.persistence.query.timeout', '5000');
	propertyList.put('datanucleus.datastoreWriteTimeout', '10000');
	propertyList.put('datanucleus.appengine.datastoreEnableXGTransactions', 'true');
	// propertyList.put('datanucleus.manageRelationshipsChecks', 'false');
	persistenceUnitCachePropertiesDataNucleus(it, unitName, propertyList);
	persistenceUnitTransactionPropertiesDataNucleus(it, unitName, propertyList);
}

def void persistenceUnitPropertiesOpenJpa(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('openjpa.Log', 'DefaultLevel=INFO');
	propertyList.put('openjpa.Compatibility', 'AbstractMappingUniDirectional=false');
	persistenceUnitCachePropertiesOpenJpa(it, unitName, propertyList);
	persistenceUnitTransactionPropertiesOpenJpa(it, unitName, propertyList);
}

/* ########################################################################## */
/* CACHE PROPERTIES                                                           */
/* ########################################################################## */
def persistenceUnitCachePropertiesHibernate(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('hibernate.cache.use_query_cache', 'true');
	propertyList.put('hibernate.cache.use_second_level_cache', 'true');
	propertyList.put('hibernate.cache.region_prefix', '');
	if (cacheProvider() == 'JCache') {
		// Default jcache provider will be used
		propertyList.put("hibernate.cache.region.factory_class", "org.hibernate.cache.jcache.internal.JCacheRegionFactory");
	} else if (cacheProvider() == 'EhCache') {
		// Enforce EhCache provider
		propertyList.put("hibernate.cache.region.factory_class", "org.hibernate.cache.jcache.internal.JCacheRegionFactory");
		propertyList.put("hibernate.javax.cache.provider", "org.ehcache.jsr107.EhcacheCachingProvider");
		propertyList.put("hibernate.javax.cache.uri", "classpath:///ehcache.xml");
	} else if (cacheProvider() == "TreeCache") {
		propertyList.put('hibernate.cache.provider_class', 'org.hibernate.cache.TreeCacheProvider');
	} else if (cacheProvider() == "JbossTreeCache") {
		// Clustered cache with Jboss TreeCache
		propertyList.put('hibernate.cache.provider_class', 'org.jboss.ejb3.entity.TreeCacheProviderHook');
		propertyList.put('treecache.mbean.object_name', "jboss.cache:service=EJB3EntityTreeCache");
	} else if (cacheProvider() == "DeployedTreeCache") {
		propertyList.put('hibernate.cache.provider_class', 'org.jboss.hibernate.cache.DeployedTreeCacheProvider');
		propertyList.put('hibernate.treecache.objectName', 'jboss.cache:service=' + (it.isDefaultPersistenceUnitName(unitName) ? name : unitName) + 'TreeCache');
		// use_minimal_puts in clustered environment
		propertyList.put('hibernate.cache.use_minimal_puts', 'true');
	} else if (cacheProvider() == "Infinispan") {
		if (!isEar() || applicationServer() != "jboss") {
			propertyList.put('hibernate.cache.region.factory_class', 'org.hibernate.cache.infinispan.JndiInfinispanRegionFactory');
			propertyList.put('hibernate.cache.infinispan.cachemanager', 'java:/CacheManager');
		}
	}
}

def persistenceUnitCachePropertiesEclipseLink(Application it, String unitName, java.util.Properties propertyList) {
}

def persistenceUnitCachePropertiesDataNucleus(Application it, String unitName, java.util.Properties propertyList) {
	var dataNucleusCachePrefix="DataNucleus"
	if (cacheProvider() == "EhCache") {
		propertyList.put('datanucleus.cache.level2.type', 'ehcache');
		propertyList.put('datanucleus.cache.level2.cacheName', unitName);
		// TODO: check if needed
		// propertyList.put('datanucleus.cache.level2.configurationFile', 'ehcache.xml');
	} else if (cacheProvider().startsWith(dataNucleusCachePrefix)) {
		propertyList.put('datanucleus.cache.level2.type', cacheProvider().substring(dataNucleusCachePrefix.length()).toLowerCase());
		propertyList.put('datanucleus.cache.level2.cacheName', unitName);
	}
}

def persistenceUnitCachePropertiesOpenJpa(Application it, String unitName, java.util.Properties propertyList) {
}

/* ########################################################################## */
/* TRANSACTION PROPERTIES                                                     */
/* ########################################################################## */
def persistenceUnitTransactionPropertiesHibernate(Application it, String unitName, java.util.Properties propertyList) {
	if (isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")) {
		propertyList.put('jboss.entity.manager.factory.jndi.name', 'java:/' + unitName);
		propertyList.put('hibernate.transaction.manager_lookup_class', 'org.hibernate.transaction.JBossTransactionManagerLookup');
	}
}

def persistenceUnitTransactionPropertiesEclipseLink(Application it, String unitName, java.util.Properties propertyList) {
}

def persistenceUnitTransactionPropertiesDataNucleus(Application it, String unitName, java.util.Properties propertyList) {
	if (isEar() && (!isSpringDataSourceSupportToBeGenerated())) {
		propertyList.put('datanucleus.jtaLocator', applicationServer());
		// propertyList.put('datanucleus.jtaJndiLocation', 'java:/TransactionManager');
	}
}

def persistenceUnitTransactionPropertiesOpenJpa(Application it, String unitName, java.util.Properties propertyList) {
}

/* ########################################################################## */
/* TEST PERSISTENCE UNIT                                                      */
/* ########################################################################## */
def String persistenceUnitXmlFileTest(Application it) {
	fileOutput("META-INF/persistence-test.xml", OutputSlot.TO_GEN_RESOURCES_TEST, '''
	«persistenceUnitHeader(it)»
		«FOR unitName : modules.filter(e| !e.external).map(e|e.persistenceUnit).toSet()»
			«persistenceUnitContentTest(it, unitName)»
		«ENDFOR»
	</persistence>
	'''
	)
}

def String persistenceUnitContentTest(Application it, String unitName) {
	'''
	<persistence-unit name="«unitName»">
		<description>JPA configuration for «name» «IF !it.isDefaultPersistenceUnitName(unitName)»«unitName»«ENDIF»</description>
		<provider>«jpaProviderClass»</provider>
		<!-- annotated classes -->
		«persistenceUnitAnnotatedClasses(it, unitName)»
		«persistenceUnitExcludeUnlistedClasses(it, unitName)»
		«persistenceUnitSharedCacheMode(it)»
		«persistenceUnitValidationMode(it)»
		<!-- properties -->
		«persistenceUnitPropertiesTest(it, unitName)»
		«persistenceUnitAdditionsTest(it, unitName)»
	</persistence-unit>
	'''
}

def String persistenceUnitAdditionsTest(Application it, String unitName) {
	'''
		<!-- add additional configuration by overriding "JPATmpl.persistenceUnitAdditionsTest(Application app, String unitName)" -->
	'''
}

/* ########################################################################## */
/* TEST PERSISTENCE UNIT PROPERTIES                                           */
/* ########################################################################## */
def String persistenceUnitPropertiesTest(Application it, String unitName) {
	var propertyList=new java.util.Properties();
	'''
		<properties>
			«IF isJpaProviderHibernate()»
				«persistenceUnitPropertiesTestHibernate(it, unitName, propertyList)»
			«ELSEIF isJpaProviderEclipseLink()»
				«persistenceUnitPropertiesTestEclipseLink(it, unitName, propertyList)»
			«ELSEIF isJpaProviderDataNucleus()»
				«persistenceUnitPropertiesTestDataNucleus(it, unitName, propertyList)»
			«ELSEIF isJpaProviderOpenJpa()»
				«persistenceUnitPropertiesTestOpenJpa(it, unitName, propertyList)»
			«ENDIF»
			«printProperties("persistenceUnitTest", propertyList)»
			«persistenceUnitAdditionalPropertiesTest(it, unitName)»
		</properties>
	'''
}

def String persistenceUnitAdditionalPropertiesTest(Application it, String unitName) {
	'''
		<!-- add additional configuration properties by overriding "JPATmpl.persistenceUnitAdditionalPropertiesTest(Application it, String unitName)" -->
	'''
}

def void persistenceUnitPropertiesTestHibernate(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('hibernate.dialect', propBase.getTestHibernateDialect());
	propertyList.put('hibernate.show_sql', 'false');
	propertyList.put('hibernate.hbm2ddl.auto', 'create-drop');
	propertyList.put('query.substitutions', 'true 1, false 0');
	propertyList.put('hibernate.cache.use_query_cache', 'true');
	propertyList.put('hibernate.cache.use_second_level_cache', 'true');
	propertyList.put('hibernate.cache.region.factory_class', 'org.hibernate.cache.jcache.internal.JCacheRegionFactory');
	if (cacheProvider() != 'JCache') {
		// Enforce EhCache provider
		propertyList.put("hibernate.javax.cache.provider", "org.ehcache.jsr107.EhcacheCachingProvider");
		propertyList.put("hibernate.javax.cache.uri", "classpath://ehcache-test.xml");
	}
}

def void persistenceUnitPropertiesTestEclipseLink(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('eclipselink.target-database', getEclipseLinkTargetDatabase(propBase.testDbProduct));
	propertyList.put('eclipselink.ddl-generation', 'create-tables');
	propertyList.put('eclipselink.ddl-generation.output-mode', 'database');
	propertyList.put('eclipselink.logging.level', 'FINE');
	propertyList.put('eclipselink.weaving', 'static');
}

def void persistenceUnitPropertiesTestDataNucleus(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('datanucleus.storeManagerType', 'rdbms');
	propertyList.put('datanucleus.jpa.addClassTransformer', 'false');
	propertyList.put('datanucleus.autoStartMechanism', 'none');
	propertyList.put('datanucleus.autoCreateSchema', 'true');
}

def void persistenceUnitPropertiesTestOpenJpa(Application it, String unitName, java.util.Properties propertyList) {
	propertyList.put('openjpa.Log', 'DefaultLevel=TRACE');
	propertyList.put('openjpa.DynamicEnhancementAgent', 'false');
	propertyList.put('openjpa.jdbc.SynchronizeMappings', 'buildSchema(PrimaryKeys=true,ForeignKeys=true,Indexes=true)');
	propertyList.put('openjpa.jdbc.MappingDefaults', 'ForeignKeyDeleteAction=restrict, JoinForeignKeyDeleteAction=restrict');
	propertyList.put('openjpa.Compatibility', 'AbstractMappingUniDirectional=false');
	propertyList.put('openjpa.Sequence', 'InitialValue=100');
}

}
