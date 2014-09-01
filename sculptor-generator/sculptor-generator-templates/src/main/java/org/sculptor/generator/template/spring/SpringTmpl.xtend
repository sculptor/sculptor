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
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.camel.CamelTmpl
import org.sculptor.generator.template.common.EhCacheTmpl
import org.sculptor.generator.template.drools.DroolsTmpl
import org.sculptor.generator.template.springint.SpringIntegrationTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.CommandEvent
import sculptormetamodel.Enum
import sculptormetamodel.Module
import sculptormetamodel.Service
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class SpringTmpl {

	@Inject private var CamelTmpl camelTmpl
	@Inject private var DroolsTmpl droolsTmpl
	@Inject private var SpringIntegrationTmpl springIntegrationTmpl
	@Inject private var EhCacheTmpl ehcacheTmpl

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
			xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd">

	'''
}

def String headerWithMoreNamespaces(Object it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:aop="http://www.springframework.org/schema/aop"
			xmlns:tx="http://www.springframework.org/schema/tx"
			xmlns:jee="http://www.springframework.org/schema/jee"
			xmlns:context="http://www.springframework.org/schema/context"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			«headerNamespaceAdditions»
			xsi:schemaLocation="
				http://www.springframework.org/schema/beans
				http://www.springframework.org/schema/beans/spring-beans.xsd
				http://www.springframework.org/schema/context
				http://www.springframework.org/schema/context/spring-context.xsd
				http://www.springframework.org/schema/aop
				http://www.springframework.org/schema/aop/spring-aop.xsd
				http://www.springframework.org/schema/jee
				http://www.springframework.org/schema/jee/spring-jee.xsd
				http://www.springframework.org/schema/tx
				http://www.springframework.org/schema/tx/spring-tx.xsd
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
	fileOutput(it.getResourceDir("spring") + "applicationContext.xml", OutputSlot::TO_GEN_RESOURCES, '''
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
	fileOutput("applicationContext-test.xml", OutputSlot::TO_GEN_RESOURCES_TEST, '''
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
		<bean id="springPropertyConfig" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
			<property name="locations">
				<list>
					<value>classpath:/«it.getResourceDir("spring")»generated-spring.properties</value>
					<value>classpath:/«it.getResourceDir("spring")»spring.properties</value>
				</list>
			</property>
		</bean>
	'''
}

def String springPropertyConfigTest(Application it) {
	'''
		<bean id="springPropertyConfig" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
			<property name="locations">
				<list>
					<value>classpath:/«it.getResourceDir("spring")»generated-spring.properties</value>
					<value>classpath:/«it.getResourceDir("spring")»spring-test.properties</value>
				</list>
			</property>
		</bean>
	'''
}

def String springProperties(Application it) {
	fileOutput(it.getResourceDir("spring") + "spring.properties", OutputSlot::TO_RESOURCES, '''
	«IF applicationServer() == "jboss"»
		jndi.port=4447
	«ENDIF»
	'''
	)
}

def String springPropertiesTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("spring-test.properties"), OutputSlot::TO_RESOURCES_TEST, '''
	# Spring properties for test
	'''
	)
}

