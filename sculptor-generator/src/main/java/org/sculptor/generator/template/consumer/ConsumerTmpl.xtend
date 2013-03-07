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

import org.sculptor.generator.template.common.PubSubTmpl
import sculptormetamodel.Consumer

import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.consumer.ConsumerTmpl.*
import static org.sculptor.generator.util.PropertiesBase.*

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*

class ConsumerTmpl {

def static String consumer(Consumer it) {
	'''
	«IF pureEjb3()»
		«ConsumerEjbTmpl::messageBeanImplBase(it)»
			«ConsumerEjbTmpl::messageBeanImplSubclass(it)»
	«ELSE»
		«consumerInterface(it)»
		«eventConsumerImplBase(it)»
			«eventConsumerImplSubclass(it)»
	«ENDIF»
		
		«IF isTestToBeGenerated()»
	    «IF pureEjb3()»
	    	«ConsumerEjbTestTmpl::consumerJUnitOpenEjb(it)»
	    «ELSEIF applicationServer() == "appengine"»
	    	/*TODO */
	    «ELSEIF mongoDb()»
	    	/*TODO */
	    «ELSE»
		    «ConsumerTestTmpl::consumerJUnitWithAnnotations(it)»
		«ENDIF»
		«IF isDbUnitTestDataToBeGenerated()»
			«ConsumerTestTmpl::dbunitTestData(it)»
		«ENDIF»
	«ENDIF»
	'''
}

def static String consumerInterface(Consumer it) {
	fileOutput(javaFileName(getConsumerPackage() + "." + name), '''
	«javaHeader()»
	package «getConsumerPackage()»;

	public interface «name» ^extends «consumerInterface()» {

	}
	'''
	)
}


def static String eventConsumerImplBase(Consumer it) {
	fileOutput(javaFileName(getConsumerPackage() + "." + name + "ImplBase"), '''
	«javaHeader()»
	package «getConsumerPackage()»;

	«IF it.formatJavaDoc() == "" »
	/**
	 * Generated base class for implementation of Consumer «name».
	«IF isSpringToBeGenerated() »
		 * <p>Make sure that subclass defines the following annotations:
		 * <pre>
		    @org.springframework.stereotype.Component("«name.toFirstLower()»")
		 * </pre>
		 *
	«ENDIF»
	 */
	«ELSE »
		«it.formatJavaDoc()»
	«ENDIF »
	«IF subscribe != null»«PubSubTmpl::subscribeAnnotation(it.subscribe)»«ENDIF»
	public abstract class «name»ImplBase implements «name» {

		public final static String BEAN_ID = "«name.toFirstLower()»";

		public «name»ImplBase() {
		}
		
		«serviceDependencies(it)»
		«repositoryDependencies(it)»

		«consumerHook(it)»

	}
	'''
	)
}


def static String eventConsumerImplSubclass(Consumer it) {
	fileOutput(javaFileName(getConsumerPackage() + "." + name + "Impl"), 'TO_SRC', '''
	«javaHeader()»
	package «getConsumerPackage()»;

	/**
	 * Implementation of «name».
	 */
	«IF isSpringToBeGenerated()»
		@org.springframework.stereotype.Component("«name.toFirstLower()»")
	«ENDIF»
	public class «name»Impl ^extends «name»ImplBase {

		public «name»Impl() {
		}

		«otherDependencies(it)»

		«receiveMethodSubclass(it)»

	}
	'''
	)
}

def static String receiveMethodSubclass(Consumer it) {
	'''
	public void receive(«fw("event.Event")» event) {
		// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
	}
	'''
}

def static String serviceDependencies(Consumer it) {
	'''
	«FOR serviceDependency  : serviceDependencies»
		«IF isSpringToBeGenerated()»
			@org.springframework.beans.factory.annotation.Autowired
		«ENDIF»
		«IF pureEjb3()»
			@javax.ejb.EJB
		«ENDIF»
			private «getServiceapiPackage(serviceDependency)».«serviceDependency.name»«IF pureEjb3()»Local«ENDIF» «serviceDependency.name.toFirstLower()»;
		
			protected «getServiceapiPackage(serviceDependency)».«serviceDependency.name» get«serviceDependency.name»() {
				return «serviceDependency.name.toFirstLower()»;
			}
	«ENDFOR»
	'''
}

def static String repositoryDependencies(Consumer it) {
	'''
	«FOR repositoryDependency  : repositoryDependencies»
		«IF isSpringToBeGenerated()»
			@org.springframework.beans.factory.annotation.Autowired
		«ENDIF»
		«IF pureEjb3()»
			@javax.ejb.EJB
		«ENDIF»
			private «getRepositoryapiPackage(repositoryDependency.aggregateRoot.module)».«repositoryDependency.name» «repositoryDependency.name.toFirstLower()»;
			
			protected «getRepositoryapiPackage(repositoryDependency.aggregateRoot.module)».«repositoryDependency.name» get«repositoryDependency.name»() {
				return «repositoryDependency.name.toFirstLower()»;
			}
	«ENDFOR»
	'''
}

def static String otherDependencies(Consumer it) {
	'''
	«FOR dependency  : otherDependencies»
		/**
			* Dependency injection
			*/
	«IF isSpringToBeGenerated()»
		@org.springframework.beans.factory.annotation.Autowired
	«ENDIF»
	«IF pureEjb3()»
		@javax.ejb.EJB
	«ENDIF»
		public void set«dependency.toFirstUpper()»(Object «dependency») {
			// TODO implement setter for dependency injection of «dependency»
			throw new UnsupportedOperationException("Implement setter for dependency injection of «dependency» in «name»");
		}

		«ENDFOR»
	'''
}

def static String consumeMethodBase(Consumer it) {
	'''
	«IF messageRoot != null»
		public String consume(String textMessage)
			throws «applicationExceptionClass()» {

			«getXmlMapperPackage()».«messageRoot.name»Mapper mapper = new «getXmlMapperPackage()».«messageRoot.name»Mapper(textMessage);
			return consume(mapper.get«messageRoot.name»());
		}

		protected abstract String consume(«messageRoot.getDomainPackage()».«messageRoot.name» «messageRoot.name.toFirstLower()»)
			throws «applicationExceptionClass()»;
		«ENDIF»
	'''
}

def static String consumeMethodSubclass(Consumer it) {
	'''
	«IF messageRoot == null»
		public String consume(String textMessage) throws «applicationExceptionClass()» {
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name».consume not implemented");

			//return null; // no reply
		}
		«ELSE»
		protected String consume(«messageRoot.getDomainPackage()».«messageRoot.name» «messageRoot.name.toFirstLower()»)
			throws «applicationExceptionClass()» {

			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name».consume not implemented");

			//return null; // no reply
		}
		«ENDIF»
	'''
}

/*TODO move to common template */
def static String serialVersionUID(Consumer it) {
	'''
		private static final long serialVersionUID = 1L;
	'''
}

/*Extension point to generate more stuff in consumer implementation.
	User AROUND ConsumerTmpl::consumerHook FOR Consumer
	in SpecialCases.xpt */
def static String consumerHook(Consumer it) {
	'''
	'''
}



}
