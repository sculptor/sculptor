/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.spring

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.camel.CamelTmpl
import org.sculptor.generator.template.common.EhCacheTmpl
import org.sculptor.generator.template.drools.DroolsTmpl
import org.sculptor.generator.template.springint.SpringIntegrationTmpl
import org.sculptor.generator.template.jpa.JPATmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.CommandEvent
import sculptormetamodel.Service

@ChainOverridable
class SpringTmpl {

	@Inject var CamelTmpl camelTmpl
	@Inject var DroolsTmpl droolsTmpl
	@Inject var SpringIntegrationTmpl springIntegrationTmpl
	@Inject var EhCacheTmpl ehcacheTmpl
	@Inject var JPATmpl jpaTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

def String spring(Application it) {
	'''
	«applicationContext(it)»
	«springProperties(it)»
	«generatedSpringProperties(it)»
	«beanRefContext(it)»
	«more(it)»
	«IF isInjectDrools()»
		«droolsTmpl.droolsSupport(it)»
	«ENDIF»
	«IF jpa()»
		«entityManagerFactory(it)»
	«ENDIF»
	«IF isPubSubToBeGenerated()»
		«pubSub(it)»
		«IF getProperty("integration.product") == "camel"»
			«camelTmpl.camelConfig(it)»
		«ELSEIF getProperty("integration.product") == "spring-integration"»
			«springIntegrationTmpl.springIntegrationConfig(it)»
		«ENDIF»
	«ENDIF»
	«interceptor(it)»
	«IF isSpringRemotingToBeGenerated()»
		«springRemoting(it)»
	«ENDIF»

	«IF hasConsumers(it) && isEar()»
		«jms(it)»
	«ENDIF»

	«IF cacheProvider() == "EhCache"»
		«ehcacheTmpl.ehcacheXml(it)»
	«ENDIF»

	«IF isTestToBeGenerated()»
		«applicationContextTest(it)»
		«springPropertiesTest(it)»
		«moreTest(it)»
		«interceptorTest(it)»
		«IF jpa()»
			«IF !isJpaProviderAppEngine()»
				«entityManagerFactoryTest(it)»
			«ENDIF»
			«IF !isJpaProviderAppEngine() || (cacheProvider() == "EhCache")»
				«ehcacheTmpl.ehcacheTestXml(it)»
			«ENDIF»
		«ENDIF»
		«IF isPubSubToBeGenerated()»
			«IF getProperty("integration.product") == "camel"»
				«camelTmpl.camelTestConfig(it)»
			«ELSEIF getProperty("integration.product") == "spring-integration"»
				«springIntegrationTmpl.springIntegrationTestConfig(it)»
			«ENDIF»
		«ENDIF»
	«ENDIF»
	'''
}

def String header(Object it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.springframework.org/schema/beans https://www.springframework.org/schema/beans/spring-beans.xsd">

	'''
}

def String headerWithMoreNamespaces(Object it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:context="http://www.springframework.org/schema/context"
			xmlns:aop="http://www.springframework.org/schema/aop"
			xmlns:jee="http://www.springframework.org/schema/jee"
			xmlns:tx="http://www.springframework.org/schema/tx"
			xmlns:util="http://www.springframework.org/schema/util"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			«headerNamespaceAdditions»
			xsi:schemaLocation="
				http://www.springframework.org/schema/beans
				https://www.springframework.org/schema/beans/spring-beans.xsd
				http://www.springframework.org/schema/context
				https://www.springframework.org/schema/context/spring-context.xsd
				http://www.springframework.org/schema/aop
				https://www.springframework.org/schema/aop/spring-aop.xsd
				http://www.springframework.org/schema/jee
				https://www.springframework.org/schema/jee/spring-jee.xsd
				http://www.springframework.org/schema/tx
				https://www.springframework.org/schema/tx/spring-tx.xsd
				http://www.springframework.org/schema/util
				https://www.springframework.org/schema/util/spring-util.xsd
				«headerSchemaLocationAdditions»">

	'''
}

/*
 * Extension point to generate more namespaces in header.
 */
def String headerNamespaceAdditions(Object it) {
	'''
	'''
}

/*
 * Extension point to generate more schema locations in header.
 */
def String headerSchemaLocationAdditions(Object it) {
	'''
	'''
}

def String applicationContext(Application it) {
	fileOutput(it.getResourceDir("spring") + "applicationContext.xml", OutputSlot.TO_GEN_RESOURCES, '''
	«headerWithMoreNamespaces(it)»
		«serviceContext(it)»

		«springPropertyConfig(it)»

		<!-- import additional spring configuration files -->
		«IF jpa()»
		    <import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("EntityManagerFactory.xml")»"/>
		«ENDIF»
		«IF isPubSubToBeGenerated()»
			<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("pub-sub.xml")»"/>
			«IF getProperty("integration.product") == "camel"»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("camel.xml")»"/>
			«ELSEIF getProperty("integration.product") == "spring-integration"»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("spring-integration.xml")»"/>
			«ENDIF»
		«ENDIF»
		<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("Interceptor.xml")»"/>
		<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("more.xml")»"/>
		«IF it.hasConsumers() && isEar() »
			<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("Jms.xml")»"/>
		«ENDIF»
		«IF isSpringRemotingToBeGenerated()»
			<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("remote-services.xml")»"/>
		«ENDIF»

		«applicationContextAdditions(it)»
	</beans>
	'''
	)
}

/*
 * Extension point to generate more Spring beans to the Spring application context.
 */
def String applicationContextAdditions(Application it) {
	'''
	'''
}


def String applicationContextTest(Application it) {
	fileOutput("applicationContext-test.xml", OutputSlot.TO_GEN_RESOURCES_TEST, '''
	«headerWithMoreNamespaces(it)»
		«serviceContext(it)»

		«springPropertyConfigTest(it)»

		«applicationContextTestImports(it)»
		
		«applicationContextTestAdditions(it)»
	</beans>
	'''
	)
}

def String applicationContextTestImports(Application it) {
	'''
		«IF jpa()»
			«IF isJpaProviderAppEngine()»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("EntityManagerFactory.xml")»"/>
			«ELSE»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("EntityManagerFactory-test.xml")»"/>
			«ENDIF»
		«ENDIF»
		«IF isPubSubToBeGenerated()»
			<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("pub-sub.xml")»"/>
			«IF getProperty("integration.product") == "camel"»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("camel-test.xml")»"/>
			«ELSEIF getProperty("integration.product") == "spring-integration"»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("spring-integration-test.xml")»"/>
			«ENDIF»
		«ENDIF»
		<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("Interceptor-test.xml")»"/>
		<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("more-test.xml")»"/>

	'''
}

/*
 * Extension point to generate more Spring beans to the test Spring application context.
 */
def String applicationContextTestAdditions(Application it) {
	'''
	'''
}

def String springPropertyConfig(Application it) {
	'''
		<context:property-placeholder location="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("generated-spring.properties")», classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("spring.properties")»"/>
	'''
}

def String springPropertyConfigTest(Application it) {
	'''
		<context:property-placeholder location="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("generated-spring.properties")», classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("spring-test.properties")»"/>
	'''
}

def String springProperties(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("spring.properties"), OutputSlot.TO_RESOURCES, '''
	«IF applicationServer() == "jboss"»
		jndi.port=4447
	«ENDIF»
	'''
	)
}

