/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.rest

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

@ChainOverridable
class RestWebConfigTmpl {

	@Inject var RestWebContextTmpl contextTmpl

	@Inject extension Helper helper
	@Inject extension Properties properties

def String config(Application it) {
	'''
		«IF getBooleanProperty("generate.restWeb.config.springboot")»
				«springBootConfig(it)»
		«ELSE»
				«webXml(it)»
				«restServletXml(it)»
				«contextTmpl.contextXml(it)»
		«ENDIF»
	'''
}

def String webXml(Application it) {
	fileOutput("WEB-INF/web.xml", OutputSlot.TO_WEBROOT, '''
	<?xml version="1.0" encoding="UTF-8"?>
	<web-app version="3.0" xmlns="http://java.sun.com/xml/ns/javaee" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xsi:schemaLocation="http://java.sun.com/xml/ns/javaee http://java.sun.com/xml/ns/javaee/web-app_3_0.xsd">

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
		<filter-class>org.sculptor.framework.context.ServiceContextServletFilter</filter-class>
		<init-param>
			<param-name>ServiceContextFactoryImplementationClassName</param-name>
			<param-value>org.sculptor.framework.context.ServletContainerServiceContextFactory</param-value>
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

	<resource-ref>
		«IF applicationServer() == "jboss"»
			<res-ref-name>java:/jdbc/«dataSourceName(it)»</res-ref-name>
		«ELSE»
			<res-ref-name>jdbc/«dataSourceName(it)»</res-ref-name>
		«ENDIF»
	    <res-type>javax.sql.DataSource</res-type>
	    <res-auth>Container</res-auth>
	</resource-ref>
	
	</web-app>	
	'''
	)
	'''
	'''
}

def String restServletXml(Application it) {
	fileOutput("WEB-INF/rest-servlet.xml", OutputSlot.TO_WEBROOT, '''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans xmlns="http://www.springframework.org/schema/beans" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
		xmlns:p="http://www.springframework.org/schema/p" xmlns:context="http://www.springframework.org/schema/context"
		xmlns:oxm="http://www.springframework.org/schema/oxm"
		xsi:schemaLocation="http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans.xsd
				http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context.xsd
				http://www.springframework.org/schema/oxm http://www.springframework.org/schema/oxm/spring-oxm.xsd">

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
					class="org.springframework.web.servlet.view.json.MappingJackson2JsonView" />
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
		class="org.springframework.http.converter.json.MappingJackson2HttpMessageConverter" />

	</beans>
	'''
	)
}

def String springBootConfig(Application it) {
	'''
		«springBootAppConfig(it)»
		«springBootAppProperties(it)»
		«springBootBackendConfig(it)»
		«springBootWebConfig(it)»
	'''
}

def String springBootAppConfig(Application it) {
	fileOutput(basePackage + "/Application.java", OutputSlot.TO_SRC, '''
		«javaHeader()»
		package «basePackage»;

		import org.springframework.boot.autoconfigure.SpringBootApplication;
		import org.springframework.boot.autoconfigure.jdbc.DataSourceAutoConfiguration;
		import org.springframework.boot.autoconfigure.jdbc.DataSourceTransactionManagerAutoConfiguration;
		import org.springframework.boot.autoconfigure.orm.jpa.HibernateJpaAutoConfiguration;
		import org.springframework.boot.builder.SpringApplicationBuilder;

		@SpringBootApplication(exclude = {
				DataSourceAutoConfiguration.class,
				DataSourceTransactionManagerAutoConfiguration.class,
				HibernateJpaAutoConfiguration.class
		})
		public class Application {

			public static void main(String[] args) throws Exception {
				new SpringApplicationBuilder().sources(Application.class).profiles("web").run(args);
			}

		}
	'''
	)
}

def String springBootAppProperties(Application it) {
	fileOutput("/application.properties", OutputSlot.TO_RESOURCES, '''
		# LOGGING
		logging.level.org.springframework.web=INFO

		# SPRING MVC
		# Allow Thymeleaf templates to be reloaded at dev time
		spring.thymeleaf.cache=false

		# Use Sculptor banner from sculptor-framework-main
		spring.banner.location=classpath:/sculptor-banner.txt

		# EMBEDDED WEB CONTAINER CONFIGURATION
		# Set the error path
		server.error.path=/error
	'''
	)
}

def String springBootBackendConfig(Application it) {
	fileOutput(javaFileName(basePackage + ".config.BackendConfig"), OutputSlot.TO_SRC, '''
		«javaHeader()»
		package «basePackage».config;

		import org.springframework.context.annotation.Configuration;
		import org.springframework.context.annotation.ImportResource;
		import org.springframework.context.annotation.Profile;

		@Profile("!test")
		@Configuration
		@ImportResource("classpath:applicationContext.xml")
		public class BackendConfig {
		}
	'''
	)
}

def String springBootWebConfig(Application it) {
	fileOutput(javaFileName(basePackage + ".config.WebConfig"), OutputSlot.TO_SRC, '''
		«javaHeader()»
		package «basePackage».config;

		/// Sculptor code formatter imports ///

		import java.util.Arrays;
		import java.util.HashMap;
		import java.util.Map;

		import org.sculptor.framework.context.ServiceContextServletFilter;
		import org.springframework.boot.web.servlet.FilterRegistrationBean;
		import org.springframework.context.annotation.Bean;
		import org.springframework.context.annotation.Configuration;
		import org.springframework.context.annotation.Profile;
		import org.springframework.core.Ordered;
		import org.springframework.http.MediaType;
		import org.springframework.web.accept.ContentNegotiationManager;
		import org.springframework.web.servlet.View;
		import org.springframework.web.servlet.config.annotation.ContentNegotiationConfigurer;
		import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
		import org.springframework.web.servlet.view.ContentNegotiatingViewResolver;
		import org.springframework.web.servlet.view.json.MappingJackson2JsonView;
		import org.springframework.web.servlet.view.xml.MappingJackson2XmlView;

		/* We have to disable this configuration during backend tests */
		@Profile("web")
		@Configuration
		public class WebConfig implements WebMvcConfigurer {

			@Bean
			public View xmlView() {
				return new MappingJackson2XmlView();
			}

			@Bean
			public View jsonView() {
				return new MappingJackson2JsonView();
			}

			@Override
			public void configureContentNegotiation(ContentNegotiationConfigurer configurer) {
				configurer.ignoreAcceptHeader(true).defaultContentType(MediaType.TEXT_HTML)
						.mediaType("html", MediaType.TEXT_HTML).mediaType("xml", MediaType.APPLICATION_XML)
						.mediaType("json", MediaType.APPLICATION_JSON);
			}

			@Bean
			public ContentNegotiatingViewResolver viewResolver(ContentNegotiationManager manager) {
				ContentNegotiatingViewResolver resolver = new ContentNegotiatingViewResolver();
				resolver.setContentNegotiationManager(manager);
				resolver.setOrder(Ordered.HIGHEST_PRECEDENCE);
				resolver.setDefaultViews(Arrays.asList(new View[] { xmlView(), jsonView() }));
				return resolver;
			}

			@Bean
			public FilterRegistrationBean<ServiceContextServletFilter> serviceContextFilterRegistration() {
				FilterRegistrationBean<ServiceContextServletFilter> registration = new FilterRegistrationBean<>();
				registration.setFilter(new ServiceContextServletFilter());
				Map<String, String> initParams = new HashMap<String, String>(1);
				initParams.put("ServiceContextFactoryImplementationClassName",
						"org.sculptor.framework.context.ServletContainerServiceContextFactory");
				registration.setInitParameters(initParams);
				registration.addUrlPatterns("/rest/*");
				registration.setOrder(Ordered.LOWEST_PRECEDENCE);
				return registration;
			}

		}
	'''
	)
}

}
