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

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class ConsumerEjbTestTmpl {

def static String consumerJUnitOpenEjb(Consumer it) {
	'''
	'''
	fileOutput(javaFileName(getConsumerPackage() + "." + name + "Test"), 'TO_SRC_TEST', '''
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

	«ConsumerTest::consumerJUnitGetDataSetFile(it)»

		«openEjbTestMethod(it)»

		«junitCreateMessage(it)»

	}
	'''
	)
	'''
	'''
}

def static String openEjbTestMethod(Consumer it) {
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

def static String junitCreateMessage(Consumer it) {
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
		«val prefix = it.module.application.name.subString(0,1).toLowerCase()»
		private String createMessage() {
			String msg =
				"<?xml version='1.0' encoding='UTF-8'?>\n" +
				"<«prefix»:«messageRoot.name.toXmlName()»>\n" +
				"    xmlns:«prefix»='«module.application.getSchemaUrl()»' xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance' xsi:schemaLocation='«module.application.getSchemaUrl()» «module.application.getSchemaUrl()»/schemas/«messageRoot.name.toXmlName()».xsd'" +
				"</«prefix»:«messageRoot.name.toXmlName()»>\n";
			return msg;
		}
		«ENDIF»
	'''
}
}
