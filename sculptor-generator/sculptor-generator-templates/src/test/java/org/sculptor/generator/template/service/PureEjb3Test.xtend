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

package org.sculptor.generator.template.service

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class PureEjb3Test extends GeneratorTestBase {

	static val TEST_NAME = "pure-ejb3"

	new() {
		super(TEST_NAME)
	}

	@BeforeAll
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertConsumerBeanBean() {
		val bean = getFileText(TO_SRC + "/org/sculptor/example/helloworld/milkyway/consumer/PlanetConsumerBean.java")
		assertContains(bean, '@MessageDriven(name = "planetConsumer", messageListenerInterface = MessageListener.class, activationConfig = {')
	}

	@Test
	def void assertWebServiceBean() {
		val bean = getFileText(TO_SRC + "/org/sculptor/example/helloworld/milkyway/serviceimpl/PlanetWebServiceBean.java")
		assertContains(bean, '@Stateless(name = "planetWebService")')
	}

	@Test
	def void assertPackageInfo() {
		val info = getFileText(TO_GEN_SRC + "/org/sculptor/example/helloworld/milkyway/serviceapi/package-info.java")
		assertContains(info, 'import javax.xml.bind.annotation.XmlSchema;')
	}

	@Test
	def void assertPersistenceXml() {
		val info = getFileText(TO_GEN_RESOURCES + "/META-INF/persistence.xml")
		assertContains(info, '<jta-data-source>java:/jdbc/UniverseDS</jta-data-source>')
		assertContains(info, '<property name="jboss.entity.manager.factory.jndi.name" value="java:/UniverseEntityManagerFactory"/>')

		// JBoss AS 7 ships with Infinispan as default cach provider - so no cache provider configuration is necessary
		assertNotContains(info, 'RegionFactory"/>')
	}

}
