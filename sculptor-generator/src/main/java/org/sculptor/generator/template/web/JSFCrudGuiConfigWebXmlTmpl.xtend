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

class JSFCrudGuiConfigWebXmlTmpl {


def static String webXml(GuiApplication it) {
	'''
	'''
	fileOutput("WEB-INF/web.xml", 'TO_WEBROOT', '''
	«webXmlContent(it)»
	'''
	)
	'''
	'''
}

def static String webXmlContent(GuiApplication it) {
	'''
	<?xml version="1.0" encoding="ISO-8859-1"?>
	<web-app version="2.5" xmlns="http://java.sun.com/xml/ns/javaee"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="http://java.sun.com/xml/ns/javaee
				           http://java.sun.com/xml/ns/javaee/web-app_2_5.xsd">
	«applicationName(it)»
	
			<!-- Serves static resource content from .jar files such as spring-faces.jar -->
	<servlet>
		<servlet-name>Resources Servlet</servlet-name>
		<servlet-class>org.springframework.js.resource.ResourceServlet</servlet-class>
		<load-on-startup>0</load-on-startup>
	</servlet>

	<!-- Map all /resources requests to the Resource Servlet for handling -->
	<servlet-mapping>
		<servlet-name>Resources Servlet</servlet-name>
		<url-pattern>/resources/*</url-pattern>
	</servlet-mapping>

	<!-- The front controller of this Spring Web application, responsible for handling all application requests -->
	<servlet>
		<servlet-name>Spring MVC Dispatcher Servlet</servlet-name>
		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
		<init-param>
			<param-name>contextConfigLocation</param-name>
			<param-value></param-value>
		</init-param>
		<load-on-startup>2</load-on-startup>
	</servlet>

	<!-- Map all /spring requests to the Dispatcher Servlet for handling -->
	<servlet-mapping>
		<servlet-name>Spring MVC Dispatcher Servlet</servlet-name>
		<url-pattern>/«springServletMapping()»/*</url-pattern>
	</servlet-mapping>
	<!-- Just here so the JSF implementation can initialize, *not* used at runtime -->
	<servlet>
		<servlet-name>Standard Faces Servlet</servlet-name>
		<servlet-class>javax.faces.webapp.FacesServlet</servlet-class>
		<load-on-startup>1</load-on-startup>
	</servlet>
	<!-- Just here so the JSF implementation can initialize -->
	<servlet-mapping>
			<servlet-name>Standard Faces Servlet</servlet-name>
			<url-pattern>*.xhtml</url-pattern>
	</servlet-mapping>

	<context-param>
		<param-name>facelets.LIBRARIES</param-name>
		<param-value>/WEB-INF/generated/config/application.taglib.xml</param-value>
	</context-param>

	<context-param>
			<param-name>javax.faces.CONFIG_FILES</param-name>
			<param-value>/WEB-INF/generated/config/faces-config.xml</param-value>
			</context-param>
	<context-param>
			<param-name>javax.faces.DEFAULT_SUFFIX</param-name>
			<param-value>.xhtml</param-value>
			</context-param>
	<context-param>
		<param-name>javax.faces.STATE_SAVING_METHOD</param-name>
		<param-value>server</param-value>
	</context-param>
	<!--<context-param>
		<param-name>org.apache.myfaces.ALLOW_JAVASCRIPT</param-name>
		<param-value>true</param-value>
		</context-param>
		<context-param>
		<param-name>org.apache.myfaces.DETECT_JAVASCRIPT</param-name>
		<param-value>false</param-value>
		</context-param>
		<context-param>
		<param-name>org.apache.myfaces.PRETTY_HTML</param-name>
		<param-value>true</param-value>
		</context-param>
		<context-param>
		<param-name>org.apache.myfaces.AUTO_SCROLL</param-name>
		<param-value>true</param-value>
		</context-param>-->
	<context-param>
			<param-name>facelets.DEVELOPMENT</param-name>
			<param-value>true</param-value>
			</context-param>
			<!-- Causes Facelets to refresh templates during development -->
			<context-param>
				<param-name>facelets.REFRESH_PERIOD</param-name>
				<param-value>1</param-value>
			</context-param>
			<!-- Neede to prevent JBoss from using its own bundled JSF impl -->
		<context-param>
			<param-name>org.jboss.jbossfaces.WAR_BUNDLES_JSF_IMPL</param-name>
			<param-value>true</param-value>
		</context-param>
		<!--context-param>
			<param-name>org.apache.myfaces.ERROR_HANDLER</param-name>
			<param-value>my.project.ErrorHandler</param-value>
		</context-param>
		<context-param>
			<param-name>org.apache.myfaces.DISABLE_TOMAHAWK_FACES_CONTEXT_WRAPPER</param-name>
			<param-value>true</param-value>
		</context-param-->
	<!--  spring config params and listeners -->
	<context-param>
			<param-name>contextConfigLocation</param-name>
			<param-value>
				/WEB-INF/generated/config/applicationContext.xml
			</param-value>
		</context-param>

		<!--listener>
			<listener-class>org.apache.myfaces.webapp.StartupServletContextListener</listener-class>
		</listener-->
		<listener>
			<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
		</listener>
		<listener>
			<listener-class>org.springframework.web.context.request.RequestContextListener</listener-class>
		</listener>
		<listener>
				<listener-class>com.sun.faces.config.ConfigureListener</listener-class>
			</listener> 
		<!--  load a shared business tier parent application context -->
	<context-param>
		<param-name>locatorFactorySelector</param-name>
		<param-value>beanRefContext.xml</param-value>
	</context-param>
	<context-param>
		<param-name>parentContextKey</param-name>
		<param-value>«guiForApplication.basePackage»</param-value>
	</context-param>


	«IF isServiceContextToBeGenerated() »
	<filter>
		<filter-name>serviceContextFilter</filter-name>
		<filter-class>«serviceContextServletFilterClass()»</filter-class>
		«IF isRunningInServletContainer() »
	    <init-param>
			<param-name>ServiceContextFactoryImplementationClassName</param-name>
			<param-value>«servletContainerServiceContextFactoryClass()»</param-value>
		</init-param>
		«ENDIF »
	</filter>
	<filter-mapping>
		<filter-name>serviceContextFilter</filter-name>
		<url-pattern>/*</url-pattern>
	</filter-mapping>
	«ENDIF »
	«IF mongoDb() »
	<filter>
		<filter-name>mongodbManagerFilter</filter-name>
		<filter-class>«fw("accessimpl.mongodb.DbManagerFilter")»</filter-class>
	</filter>
	<filter-mapping>
		<filter-name>mongodbManagerFilter</filter-name>
		<url-pattern>/*</url-pattern>
	</filter-mapping>
	«ENDIF»
	<filter>
		<filter-name>MyFacesExtensionsFilter</filter-name>
		<filter-class>
			org.apache.myfaces.webapp.filter.ExtensionsFilter
		</filter-class>
		<init-param>
			<param-name>maxFileSize</param-name>
			<param-value>20m</param-value>
		</init-param>
	</filter>
	<filter-mapping>
			<filter-name>MyFacesExtensionsFilter</filter-name>
			<servlet-name>Spring MVC Dispatcher Servlet</servlet-name>
		</filter-mapping>
	<filter-mapping>
		<filter-name>MyFacesExtensionsFilter</filter-name>
		<servlet-name>Standard Faces Servlet</servlet-name>
	</filter-mapping>
	<filter-mapping>
		<filter-name>MyFacesExtensionsFilter</filter-name>
		<url-pattern>/faces/myFacesExtensionResource/*</url-pattern>
	</filter-mapping>
	<filter-mapping>
		<filter-name>MyFacesExtensionsFilter</filter-name>
		<url-pattern>*.xhtml</url-pattern>
	</filter-mapping>

	<error-page>
		<error-code>500</error-code>
		<location>/error.xhtml</location>
	</error-page>


	<welcome-file-list>
		<!-- We need a redirect because of MyFaces filter -->
		<!-- <welcome-file>index.xhtml</welcome-file> -->
		<welcome-file>index.jsp</welcome-file>
	</welcome-file-list>

	</web-app>
	'''
}

def static String applicationName(GuiApplication it) {
	'''
	<display-name>«getWebRoot()»</display-name>
	'''
}
}
