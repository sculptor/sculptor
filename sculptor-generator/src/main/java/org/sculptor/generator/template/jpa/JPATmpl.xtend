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

package org.sculptor.generator.template.jpa

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class JPATmpl {

def static String jpa(Application it) {
	'''
	«persistenceUnitXmlFile(it)»
		«IF isJpaProviderHibernate()»
			«Hibernate::hibernate(it)»
		«ENDIF»
	«IF isJpaProviderEclipseLink()»
		«EclipseLink::eclipseLink(it)»
	«ENDIF»
	«IF isJpaProviderDataNucleus()»
		«DataNucleus::dataNucleus(it)»
	«ENDIF»
	«IF isJpaProviderOpenJpa()»
		«OpenJpa::openJpa(it)»
	«ENDIF»
	«IF isTestToBeGenerated() && !pureEjb3()»
		«persistenceUnitXmlFileTest(it)»
	«ENDIF»
	'''
}


/*###################################################################### */
/*JPA PersistenceUnit configuration                                      */
/*###################################################################### */

def static String persistenceUnitXmlFile(Application it) {
	'''
	'''
	fileOutput(persistenceXml(), 'TO_GEN_RESOURCES', '''
	«persistenceUnitHeader(it)»

	«FOR unitName : modules.reject(e|e.external).collect(e|e.persistenceUnit).toSet()»
		«persistenceUnitContent(it)(unitName)»
	«ENDFOR»

	</persistence>
	'''
	)
	'''
	'''
}

def static String persistenceUnitHeader(Application it) {
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

def static String persistenceUnitContent(Application it, String unitName) {
	'''
	<persistence-unit name="«unitName»" «IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")»transaction-type="JTA"«ELSE»transaction-type="RESOURCE_LOCAL"«ENDIF»>
		<description>JPA configuration for «name» «IF !isDefaultPersistenceUnitName(unitName)»«unitName»«ENDIF»</description>
	    «persistenceUnit(it)(unitName)»
	    «persistenceUnitProvider(it)»
	    «persistenceUnitDataSource(it)(unitName)»
		<!-- annotated classes -->
	    «persistenceUnitAnnotatedClasses(it)(unitName)»
		«IF isJpa2()»
		    «persistenceUnitSharedCacheMode(it)»
		    «persistenceUnitValidationMode(it)»
		«ENDIF»
		<!-- properties  -->
	    «persistenceUnitProperties(it)(unitName)»
		/*extension point for additional configuration of the PersistenceUnit */
		<!-- add additional configuration properties by using SpecialCases.xpt "AROUND JPATmpl::persistenceUnitAdditions FOR Application" -->
	    «persistenceUnitAdditions(it)(unitName)»
		</persistence-unit>
	'''
}

def static String persistenceUnit(Application it, String unitName) {
	'''
		/*
		<exclude-unlisted-classes>true</exclude-unlisted-classes>
			 */
	'''
}

def static String persistenceUnitAnnotatedClasses(Application it, String unitName) {
	'''
	«IF isJpaProviderEclipseLink()»
	<mapping-file>«getResourceDir("META-INF") + "orm.xml"»</mapping-file>
	«ENDIF»
		«it.getAllDomainObjects().filter(d | d.module.persistenceUnit == unitName).forEach[persistenceUnitAnnotatedClasses(it)]»
	'''
}

def static String persistenceUnitAnnotatedClasses(DomainObject it) {
	'''
	«IF hasOwnDatabaseRepresentation()»
	<class>«getDomainPackage()».«name»</class>
	«ENDIF»
		«IF isEmbeddable()»
		<class>«getDomainPackage()».«name»</class>
		«ENDIF»
	/*seems that openjpa needs also the mappedsuperclasses in persistence.xml */
	«IF isJpaProviderOpenJpa()»
		«IF gapClass»
	<class>«getDomainPackage()».«name»Base</class>
		«ENDIF»
	«ENDIF»
	'''
}

def static String persistenceUnitDataSource(Application it, String unitName) {
	'''
	/*TODO: add additional support for jta */
	/*Invoke old dataSourceName() for backwards compatibility reasons */
	«val dataSourceName = it.isDefaultPersistenceUnitName(unitName) ? dataSourceName() : dataSourceName(unitName)»
	«IF isEar()»
	    «IF applicationServer() == "jboss" »
		<jta-data-source>java:jdbc/«dataSourceName»</jta-data-source>
			«ELSE »
			«IF !isSpringDataSourceSupportToBeGenerated()»
		<jta-data-source>java:comp/env/jdbc/«dataSourceName»</jta-data-source>
			«ENDIF»
		«ENDIF»
	«ELSEIF isWar()»
		«IF applicationServer() == "appengine" »
	    «ELSEIF applicationServer() == "jboss" »
		<non-jta-data-source>java:jdbc/«dataSourceName»</non-jta-data-source>
			«ELSE »
			«IF !isSpringDataSourceSupportToBeGenerated()»
		<non-jta-data-source>java:comp/env/jdbc/«dataSourceName»</non-jta-data-source>
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def static String persistenceUnitProvider(Application it) {
	'''
	«IF isJpaProviderHibernate()»
	<provider>org.hibernate.ejb.HibernatePersistence</provider>
	«ELSEIF isJpaProviderEclipseLink()»
		<provider>org.eclipse.persistence.jpa.PersistenceProvider</provider>
	«ELSEIF isJpaProviderDataNucleus()»
		<provider>org.datanucleus.api.jpa.PersistenceProviderImpl</provider>
	«ELSEIF isJpaProviderAppEngine()»
		<provider>org.datanucleus.store.appengine.jpa.DatastorePersistenceProvider</provider>
	«ELSEIF isJpaProviderOpenJpa()»
		<provider>org.apache.openjpa.persistence.PersistenceProviderImpl</provider>
	«ENDIF»
	'''
}

def static String persistenceUnitSharedCacheMode(Application it) {
	'''
	<shared-cache-mode>ENABLE_SELECTIVE</shared-cache-mode>
	'''
}

def static String persistenceUnitValidationMode(Application it) {
	'''
 	<validation-mode>AUTO</validation-mode>
	'''
}

def static String persistenceUnitProperties(Application it, String unitName) {
	'''
	<properties>
	«IF isJpaProviderHibernate()»
		«persistenceUnitPropertiesHibernate(it)(unitName)»
	«ELSEIF isJpaProviderEclipseLink()»
		«persistenceUnitPropertiesEclipseLink(it)(unitName)»
	«ELSEIF isJpaProviderDataNucleus()»
		«persistenceUnitPropertiesDataNucleus(it)(unitName)»
	«ELSEIF isJpaProviderAppEngine()»
		«persistenceUnitPropertiesAppEngine(it)»
	«ELSEIF isJpaProviderOpenJpa()»
		«persistenceUnitPropertiesOpenJpa(it)»
	«ENDIF»
	/*extension point for additional configuration of the PersistenceUnit */
	<!-- add additional configuration properties by using SpecialCases.xpt "AROUND JPATmpl::persistenceUnitAdditionalProperties FOR Application" -->
		«persistenceUnitAdditionalProperties(it)(unitName)»
	</properties>
	'''
}

def static String persistenceUnitAdditionalProperties(Application it, String unitName) {
	'''
	«persistenceUnitAdditionalProperties(it)»
	'''
}

def static String persistenceUnitAdditionalProperties(Application it) {
	'''
	'''
}

def static String persistenceUnitPropertiesHibernate(Application it, String unitName) {
	'''
		<property name="hibernate.dialect" value="«hibernateDialect()»" />
		<property name="query.substitutions" value="true 1, false 0" />
	/*for testing purposes only */
	«IF dbProduct() == "hsqldb-inmemory"»
		<property name="hibernate.show_sql" value="true" />
		<property name="hibernate.hbm2ddl.auto" value="create-drop" />
	«ENDIF»
	«persistenceUnitCacheProperties(it)(unitName)»
	«IF isEar()»
		«persistenceUnitTransactionProperties(it)(unitName)»
		«IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")»
		<property name="jboss.entity.manager.factory.jndi.name" value="java:/«unitName»"/>
		«ENDIF»
	«ENDIF»
	'''
}

def static String persistenceUnitPropertiesEclipseLink(Application it, String unitName) {
	'''
		<property name="eclipselink.weaving" value="static"/>
		<property name="eclipselink.target-database" value="«getEclipseLinkTargetDatabase(unitName)»"/>
		«IF isEar() && applicationServer() == "jboss"»
		<property name="eclipselink.target-server" value="JBoss"/>
		«ENDIF»
		/* need this to create sequence table «IF dbProduct() == "hsqldb-inmemory"»  */
		/* TODO: find better solution, maybe put seequnce table generation to ddl script  */
		<property name="eclipselink.ddl-generation" value="create-tables"/>
		<property name="eclipselink.ddl-generation.output-mode" value="database"/>
		/*«ENDIF» */
	'''
}

def static String persistenceUnitPropertiesDataNucleus(Application it, String unitName) {
	'''
		<property name="datanucleus.storeManagerType" value="rdbms"/>
		<property name="datanucleus.ConnectionFactoryName" value="java:comp/env/jdbc/«dataSourceName(unitName)»"/>
 	«IF dbProduct() == "hsqldb-inmemory"»
			<property name="datanucleus.autoCreateSchema" value="true"/>
	«ENDIF»
	'''
}

def static String persistenceUnitPropertiesAppEngine(Application it) {
	'''
			<property name="datanucleus.NontransactionalRead" value="true"/>
			<property name="datanucleus.NontransactionalWrite" value="true"/>
			<property name="datanucleus.ConnectionURL" value="appengine"/>
			<!-- <property name="datanucleus.appengine.autoCreateDatastoreTxns" value="true"/> -->
			<!-- <property name="datanucleus.manageRelationshipsChecks" value="false"/> -->
	'''
}

def static String persistenceUnitPropertiesOpenJpa(Application it, String unitName) {
	'''
			<property name="openjpa.Log" value="DefaultLevel=INFO"/>
			<property name="openjpa.Compatibility" value="AbstractMappingUniDirectional=false"/>
	'''
}

def static String persistenceUnitCacheProperties(Application it, String unitName) {
	'''
	«IF isJpaProviderHibernate()»
		«persistenceUnitCachePropertiesHibernate(it)(unitName)»
	«ELSEIF isJpaProviderEclipseLink()»
		«persistenceUnitCachePropertiesEclipseLink(it)(unitName)»
	«ELSEIF isJpaProviderDataNucleus() || isJpaProviderAppEngine()»
		«persistenceUnitCachePropertiesDataNucleus(it)(unitName)»
	«ELSEIF isJpaProviderOpenJpa()»
		«persistenceUnitCachePropertiesOpenJpa(it)(unitName)»
	«ENDIF»
	'''
}

def static String persistenceUnitCachePropertiesHibernate(Application it, String unitName) {
	'''
			<property name="hibernate.cache.use_query_cache" value="true"/>
			<property name="hibernate.cache.use_second_level_cache" value="true"/>
			<property name="hibernate.cache.region_prefix" value=""/>
	«IF cacheProvider() == "EhCache"»
			«IF isJpaProviderHibernate3()»
			<property name="hibernate.cache.region.factory_class" value="org.hibernate.cache.SingletonEhCacheRegionFactory"/>
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
			<property name="hibernate.treecache.objectName" value="jboss.cache:service=«isDefaultPersistenceUnitName(unitName) ? name : unitName»TreeCache"/>
			<!-- use_minimal_puts in clustered environment -->
			<property name="hibernate.cache.use_minimal_puts" value="true"/>
	«ENDIF»
	'''
}

def static String persistenceUnitCachePropertiesEclipseLink(Application it, String unitName) {
	'''
	'''
}

def static String persistenceUnitCachePropertiesDataNucleus(Application it, String unitName) {
	'''
	/*TODO: add more cache providers, oscache, swarmcache, ... */
	«IF cacheProvider() == "EhCache"»
			<property name="datanucleus.cache.level2.type" value="ehcache"/>
		/*TODO: check if needed
			<property name="datanucleus.cache.level2.cacheName" value="ehcache"/>
			<property name="datanucleus.cache.level2.configurationFile" value="ehcache.xml"/>
				*/
	«ELSEIF cacheProvider() == "DataNucleusWeak"»
			<property name="datanucleus.cache.level2.type" value="weak"/>
	«ELSEIF cacheProvider() == "DataNucleusSoft"»
			<property name="datanucleus.cache.level2.type" value="soft"/>
	«ENDIF»
	'''
}

def static String persistenceUnitCachePropertiesOpenJpa(Application it, String unitName) {
	'''
	'''
}

def static String persistenceUnitPropertiesOpenJpa(Application it) {
	'''
			<property name="openjpa.Log" value="DefaultLevel=WARN"/>
	'''
}

def static String persistenceUnitTransactionProperties(Application it, String unitName) {
	'''
	«IF isJpaProviderHibernate()»
		«persistenceUnitTransactionPropertiesHibernate(it)(unitName)»
	«ENDIF»
	'''
}

def static String persistenceUnitTransactionPropertiesHibernate(Application it, String unitName) {
	'''
		/*TODO remove
		<property name="hibernate.transaction.factory_class" value="org.hibernate.ejb.transaction.JoinableCMTTransactionFactory"/>
		<property name="javax.persistence.transactionType" value="jta"/>
		<property name="hibernate.transaction.factory_class" value="org.hibernate.transaction.CMTTransactionFactory"/>
		an alternative is: <property name="hibernate.transaction.factory_class" value="org.hibernate.transaction.JTATransactionFactory"/>
		 */
		<!-- «!isSpringDataSourceSupportToBeGenerated()» -->
		«IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss") »
		<property name="hibernate.transaction.manager_lookup_class" value="org.hibernate.transaction.JBossTransactionManagerLookup"/>
		«ENDIF»
	'''
}

def static String persistenceUnitTransactionPropertiesEclipseLink(Application it, String unitName) {
	'''
	'''
}

def static String persistenceUnitTransactionPropertiesDataNucleus(Application it, String unitName) {
	'''
		«IF isEar() && (!isSpringDataSourceSupportToBeGenerated()) »
		<property name="datanucleus.jtaLocator" value="«applicationServer()»"/>
		/*
		<property name="datanucleus.jtaJndiLocation " value="java:/TransactionManager"/>
		 */
 		«ENDIF»
	'''
}

/*extension point for additional configuration of the PersistenceUnit */
def static String persistenceUnitAdditions(Application it, String unitName) {
	'''
	'''
}

def static String persistenceUnitXmlFileTest(Application it) {
	'''
	'''
	fileOutput("META-INF/persistence-test.xml", 'TO_GEN_RESOURCES_TEST', '''
	«persistenceUnitHeader(it)»
	«FOR unitName : modules.reject(e|e.external).collect(e|e.persistenceUnit).toSet()»
		«persistenceUnitContentTest(it)(unitName)»
	«ENDFOR»
	</persistence>
	'''
	)
	'''
	'''
}

def static String persistenceUnitContentTest(Application it, String unitName) {
	'''
	<persistence-unit name="«unitName»">
		<description>JPA configuration for «name» «IF !isDefaultPersistenceUnitName(unitName)»«unitName»«ENDIF»</description>
	    «persistenceUnit(it)(unitName)»
	    «persistenceUnitProvider(it)»
		<!-- annotated classes -->
	    «persistenceUnitAnnotatedClasses(it)(unitName)»
		«IF isJpa2()»
		    «persistenceUnitSharedCacheMode(it)»
		    «persistenceUnitValidationMode(it)»
		«ENDIF»
		<!-- propeties  -->
	    «persistenceUnitPropertiesTest(it)(unitName)»
		/*extension point for additional configuration of the PersistenceUnit */
		<!-- add additional configuration properties by using SpecialCases.xpt "AROUND JPATmpl::persistenceUnitAdditions FOR Application" -->
	    «persistenceUnitAdditions(it)(unitName)»
		</persistence-unit>
	'''
}

def static String persistenceUnitPropertiesTest(Application it, String unitName) {
	'''
	<properties>
	«IF isJpaProviderHibernate()»
		«persistenceUnitPropertiesTestHibernate(it)(unitName)»
	«ELSEIF isJpaProviderEclipseLink()»
		«persistenceUnitPropertiesTestEclipseLink(it)(unitName)»
	«ELSEIF isJpaProviderDataNucleus()»
		«persistenceUnitPropertiesTestDataNucleus(it)(unitName)»
	«ELSEIF isJpaProviderOpenJpa()»
		«persistenceUnitPropertiesTestOpenJpa(it)(unitName)»
	«ENDIF»
	/*extension point for additional configuration of the PersistenceUnit */
	<!-- add additional configuration properties by using SpecialCases.xpt "AROUND JPATmpl::persistenceUnitAdditionalPropertiesTest FOR Application" -->
		«persistenceUnitAdditionalPropertiesTest(it)(unitName)»
	</properties>
	'''
}

def static String persistenceUnitAdditionalPropertiesTest(Application it, String unitName) {
	'''
	«persistenceUnitAdditionalPropertiesTest(it)»
	'''
}

def static String persistenceUnitAdditionalPropertiesTest(Application it) {
	'''
	'''
}

def static String persistenceUnitPropertiesTestHibernate(Application it, String unitName) {
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

def static String persistenceUnitPropertiesTestEclipseLink(Application it, String unitName) {
	'''
		<property name="eclipselink.target-database" value="HSQL"/>
		<property name="eclipselink.ddl-generation" value="create-tables"/>
		<property name="eclipselink.ddl-generation.output-mode" value="database"/>
		<property name="eclipselink.logging.level" value="FINE" />
		<property name="eclipselink.weaving" value="static"/>
	'''
}

def static String persistenceUnitPropertiesTestDataNucleus(Application it, String unitName) {
	'''
			<property name="datanucleus.storeManagerType" value="rdbms"/>
			<property name="datanucleus.jpa.addClassTransformer" value="false"/>
			<property name="datanucleus.autoStartMechanism" value="none"/>
			<property name="datanucleus.autoCreateSchema" value="true"/>
	'''
}

def static String persistenceUnitPropertiesTestOpenJpa(Application it, String unitName) {
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
