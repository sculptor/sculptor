/*
 * Copyright 2007 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.consumer

import org.sculptor.generator.ext.GeneratorFactory
import org.sculptor.generator.ext.GeneratorFactoryImpl

import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Consumer

import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties

import org.sculptor.generator.util.PropertiesBase

import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.XmlHelperBase

class ConsumerEjbTestTmpl {
	private static val GeneratorFactory GEN_FACTORY = GeneratorFactoryImpl::getInstance()

	private static val ConsumerTestTmpl consumerTestTmpl = GEN_FACTORY.consumerTestTmpl

	extension HelperBase helperBase = GEN_FACTORY.helperBase
	extension Helper helper = GEN_FACTORY.helper
	extension PropertiesBase propertiesBase = GEN_FACTORY.propertiesBase
	extension Properties properties = GEN_FACTORY.properties
	extension XmlHelperBase xmlHelperBase = GEN_FACTORY.xmlHelperBase

	def String consumerJUnitOpenEjb(Consumer it) {
		fileOutput(javaFileName(getConsumerPackage() + "." + name + "Test"), OutputSlot::TO_SRC_TEST, '''
		«javaHeader()»
		package «getConsumerPackage()»;

		import static org.junit.Assert.assertNotNull;
		import static org.junit.Assert.assertTrue;
		import static org.junit.Assert.fail;

		/**
		 * JUnit test with OpenEJB and DbUnit support.
		 */
		public class «name»Test ^extends «IF jpa()»«fw("test.AbstractOpenEJBDbUnitTest")»«ELSE»«fw("test.AbstractOpenEJBTest")»«ENDIF» {

			@javax.annotation.Resource(mappedName="«name.toFirstLower()»")
			private javax.jms.Queue queue;

		«consumerTestTmpl.consumerJUnitGetDataSetFile(it)»

			«openEjbTestMethod(it)»

			«junitCreateMessage(it)»

		}
		'''
		)
	}
	
	def String openEjbTestMethod(Consumer it) {
		'''
		@org.junit.Test
			public void testConsume() throws Exception {
				// TODO Auto-generated method stub
				String message = createMessage();
				javax.jms.Destination replyTo = sendMessage(queue, message);
				waitForReply(replyTo);
				fail("testConsume not implemented");
			}
		'''
	}
	
	def String junitCreateMessage(Consumer it) {
		'''
		«IF messageRoot == null»
		private String createMessage() {
			String msg =
				"<?xml version='1.0' encoding='UTF-8'?>\n" +
				"<«name.toXmlName()»-message>\n" +
				"</«name.toXmlName()»-message>\n";
			return msg;
		}
		«ELSE»
		«val prefix = it.module.application.name.substring(0,1).toLowerCase()»
		private String createMessage() {
			String msg =
				"<?xml version='1.0' encoding='UTF-8'?>\n" +
				"<«prefix»:«messageRoot.name.toXmlName()»>\n" +
				"    xmlns:«prefix»='«module.application.schemaUrl()»' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='«module.application.schemaUrl()» «module.application.schemaUrl()»/schemas/«messageRoot.name.toXmlName()».xsd'" +
				"</«prefix»:«messageRoot.name.toXmlName()»>\n";
			return msg;
		}
		«ENDIF»
		'''
	}
}
