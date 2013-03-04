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

class JSFCrudGuiConfigFacesConfigTmpl {


def static String facesConfig(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/generated/config/faces-config.xml", 'TO_GEN_WEBROOT', '''
	«facesConfigContent(it)»
	'''
	)
	'''
	'''
}

def static String facesConfigContent(GuiApplication it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>

	<faces-config xmlns="http://java.sun.com/xml/ns/javaee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-facesconfig_1_2.xsd"
	version="1.2">

	<application>
		<!--navigation-handler>org.springframework.webflow.executor.jsf.FlowNavigationHandler</navigation-handler-->
		<view-handler>com.sun.facelets.FaceletViewHandler</view-handler>
		<variable-resolver>org.springframework.web.jsf.DelegatingVariableResolver</variable-resolver>
		<!--variable-resolver>
			org.springframework.webflow.executor.jsf.DelegatingFlowVariableResolver
		</variable-resolver-->

		<locale-config>
			<default-locale>en</default-locale>
			<supported-locale>en</supported-locale>
		</locale-config>

		<message-bundle>i18n.defaultMessages</message-bundle>
		<message-bundle>i18n.messages</message-bundle>
		«FOR module : this.modules»
		<message-bundle>i18n.«module.name»Messages</message-bundle>
		«ENDFOR»
		/*<message-bundle>i18n.errorMessages</message-bundle> */
		/*// TODO: decide if errorMessages should be generated */
		<resource-bundle>
				<base-name>i18n.messages</base-name>
				<var>msg</var>
			</resource-bundle>
			«FOR module : this.modules»
			<resource-bundle>
				<base-name>i18n.«module.name»Messages</base-name>
				<var>msg«module.name.toFirstUpper()»</var>
			</resource-bundle>
			«ENDFOR»
	</application>

	<lifecycle>
		<!--phase-listener>org.springframework.webflow.executor.jsf.FlowPhaseListener</phase-listener-->
		<phase-listener>«fw("web.errorhandling.ErrorBindingPhaseListener")»</phase-listener>
	</lifecycle>
	<!--<factory>
			<faces-context-factory>org.apache.myfaces.context.FacesContextFactoryImpl</faces-context-factory>
		</factory>-->
		<!--factory>
		<faces-context-factory>org.apache.myfaces.webapp.filter.TomahawkFacesContextFactory</faces-context-factory>
		</factory-->
	<converter>
		<converter-id>DateConverter</converter-id>
		<converter-class>«basePackage».util.web.DateConverter</converter-class>
		<property>
			<property-name>pattern</property-name>
			<property-class>java.lang.String</property-class>
		</property>
	</converter>
	«IF getDateTimeLibrary() == "joda"»
	<converter>
		<converter-id>LocalDateConverter</converter-id>
		<converter-class>«basePackage».util.web.LocalDateConverter</converter-class>
		<property>
			<property-name>pattern</property-name>
			<property-class>java.lang.String</property-class>
		</property>
	</converter>
	<converter>
		<converter-id>DateTimeConverter</converter-id>
		<converter-class>«basePackage».util.web.DateTimeConverter</converter-class>
		<property>
			<property-name>pattern</property-name>
			<property-class>java.lang.String</property-class>
		</property>
	</converter>
	«ENDIF»
	</faces-config>
	'''
}
}