def String springPropertiesTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("spring-test.properties"), OutputSlot.TO_RESOURCES_TEST, '''
	# Spring properties for test
	# datasource provider

	«IF testDbProduct == "mysql"»
		# datasource properties for MySQL
		test.jdbc.driverClassName=com.mysql.jdbc.Driver
		test.jdbc.url=jdbc:mysql://localhost/«name.toFirstLower()»
		test.jdbc.username=«name.toFirstLower()»
		test.jdbc.password=«name.toFirstLower()»123
	«ELSEIF testDbProduct == "hsqldb-inmemory"»
		# datasource properties for HSQLDB
		test.jdbc.driverClassName=org.hsqldb.jdbcDriver
		test.jdbc.url=jdbc:hsqldb:mem:«name.toFirstLower()»
		test.jdbc.username=sa
		test.jdbc.password=
	«ELSEIF testDbProduct == "oracle"»
		# datasource properties for Oracle
		test.jdbc.driverClassName=oracle.jdbc.OracleDriver
		test.jdbc.url=jdbc:oracle:thin:@localhost:1521:XE
		test.jdbc.username=«name.toFirstLower()»
		test.jdbc.password=«name.toFirstLower()»123
	«ELSEIF testDbProduct == "postgresql"»
		# datasource properties for PostgreSQL
		test.jdbc.driverClassName=org.postgresql.Driver
		test.jdbc.url=jdbc:postgresql://localhost/«name.toFirstLower()»
		test.jdbc.username=«name.toFirstLower()»
		test.jdbc.password=«name.toFirstLower()»123
	«ENDIF»
	'''
	)
}

