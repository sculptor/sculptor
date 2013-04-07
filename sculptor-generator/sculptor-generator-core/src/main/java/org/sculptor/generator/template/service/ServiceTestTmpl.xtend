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

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.db.DbUnitTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Service

class ServiceTestTmpl {

	@Inject private var DbUnitTmpl dbUnitTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String serviceJUnitBase(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "TestBase"), OutputSlot::TO_GEN_SRC_TEST, '''
	«javaHeader()»
	package «it.getServiceapiPackage()»;

	/**
	 * Definition of test methods to implement.
	 */
	public interface «name»TestBase {
		«/* There may be several operations with the same name
		  * and to avoid name collision we only generate one test method.
		  */»
		«it.operations.filter(op | op.isPublicVisibility()).map(op| op.name).toSet().map[testInterfaceMethod(it)].join()»
	}
	'''
	)
}

/*this (FOR String) is the name of the operation */
def String testInterfaceMethod(String it) {
	'''
		public void test«it.toFirstUpper()»() throws Exception;
	'''
}

def String serviceJUnitSubclassWithAnnotations(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Test"), OutputSlot::TO_SRC_TEST, '''
	«javaHeader()»
	package «it.getServiceapiPackage()»;

	import static org.junit.Assert.fail;

	/**
	 * Spring based transactional test with DbUnit support.
	 */
	public class «name»Test extends «databaseJpaTestCaseClass()» implements «name»TestBase {

		«serviceJUnitDependencyInjection(it)»

		«serviceJUnitGetDataSetFile(it)»

		«it.operations.filter(op | op.isPublicVisibility()).map(op| op.name).toSet().map[testMethod(it)].join()»
	}
	'''
	)
}

def String serviceJUnitDependencyInjection(Service it) {
	'''
		@org.springframework.beans.factory.annotation.Autowired
		protected «it.getServiceapiPackage()».«name» «name.toFirstLower()»;
	'''
}

def String serviceJUnitSubclassAppEngine(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Test"), OutputSlot::TO_SRC_TEST, '''
	«javaHeader()»
	package «it.getServiceapiPackage()»;

	import static org.junit.Assert.assertNotNull;
	import static org.junit.Assert.assertTrue;
	import static org.junit.Assert.fail;

	/**
	 * Spring based test with Google App Engine support.
	 */
	public class «name»Test extends «fw("test.AbstractAppEngineJpaTests")» implements «name»TestBase {

	«serviceJUnitDependencyInjection(it)»
	
	«serviceJUnitSubclassAppEnginePopulateDataStore(it)»
	
		«it.operations.filter(op | op.isPublicVisibility()).map(op| op.name).toSet().map[testMethod(it)]»
	}
	'''
	)
}

def String serviceJUnitSubclassAppEnginePopulateDataStore(Service it) {
	'''
		@org.junit.Before
		public void populateDatastore() {
			// here you can add objects to data store before test methods are executed
			// getEntityManager().persist(obj);
		}
	'''
}



def String serviceJUnitGetDataSetFile(Service it) {
	'''
	«IF getDbUnitDataSetFile() != null»
		@Override
		protected String getDataSetFile() {
			return "«getDbUnitDataSetFile()»";
		}
	«ENDIF»
	'''
}

/*this (FOR String) is the name of the operation */
def String testMethod(String it) {
	'''
	@org.junit.Test
	public void test«it.toFirstUpper()»() throws Exception {
		// TODO Auto-generated method stub
		fail("test«it.toFirstUpper()» not implemented");
	}
	'''
}

def String dbunitTestData(Service it) {
	fileOutput("dbunit/" + name + "Test.xml", OutputSlot::TO_RESOURCES_TEST, '''
		«dbUnitTmpl.dbunitTestDataContent(it.module.application)»
	'''
	)
}

def String serviceDependencyInjectionJUnit(Service it) {
	fileOutput(javaFileName(it.getServiceimplPackage() + "." + name + "DependencyInjectionTest"), OutputSlot::TO_GEN_SRC_TEST, '''
	«javaHeader()»
	package «it.getServiceimplPackage()»;

	/**
	 * JUnit test to verify that dependency injection setter methods
	 * of other Spring beans have been implemented.
	 */
	public class «name»DependencyInjectionTest extends junit.framework.TestCase {

		«it.otherDependencies.map[d | serviceDependencyInjectionTestMethod(d, it)]»

	}
	'''
	)
}

/*This (String) is the name of the dependency */
def String serviceDependencyInjectionTestMethod(String it, Service service) {
	'''
	public void test«it.toFirstUpper()»Setter() throws Exception {
		Class clazz = «service.getServiceimplPackage()».«service.name»Impl.class;
		java.lang.reflect.Method[] methods = clazz.getMethods();
		String setterMethodName = "set«it.toFirstUpper()»";
		java.lang.reflect.Method setter = null;
		for (int i = 0; i < methods.length; i++) {
			if (methods[i].getName().equals(setterMethodName) &&
			        void.class.equals(methods[i].getReturnType()) &&
			        methods[i].getParameterTypes().length == 1) {
			    setter = methods[i];
			    break;
			}
		}

		assertNotNull("Setter method for dependency injection of " +
			        "«it» must be defined in «service.name».",
			        setter);

		«service.getServiceimplPackage()».«service.name»Impl «service.name.toFirstLower()» = new «service.getServiceimplPackage()».«service.name»Impl();
		try {
			setter.invoke(«service.name.toFirstLower()», new Object[] {null});
		} catch (java.lang.reflect.InvocationTargetException e) {
			if (e.getCause().getClass().equals(UnsupportedOperationException.class)) {
			    assertTrue(e.getCause().getMessage(), false);
			} else {
			    // exception due to something else, but the method was not forgotten
			}
		}

	}
	'''
}
}
