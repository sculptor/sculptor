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

package org.sculptor.generator.template.camel

import sculptormetamodel.Application

import static org.sculptor.generator.ext.Helper.*

import static extension org.sculptor.generator.ext.Properties.*

class CamelTmpl {

def static String camelConfig(Application it) {
	fileOutput(it.getResourceDir("spring") + "camel.xml", 'TO_RESOURCES', '''
	«header(it)»
	
	«camelEventBus(it)»

	«camelContext(it)»
	«camelJmsEndpoint(it)»

	</beans>
	'''
	)
}

def static String camelTestConfig(Application it) {
	fileOutput(it.getResourceDir("spring") + "camel-test.xml", 'TO_RESOURCES_TEST', '''
	«header(it)»
	<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("camel.xml")»"/>
	
	«camelTestJmsEndpoint(it)»

	</beans>
	'''
	)
}


def static String header(Application it) {
	'''
	<?xml version="1.0" encoding="UTF-8"?>

	<beans xmlns="http://www.springframework.org/schema/beans"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:context="http://www.springframework.org/schema/context"
	xmlns:camel="http://camel.apache.org/schema/spring" xmlns:broker="http://activemq.apache.org/schema/core"
	xsi:schemaLocation="
			http://www.springframework.org/schema/beans http://www.springframework.org/schema/beans/spring-beans-2.5.xsd
			http://www.springframework.org/schema/context http://www.springframework.org/schema/context/spring-context-2.5.xsd
			http://camel.apache.org/schema/spring http://camel.apache.org/schema/spring/camel-spring.xsd
			http://activemq.apache.org/schema/core http://activemq.apache.org/schema/core/activemq-core.xsd">
	'''
}

def static String camelContext(Application it) {
	'''
	<camel:camelContext id="camel">
		<camel:package>«basePackage»</camel:package>
		«camelProducerTemplate(it)»
		«camelContextHook(it)»
	</camel:camelContext>
	'''
}

def static String camelEventBus(Application it) {
	'''
	<bean id="camelEventBusImpl" class="«fw("event.CamelEventBusImpl")»" />
	<alias name="camelEventBusImpl" alias="eventBus" />
	'''
}

def static String camelProducerTemplate(Application it) {
	'''
		<camel:template id="producerTemplate"/>
	'''
}

def static String camelContextHook(Application it) {
	'''
	'''
}

def static String camelJmsEndpoint(Application it) {
	'''
	<!--
		Camel ActiveMQ to use the ActiveMQ broker 
	-->
	<bean id="jms" class="org.apache.activemq.camel.component.ActiveMQComponent">
		<property name="brokerURL" value="tcp://localhost:61616" />
	</bean>
	'''
}

def static String camelTestJmsEndpoint(Application it) {
	'''
	<!--
		Camel ActiveMQ to use the inmemory ActiveMQ broker 
	-->
	<bean id="jms" class="org.apache.activemq.camel.component.ActiveMQComponent">
		<property name="brokerURL" value="vm://localhost?broker.persistent=false" />
	</bean>
	'''
}
}
