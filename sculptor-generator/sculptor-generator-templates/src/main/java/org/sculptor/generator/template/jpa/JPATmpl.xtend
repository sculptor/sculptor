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
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.DomainObject
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class JPATmpl {

	@Inject private var HibernateTmpl hibernateTmpl
	@Inject private var EclipseLinkTmpl eclipseLinkTmpl
	@Inject private var DataNucleusTmpl dataNucleusTmpl
	@Inject private var OpenJpaTmpl openJpaTmpl
	@Inject private var PropertiesBase propBase

	@Inject extension DbHelper dbHelper
	@Inject extension Helper helper

	@Inject extension Properties properties
	@Inject extension HelperBase helperBase

def String jpa(Application it) {
	'''
	«persistenceUnitXmlFile(it)»
	«IF isJpaProviderHibernate()»
		«hibernateTmpl.hibernate(it)»
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
	«IF isTestToBeGenerated() && !pureEjb3()»
		«persistenceUnitXmlFileTest(it)»
	«ENDIF»
	'''
}


/* ###################################################################### */
/* JPA PersistenceUnit configuration                                      */
/* ###################################################################### */

def String persistenceUnitXmlFile(Application it) {
	fileOutput(persistenceXml(), OutputSlot::TO_GEN_RESOURCES, '''
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
	«IF isJpa1()»
	<?xml version="1.0" encoding="UTF-8"?>
	<persistence xmlns="http://java.sun.com/xml/ns/persistence"
				 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				 xsi:schemaLocation="http://java.sun.com/xml/ns/persistence http://java.sun.com/xml/ns/persistence/persistence_1_0.xsd"
				 version="1.0">
	«ELSE»
	<?xml version="1.0" encoding="UTF-8"?>
	<persistence xmlns="http://java.sun.com/xml/ns/persistence"
				 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				 xsi:schemaLocation="http://java.sun.com/xml/ns/persistence http://java.sun.com/xml/ns/persistence/persistence_2_0.xsd"
				 version="2.0">
	«ENDIF»
	'''
}

def String persistenceUnitContent(Application it, String unitName) {
	'''
	<persistence-unit name="«unitName»" «IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")»transaction-type="JTA"«ELSE»transaction-type="RESOURCE_LOCAL"«ENDIF»>
		<description>JPA configuration for «name» «IF !it.isDefaultPersistenceUnitName(unitName)»«unitName»«ENDIF»</description>
		«persistenceUnit(it, unitName)»
		«persistenceUnitProvider(it)»
		«persistenceUnitDataSource(it, unitName)»
		<!-- annotated classes -->
		«persistenceUnitAnnotatedClasses(it, unitName)»
		«IF isJpa2()»
		    «persistenceUnitSharedCacheMode(it)»
		    «persistenceUnitValidationMode(it)»
		«ENDIF»
		<!-- properties -->
		«persistenceUnitProperties(it, unitName)»
		<!-- add additional configuration by overriding "JPATmpl.persistenceUnitAdditions(Application)" -->
		«persistenceUnitAdditions(it, unitName)»
	</persistence-unit>
	'''
}

def String persistenceUnit(Application it, String unitName) {
	'''
		<exclude-unlisted-classes>true</exclude-unlisted-classes>
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
	«ENDIF»'''
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

def String persistenceUnitProvider(Application it) {
	'''
	«IF isJpaProviderHibernate()»
	<provider>org.hibernate.ejb.HibernatePersistence</provider>
	«ELSEIF isJpaProviderEclipseLink()»
		<provider>org.eclipse.persistence.jpa.PersistenceProvider</provider>
	«ELSEIF isJpaProviderDataNucleus() || isJpaProviderAppEngine()»
		<provider>org.datanucleus.api.jpa.PersistenceProviderImpl</provider>
	«ELSEIF isJpaProviderOpenJpa()»
		<provider>org.apache.openjpa.persistence.PersistenceProviderImpl</provider>
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
 	<validation-mode>AUTO</validation-mode>
	'''
}

def String persistenceUnitProperties(Application it, String unitName) {
	'''
	<properties>
		«IF isJpaProviderHibernate()»
			«persistenceUnitPropertiesHibernate(it, unitName)»
		«ELSEIF isJpaProviderEclipseLink()»
			«persistenceUnitPropertiesEclipseLink(it, unitName)»
		«ELSEIF isJpaProviderDataNucleus()»
			«persistenceUnitPropertiesDataNucleus(it, unitName)»
		«ELSEIF isJpaProviderAppEngine()»
			«persistenceUnitPropertiesAppEngine(it)»
		«ELSEIF isJpaProviderOpenJpa()»
			«persistenceUnitPropertiesOpenJpa(it)»
		«ENDIF»
		<!-- add additional configuration properties by overriding "JPATmpl.persistenceUnitAdditionalProperties(Application)" -->
		«persistenceUnitAdditionalProperties(it, unitName)»
	</properties>
	'''
}

def String persistenceUnitAdditionalProperties(Application it, String unitName) {
	'''
	«persistenceUnitAdditionalProperties(it)»
	'''
}

def String persistenceUnitAdditionalProperties(Application it) {
	'''
	'''
}

def String persistenceUnitPropertiesHibernate(Application it, String unitName) {
	'''
	<property name="hibernate.dialect" value="«propBase.hibernateDialect»" />
	<property name="query.substitutions" value="true 1, false 0" />
	«/* for testing purposes only */»
	«IF propBase.dbProduct == "hsqldb-inmemory"»
		<property name="hibernate.show_sql" value="true" />
		<property name="hibernate.hbm2ddl.auto" value="create-drop" />
	«ENDIF»
	«persistenceUnitCacheProperties(it, unitName)»
	«IF isEar()»
		«persistenceUnitTransactionProperties(it, unitName)»
		«IF !isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss"»
			<!-- Bind entity manager factory to JNDI -->
			<property name="jboss.entity.manager.factory.jndi.name" value="java:/«unitName»"/>
		«ENDIF»
	«ENDIF»
	'''
}

def String persistenceUnitPropertiesEclipseLink(Application it, String unitName) {
	'''
		<property name="eclipselink.weaving" value="static"/>
		<property name="eclipselink.target-database" value="«getEclipseLinkTargetDatabase(unitName)»"/>
		«IF isEar() && applicationServer() == "jboss"»
			<property name="eclipselink.target-server" value="JBoss"/>
		«ENDIF»
		«
		/* need this to create sequence table «IF dbProduct == "hsqldb-inmemory"» */
		/* TODO: find better solution, maybe put seequnce table generation to ddl script */
		»<property name="eclipselink.ddl-generation" value="create-tables"/>
		<property name="eclipselink.ddl-generation.output-mode" value="database"/>
		«/* «ENDIF» */»
	'''
}

def String persistenceUnitPropertiesDataNucleus(Application it, String unitName) {
	'''
		<property name="datanucleus.storeManagerType" value="rdbms"/>
		<property name="datanucleus.ConnectionFactoryName" value="java:comp/env/jdbc/«it.dataSourceName(unitName)»"/>
		«IF propBase.dbProduct == "hsqldb-inmemory"»
			<property name="datanucleus.autoCreateSchema" value="true"/>
		«ENDIF»
	'''
}

def String persistenceUnitPropertiesAppEngine(Application it) {
	'''
			<property name="datanucleus.NontransactionalRead" value="true"/>
			<property name="datanucleus.NontransactionalWrite" value="true"/>
			<property name="datanucleus.ConnectionURL" value="appengine"/>
			<property name="datanucleus.singletonEMFForName" value="true"/>
			<!-- <property name="datanucleus.appengine.autoCreateDatastoreTxns" value="true"/> -->
			<!-- <property name="datanucleus.manageRelationshipsChecks" value="false"/> -->
	'''
}

def String persistenceUnitPropertiesOpenJpa(Application it, String unitName) {
	'''
			<property name="openjpa.Log" value="DefaultLevel=INFO"/>
			<property name="openjpa.Compatibility" value="AbstractMappingUniDirectional=false"/>
	'''
}

def String persistenceUnitCacheProperties(Application it, String unitName) {
	'''
	«IF isJpaProviderHibernate()»
		«persistenceUnitCachePropertiesHibernate(it, unitName)»
	«ELSEIF isJpaProviderEclipseLink()»
		«persistenceUnitCachePropertiesEclipseLink(it, unitName)»
	«ELSEIF isJpaProviderDataNucleus() || isJpaProviderAppEngine()»
		«persistenceUnitCachePropertiesDataNucleus(it, unitName)»
	«ELSEIF isJpaProviderOpenJpa()»
		«persistenceUnitCachePropertiesOpenJpa(it, unitName)»
	«ENDIF»
	'''
}

def String persistenceUnitCachePropertiesHibernate(Application it, String unitName) {
	'''
		<property name="hibernate.cache.use_query_cache" value="true"/>
		<property name="hibernate.cache.use_second_level_cache" value="true"/>
		<property name="hibernate.cache.region_prefix" value=""/>
		«IF cacheProvider() == "EhCache"»
			«IF isJpaProviderHibernate3()»
				<property name="hibernate.cache.region.factory_class" value="net.sf.ehcache.hibernate.SingletonEhCacheRegionFactory"/>
			«ELSE»
				<property name="hibernate.cache.region.factory_class" value="org.hibernate.cache.ehcache.SingletonEhCacheRegionFactory"/>
			«ENDIF»
		«ELSEIF cacheProvider() == "TreeCache"»
			<property name="hibernate.cache.provider_class" value="org.hibernate.cache.TreeCacheProvider"/>
		«ELSEIF cacheProvider() == "JbossTreeCache"»
			<!-- Clustered cache with Jboss TreeCache -->
			<property name="hibernate.cache.provider_class" value="org.jboss.ejb3.entity.TreeCacheProviderHook"/>
			<property name="treecache.mbean.object_name" value="jboss.cache:service=EJB3EntityTreeCache"/>
		«ELSEIF cacheProvider() == "DeployedTreeCache"»
			<property name="hibernate.cache.provider_class" value="org.jboss.hibernate.cache.DeployedTreeCacheProvider"/>
			<property name="hibernate.treecache.objectName" value="jboss.cache:service=«if (it.isDefaultPersistenceUnitName(unitName)) name else unitName»TreeCache"/>
			<!-- use_minimal_puts in clustered environment -->
			<property name="hibernate.cache.use_minimal_puts" value="true"/>
		«ELSEIF cacheProvider() == "Infinispan"»
			«IF !isEar() || applicationServer() != "jboss"»
				<property name="hibernate.cache.region.factory_class" value="org.hibernate.cache.infinispan.JndiInfinispanRegionFactory"/>
				<property name="hibernate.cache.infinispan.cachemanager" value="java:/CacheManager"/>
			«ENDIF»
		«ENDIF»
	'''
}

def String persistenceUnitCachePropertiesEclipseLink(Application it, String unitName) {
	'''
	'''
}

def String persistenceUnitCachePropertiesDataNucleus(Application it, String unitName) {
	'''
	«/* TODO: add more cache providers, oscache, swarmcache, ... */
	»«IF cacheProvider() == "EhCache"»
		<property name="datanucleus.cache.level2.type" value="ehcache"/>
		«/* TODO: check if needed
		<property name="datanucleus.cache.level2.cacheName" value="ehcache"/>
		<property name="datanucleus.cache.level2.configurationFile" value="ehcache.xml"/>
		*/»
	«ELSEIF cacheProvider() == "DataNucleusWeak"»
		<property name="datanucleus.cache.level2.type" value="weak"/>
	«ELSEIF cacheProvider() == "DataNucleusSoft"»
		<property name="datanucleus.cache.level2.type" value="soft"/>
	«ENDIF»
	'''
}

def String persistenceUnitCachePropertiesOpenJpa(Application it, String unitName) {
	'''
	'''
}

def String persistenceUnitPropertiesOpenJpa(Application it) {
	'''
		<property name="openjpa.Log" value="DefaultLevel=WARN"/>
	'''
}

def String persistenceUnitTransactionProperties(Application it, String unitName) {
	'''
	«IF isJpaProviderHibernate()»
		«persistenceUnitTransactionPropertiesHibernate(it, unitName)»
	«ELSEIF isJpaProviderEclipseLink()»
		«persistenceUnitTransactionPropertiesEclipseLink(it, unitName)»
	«ELSEIF isJpaProviderDataNucleus()»
		«persistenceUnitTransactionPropertiesDataNucleus(it, unitName)»
	«ENDIF»
	'''
}

def String persistenceUnitTransactionPropertiesHibernate(Application it, String unitName) {
	'''
		«IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")»
			<property name="hibernate.transaction.manager_lookup_class" value="org.hibernate.transaction.JBossTransactionManagerLookup"/>
		«ENDIF»
	'''
}

def String persistenceUnitTransactionPropertiesEclipseLink(Application it, String unitName) {
	'''
	'''
}

def String persistenceUnitTransactionPropertiesDataNucleus(Application it, String unitName) {
	'''
		«IF isEar() && (!isSpringDataSourceSupportToBeGenerated())»
			<property name="datanucleus.jtaLocator" value="«applicationServer()»"/>
			<!--
			<property name="datanucleus.jtaJndiLocation " value="java:/TransactionManager"/>
			-->
 		«ENDIF»
	'''
}

/* extension point for additional configuration of the PersistenceUnit */
def String persistenceUnitAdditions(Application it, String unitName) {
	'''
	'''
}

def String persistenceUnitXmlFileTest(Application it) {
	fileOutput("META-INF/persistence-test.xml", OutputSlot::TO_GEN_RESOURCES_TEST, '''
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
		«persistenceUnit(it, unitName)»
		«persistenceUnitProvider(it)»
		<!-- annotated classes -->
		«persistenceUnitAnnotatedClasses(it, unitName)»
		«IF isJpa2()»
			«persistenceUnitSharedCacheMode(it)»
			«persistenceUnitValidationMode(it)»
		«ENDIF»
		<!-- properties -->
		«persistenceUnitPropertiesTest(it, unitName)»
		<!-- add additional configuration by overriding "JPATmpl.persistenceUnitAdditions(Application)" -->
		«persistenceUnitAdditions(it, unitName)»
	</persistence-unit>
	'''
}

def String persistenceUnitPropertiesTest(Application it, String unitName) {
	'''
		<properties>
			«IF isJpaProviderHibernate()»
				«persistenceUnitPropertiesTestHibernate(it, unitName)»
			«ELSEIF isJpaProviderEclipseLink()»
				«persistenceUnitPropertiesTestEclipseLink(it, unitName)»
			«ELSEIF isJpaProviderDataNucleus()»
				«persistenceUnitPropertiesTestDataNucleus(it, unitName)»
			«ELSEIF isJpaProviderOpenJpa()»
				«persistenceUnitPropertiesTestOpenJpa(it, unitName)»
			«ENDIF»
			<!-- add additional configuration properties by overriding "JPATmpl.persistenceUnitAdditionalPropertiesTest(Application)" -->
			«persistenceUnitAdditionalPropertiesTest(it, unitName)»
		</properties>
	'''
}

def String persistenceUnitAdditionalPropertiesTest(Application it, String unitName) {
	'''
	«persistenceUnitAdditionalPropertiesTest(it)»
	'''
}

def String persistenceUnitAdditionalPropertiesTest(Application it) {
	'''
	'''
}

def String persistenceUnitPropertiesTestHibernate(Application it, String unitName) {
	'''
		<property name="hibernate.dialect" value="«fw("persistence.CustomHSQLDialect")»" />
		<property name="hibernate.show_sql" value="true" />
		<property name="hibernate.hbm2ddl.auto" value="create-drop" />
		«IF !isJpa2()»
			<property name="hibernate.ejb.cfgfile" value="hibernate.cfg.xml"/>
		«ENDIF»
		<property name="query.substitutions" value="true 1, false 0" />
		<property name="hibernate.cache.use_query_cache" value="true"/>
		<property name="hibernate.cache.use_second_level_cache" value="true"/>
		«IF isJpaProviderHibernate3()»
			<property name="hibernate.cache.region.factory_class" value="org.hibernate.cache.SingletonEhCacheRegionFactory"/>
		«ELSE»
			<property name="hibernate.cache.region.factory_class" value="org.hibernate.cache.ehcache.SingletonEhCacheRegionFactory"/>
		«ENDIF»
	'''
}

def String persistenceUnitPropertiesTestEclipseLink(Application it, String unitName) {
	'''
		<property name="eclipselink.target-database" value="HSQL"/>
		<property name="eclipselink.ddl-generation" value="create-tables"/>
		<property name="eclipselink.ddl-generation.output-mode" value="database"/>
		<property name="eclipselink.logging.level" value="FINE" />
		<property name="eclipselink.weaving" value="static"/>
	'''
}

def String persistenceUnitPropertiesTestDataNucleus(Application it, String unitName) {
	'''
		<property name="datanucleus.storeManagerType" value="rdbms"/>
		<property name="datanucleus.jpa.addClassTransformer" value="false"/>
		<property name="datanucleus.autoStartMechanism" value="none"/>
		<property name="datanucleus.autoCreateSchema" value="true"/>
	'''
}

def String persistenceUnitPropertiesTestOpenJpa(Application it, String unitName) {
	'''
		<property name="openjpa.Log" value="DefaultLevel=TRACE"/>
		<property name="openjpa.DynamicEnhancementAgent" value="false"/>
		<property name="openjpa.jdbc.SynchronizeMappings" value="buildSchema(PrimaryKeys=true,ForeignKeys=true,Indexes=true)"/>
		<property name="openjpa.jdbc.MappingDefaults" value="ForeignKeyDeleteAction=restrict, JoinForeignKeyDeleteAction=restrict"/>
		<property name="openjpa.Compatibility" value="AbstractMappingUniDirectional=false"/>
		<property name="openjpa.Sequence" value="InitialValue=100"/>
	'''
}

}
