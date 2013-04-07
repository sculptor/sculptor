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

package org.sculptor.generator.template.mongodb

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.service.ServiceTestTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Service

class MongoDbServiceTestTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties
	@Inject private var ServiceTestTmpl serviceTestTmpl

def String serviceJUnitSubclassMongoDb(Service it) {
	fileOutput(javaFileName(it.getServiceapiPackage() + "." + name + "Test"), OutputSlot::TO_SRC_TEST, '''
	«javaHeader()»
	package «it.getServiceapiPackage()»;

	import static org.junit.Assert.fail;

	/**
	 * Spring based test with MongoDB.
	 */
	@org.junit.runner.RunWith(org.springframework.test.context.junit4.SpringJUnit4ClassRunner.class)
	@org.springframework.test.context.ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
	public class «name»Test extends org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests implements «name»TestBase {


	«dependencyInjection(it)»
	«initTestData(it)»
	«initDbManagerThreadInstance(it)»
	«dropDatabase(it)»
	«countRows(it)»
	
		«it.operations.filter(op | op.isPublicVisibility()).map(op| op.name).toSet.map[serviceTestTmpl.testMethod(it)]»
	}
	'''
	)
}

def String dependencyInjection(Service it) {
	'''
	@org.springframework.beans.factory.annotation.Autowired
	private «fw("accessimpl.mongodb.DbManager")» dbManager;
	
	@org.springframework.beans.factory.annotation.Autowired
		private «it.getServiceapiPackage()».«name» «name.toFirstLower()»;
	'''
}

def String initTestData(Service it) {
	'''
		@org.junit.Before
		public void initTestData() {
		}
	'''
} 

def String initDbManagerThreadInstance(Service it) {
	'''
	@org.junit.Before
		public void initDbManagerThreadInstance() throws Exception {
			// to be able to do lazy loading of associations inside test class
			«fw("accessimpl.mongodb.DbManager")».setThreadInstance(dbManager);
		}
	'''
}

def String dropDatabase(Service it) {
	'''
		@org.junit.After
		public void dropDatabase() {
			java.util.Set<String> names = dbManager.getDB().getCollectionNames();
			for (String each : names) {
				if (!each.startsWith("system")) {
				    dbManager.getDB().getCollection(each).drop();
				}
			}
			// dbManager.getDB().dropDatabase();
		}
	'''
}

def String countRows(Service it) {
	'''
		private int countRowsInDBCollection(String name) {
			return (int) dbManager.getDBCollection(name).getCount();
		}
	'''
}
}