def String generatedSpringProperties(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("generated-spring.properties"), OutputSlot.TO_GEN_RESOURCES, '''
	# Default configuration properties, possible to override in spring.properties
	«IF applicationServer() == "jboss"»
		jndi.port=4447
	«ENDIF»
	«IF getSpringRemotingType() == "rmi" »
		rmiRegistry.port=1199
	«ENDIF»
	«IF isSpringDataSourceSupportToBeGenerated()»
		# datasource provider
		«IF dbProduct == "mysql"»
			# datasource properties for MySQL
			jdbc.driverClassName=com.mysql.jdbc.Driver
			jdbc.url=jdbc:mysql://localhost/«name.toFirstLower()»
			jdbc.username=«name.toFirstLower()»
		«ELSEIF dbProduct == "oracle"»
			# datasource properties for Oracle
			jdbc.driverClassName=oracle.jdbc.OracleDriver
			jdbc.url=jdbc:oracle:thin:@localhost:1521:XE
			jdbc.username=«name.toFirstLower()»
		«ELSEIF dbProduct == "hsqldb-inmemory"»
			# datasource properties for HSQLDB
			jdbc.driverClassName=org.hsqldb.jdbcDriver
			jdbc.url=jdbc:hsqldb:mem:«name.toFirstLower()»
			jdbc.username=sa
		«ELSEIF dbProduct == "postgresql"»
			# datasource properties for PostgreSQL
			jdbc.driverClassName=org.postgresql.Driver
			jdbc.url=jdbc:postgresql://localhost/«name.toFirstLower()»
			jdbc.username=«name.toFirstLower()»
		«ELSE»
			jdbc.driverClassName=
			jdbc.url=
			jdbc.username=
		«ENDIF»
		jdbc.password=
	«ENDIF»
	«IF isInjectDrools()»
		# Drools properties
		drools.rule-source=/CompanyPolicy.xml
		drools.rule-refresh=300
		drools.catch-all-exceptions=false
	«ENDIF»
	«IF it.hasConsumers() && isEar() »
		connectionFactory.jndiName=jms/ConnectionFactory
		invalidMessageDestination.jndiName=queue/«name.toLowerCase()».invalidMessageQueue
		java.naming.factory.initial=org.jboss.naming.remote.client.InitialContextFactory
		java.naming.provider.url=remote://localhost:4447
	«ENDIF»
	«generatedSpringPropertiesAdditions(it)»
	'''
	)
}

/*
 * Extension point to generate more properties to the Spring properties.
 */
def String generatedSpringPropertiesAdditions(Application it) {
	'''
	'''
}

def String serviceContext(Application it) {
	'''

	<!-- activates annotation-based bean configuration -->
	<context:annotation-config/>

	«componentScan(it)»

	«IF isJpaProviderEclipseLink()»
		«loadTimeWeaving(it)»
	«ENDIF»

	'''
}

def String componentScan(Application it) {
	'''
	<!-- scans for @Components, @Repositories, @Services, ... -->
	<context:component-scan base-package="«basePackage»">
		«componentScanExclusionFilter(it)»
	</context:component-scan>
	'''
}

def String componentScanExclusionFilter(Application it) {
	'''
	<context:exclude-filter type="regex" expression=".*web.*"/>
	'''
}

def String loadTimeWeaving(Application it) {
	'''
	<!--
	<context:load-time-weaver/>
	-->
	'''
}

def String more(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("more.xml"), OutputSlot.TO_RESOURCES, '''
	«headerWithMoreNamespaces(it)»
		<!-- Import more custom beans
			<import resource="classpath:/«it.getResourceDir("spring")»moreBeans.xml"/>
		-->
	</beans>
	'''
	)
}

def String moreTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("more-test.xml"), OutputSlot.TO_RESOURCES_TEST, '''
	«headerWithMoreNamespaces(it)»
		<!-- Import more custom beans for test
			<import resource="classpath:/«it.getResourceDir("spring")»moreTestBeans.xml"/>
		-->
	</beans>
	'''
	)
}

def String beanRefContext(Application it) {
	fileOutput("beanRefContext.xml", OutputSlot.TO_GEN_RESOURCES, '''
	«header(it)»
		<bean id="«basePackage»" lazy-init="true"
			class="org.springframework.context.support.GenericXmlApplicationContext">
			<constructor-arg>
				<value>«it.getResourceDir("spring")»applicationContext.xml</value>
			</constructor-arg>
		</bean>
	</beans>
	'''
	)
}