def String generatedSpringProperties(Application it) {
	fileOutput(it.getResourceDir("spring") + "generated-spring.properties", OutputSlot::TO_GEN_RESOURCES, '''
	# Default configuration properties, possible to override in spring.properties
	«IF applicationServer() == "jboss"»
		jndi.port=4447
	«ENDIF»
	«IF getSpringRemotingType() == "rmi" »
		rmiRegistry.port=1199
	«ENDIF»
	«IF isSpringDataSourceSupportToBeGenerated()»
		# datasource provider
		jdbc.dataSourceClassName=org.apache.commons.dbcp.BasicDataSource
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
	<context:annotation-config />

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
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("more.xml"), OutputSlot::TO_RESOURCES, '''
	«headerWithMoreNamespaces(it)»
		<!-- Import more custom beans
			<import resource="classpath:/«it.getResourceDir("spring")»moreBeans.xml"/>
		-->
	</beans>
	'''
	)
}

def String moreTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("more-test.xml"), OutputSlot::TO_RESOURCES_TEST, '''
	«headerWithMoreNamespaces(it)»
		<!-- Import more custom beans for test
			<import resource="classpath:/«it.getResourceDir("spring")»moreTestBeans.xml"/>
		-->
	</beans>
	'''
	)
}

def String beanRefContext(Application it) {
	fileOutput("beanRefContext.xml", OutputSlot::TO_GEN_RESOURCES, '''
	«header(it)»
		<bean id="«basePackage»" lazy-init="true"
			class="org.springframework.context.support.ClassPathXmlApplicationContext">
			<constructor-arg>
				<value>«it.getResourceDir("spring")»applicationContext.xml</value>
			</constructor-arg>
		</bean>
	</beans>
	'''
	)
}

def String interceptor(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("Interceptor.xml"), OutputSlot::TO_GEN_RESOURCES, '''
	«IF isWar()»
		«headerWithMoreNamespaces(it)»
	«ELSE »
		«headerWithMoreNamespaces(it)»
	«ENDIF»

		«aspectjAutoproxy(it)»
	
		«IF jpa()»
			«jpaInterceptor(it) »
		«ENDIF»
	
		«IF nosql()»
			<bean id="errorHandlingAdvice" class="«fw("errorhandling.BasicErrorHandlingAdvice")»" />
		«ELSE»
			<bean id="errorHandlingAdvice" class="«fw("errorhandling.ErrorHandlingAdvice")»" />
		«ENDIF»
		«IF isJpaProviderHibernate()»
			<bean id="hibernateErrorHandlingAdvice" class="«fw("errorhandling.HibernateErrorHandlingAdvice")»" />
		«ELSEIF isValidationAnnotationToBeGenerated()»
			<bean id="hibernateValidatorErrorHandlingAdvice" class="«fw("errorhandling.HibernateValidatorErrorHandlingAdvice")»" />
		«ENDIF»
		«IF isServiceContextToBeGenerated()»
			<bean id="serviceContextStoreAdvice" class="«serviceContextStoreAdviceClass()»" />
		«ENDIF»
		«IF isInjectDrools()»
			<bean id="droolsAdvice" class="«fw('drools.DroolsAdvice')»">
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

def String jpaInterceptor(Application it) {
	'''
	<bean id="jpaInterceptorFlushEager" class="org.springframework.orm.jpa.JpaInterceptor">
		<property name="entityManagerFactory" ref="entityManagerFactory"/>
		<!-- Need to flush to detect OptimisticLockingException and do proper rollback. -->
		<property name="flushEager" value="true"/>
	</bean>
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
		<!-- Repeating the expression, since I can't find a way to refer to the other pointcuts. -->
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
			<aop:advisor pointcut-ref="businessService" advice-ref="txAdvice" order="1" />
		«ENDIF»
		«IF isServiceContextToBeGenerated()»
			<aop:advisor pointcut-ref="businessService" advice-ref="serviceContextStoreAdvice" order="2" />
		«ENDIF»
		<aop:advisor pointcut-ref="businessService" advice-ref="errorHandlingAdvice" order="3" />
		«IF isJpaProviderHibernate()»
			<aop:advisor pointcut-ref="businessService" advice-ref="hibernateErrorHandlingAdvice" order="4" />
		«ELSEIF isValidationAnnotationToBeGenerated()»
			<aop:advisor pointcut-ref="businessService" advice-ref="hibernateValidatorErrorHandlingAdvice" order="4" />
		«ENDIF»
		«IF jpa()»
			<aop:advisor pointcut-ref="updatingBusinessService" advice-ref="jpaInterceptorFlushEager" order="5" />
		«ENDIF»

		«IF isInjectDrools()»
			<aop:advisor pointcut-ref="businessService" advice-ref="droolsAdvice" order="6" />
		«ENDIF»

		«IF it.hasConsumers()»
			«IF isSpringTxAdviceToBeGenerated()»
				<aop:advisor pointcut-ref="messageConsumer" advice-ref="txAdvice" order="1" />
			«ENDIF»
			«IF isServiceContextToBeGenerated()»
				<aop:advisor pointcut-ref="messageConsumer" advice-ref="serviceContextStoreAdvice" order="2" />
			«ENDIF»
			<aop:advisor pointcut-ref="messageConsumer" advice-ref="errorHandlingAdvice" order="3" />
			«IF isJpaProviderHibernate()»
				<aop:advisor pointcut-ref="messageConsumer" advice-ref="hibernateErrorHandlingAdvice" order="4" />
			«ELSEIF isValidationAnnotationToBeGenerated()»
				<aop:advisor pointcut-ref="messageConsumer" advice-ref="hibernateValidatorErrorHandlingAdvice" order="4" />
			«ENDIF»
		«ENDIF»

		«aopConfigAdditions(it, false)»
	</aop:config>
	'''
}

def String interceptorTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("Interceptor-test.xml"), OutputSlot::TO_GEN_RESOURCES_TEST, '''
	«headerWithMoreNamespaces(it)»
		<import resource="classpath:/«it.getResourceDir("spring")»Interceptor.xml"/>

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
			<aop:advisor pointcut-ref="businessService" advice-ref="txAdvice" order="1" />
			-->
		«ENDIF»

		<!-- Need this when JUnit directly to Repository -->
		<aop:advisor pointcut-ref="repository" advice-ref="errorHandlingAdvice" order="3" />
		«IF isJpaProviderHibernate()»
			<aop:advisor pointcut-ref="repository" advice-ref="hibernateErrorHandlingAdvice" order="4" />
		«ELSEIF isValidationAnnotationToBeGenerated()»
			<aop:advisor pointcut-ref="repository" advice-ref="hibernateValidatorErrorHandlingAdvice" order="4" />
		«ENDIF»

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

def String sessionFactory(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("SessionFactory.xml"), OutputSlot::TO_GEN_RESOURCES, '''
	«IF dbProduct == "hsqldb-inmemory" && !isSpringDataSourceSupportToBeGenerated()»
		«sessionFactoryInMemory(it, false)»
	«ELSE»
	«header(it)»
		«IF isWar() »
			«txManager(it)»
		«ENDIF»

		«IF isSpringDataSourceSupportToBeGenerated()»
			«dataSource(it)»
		«ENDIF»

		«IF isJpaAnnotationToBeGenerated()»
			<bean id="sessionFactory" class="org.springframework.orm.hibernate3.annotation.AnnotationSessionFactoryBean">
				<property name="configLocation" value="hibernate.cfg.xml"/>
		«ENDIF»
			<property name="entityInterceptor">
				<ref bean="auditInterceptor" />
			</property>
			«IF isSpringDataSourceSupportToBeGenerated()»
				<property name="dataSource" ref="dataSource"/>
			«ENDIF»
			<!-- add additional configurations by extending SpringTmpl::sessionFactoryAdditions -->
			«sessionFactoryAdditions(it)»
		</bean>
		«IF isAuditableToBeGenerated()»
			<bean id="auditInterceptor" class="«auditInterceptorClass()»"/>
		«ENDIF»
	</beans>

	«ENDIF»
	'''
	)
}

/*extension point for adding additional configuration */
def String sessionFactoryAdditions(Application it) {
	'''
	'''
}

def String txManager(Application it) {
	'''
	<bean id="txManager" class="org.springframework.orm.hibernate3.HibernateTransactionManager">
		<property name="sessionFactory" ref="sessionFactory" />
	</bean>
	'''
}

def String sessionFactoryTest(Application it) {
	fileOutput(it.getResourceDir("spring") + "SessionFactory-test.xml", OutputSlot::TO_GEN_RESOURCES_TEST, '''
	«sessionFactoryInMemory(it, true)»
	'''
	)
}

def String sessionFactoryInMemory(Application it, boolean test) {
	'''
	«header(it)»

		«IF isWar() »
			«txManager(it)»
		«ENDIF»

		«hsqldbDataSource(it)»

		«IF isJpaAnnotationToBeGenerated()»
			<bean id="sessionFactory" class="org.springframework.orm.hibernate3.annotation.AnnotationSessionFactoryBean">
				<property name="dataSource" ref="hsqldbDataSource"/>
				«IF test»
					<property name="configLocation" value="hibernate-test.cfg.xml"></property>
				«ELSE»
					<property name="configLocation" value="hibernate.cfg.xml"></property>
				«ENDIF»
				<!-- add additional configuration by aop -->
				«additionalSessionFactoryPropertiesTest(it)»
		«ENDIF»
	
			<property name="entityInterceptor">
				<ref bean="auditInterceptor" />
			</property>
		</bean>
		«IF isAuditableToBeGenerated()»
			<bean id="auditInterceptor" class="«auditInterceptorClass()»"/>
		«ENDIF»

	</beans>
	'''
}

/*extension point for adding additional configuration by aop */
def String additionalSessionFactoryPropertiesTest(Application it) {
	'''
	'''
}

def String hsqldbDataSource(Application it) {
	'''
	<bean id="hsqldbDataSource" class="org.apache.commons.dbcp.BasicDataSource">
		<property name="driverClassName" value="org.hsqldb.jdbcDriver"/>
		<property name="url" value="jdbc:hsqldb:mem:«name.toFirstLower()»"/>
		<property name="username" value="sa"/>
		<property name="password" value=""/>
	</bean>
	'''
}

def String dataSource(Application it) {
	'''
	<bean id="dataSource" class="${jdbc.dataSourceClassName}">
		<property name="driverClassName" value="${jdbc.driverClassName}"/>
		<property name="url" value="${jdbc.url}"/>
		<property name="username" value="${jdbc.username}"/>
		<property name="password" value="${jdbc.password}"/>
		<!-- add additional properties by extending SpringTmpl::dataSourceAdditions -->
		«dataSourceAdditions(it)»
	</bean>
	'''
}

/*
 * Extension point to generate more properties in data source bean.
 */
def String dataSourceAdditions(Application it) {
	'''
	'''
}

def String hibernateResource(Module it) {
	'''
	«IF !domainObjects.filter[e | e instanceof Enum].isEmpty »
		«hibernateEnumTypedefResource(it)»
	«ENDIF»
	'''
}

def String hibernateEnumTypedefResource(Module it) {
	'''
	<value>«it.getResourceDirModule("hibernate")»«it.getEnumTypeDefFileName()»</value>
	'''
}

def String jms(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("Jms.xml"), OutputSlot::TO_GEN_RESOURCES, '''
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
		<bean id="jndiTemplateLocal" class="org.springframework.jndi.JndiTemplate" />
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
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("EntityManagerFactory.xml") , OutputSlot::TO_GEN_RESOURCES, '''
	«headerWithMoreNamespaces(it)»

		«IF isEar() && (!isSpringDataSourceSupportToBeGenerated() || applicationServer() == "jboss")»
			<jee:jndi-lookup id="entityManagerFactory" jndi-name="java:/«it.persistenceUnitName()»"/>
		«ELSE»
			<!-- Creates a EntityManagerFactory for use with a JPA provider -->
			«IF isJpaProviderAppEngine()»
				<bean id="appEngineEntityManagerFactory" class="«fw("persistence.AppEngineEntityManagerFactory")»" />
				<bean id="entityManagerFactory" factory-bean="appEngineEntityManagerFactory" factory-method="entityManagerFactory" />
			«ELSE»
				«IF isSpringDataSourceSupportToBeGenerated()»
					«dataSource(it)»
				«ENDIF»
				<bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
					«IF isSpringDataSourceSupportToBeGenerated()»
						<property name="dataSource" ref="dataSource"/>
					«ENDIF»
					«IF persistenceXml() != "META-INF/persistence.xml"»
						<property name="persistenceXmlLocation" value="«persistenceXml()»"/>
					«ENDIF»
				</bean>
			«ENDIF»
		«ENDIF»
		«entityManagerFactoryTx(it, false)»
		<!-- add additional beans by extending SpringTmpl::entityManagerFactoryAdditions -->
		«entityManagerFactoryAdditions(it, false)»
	</beans>
	'''
	)
}

