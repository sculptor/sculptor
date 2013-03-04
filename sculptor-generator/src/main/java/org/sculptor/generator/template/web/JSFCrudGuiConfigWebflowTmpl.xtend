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

class JSFCrudGuiConfigWebflowTmpl {


def static String springWebFlowConfigXml(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/generated/config/webflow-config.xml", 'TO_GEN_WEBROOT', '''
	«springWebFlowConfigXmlContent(it)»
	'''
	)
	'''
	'''
}

def static String springWebFlowConfigXmlContent(GuiApplication it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:webflow="http://www.springframework.org/schema/webflow-config"
			xmlns:faces="http://www.springframework.org/schema/faces"
			xmlns:aop="http://www.springframework.org/schema/aop"
			xsi:schemaLocation="
				http://www.springframework.org/schema/beans
				http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
				http://www.springframework.org/schema/webflow-config
				http://www.springframework.org/schema/webflow-config/spring-webflow-config-2.0.xsd
				http://www.springframework.org/schema/faces
				http://www.springframework.org/schema/faces/spring-faces-2.0.xsd
				http://www.springframework.org/schema/aop
				http://www.springframework.org/schema/aop/spring-aop-2.5.xsd">
	
	«flowExecutor(it)»
	«flowRegistry(it)»
	«flowBuilderService(it)»
	«IF jpa()»
		«flowPersistenceListener(it)»
	«ENDIF»
	«flowFacesContextLifecycleListener(it) »
	</beans>
	'''
}


def static String flowExecutor(GuiApplication it) {
	'''
	<!-- Launches new flow executions and resumes existing executions -->
	<webflow:flow-executor id="flowExecutor" flow-registry="flowRegistry">
	<webflow:flow-execution-attributes>
		<webflow:always-redirect-on-pause value="true" />
	</webflow:flow-execution-attributes>

	<webflow:flow-execution-listeners>
	   	«IF jpa()»
	    <webflow:listener ref="jpaFlowExecutionListener" />
			«ENDIF»
	    <webflow:listener ref="facesContextListener" />
	</webflow:flow-execution-listeners>
	</webflow:flow-executor>
	'''
}


def static String flowRegistry(GuiApplication it) {
	'''
	<!-- Flow registry to put custom flows -->
	<webflow:flow-registry id="flowRegistry" flow-builder-services="facesFlowBuilderServices" base-path="/WEB-INF">
	«it.this.modules.userTasks.forEach[flowDeclaration(it)]»
	<webflow:flow-location-pattern value="/**/*-flow.xml"/>
	</webflow:flow-registry>

/*
	<!-- The registry of generated flow definitions -->
	<webflow:flow-registry id="flowRegistryGenerated" flow-builder-services="facesFlowBuilderServices" base-path="/WEB-INF/generated/flows">

	«it.this.modules.userTasks.filter(e|e.gapClass).forEach[flowDeclaration(it)(true)]»
	<webflow:flow-location-pattern value="/**/*-flow.xml" />
	</webflow:flow-registry>
 */
	'''
}

def static String flowDeclaration(UserTask it) {
	'''
	<webflow:flow-location path="«IF gapClass»flows/«ELSE»generated/flows/«ENDIF»«module.name»/«name»/«name»-flow.xml" id="«module.name»/«name»"/>
	«IF gapClass»
	<webflow:flow-location path="generated/flows/«module.name»/«name»/«name»-base.xml" id="«module.name»/«name»Base"/>
	«ENDIF»
	'''
}

def static String flowBuilderService(GuiApplication it) {
	'''
	<!-- Configures the Spring Web Flow JSF integration -->
	<faces:flow-builder-services id="facesFlowBuilderServices" />
	'''
}

def static String flowPersistenceListener(GuiApplication it) {
	'''
	<bean id="jpaFlowExecutionListener"
		class="«jpaFlowExecutionListenerListenerClass()»">
	<constructor-arg ref="entityManagerFactory" />
	<constructor-arg ref="txManager" />
	</bean>
	'''
}
def static String flowFacesContextLifecycleListener(GuiApplication it) {
	'''
	<!-- A listener maintain one FacesContext instance per Web Flow request. -->
	<bean id="facesContextListener" class="org.springframework.faces.webflow.FlowFacesContextLifecycleListener" />
	'''
}
}