def String interceptor(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("Interceptor.xml"), OutputSlot.TO_GEN_RESOURCES, '''
	«IF isWar()»
		«headerWithMoreNamespaces(it)»
	«ELSE »
		«headerWithMoreNamespaces(it)»
	«ENDIF»

		«aspectjAutoproxy(it)»

		«IF jpa()»
			<bean id="jpaFlushEagerAdvice" class="«fw("persistence.JpaFlushEagerAdvice")»"/>
		«ENDIF»
		«IF nosql()»
			<bean id="errorHandlingAdvice" class="«fw("errorhandling.BasicErrorHandlingAdvice")»"/>
		«ELSE»
			<bean id="errorHandlingAdvice" class="«fw("errorhandling.ErrorHandlingAdvice")»"/>
		«ENDIF»
		«IF isServiceContextToBeGenerated()»
			<bean id="serviceContextStoreAdvice" class="«serviceContextStoreAdviceClass()»"/>
		«ENDIF»
		«IF isInjectDrools()»
			<bean id="droolsAdvice" class="«fw("drools.DroolsAdvice")»">
				<property name="droolsRuleSet" value="${drools.rule-source}"/>
				<property name="updateInterval" value="${drools.rule-refresh}"/>
				<property name="catchAllExceptions" value="${drools.catch-all-exceptions}"/>
			</bean>
		«ENDIF»
	
		«IF isSpringTxAdviceToBeGenerated()»
			«txAdvice(it, false)»
		«ENDIF»
	
		«aopConfig(it) »

		«interceptorAdditions(it)»
	</beans>
	'''
	)
}

/*
 * Extension point to generate more beans to the Spring interceptor chain.
 */
def String interceptorAdditions(Application it) {
	'''
	'''
}

def String aspectjAutoproxy(Application it) {
	'''
	<aop:aspectj-autoproxy/>
	'''
}

def String txAdvice(Application it, boolean isInComment) {
	'''
	<tx:advice id="txAdvice" transaction-manager="txManager">
		<tx:attributes>
			<!-«IF !isInComment»-«ENDIF» all methods starting with 'get' or 'find' are read-only «IF !isInComment»-«ENDIF»->
			<tx:method name="get*" read-only="true"/>
			<tx:method name="find*" read-only="true"/>
			<!-«IF !isInComment»-«ENDIF» all other methods are transactional and ApplicationException will cause rollback «IF !isInComment»-«ENDIF»->
			<tx:method name="*" read-only="false" rollback-for="«applicationExceptionClass()»"/>
		</tx:attributes>
	</tx:advice>
	'''
}

def String aopConfigServicePointcuts(Application it) {
	'''
		<aop:pointcut id="businessService"
			expression="execution(public * «basePackage»..«subPackage("serviceInterface")».*.*(..))"/>
		<aop:pointcut id="readOnlyBusinessService"
			expression="execution(public * «basePackage»..«subPackage("serviceInterface")».*.get*(..)) or execution(public * «basePackage»..«subPackage("serviceInterface")».*.find*(..))"/>
		<!-- Repeating the previous expressions because there's no way to combine existing pointcuts in schema-based Spring AOP. -->
		<aop:pointcut id="updatingBusinessService"
			expression="execution(public * «basePackage»..«subPackage("serviceInterface")».*.*(..)) and not (execution(public * «basePackage»..«subPackage("serviceInterface")».*.get*(..)) or execution(public * «basePackage»..«subPackage("serviceInterface")».*.find*(..)))"/>
	'''	
}

def String aopConfig(Application it) {
	'''
	<aop:config>

		«aopConfigServicePointcuts»

		«IF it.hasConsumers()»
			<aop:pointcut id="messageConsumer"
				expression="execution(public * «basePackage»..«subPackage("consumer")».*.*(..))"/>
		«ENDIF»

		«IF isSpringTxAdviceToBeGenerated()»
			<aop:advisor pointcut-ref="businessService" advice-ref="txAdvice" order="1"/>
		«ENDIF»
		«IF isServiceContextToBeGenerated()»
			<aop:advisor pointcut-ref="businessService" advice-ref="serviceContextStoreAdvice" order="2"/>
		«ENDIF»
		<aop:advisor pointcut-ref="businessService" advice-ref="errorHandlingAdvice" order="3"/>
		«IF jpa()»
			<aop:advisor pointcut-ref="updatingBusinessService" advice-ref="jpaFlushEagerAdvice" order="4"/>
		«ENDIF»

		«IF isInjectDrools()»
			<aop:advisor pointcut-ref="businessService" advice-ref="droolsAdvice" order="5"/>
		«ENDIF»

		«IF it.hasConsumers()»
			«IF isSpringTxAdviceToBeGenerated()»
				<aop:advisor pointcut-ref="messageConsumer" advice-ref="txAdvice" order="1"/>
			«ENDIF»
			«IF isServiceContextToBeGenerated()»
				<aop:advisor pointcut-ref="messageConsumer" advice-ref="serviceContextStoreAdvice" order="2"/>
			«ENDIF»
			<aop:advisor pointcut-ref="messageConsumer" advice-ref="errorHandlingAdvice" order="3"/>
		«ENDIF»

		«aopConfigAdditions(it, false)»
	</aop:config>
	'''
}

