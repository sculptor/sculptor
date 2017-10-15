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
package org.sculptor.generator.template.consumer

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.common.PubSubTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Consumer

@ChainOverridable
class ConsumerTmpl {

	@Inject private var PubSubTmpl pubSubTmpl
	@Inject private var ConsumerEjbTmpl consumerEjbTmpl
	@Inject private var ConsumerEjbTestTmpl consumerEjbTestTmpl
	@Inject private var ConsumerTestTmpl consumerTestTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

def String consumer(Consumer it) {
	'''
	«IF pureEjb3()»
		«consumerEjbTmpl.messageBeanImplBase(it)»
		«consumerEjbTmpl.messageBeanImplSubclass(it)»
	«ELSE»
		«consumerInterface(it)»
		«eventConsumerImplBase(it)»
		«eventConsumerImplSubclass(it)»
	«ENDIF»

	«IF isTestToBeGenerated()»
		«consumerTest(it)»
		«IF isDbUnitTestDataToBeGenerated()»
			«consumerTestDbUnitData(it)»
		«ENDIF»
	«ENDIF»
	'''
}

def void consumerTest(Consumer it) {
	if(pureEjb3) {
		consumerEjbTestTmpl.consumerJUnitOpenEjb(it)
	} else if(applicationServer() == "appengine") {
		/* TODO */
	} else {
		consumerTestTmpl.consumerJUnitWithAnnotations(it)
	}
}

def void consumerTestDbUnitData(Consumer it) {
	consumerTestTmpl.dbunitTestData(it)
}

def String consumerInterface(Consumer it) {
	fileOutput(javaFileName(it.getConsumerPackage() + "." + name), OutputSlot.TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getConsumerPackage()»;

/// Sculptor code formatter imports ///

	public interface «name» extends «consumerInterface()» {

	}
	'''
	)
}


def String eventConsumerImplBase(Consumer it) {
	fileOutput(javaFileName(it.getConsumerPackage() + "." + name + "ImplBase"), OutputSlot.TO_GEN_SRC, '''
	«javaHeader()»
	package «it.getConsumerPackage()»;

/// Sculptor code formatter imports ///

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
	«IF subscribe !== null»«pubSubTmpl.subscribeAnnotation(it.subscribe)»«ENDIF»
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


def String eventConsumerImplSubclass(Consumer it) {
	fileOutput(javaFileName(it.getConsumerPackage() + "." + name + "Impl"), OutputSlot.TO_SRC, '''
	«javaHeader()»
	package «it.getConsumerPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * Implementation of «name».
	 */
	«IF isSpringToBeGenerated()»
		@org.springframework.stereotype.Component("«name.toFirstLower()»")
	«ENDIF»
	public class «name»Impl extends «name»ImplBase {

		public «name»Impl() {
		}

		«otherDependencies(it)»

		«receiveMethodSubclass(it)»

	}
	'''
	)
}

def String receiveMethodSubclass(Consumer it) {
	'''
	public void receive(«fw("event.Event")» event) {
		// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
	}
	'''
}

def String serviceDependencies(Consumer it) {
	'''
	«FOR serviceDependency : serviceDependencies»
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

def String repositoryDependencies(Consumer it) {
	'''
	«FOR repositoryDependency : repositoryDependencies»
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

def String otherDependencies(Consumer it) {
	'''
	«FOR dependency : otherDependencies»
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

def String consumeMethodBase(Consumer it) {
	'''
	«IF messageRoot !== null»
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

def String consumeMethodSubclass(Consumer it) {
	'''
	«IF messageRoot === null»
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

/* TODO move to common template */
def String serialVersionUID(Consumer it) {
	'''private static final long serialVersionUID = 1L;'''
}

/* Extension point to generate more stuff in consumer implementation.
	User AROUND consumerTmpl.consumerHook FOR Consumer
	in SpecialCases.xpt */
def String consumerHook(Consumer it) {
	''''''
}



}
