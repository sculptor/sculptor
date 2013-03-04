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

class JSFCrudGuiConfigWebmvcTmpl {


def static String springMvcConfigXml(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/generated/config/webmvc-config.xml", 'TO_GEN_WEBROOT', '''
	«springMvcConfigXmlContent(it)»
	'''
	)
	'''
	'''
}

def static String springMvcConfigXmlContent(GuiApplication it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xsi:schemaLocation="
				http://www.springframework.org/schema/beans
				http://www.springframework.org/schema/beans/spring-beans-2.5.xsd">

	<!-- Maps request paths to flows in the flowRegistry; -->
	<bean id="flowMapper" class="org.springframework.webflow.mvc.servlet.FlowHandlerMapping">
		<property name="flowRegistry" ref="flowRegistry"/>
	</bean>

	<!-- Maps logical view names to Facelet templates in /WEB-INF (e.g. 'search' to '/WEB-INF/search.xhtml' -->
	<bean id="faceletsViewResolver" class="org.springframework.web.servlet.view.UrlBasedViewResolver">
		<property name="viewClass" value="org.springframework.faces.mvc.JsfView"/>
		<property name="prefix" value="/" />
		<property name="suffix" value=".xhtml" />
	</bean>

	<!-- Dispatches requests mapped to org.springframework.web.servlet.mvc.Controller implementations -->
	<bean class="org.springframework.web.servlet.mvc.SimpleControllerHandlerAdapter" />

	<!-- Dispatches requests mapped to flows to FlowHandler implementations -->
	<bean class="org.springframework.webflow.mvc.servlet.FlowHandlerAdapter">
		<property name="flowExecutor" ref="flowExecutor" />
	</bean>
	<bean id="localeResolver" class="org.springframework.web.servlet.i18n.SessionLocaleResolver"/>
		<bean id="themeResolver" class="org.springframework.web.servlet.theme.SessionThemeResolver">
			<property name="defaultThemeName" value="theme"/>
		</bean>
		«messageSource(it)»
		<bean name="urlController" class="org.springframework.web.servlet.mvc.UrlFilenameViewController"/>
		
		<bean id="urlHandler" class=" org.springframework.web.servlet.handler.SimpleUrlHandlerMapping">
			<property name="mappings">
			<props>
				<prop key="/index.xhtml">urlController</prop>
			</props>
			</property>
			<property name="interceptors">
			<list>
				<ref bean="localeChangeInterceptor"/>
				<ref bean="themeChangeInterceptor"/>
			</list>
			</property>
		</bean>
		<bean id="localeChangeInterceptor" class="org.springframework.web.servlet.i18n.LocaleChangeInterceptor"/>
		<bean id="themeChangeInterceptor" class="org.springframework.web.servlet.theme.ThemeChangeInterceptor"/>

	</beans>
	'''
}

def static String messageSource(GuiApplication it) {
	'''
	<bean id="messageSource" class="org.springframework.context.support.ResourceBundleMessageSource">
		<property name="basenames">
			<list>
				<value>i18n/defaultMessages</value>
				<value>i18n/messages</value>
				«FOR module : this.modules»
				<value>i18n/«module.name»Messages</value>
				«ENDFOR»
				«IF isValidationAnnotationToBeGenerated()»
				<value>org/hibernate/validator/resources/DefaultValidatorMessages</value>
				«ENDIF»
			</list>
		</property>
 	</bean>
	'''
}

}