def String interceptorTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("Interceptor-test.xml"), OutputSlot.TO_GEN_RESOURCES_TEST, '''
	«headerWithMoreNamespaces(it)»
		<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("Interceptor.xml")»"/>

		«aopConfigTest(it) »

	</beans>
	'''
	)
}

def String aopConfigTest(Application it) {
	'''
	«IF !isWar()»
		<!-- When isWar txAdvice is already included in included Interceptor.xml, but otherwise we need it for testing -->
		<!-- TODO remove
		«txAdvice(it, true) »
		-->
	«ENDIF»

	<aop:config>

		<aop:pointcut id="repository"
			expression="execution(public * «basePackage»..*Repository*.*(..))"/>

		«IF !isWar()»
			<!-- TODO remove
			<aop:advisor pointcut-ref="businessService" advice-ref="txAdvice" order="1"/>
			-->
		«ENDIF»

		<!-- Error handling is needed for repository methods as well because they're used from within unit tests -->
		<aop:advisor pointcut-ref="repository" advice-ref="errorHandlingAdvice" order="3"/>

		«aopConfigAdditions(it, true)»
	</aop:config>
	'''
}

/*
 * Extension point to generate more beans to the Spring AOP configuration (test = true indicates the test environment).
 */
def String aopConfigAdditions(Application it, boolean test) {
	'''
	'''
}

def String testDataSource(Application it) {
	'''
	<bean id="testDataSource" class="com.zaxxer.hikari.HikariDataSource" destroy-method="close">
		<property name="driverClassName" value="${test.jdbc.driverClassName}"/>
		<property name="jdbcUrl" value="${test.jdbc.url}"/>
		<property name="username" value="${test.jdbc.username}"/>
		<property name="password" value="${test.jdbc.password}"/>
		«printProperties("test.dataSource")»
		«testDataSourceAdditions(it)»
	</bean>
	'''
}

/*
 * Extension point to generate more properties in test data source bean.
 */
def String testDataSourceAdditions(Application it) {
	'''
		<!-- override following properties by extending SpringTmpl.testDataSourceAdditions -->
	'''
}

def String dataSource(Application it) {
	'''
	<bean id="dataSource" class="com.zaxxer.hikari.HikariDataSource" destroy-method="close">
		<property name="driverClassName" value="${jdbc.driverClassName}"/>
		<property name="jdbcUrl" value="${jdbc.url}"/>
		<property name="username" value="${jdbc.username}"/>
		<property name="password" value="${jdbc.password}"/>
		«printProperties("dataSource")»
		«dataSourceAdditions(it)»
	</bean>
	'''
}

/*
 * Extension point to generate more properties in data source bean.
 */
def String dataSourceAdditions(Application it) {
	'''
		<!-- override following properties by extending SpringTmpl.dataSourceAdditions -->
	'''
}

def String jms(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("Jms.xml"), OutputSlot.TO_GEN_RESOURCES, '''
	«header(it)»
		«IF isEar() »
			«jndiTemplate(it)»
			«jndiTemplateLocal(it)»
			«jmsQueueConnectionFactory(it)»
			«invalidMessageQueue(it)»
		«ELSE »
			<!-- JMS requires deployment in EAR -->
		«ENDIF»
	</beans>
	'''
	)
}

def String jndiTemplate(Application it) {
	'''
	<bean id="jndiTemplate" class="org.springframework.jndi.JndiTemplate">
		<property name="environment">
			<props>
			    <prop key="java.naming.factory.initial">${java.naming.factory.initial}</prop>
			    <prop key="java.naming.provider.url">${java.naming.provider.url}</prop>
			    <prop key="java.naming.factory.url.pkgs">${java.naming.factory.url.pkgs}</prop>
			</props>
		</property>
	</bean>
	'''
}