def String entityManagerFactoryTest(Application it) {
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("EntityManagerFactory-test.xml") , OutputSlot::TO_GEN_RESOURCES_TEST, '''
	«headerWithMoreNamespaces(it)»
		«hsqldbDataSource(it)»

		<!-- Creates a EntityManagerFactory for use with the Hibernate JPA provider -->
		<bean id="entityManagerFactory" class="org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean">
			<property name="dataSource" ref="hsqldbDataSource"/>
			<property name="persistenceXmlLocation" value="META-INF/persistence-test.xml"/>
			«IF isJpaProviderEclipseLink()»
				<property name="jpaVendorAdapter" ref="jpaVendorAdapter"/>
			«ENDIF»
		</bean>
	
		«IF isJpaProviderEclipseLink()»
		<bean id="jpaVendorAdapter" class="org.springframework.orm.jpa.vendor.EclipseLinkJpaVendorAdapter">
			<property name="databasePlatform" value="org.eclipse.persistence.platform.database.HSQLPlatform" />
			<property name="showSql" value="true" />
			<property name="generateDdl" value="true" />
		</bean>
		«ENDIF»
		«entityManagerFactoryTx(it, true)»
		<!-- add additional beans by extending SpringTmpl::entityManagerFactoryAdditions -->
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

def String entityManagerFactoryTx(Application it, boolean test) {
	'''
	«IF isWar() || test || (isSpringDataSourceSupportToBeGenerated() && applicationServer() != "jboss")»
		«jpaTxManager(it)»
	«ELSE»
		«jtaTxManager(it)»
	«ENDIF»

	«IF isSpringAnnotationTxToBeGenerated()»
		<!-- enables @Transactional support -->
		<tx:annotation-driven transaction-manager="txManager"/>
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
		<property name="entityManagerFactory" ref="entityManagerFactory" />
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
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("pub-sub.xml"), OutputSlot::TO_GEN_RESOURCES, '''
	«header(it)»
		<bean id="publishAdvice" class="«fw("event.annotation.PublishAdvice")»" />

		<bean id="subscribeBeanPostProcessor" class="«fw("event.annotation.SubscribeBeanPostProcessor")»" />

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
	<bean id="simpleEventBusImpl" class="«fw("event.SimpleEventBusImpl")»" />
	<alias name="simpleEventBusImpl" alias="eventBus" />
	'''
}

def String simpleCommandBus(Application it) {
	'''
	<bean id="simpleCommandBusImpl" class="«fw("event.SimpleEventBusImpl")»" >
		<constructor-arg value="true" />
	</bean>
	<alias name="simpleCommandBusImpl" alias="commandBus" />
	'''
}

def String springRemoting(Application it) {
	val remoteServices = it.getAllServices().filter(e|e.remoteInterface)
	fileOutput(it.getResourceDir("spring") + it.getApplicationContextFile("remote-services.xml"), OutputSlot::TO_GEN_RESOURCES, '''
	«header(it)»
		«IF getSpringRemotingType() == "rmi"»
			«remoteServices .map[rmiServiceExporter(it)]»
		«ELSEIF getSpringRemotingType() == "httpinvoker"»
			«remoteServices .map[httpInvokerServiceExporter(it)]»
		«ELSEIF getSpringRemotingType() == "hessian"»
			«remoteServices .map[hessianServiceExporter(it)]»
		«ELSEIF getSpringRemotingType() == "burlap"»
			«remoteServices .map[burlapServiceExporter(it)]»
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

def String burlapServiceExporter(Service it) {
	'''
		«serviceExporter(it, "org.springframework.remoting.caucho.BurlapExporter")»
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
