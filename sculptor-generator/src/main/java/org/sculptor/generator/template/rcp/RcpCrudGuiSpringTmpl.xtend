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

class RcpCrudGuiSpringTmpl {



def static String spring(GuiApplication it) {
	'''
	«applicationContext(it)»
	«applicationContextStub(it)»
	«more(it)»
	«moreTest(it)»
	«generatedSpringProperties(it)»
		«springProperties(it)»

		«richObjectAll(it)»

	«serviceRemoteAll(it)»
	«serviceStubAll(it)»

	«it.modules.forEach[richObjectModule(it)]»

	'''
}

def static String header(Object it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">
	'''
}

def static String headerWithMoreNamespaces(Object it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:aop="http://www.springframework.org/schema/aop"
	xmlns:tx="http://www.springframework.org/schema/tx"
	xmlns:context="http://www.springframework.org/schema/context"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd http://www.springframework.org/schema/aop http://www.springframework.org/schema/aop/spring-aop-2.5.xsd http://www.springframework.org/schema/tx http://www.springframework.org/schema/tx/spring-tx-2.5.xsd http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-2.5.xsd">
	'''
}

def static String applicationContext(GuiApplication it) {
	'''
	'''
	fileOutput("applicationContext.xml", 'TO_GEN_RESOURCES', '''
	«headerWithMoreNamespaces(it)»
	<import resource="RichObject-all.xml"/>
		<import resource="Service-remote-all.xml"/>

	«annotationScan(it)»
		«IF isServiceContextToBeGenerated()»
			«serviceContextFactoryBean(it)»
		«ENDIF»

		«messageSourceBean(it)»
		«springPropertyConfig(it)»

		<import resource="more.xml"/>
	</beans>
	'''
	)
	'''
	'''
}

def static String applicationContextStub(GuiApplication it) {
	'''
	'''
	fileOutput("applicationContext-stub.xml", 'TO_GEN_RESOURCES', '''
	«headerWithMoreNamespaces(it)»
	<import resource="RichObject-all.xml"/>

	«annotationScanStub(it)»
		«IF isServiceContextToBeGenerated()»
			«serviceContextFactoryBean(it)»
		«ENDIF»

		«messageSourceBean(it)»
		«springPropertyConfig(it)»

		<import resource="more.xml"/>
	</beans>
	'''
	)
	'''
	'''
}

def static String springPropertyConfig(GuiApplication it) {
	'''
		<bean id="springPropertyConfig" class="org.springframework.beans.factory.config.PropertyPlaceholderConfigurer">
		<property name="locations">
			<list>
	      <value>classpath:generated-spring.properties</value>
	      <value>classpath:spring.properties</value>
				</list>
		</property>
		</bean>
	'''
}

def static String springProperties(GuiApplication it) {
	'''
	'''
	fileOutput("spring.properties", 'TO_RESOURCES', '''
	# Here you can overwrite properties defined in
	# generated-spring.properties.

	«IF getSpringRemotingType() == "rmi"»
	rmiUrl=rmi://localhost:1199
	«ELSEIF getSpringRemotingType() == "hessian"»
	hessianUrl=http://localhost:8888/remoting
	«ELSEIF getSpringRemotingType() == "burlap"»
	burlapUrl=http://localhost:8888/remoting
	«ELSEIF getSpringRemotingType() == "httpinvoker"»
	httpInvokerUrl=http://localhost:8888/remoting
	«ENDIF»


	'''
	)
	'''
	'''
}

def static String generatedSpringProperties(GuiApplication it) {
	'''
	'''
	fileOutput("generated-spring.properties", 'TO_GEN_RESOURCES', '''
	rmiUrl=rmi://localhost:1199

	'''
	)
	'''
	'''
}

def static String messageSourceBean(GuiApplication it) {
	'''
		<bean id="messageSource" class="org.springframework.context.support.ResourceBundleMessageSource">
			<property name="basenames">
			<list>
				<value>i18n/messages</value>
				«FOR module  : modules»
				<value>i18n/«module.name»Messages</value>
				«ENDFOR»
				<value>org/hibernate/validator/resources/DefaultValidatorMessages</value>
			</list>
			</property>
		</bean>
	'''
}

def static String more(GuiApplication it) {
	'''
	'''
	fileOutput("more.xml", 'TO_RESOURCES', '''
	«header(it)»
		<!-- Import more custom beans
		<import resource="moreBeans.xml"/>
		-->

	</beans>
	'''
	)
	'''
	'''
}

def static String moreTest(GuiApplication it) {
	'''
	'''
	fileOutput("more-test.xml", 'TO_RESOURCES_TEST', '''
	«header(it)»
		<!-- Import more custom beans for test
		<import resource="moreTestBeans.xml"/>
		-->

	</beans>
	'''
	)
	'''
	'''
}



def static String richObjectAll(GuiApplication it) {
	'''
	'''
	fileOutput("RichObject-all.xml", 'TO_GEN_RESOURCES', '''
	«header(it)»
		«FOR m : modules»<import resource="RichObject-«m.name».xml"/>«ENDFOR»
	</beans>
	'''
	)
	'''
	'''
}

def static String serviceContextFactoryBean(GuiApplication it) {
	'''
	<bean id="serviceContextFactory"
				class="«fw("richclient.errorhandling.RichServiceContextFactoryImpl")»">
			<property name="applicationId" value="«name»"/>
		</bean>
	'''
}

def static String serviceRemoteAll(GuiApplication it) {
	'''
	«val allUsedServices = it.groupByTarget().getUsedServices().toSet().typeSelect(Service)»
	«val allUsedServiceModules = it.allUsedServices.module.toSet().typeSelect(Module)»
	«FOR m : allUsedServiceModules»
		«serviceRemoteModule(it)(allUsedServices.filter(e | e.module == m)) FOR m»
	«ENDFOR»

	'''
	fileOutput("Service-remote-all.xml", 'TO_GEN_RESOURCES', '''
	«headerWithMoreNamespaces(it)»
	«contextClassLoaderBean(it)»
	«contextClassLoaderAdviceBean(it)»
	«aopConfig(it)(allUsedServices)»

		«FOR m : allUsedServiceModules»<import resource="Service-remote-«m.name».xml"/>«ENDFOR»
	</beans>
	'''
	)
	'''

	'''
}

def static String contextClassLoaderBean(GuiApplication it) {
	'''
		<bean id="contextClassLoader"
		class="«getRichClientPackage()».ContextClassLoaderFactory"
		factory-method="getClassLoader">
	</bean>
	'''
}

def static String contextClassLoaderAdviceBean(GuiApplication it) {
	'''
	<bean id="contextClassLoaderAdvice"
		class="«fw("richclient.util.ContextClassLoaderAdvice")»">
		<property name="classLoader">
				<ref bean="contextClassLoader"/>
			</property>
	</bean>
	'''
}

def static String aopConfig(GuiApplication it, List[Service] allUsedServices) {
	'''
	<aop:config>
		<aop:pointcut id="servicePointcut"
			expression="«FOR service SEPARATOR ' || ' : allUsedServices»bean(«service.name.toFirstLower()»)«ENDFOR»" />

		<aop:advisor advice-ref="contextClassLoaderAdvice" order="1"
			pointcut-ref="servicePointcut" />

	</aop:config>
	'''
}

def static String serviceStubAll(GuiApplication it) {
	'''
	«val allUsedServices = it.groupByTarget().getUsedServices().toSet().typeSelect(Service)»
	«val allUsedServiceModules = it.allUsedServices.module.toSet().typeSelect(Module)»
	«FOR m : allUsedServiceModules»
		«serviceStubModule(it)(allUsedServices.filter(e | e.module == m)) FOR m»
	«ENDFOR»

	'''
	fileOutput("Service-stub-all.xml", 'TO_GEN_RESOURCES', '''
	«header(it)»
		«FOR m : allUsedServiceModules»<import resource="Service-stub-«m.name».xml"/>«ENDFOR»
	</beans>
	'''
	)
	'''
	'''
}

def static String richObjectModule(GuiModule it) {
	'''
	'''
	fileOutput("RichObject-" + name + ".xml", 'TO_GEN_RESOURCES', '''
	«header(it)»
	«FOR group : groupByTarget()»
	«richObjectFactoryBean(it) FOR group»
	«ENDFOR»

	</beans>
	'''
	)
	'''
	'''
}


def static String richObjectFactoryBean(UserTaskGroup it) {
	'''
		<bean id="rich«for.name»Factory"
			class="«module.getRichClientPackage()».data.Rich«for.name»«gapSubclassSuffix(this, "Rich" + for.name)»$Factory">
		<lookup-method name="create" bean="rich«for.name»"/>
		</bean>
	'''
}

def static String serviceRemoteModule(Module it, List[Service] usedServices) {
	'''
	'''
	fileOutput("Service-remote-" + name + ".xml", 'TO_GEN_RESOURCES', '''
	«header(it)»

	«IF getSpringRemotingType() == "rmi"»
		«it.usedServices.forEach[rmiProxyBean(it)]»
	«ELSEIF getSpringRemotingType() == "hessian"»
		«it.usedServices .forEach[hessianProxyBean(it)]»
	«ELSEIF getSpringRemotingType() == "burlap"»
		«it.usedServices .forEach[burlapProxyBean(it)]»
	«ELSEIF getSpringRemotingType() == "httpinvoker"»
		«it.usedServices .forEach[httpInvokerProxyBean(it)]»
	«ENDIF»
	</beans>
	'''
	)
	'''
	'''
}

def static String rmiProxyBean(Service it) {
	'''
	<bean id="«name.toFirstLower()»" class="org.springframework.remoting.rmi.RmiProxyFactoryBean">
		<property name="serviceUrl" value="${rmiUrl}/«module.application.name»/«name.toFirstLower()»" />
		<property name="serviceInterface" value="«getServiceapiPackage()».«name»" />
	</bean>
	'''
}

def static String hessianProxyBean(Service it) {
	'''
	<bean id="«name.toFirstLower()»" class="org.springframework.remoting.caucho.HessianProxyFactoryBean">
		<property name="serviceUrl" value="${hessianUrl}/«name»" />
		<property name="serviceInterface" value="«getServiceapiPackage()».«name»" />
	</bean>
	'''
}

def static String burlapProxyBean(Service it) {
	'''
	<bean id="«name.toFirstLower()»" class="org.springframework.remoting.caucho.BurlapProxyFactoryBean">
		<property name="serviceUrl" value="${burlapUrl}/«name»" />
		<property name="serviceInterface" value="«getServiceapiPackage()».«name»" />
	</bean>
	'''
}

def static String httpInvokerProxyBean(Service it) {
	'''
	<bean id="«name.toFirstLower()»" class="org.springframework.remoting.httpinvoker.HttpInvokerProxyFactoryBean">
		<property name="serviceUrl" value="${httpInvokerUrl}/«name»" />
		<property name="serviceInterface" value="«getServiceapiPackage()».«name»" />
	</bean>
	'''
}

def static String serviceStubModule(Module it, List[Service] services) {
	'''
	'''
	fileOutput("Service-stub-" + name + ".xml", 'TO_GEN_RESOURCES', '''
	«header(it)»
	«FOR s : services»
	«serviceStubBean(it) FOR s»
	«ENDFOR»
	</beans>
	'''
	)
	'''
	'''
}

def static String serviceStubBean(Service it) {
	'''
	    <bean id="«name.toFirstLower()»" class="«module.getServicestubPackage()».«name»Stub">
	    </bean>
	'''
}

def static String annotationScan(GuiApplication it) {
	'''
	<!-- activates annotation-based bean configuration -->
	<context:annotation-config />
	<!-- scans for @Components, @Repositories, @Services, ... -->
	<context:component-scan base-package="«this.guiForApplication.basePackage»" >
		<context:exclude-filter type="regex" expression=".*ServiceStub"/>
	</context:component-scan>
	'''
}

def static String annotationScanStub(GuiApplication it) {
	'''
	<!-- activates annotation-based bean configuration -->
	<context:annotation-config />
	<!-- scans for @Components, @Repositories, @Services, ... -->
	<context:component-scan base-package="«this.guiForApplication.basePackage»" />
	'''
}
}