def String jndiTemplateLocal(Application it) {
	'''
		<bean id="jndiTemplateLocal" class="org.springframework.jndi.JndiTemplate"/>
	'''
}

def String jmsQueueConnectionFactory(Application it) {
	'''
	<bean id="jmsQueueConnectionFactory"
			class="org.springframework.jndi.JndiObjectFactoryBean">
		<property name="jndiTemplate">
			<ref bean="jndiTemplateLocal"/>
		</property>
		<property name="resourceRef">
			<value type="boolean">false</value>
		</property>
		<property name="jndiName">
			<value>${connectionFactory.jndiName}</value>
		</property>
	</bean>
	'''
}

def String invalidMessageQueue(Application it) {
	'''
		«invalidMessageQueueJmsTemplate(it)»
		«invalidMessageDestination(it)»
	'''
}

def String invalidMessageQueueJmsTemplate(Application it) {
	'''
	<bean id="invalidMessageQueueJmsTemplate"
			class="org.springframework.jms.core.JmsTemplate">
		<property name="connectionFactory">
			<ref bean="jmsQueueConnectionFactory"/>
		</property>
		<property name="defaultDestination">
			<ref bean="invalidMessageDestination"/>
		</property>
	</bean>
	'''
}

def String invalidMessageDestination(Application it) {
	'''
	<bean id="invalidMessageDestination"
		class="org.springframework.jndi.JndiObjectFactoryBean">
		<property name="jndiTemplate">
			<ref bean="jndiTemplateLocal"/>
		</property>
		<property name="jndiName">
			<value>${invalidMessageDestination.jndiName}</value>
		</property>
	</bean>
	'''
}

def String entityManagerFactory(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("EntityManagerFactory.xml"), OutputSlot.TO_GEN_RESOURCES, '''
	«headerWithMoreNamespaces(it)»

		«IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")»
			<jee:jndi-lookup id="entityManagerFactory" jndi-name="java:/«it.persistenceUnitName()»"/>
		«ELSE»
			<!-- Creates a EntityManagerFactory for use with a JPA provider -->
			«IF isJpaProviderAppEngine()»
				<bean id="appEngineEntityManagerFactory" class="«fw("persistence.AppEngineEntityManagerFactory")»"/>
				<bean id="entityManagerFactory" factory-bean="appEngineEntityManagerFactory" factory-method="entityManagerFactory"/>
			«ELSE»
				«IF isSpringDataSourceSupportToBeGenerated()»
					«dataSource(it)»
				«ENDIF»
				«IF entityManagerFactoryType == "scan" && (isJpaProviderHibernate() || isJpaProviderEclipseLink())»
					«IF isJpaProviderHibernate()»
						<bean id="jpaVendorAdapter" class="org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter">
					«ELSEIF isJpaProviderEclipseLink()»
						<bean id="jpaVendorAdapter" class="org.springframework.orm.jpa.vendor.EclipseLinkJpaVendorAdapter"/>
					«ENDIF»
						«printProperties('vendorAdapter')»
					</bean>
				«ENDIF»
				<bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
					«entityManagerFactoryScan(it)»
				</bean>
			«ENDIF»
		«ENDIF»
		«entityManagerFactoryTx(it, false)»
		<!-- add additional beans by extending SpringTmpl.entityManagerFactoryAdditions -->
		«entityManagerFactoryAdditions(it, false)»
	</beans>
	'''
	)
}

def String entityManagerFactoryScan(Application it) {
	var emList=new java.util.Properties();
	var jpaPropList=new java.util.Properties();
	if (isSpringDataSourceSupportToBeGenerated()) {
		emList.put("dataSource", "#REF#dataSource");
	}
	if (entityManagerFactoryType == "scan") {
		emList.put("packagesToScan", basePackage);
		emList.put("persistenceUnitName", persistenceUnitName);
		if (isJpaProviderHibernate() || isJpaProviderEclipseLink()) {
			emList.put("jpaVendorAdapter", "#REF#jpaVendorAdapter");
		} else {
			emList.put("persistenceProvider", jpaProviderClass);
		}

		if (isJpaProviderHibernate()) {
			jpaTmpl.persistenceUnitPropertiesHibernate(it, persistenceUnitName, jpaPropList);
		} else if (isJpaProviderEclipseLink()) {
			jpaTmpl.persistenceUnitPropertiesEclipseLink(it, persistenceUnitName, jpaPropList)
		} else if (isJpaProviderDataNucleus()) {
			jpaTmpl.persistenceUnitPropertiesDataNucleus(it, persistenceUnitName, jpaPropList);
		} else if (isJpaProviderAppEngine()) {
			jpaTmpl.persistenceUnitPropertiesAppEngine(it, persistenceUnitName, jpaPropList);
		} else if (isJpaProviderOpenJpa()) {
			jpaTmpl.persistenceUnitPropertiesOpenJpa(it, persistenceUnitName, jpaPropList);
		}
	} else if (persistenceXml() != "META-INF/persistence.xml") {
		emList.put("persistenceXmlLocation", persistenceXml());
	}
	'''
	«printProperties("entityManagerFactory", emList)»
	«IF getEntityManagerFactoryType() == "scan"»
		<property name="jpaProperties">
			<props>
				«printPropertiesForHash("jpaProperties", jpaPropList)»
			</props>
		</property>
	«ENDIF»
	'''
}

