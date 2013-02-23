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

package org.sculptor.generator

import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.sculptordsl.SculptordslFactory
import sculptormetamodel.Module
import sculptormetamodel.Service

import static org.junit.Assert.*
import static org.sculptor.generator.HelperExtensions.*
import static org.sculptor.generator.SculptorDslTransformationTest.*
import org.junit.runners.JUnit4

@RunWith(typeof(JUnit4))
class SculptorDslTransformationTest {

	private static val SculptordslFactory FACTORY = SculptordslFactory::eINSTANCE

	@Test
	def testTransformDslModel() {
		val model = createDslModel
		val transformation = new SculptorDslTransformation
		val app = transformation.transform(model)
		assertNotNull(app)
		assertEquals("appName", app.name)
		assertEquals("com.acme", app.basePackage)
		assertEquals("appDoc", app.doc)

		assertEquals(2, app.modules.size)
		for (i : 1..2) {
			val module = app.modules.get(i - 1) as Module
			assertEquals("module" + i + "Name", module.name)
			assertEquals("com.acme.module" + i, module.basePackage)
			assertEquals("module" + i + "Doc", module.doc)
			assertEquals("module" + i + "Value2", getHint(module.hint, "key2"))

			assertEquals(1, module.services.size)
			val service = module.services.get(0) as Service
			assertEquals("service" + i + "Name", service.name)
			assertEquals("service" + i + "Doc", service.doc)
			assertEquals("service" + i + "Value2", getHint(service.hint, "key2"))
			assertFalse(service.localInterface)
			assertFalse(service.remoteInterface)
		}
	}
	
	def createDslModel() {
		val service1 = FACTORY.createDslService
		service1.setName("service1Name")
		service1.setDoc("service1Doc")
		service1.setHint("key1 = service1Value1 , notRemote, notLocal , key2 = service1Value2 , key3")

		val module1 = FACTORY.createDslModule
		module1.setBasePackage("com.acme.module1")
		module1.setName("module1Name")
		module1.setDoc("module1Doc")
		module1.setHint("key1 = module1Value1 , key2 = module1Value2 , key3")
		module1.services.add(service1)

		val service2 = FACTORY.createDslService
		service2.setName("service2Name")
		service2.setDoc("service2Doc")
		service2.setHint("key1 = service2Value1 , notRemote, notLocal , key2 = service2Value2 , key3")

		val module2 = FACTORY.createDslModule
		module2.setBasePackage("com.acme.module2")
		module2.setName("module2Name")
		module2.setDoc("module2Doc")
		module2.setHint("key1 = module2Value1 , key2 = module2Value2 , key3")
		module2.services.add(service2)
		
		val app = FACTORY.createDslApplication
		app.setBasePackage("com.acme")
		app.setName("appName")
		app.setDoc("appDoc")
		app.modules.addAll(module1, module2)

		app
	}
}