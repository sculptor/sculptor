/*
 * Copyright 2010 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.springint

import sculptormetamodel.Application

import static org.sculptor.generator.ext.Helper.*
import static org.sculptor.generator.template.springint.SpringIntegrationTmpl.*

import static extension org.sculptor.generator.ext.Properties.*

class SpringIntegrationTmpl {

def static String springIntegrationConfig(Application it) {
	fileOutput(it.getResourceDir("spring") + "spring-integration.xml", 'TO_RESOURCES', '''
	«header(it)»

	«springIntegrationEventBus(it)»
	
	«springIntegrationConfigHook(it)»

	</beans:beans>
	'''
	)
}

def static String springIntegrationTestConfig(Application it) {
	fileOutput(it.getResourceDir("spring") + "spring-integration-test.xml", 'TO_RESOURCES_TEST', '''
	«header(it)»
	<beans:import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("spring-integration.xml")»"/>

	«springIntegrationTestConfigHook(it)»
	</beans:beans>
	'''
	)
}

def static String springIntegrationConfigHook(Application it) {
	'''
	<publish-subscribe-channel id="testChannel" />
	'''
}

def static String springIntegrationTestConfigHook(Application it) {
	'''
	'''
}


def static String header(Application it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>
	<beans:beans xmlns="http://www.springframework.org/schema/integration"
				 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				 xmlns:beans="http://www.springframework.org/schema/beans"
				 xmlns:stream="http://www.springframework.org/schema/integration/stream"
				 xmlns:si-xml="http://www.springframework.org/schema/integration/xml"
				 xmlns:file="http://www.springframework.org/schema/integration/file"
				 xsi:schemaLocation="http://www.springframework.org/schema/beans
				http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
				http://www.springframework.org/schema/integration
				http://www.springframework.org/schema/integration/spring-integration-1.0.xsd
				http://www.springframework.org/schema/integration/stream
				http://www.springframework.org/schema/integration/stream/spring-integration-stream-1.0.xsd
				http://www.springframework.org/schema/integration/xml
				http://www.springframework.org/schema/integration/xml/spring-integration-xml-1.0.xsd
				http://www.springframework.org/schema/integration/file
				http://www.springframework.org/schema/integration/file/spring-integration-file-1.0.xsd">
	'''
}

def static String springIntegrationEventBus(Application it) {
	'''
	<beans:bean id="springIntegrationEventBusImpl" class="«fw("event.SpringIntegrationEventBusImpl")»" />
	<beans:alias name="springIntegrationEventBusImpl" alias="eventBus" />
	'''
}

}