def String entityManagerFactoryTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("EntityManagerFactory-test.xml"), OutputSlot.TO_GEN_RESOURCES_TEST, '''
	«headerWithMoreNamespaces(it)»
		«testDataSource(it)»

		«IF entityManagerFactoryTestType == "scan" && (isJpaProviderHibernate() || isJpaProviderEclipseLink())»
			«IF isJpaProviderHibernate()»
				<bean id="jpaVendorAdapter" class="org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter">
			«ELSEIF isJpaProviderEclipseLink()»
				<bean id="jpaVendorAdapter" class="org.springframework.orm.jpa.vendor.EclipseLinkJpaVendorAdapter"/>
			«ENDIF»
				«printProperties('test.vendorAdapter')»
			</bean>
		«ENDIF»

		<bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
			«entityManagerFactoryTestScan(it)»
		</bean>

		«entityManagerFactoryTx(it, true)»
		<!-- add additional beans by extending SpringTmpl.entityManagerFactoryAdditions -->
		«entityManagerFactoryAdditions(it, true)»
	</beans>
	'''
	)
}

/*
 * Extension point to generate more Spring beans in entity manager factory (test = true indicates the test entity manager factory).
 */
def String entityManagerFactoryAdditions(Application it, boolean test) {
	'''
	'''
}

def String entityManagerFactoryTestScan(Application it) {
	var emList=new java.util.Properties();
	var jpaPropList=new java.util.Properties();
	emList.put("dataSource", "#REF#testDataSource");
	if (entityManagerFactoryTestType == "scan") {
		emList.put("packagesToScan", basePackage);
		emList.put("persistenceUnitName", persistenceUnitName);
		if (isJpaProviderHibernate() || isJpaProviderEclipseLink()) {
			emList.put("jpaVendorAdapter", "#REF#jpaVendorAdapter");
		} else {
			emList.put("persistenceProvider", jpaProviderClass);
		}

		if (isJpaProviderHibernate()) {
			jpaTmpl.persistenceUnitPropertiesTestHibernate(it, null, jpaPropList);
		} else if (isJpaProviderEclipseLink()) {
			jpaTmpl.persistenceUnitPropertiesTestEclipseLink(it, null, jpaPropList);
		} else if (isJpaProviderDataNucleus()) {
			jpaTmpl.persistenceUnitPropertiesTestDataNucleus(it, null, jpaPropList);
		} else if (isJpaProviderOpenJpa()) {
			jpaTmpl.persistenceUnitPropertiesTestOpenJpa(it, null, jpaPropList);
		}
	} else {
		emList.put("persistenceXmlLocation", "classpath:META-INF/persistence-test.xml");
	}

	'''
	«printProperties("test.entityManagerFactory", emList)»
	«IF getEntityManagerFactoryTestType() == "scan"»
		<property name="jpaProperties">
			<props>
				«printPropertiesForHash("test.jpaProperties", jpaPropList)»
			</props>
		</property>
	«ENDIF»
	'''
}


def String entityManagerFactoryTx(Application it, boolean test) {
	'''
	«IF isWar() || test || (isSpringDataSourceSupportToBeGenerated() && applicationServer() != "jboss")»
		«jpaTxManager(it)»
	«ELSE»
		«jtaTxManager(it)»
	«ENDIF»

	«IF isSpringAnnotationTxToBeGenerated()»
		<!-- enables @Transactional support -->
		<tx:annotation-driven transaction-manager="txManager" order="1"/>
	«ENDIF»
	«persistenceExceptionTranslationPostProcessor(it)»
	'''
}

