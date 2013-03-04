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

package org.sculptor.generator.template.web

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class JSFCrudGuiConfigAppContextTmpl {


def static String springApplicationContextXml(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/generated/config/applicationContext.xml", 'TO_GEN_WEBROOT', '''
	«springApplicationContextXmlContent(it)»
	'''
	)
	'''
	'''
}

def static String springApplicationContextXmlContent(GuiApplication it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:aop="http://www.springframework.org/schema/aop"
			xmlns:context="http://www.springframework.org/schema/context"
			xsi:schemaLocation="
				http://www.springframework.org/schema/beans
				http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
				http://www.springframework.org/schema/aop 
		   http://www.springframework.org/schema/aop/spring-aop-2.5.xsd
				http://www.springframework.org/schema/context
		   http://www.springframework.org/schema/context/spring-context-2.5.xsd">
	«IF isEar() »
	«FOR service : getAllUsedServices()»
		/*  TODO can't we use Spring lookup instead of our Proxy for EJB3
		<jee:local-slsb id="«service.name.toFirstLower()»Proxy"
				         jndi-name="ejb/«service.name»Local"
				         lookup-home-on-startup="true"
				         business-interface="«service.getServiceapiPackage()».«service.name»"/>
			*/
		<bean id="«service.name.toFirstLower()»Proxy" class="«service.getServiceproxyPackage()».«service.name»Proxy" />
	«ENDFOR»
	«ENDIF »
		<bean id="exceptionResolver" class="org.springframework.web.servlet.handler.SimpleMappingExceptionResolver" >
			<property name="defaultErrorView" value="error"/>
		</bean>
	«IF jpa()»
	    <bean id="repository" class="«conversationDomainObjectJpaRepositoryImplClass()»" >
	    	<property name="entityManagerFactory" ref="entityManagerFactory" />
	    </bean>
	«ELSEIF mongoDb()»
	<bean id="repository" class="«basePackage».util.«subPackage("web")».ConversationDomainObjectMongoDbRepositoryImpl" >
		<property name="dbManager" ref="mongodbManager" />
	</bean>
	«ENDIF»

	«IF isDynamicMenu()»
	<bean id="dynamicMenu" class="«this.basePackage».«this.name.toFirstUpper()»DynamicMenu">
		<property name="messages" ref="messageSource"/>
	 </bean>
	«ENDIF»

		<bean id="webExceptionAdvice" class="«webExceptionAdviceClass()»" />
		«actionAopConfig(it)»
	<import resource="webmvc-config.xml" />
	<import resource="webflow-config.xml" />
	«componentScan(it) »
	</beans>
	'''
}

def static String componentScan(GuiApplication it) {
	'''
	<!-- scans for @Components, @Repositories, @Services, ... -->
	«FOR module : modules»
	<context:component-scan base-package="«module.getWebPackage()»"/>
	«ENDFOR»
		
	'''
}

def static String actionAopConfig(GuiApplication it) {
	'''
		<aop:config>
			<aop:pointcut id="webAction" expression="execution(public String *(org.springframework.webflow.execution.RequestContext))"/>
				<aop:advisor pointcut-ref="webAction" advice-ref="webExceptionAdvice" />
				</aop:config>
	'''
}
}
