package org.sculptor.generator.template.rest

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.template.web.JSFCrudGuiConfigContextTmpl
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

class RestWebConfigTmpl {

	@Inject private var JSFCrudGuiConfigContextTmpl jSFCrudGuiConfigContextTmpl

	@Inject extension Helper helper

def String config(Application it) {
	'''
		«webXml(it)»
		«restServletXml(it)»
		«jSFCrudGuiConfigContextTmpl.contextXml(it)»
	'''
}

def String webXml(Application it) {
	fileOutput("WEB-INF/web.xml", OutputSlot::TO_WEBROOT, '''
	<?xml version="1.0" encoding="UTF-8"?>
	<web-app version="2.4" xmlns="http://java.sun.com/xml/ns/j2ee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://java.sun.com/xml/ns/j2ee http://java.sun.com/xml/ns/j2ee/web-app_2_4.xsd">

	<display-name>«name»</display-name>
	<description>«name»</description>

	<context-param>
		<param-name>webAppRootKey</param-name>
		<param-value>rest.root</param-value>
	</context-param>

	<context-param>
		<param-name>contextConfigLocation</param-name>
		<param-value>classpath:applicationContext.xml</param-value>
	</context-param>

	<listener>
		<listener-class>org.springframework.web.context.ContextLoaderListener</listener-class>
	</listener>

	<servlet>
		<servlet-name>rest</servlet-name>
		<servlet-class>org.springframework.web.servlet.DispatcherServlet</servlet-class>
		<load-on-startup>2</load-on-startup>
	</servlet>

	<servlet-mapping>
		<servlet-name>rest</servlet-name>
		<url-pattern>/rest/*</url-pattern>
	</servlet-mapping>

	<!-- TODO OpenEntityManagerInViewFilter -->

	<filter>
		<filter-name>httpMethodFilter</filter-name>
		<filter-class>org.springframework.web.filter.HiddenHttpMethodFilter</filter-class>
	</filter>

	<filter-mapping>
		<filter-name>httpMethodFilter</filter-name>
		<servlet-name>rest</servlet-name>
	</filter-mapping>
	
	<filter>
		<filter-name>ServiceContextFilter</filter-name>
		<filter-class>
			org.sculptor.framework.errorhandling.ServiceContextServletFilter</filter-class>
		<init-param>
			<param-name>ServiceContextFactoryImplementationClassName</param-name>
			<param-value>org.sculptor.framework.errorhandling.ServletContainerServiceContextFactory</param-value>
		</init-param>
	</filter>

	<filter-mapping>
		<filter-name>ServiceContextFilter</filter-name>
		<servlet-name>rest</servlet-name>
	</filter-mapping>	

	<welcome-file-list>
		<!-- Redirects for dispatcher handling -->
		<welcome-file>index.jsp</welcome-file>
	</welcome-file-list>

	<error-page>
		<exception-type>java.lang.Exception</exception-type>
		<!-- Displays a stack trace -->
		<location>/WEB-INF/jsp/uncaughtException.jsp</location>
	</error-page>
	
	</web-app>	
	'''
	)
	'''
	'''
}

def String restServletXml(Application it) {
	fileOutput("WEB-INF/rest-servlet.xml", OutputSlot::TO_WEBROOT, '''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:p="http://www.springframework.org/schema/p" xmlns:context="http://www.springframework.org/schema/context"
		xmlns:oxm="http://www.springframework.org/schema/oxm"
		xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
				http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-2.5.xsd
				http://www.springframework.org/schema/oxm http://www.springframework.org/schema/oxm/spring-oxm-3.0.xsd">

	<context:component-scan base-package="«basePackage»" use-default-filters="false">
				    <context:include-filter expression="org.springframework.stereotype.Controller" type="annotation"/>
			</context:component-scan> 
	
	<bean
		class="org.springframework.web.servlet.view.ContentNegotiatingViewResolver">
		<property name="defaultContentType" value="text/html" />
		<property name="ignoreAcceptHeader" value="true" />
		<property name="mediaTypes">
			<map>
				<entry key="html" value="text/html" />
				<entry key="xml" value="application/xml" />
				<entry key="json" value="application/json" />
			</map>
		</property>
		<property name="viewResolvers">
			<list>
				<bean class="org.springframework.web.servlet.view.BeanNameViewResolver" />
				<bean
					class="org.springframework.web.servlet.view.InternalResourceViewResolver">
					<property name="prefix" value="/WEB-INF/jsp/" />
					<property name="suffix" value=".jsp" />
				</bean>
			</list>
		</property>
		<property name="defaultViews">
			<list>
				<bean class="org.springframework.web.servlet.view.xml.MarshallingView">
					<property name="marshaller" ref="xstreamMarshaller" />
					<property name="modelKey" value="result" />
				</bean>
				<bean
					class="org.springframework.web.servlet.view.json.MappingJacksonJsonView" />
			</list>
		</property>
	</bean>
	<bean id="xstreamMarshaller" class="org.springframework.oxm.xstream.XStreamMarshaller">
		<property name="autodetectAnnotations" value="true" />
	</bean>
	<!-- Instead of xstreamMarshaller you can use the following jaxb2Marshaller -->
	<!-- 
	<bean id="jaxb2Marshaller" class="org.springframework.oxm.jaxb.Jaxb2Marshaller">
		<property name="classesToBeBound">
			<list>
				<value>«basePackage».mymodule.serviceapi.MyDto</value>
			</list>
		</property>
	</bean>
	-->

	<!-- These message converters are used for converting json or xml to java 
		obj for @RequestBody parameters -->
	<bean
		class="org.springframework.web.servlet.mvc.annotation.AnnotationMethodHandlerAdapter">
		<property name="messageConverters">
			<list>
				<ref bean="jsonMarshallingHttpMessageConverter" />
				<ref bean="xmlMarshallingHttpMessageConverter" />
			</list>
		</property>
	</bean>
	<bean id="xmlMarshallingHttpMessageConverter"
		class="org.springframework.http.converter.xml.MarshallingHttpMessageConverter">
		<property name="marshaller" ref="xstreamMarshaller" />
		<property name="unmarshaller" ref="xstreamMarshaller" />
	</bean>
	<bean id="jsonMarshallingHttpMessageConverter"
		class="org.springframework.http.converter.json.MappingJacksonHttpMessageConverter" />

	</beans>
	'''
	)
}

}
