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
package org.sculptor.generator.template.springint

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

@ChainOverridable
class SpringIntegrationTmpl {

	@Inject extension Helper helper
	@Inject extension Properties properties

def String springIntegrationConfig(Application it) {
	fileOutput(it.getResourceDir("spring") + "spring-integration.xml", OutputSlot.TO_RESOURCES, '''
	«header(it)»

		«springIntegrationEventBus(it)»
	
		«springIntegrationConfigHook(it)»

	</beans:beans>
	'''
	)
}

def String springIntegrationTestConfig(Application it) {
	fileOutput(it.getResourceDir("spring") + "spring-integration-test.xml", OutputSlot.TO_RESOURCES_TEST, '''
	«header(it)»

		<beans:import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("spring-integration.xml")»"/>

		«springIntegrationTestConfigHook(it)»

	</beans:beans>
	'''
	)
}

def String springIntegrationConfigHook(Application it) {
	'''
	<publish-subscribe-channel id="testChannel" />
	'''
}

def String springIntegrationTestConfigHook(Application it) {
	'''
	'''
}

def String header(Application it) {
	'''
	<?xml version="1.0" encoding="UTF-8" ?>
	<beans:beans xmlns="http://www.springframework.org/schema/integration"
			xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
			xmlns:beans="http://www.springframework.org/schema/beans"
			xmlns:stream="http://www.springframework.org/schema/integration/stream"
			xmlns:jms="http://www.springframework.org/schema/integration/jms"
			xmlns:si-xml="http://www.springframework.org/schema/integration/xml"
			xmlns:file="http://www.springframework.org/schema/integration/file"
			«headerNamespaceAdditions»
			xsi:schemaLocation="
				http://www.springframework.org/schema/beans
				http://www.springframework.org/schema/beans/spring-beans.xsd
				http://www.springframework.org/schema/integration
				http://www.springframework.org/schema/integration/spring-integration.xsd
				http://www.springframework.org/schema/integration/stream
				http://www.springframework.org/schema/integration/stream/spring-integration-stream.xsd
				http://www.springframework.org/schema/integration/jms
				http://www.springframework.org/schema/integration/jms/spring-integration-jms.xsd
				http://www.springframework.org/schema/integration/xml
				http://www.springframework.org/schema/integration/xml/spring-integration-xml.xsd
				http://www.springframework.org/schema/integration/file
				http://www.springframework.org/schema/integration/file/spring-integration-file.xsd
				«headerSchemaLocationAdditions»">

	'''
}

/*
 * Extension point to generate more namespaces in header.
 */
def String headerNamespaceAdditions(Object it) {
	'''
	'''
}

/*
 * Extension point to generate more schema locations in header.
 */
def String headerSchemaLocationAdditions(Object it) {
	'''
	'''
}

def String springIntegrationEventBus(Application it) {
	'''
	<beans:bean id="springIntegrationEventBusImpl" class="«fw("event.SpringIntegrationEventBusImpl")»" />
	<beans:alias name="springIntegrationEventBusImpl" alias="eventBus" />
	'''
}

}
