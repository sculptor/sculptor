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

package org.sculptor.generator.template.service

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class ServiceTmpl {

def static String service(Service it) {
	'''
		«serviceInterface(it)»
		
		«IF pureEjb3()»
			«ServiceEjb::service(it)»
		«ELSE»
			«serviceImplBase(it)»
	    «IF gapClass»
	    	«serviceImplSubclass(it)»
	    «ENDIF»
		«ENDIF»

		«IF webService»
			«ServiceEjb::webServiceInterface(it)»
			«ServiceEjb::webServicePackageInfo(it)»
		«ENDIF»

	«IF isTestToBeGenerated()»
	    «ServiceTest::serviceJUnitBase(it)»
	    «IF pureEjb3()»
	    	«ServiceEjbTest::serviceJUnitSubclassOpenEjb(it)»
		«ELSEIF applicationServer() == "appengine"»
			«ServiceTest::serviceJUnitSubclassAppEngine(it)»
		«ELSEIF mongoDb()»
			«MongoDbServiceTestTmpl::serviceJUnitSubclassMongoDb(it)»
		«ELSE»
	    	«ServiceTest::serviceJUnitSubclassWithAnnotations(it)»
		«ENDIF»
		«IF isDbUnitTestDataToBeGenerated()»
			«ServiceTest::dbunitTestData(it)»
		«ENDIF»
	    «IF !otherDependencies.isEmpty»
	        «ServiceTest::serviceDependencyInjectionJUnit(it)»
	    «ENDIF»
	«ENDIF»
	'''
}

def static String serviceInterface(Service it) {
	'''
	'''
	fileOutput(javaFileName(getServiceapiPackage() + "." + name), '''
	«javaHeader()»
	package «getServiceapiPackage()»;

	«IF formatJavaDoc() == "" »
/**
 * Generated interface for the Service «name».
 */
	«ELSE »
	«formatJavaDoc()»
	«ENDIF »
	public interface «name» «IF subscribe != null»^extends «fw("event.EventSubscriber")» «ENDIF»{

	«IF isSpringToBeGenerated()»
		public final static String BEAN_ID = "«name.toFirstLower()»";
		«ENDIF»

		«it.operations.filter(op | op.isPublicVisibility()).forEach[interfaceMethod(it)]»
		
		«serviceInterfaceHook(it)»

	}
	'''
	)
	'''
	'''
}

def static String interfaceMethod(ServiceOperation it) {
	'''
		«formatJavaDoc()»
		public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[anotParamTypeAndName(it)]») « EXPAND ExceptionTmpl::throws»;
	'''
}



def static String serviceImplBase(Service it) {
	'''
	'''
	fileOutput(javaFileName(getServiceimplPackage() + "." + name + "Impl" + (gapClass ? "Base" : "")), '''
	«javaHeader()»
	package «getServiceimplPackage()»;

	«IF gapClass»
/**
 * Generated base class for implementation of «name».
	«IF isSpringToBeGenerated() »
 * <p>Make sure that subclass defines the following annotations:
 * <pre>
	«springServiceAnnotation(it)»
 * </pre>
 *	«ENDIF»
 */
	«ELSE»
 /**
 * Implementation of «name».
 */
	«IF isSpringToBeGenerated()»
		«springServiceAnnotation(it)»
	«ENDIF»
	«IF !gapClass && webService»
		«ServiceEjb::webServiceAnnotations(it)»
	«ENDIF»
	«ENDIF»
	«IF subscribe != null»«PubSubTmpl::subscribeAnnotation(it) FOR subscribe»«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name»Impl«IF gapClass»Base«ENDIF» «^extendsLitteral()» implements «getServiceapiPackage()».«name» {

		public «name»Impl«IF gapClass»Base«ENDIF»() {
		}

		«delegateRepositories(it) »
		«delegateServices(it) »

		«it.operations.reject(op | op.isImplementedInGapClass()) .forEach[implMethod(it)]»
		
		«serviceHook(it)»
	}
	'''
	)
	'''
	'''
}

def static String springServiceAnnotation(Service it) {
	'''
	@org.springframework.stereotype.Service("«name.toFirstLower()»")
	'''
}

def static String delegateRepositories(Service it) {
	'''
	«FOR delegateRepository  : getDelegateRepositories()»
		«IF isSpringToBeGenerated()»
	    	@org.springframework.beans.factory.annotation.Autowired
		«ENDIF»
		«IF pureEjb3()»
			@javax.ejb.EJB
		«ENDIF»
			private «getRepositoryapiPackage(delegateRepository.aggregateRoot.module)».«delegateRepository.name» «delegateRepository.name.toFirstLower()»;

			protected «getRepositoryapiPackage(delegateRepository.aggregateRoot.module)».«delegateRepository.name» get«delegateRepository.name»() {
				return «delegateRepository.name.toFirstLower()»;
			}
		«ENDFOR»
	'''
}

def static String delegateServices(Service it) {
	'''
	«FOR delegateService  : getDelegateServices()»
		«IF isSpringToBeGenerated()»
	    	@org.springframework.beans.factory.annotation.Autowired
		«ENDIF»
		«IF pureEjb3()»
			@javax.ejb.EJB
		«ENDIF»
			private «getServiceapiPackage(delegateService)».«delegateService.name»«IF pureEjb3()»Local«ENDIF» «delegateService.name.toFirstLower()»;

			protected «getServiceapiPackage(delegateService)».«delegateService.name» get«delegateService.name»() {
				return «delegateService.name.toFirstLower()»;
			}
		«ENDFOR»
	'''
}

def static String serviceImplSubclass(Service it) {
	'''
	'''
	fileOutput(javaFileName(getServiceimplPackage() + "." + name + "Impl"), 'TO_SRC', '''
	«javaHeader()»
	package «getServiceimplPackage()»;

/**
 * Implementation of «name».
 */
	«IF isSpringToBeGenerated()»
	@org.springframework.stereotype.Service("«name.toFirstLower()»")
	«ENDIF»
	«IF webService»
	«ServiceEjb::webServiceAnnotations(it)»
	«ENDIF»
	public class «name»Impl ^extends «name»ImplBase {

		public «name»Impl() {
		}

	«otherDependencies(it)»

		«it.operations.filter(op | op.isImplementedInGapClass()) .forEach[implMethod(it)]»

	}
	'''
	)
	'''
	'''
}

def static String otherDependencies(Service it) {
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
			throw new UnsupportedOperationException("Implement setter for dependency injection of «dependency» in «name»Impl");
		}

		«ENDFOR»
	'''
}

def static String implMethod(ServiceOperation it) {
	'''
		«IF delegate != null »
		/**
			* Delegates to {@link «getRepositoryapiPackage(delegate.repository.aggregateRoot.module)».«delegate.repository.name»#«delegate.name»}
			*/
		«ELSEIF serviceDelegate != null »
		/**
			* Delegates to {@link «getServiceapiPackage(serviceDelegate.service)».«serviceDelegate.service.name»#«serviceDelegate.name»}
			*/
		«ENDIF »
	«serviceMethodAnnotation(it)»
		«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
		«IF delegate != null »
			«IF delegate.getTypeName() == "void" && getTypeName() != "void"»
				/*This is a special case which is used for save operations, when rcp nature */
				«delegate.repository.name.toFirstLower()».«delegate.name»(«FOR parameter SEPARATOR ", " : parameters.filter(p | p.type != serviceContextClass())»«parameter.name»«ENDFOR»);
				return «parameters.get(isServiceContextToBeGenerated() ? 1 : 0).name»;
			«ELSE»
				«IF getTypeName() != "void" »return «ENDIF»
					«delegate.repository.name.toFirstLower()».«delegate.name»(«FOR parameter SEPARATOR ", " : parameters.filter(p | p.type != serviceContextClass())»«parameter.name»«ENDFOR»);
			«ENDIF»
		«ELSEIF serviceDelegate != null »
				«IF serviceDelegate.getTypeName() != "void" && getTypeName() != "void" »return «ENDIF»
					«serviceDelegate.service.name.toFirstLower()».«serviceDelegate.name»(«FOR parameter SEPARATOR ", " : parameters»«parameter.name»«ENDFOR»);
		«ELSE»
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
		«ENDIF»
			}
	'''
}

def static String serviceMethodAnnotation(ServiceOperation it) {
	'''
	/*spring transaction support */
	«IF isSpringAnnotationTxToBeGenerated()»
		«IF name.startsWith("get") || name.startsWith("find")»
	@org.springframework.transaction.annotation.Transactional(readOnly=true)
		«ELSE»
	@org.springframework.transaction.annotation.Transactional(readOnly=false, rollbackFor=org.fornax.cartridges.sculptor.framework.errorhandling.ApplicationException.class)
		«ENDIF»
	«ENDIF»
	«IF pureEjb3() && jpa() && !name.startsWith("get") && !name.startsWith("find")»
	@javax.interceptor.Interceptors({«service.module.getJpaFlushEagerInterceptorClass()».class})
	«ENDIF»
	«IF service.webService»
	@javax.jws.WebMethod
	«ENDIF»
	«IF publish != null»«PubSubTmpl::publishAnnotation(it) FOR publish»«ENDIF»
	'''
}

def static String paramTypeAndName(Parameter it) {
	'''
	«getTypeName()» «name»
	'''
}

def static String anotParamTypeAndName(Parameter it) {
	'''
	«IF isGenerateParameterName()» @«fw("annotation.Name")»("«name»")«ENDIF» «getTypeName()» «name»
	'''
}

def static String serialVersionUID(Service it) {
	'''
		private static final long serialVersionUID = 1L;
	'''
}


/*Extension point to generate more stuff in service interface.
	User AROUND ServiceTmpl::serviceInterfaceHook FOR Service
	in SpecialCases.xpt */
def static String serviceInterfaceHook(Service it) {
	'''
	'''
}

/*Extension point to generate more stuff in service implementation.
	User AROUND ServiceTmpl::serviceHook FOR Service
	in SpecialCases.xpt */
def static String serviceHook(Service it) {
	'''
	'''
}
}
