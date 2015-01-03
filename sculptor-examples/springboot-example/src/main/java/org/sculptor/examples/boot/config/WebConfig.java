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
package org.sculptor.examples.boot.config;

import java.util.Arrays;
import java.util.HashMap;
import java.util.Map;

import org.sculptor.framework.context.ServiceContextServletFilter;
import org.springframework.boot.context.embedded.FilterRegistrationBean;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.core.Ordered;
import org.springframework.http.MediaType;
import org.springframework.web.accept.ContentNegotiationManager;
import org.springframework.web.servlet.View;
import org.springframework.web.servlet.config.annotation.ContentNegotiationConfigurer;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurerAdapter;
import org.springframework.web.servlet.view.ContentNegotiatingViewResolver;
import org.springframework.web.servlet.view.json.MappingJackson2JsonView;
import org.springframework.web.servlet.view.xml.MappingJackson2XmlView;

/* We have to disable this configuration during backend tests */
@Profile("web")
@Configuration
public class WebConfig extends WebMvcConfigurerAdapter {

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
	public FilterRegistrationBean serviceContextFilterRegistration() {
		FilterRegistrationBean registration = new FilterRegistrationBean();
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