def String persistenceExceptionTranslationPostProcessor(Application it) {
	'''
	«IF !isJpaProviderAppEngine()»
		<!--
		  TODO: Problem when using jndi lookup of persistent unit, instead of LocalContainerEntityManagerFactoryBean.
		  PersistenceExceptionTranslationPostProcessor needs a PersistenceExceptionTranslator, e.g. LocalContainerEntityManagerFactoryBean
		-->
		«IF !isEar()»
			<bean class="org.springframework.dao.annotation.PersistenceExceptionTranslationPostProcessor"/>
		«ENDIF»
	«ENDIF»
	'''
}

def String jpaTxManager(Application it) {
	'''
	<bean id="txManager" class="org.springframework.orm.jpa.JpaTransactionManager">
		<property name="entityManagerFactory" ref="entityManagerFactory"/>
	</bean>
	'''
}

def String jtaTxManager(Application it) {
	'''
	<tx:jta-transaction-manager/>
	<alias name="transactionManager" alias="txManager"/>
	'''
}

def String pubSub(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("pub-sub.xml"), OutputSlot.TO_GEN_RESOURCES, '''
	«header(it)»
		<bean id="publishAdvice" class="«fw("event.annotation.PublishAdvice")»"/>

		<bean id="subscribeBeanPostProcessor" class="«fw("event.annotation.SubscribeBeanPostProcessor")»"/>

		«simpleEventBus(it)»
		«IF getAllDomainObjects(it).exists(e|e instanceof CommandEvent)»
			«simpleCommandBus(it)»
		«ENDIF»
	</beans>
	'''
	)
}

def String simpleEventBus(Application it) {
	'''
	<bean id="simpleEventBusImpl" class="«fw("event.SimpleEventBusImpl")»"/>
	<alias name="simpleEventBusImpl" alias="eventBus"/>
	'''
}

def String simpleCommandBus(Application it) {
	'''
	<bean id="simpleCommandBusImpl" class="«fw("event.SimpleEventBusImpl")»">
		<constructor-arg value="true"/>
	</bean>
	<alias name="simpleCommandBusImpl" alias="commandBus"/>
	'''
}

def String springRemoting(Application it) {
	val remoteServices = it.getAllServices().filter(e|e.remoteInterface)
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("remote-services.xml"), OutputSlot.TO_GEN_RESOURCES, '''
	«header(it)»
		«IF getSpringRemotingType() == "rmi"»
			«remoteServices .map[rmiServiceExporter(it)]»
		«ELSEIF getSpringRemotingType() == "httpinvoker"»
			«remoteServices .map[httpInvokerServiceExporter(it)]»
		«ELSEIF getSpringRemotingType() == "hessian"»
			«remoteServices .map[hessianServiceExporter(it)]»
		«ENDIF»		
	</beans>
	'''
	)
}

def String rmiServiceExporter(Service it) {
	'''
	<bean class="org.springframework.remoting.rmi.RmiServiceExporter">
		<property name="serviceName" value="«module.application.name»/«name.toFirstLower()»"/>
		<property name="service" ref="«name.toFirstLower()»"/>
		<property name="serviceInterface" value="«it.getServiceapiPackage()».«name»"/>
		<property name="registryPort" value="${rmiRegistry.port}"/>
	</bean>
	'''
}

def String hessianServiceExporter(Service it) {
	'''
		«serviceExporter(it, "org.springframework.remoting.caucho.HessianExporter")»
	'''
}

def String httpInvokerServiceExporter(Service it) {
	'''
		«serviceExporter(it, "org.springframework.remoting.httpinvoker.HttpInvokerServiceExporter")»
	'''
}

def String serviceExporter(Service it, String exporterClass) {
	'''
	<bean name="«name.toFirstLower()»Exporter" class="«exporterClass»">
		<property name="service" ref="«name.toFirstLower()»"/>
		<property name="serviceInterface" value="«it.getServiceapiPackage()».«name»"/>
	</bean>
	<!-- You need to define corresponding servlet in web.xml -->
	<!--
	<servlet>
		<servlet-name>«name.toFirstLower()»Exporter</servlet-name>
		<servlet-class>org.springframework.web.context.support.HttpRequestHandlerServlet</servlet-class>
	</servlet>
	<servlet-mapping>
		<servlet-name>«name.toFirstLower()»Exporter</servlet-name>
		<url-pattern>/remoting/«name»</url-pattern>
	</servlet-mapping>
	-->
	'''
}

}
