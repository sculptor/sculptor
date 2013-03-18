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

import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.junit.runners.JUnit4
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslInheritanceType
import org.sculptor.dsl.sculptordsl.SculptordslFactory
import sculptormetamodel.Entity
import sculptormetamodel.InheritanceType
import sculptormetamodel.Module
import sculptormetamodel.Service
import sculptormetamodel.ValueObject

import static org.junit.Assert.*
import static org.sculptor.generator.SculptorDslTransformationTest.*
import org.sculptor.generator.ext.GeneratorFactory
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.GeneratorFactoryImpl

@RunWith(typeof(JUnit4))
class SculptorDslTransformationTest {

	private static val SculptordslFactory FACTORY = SculptordslFactory::eINSTANCE
	private static val GeneratorFactory GEN_FACTORY = GeneratorFactoryImpl::getInstance()

	extension Helper helper = GEN_FACTORY.helper

	var DslApplication model

	@Before
	def void setupDslModel() {
		model =  createDslModel
	}
	
	@Test
	def testTransformDslModel() {
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
			assertEquals("module" + i + "Value2", getHint(module, "key2"))

			assertEquals(1, module.services.size)
			val service = module.services.get(0) as Service
			assertEquals("service" + i + "Name", service.name)
			assertEquals("service" + i + "Doc", service.doc)
			assertEquals("service" + i + "Value2", getHint(service, "key2"))
			assertFalse(service.localInterface)
			assertFalse(service.remoteInterface)
		}
	}
	
	def getTransformedApp() {
		val transformation = new SculptorDslTransformation
		transformation.transform(model)
	}
	
	def getModule(String name) {
		transformedApp.modules.findFirst(mod | mod.name == name)
	}

	@Test
	def void testTransformEntity() {
		val module = getModule("module1Name")
		assertNotNull(module)
		assertEquals(2, module.domainObjects.size)
		val Entity entity1 = module.domainObjects.findFirst[name == "Entity1"] as Entity
		assertNotNull(entity1)
		entity1 => [
			assertEquals("Documentation1", doc)
			assertEquals("some.com.package", getPackage())			
			assertEquals("hint1", hint)
			assertEquals(false, auditable)
			assertEquals(false, cache)
			assertEquals("SOME_TABLE", databaseTable)
			assertNull(belongsToAggregate)
			assertTrue(aggregateRoot)
			assertEquals("validator1", validate)
			assertEquals(true, gapClass)
			assertEquals("disc1", discriminatorColumnValue)
			assertEquals(InheritanceType::JOINED, inheritance.type)
			assertNull(extendsName)
			assertEquals(0, attributes.size)
			assertEquals(0, references.size)
			assertEquals(0, operations.size)
			assertEquals(0, traits.size)
			assertNull(repository)
			
			// TODO: Verify references, attributes, etc
		]
	}
	
	@Test
	def void testTransformValueObject() {
		val module = getModule("module1Name")
		val ValueObject vo1 = module.domainObjects.findFirst[name == "ValueObject1"] as ValueObject
		assertNotNull(vo1)
		vo1 => [
			assertEquals("ValueObject doc1", doc)
			
			// TODO
		]
	}
	
	def createDslModel() {
		val service1 = FACTORY.createDslService
		service1.setName("service1Name")
		service1.setDoc("service1Doc")
		service1.setHint("key1 = service1Value1 , notRemote, notLocal , key2 = service1Value2 , key3")

		
		val entity1 = FACTORY.createDslEntity => [
			name = "Entity1"
			doc = "Documentation1"
			setPackage("some.com.package")
			hint = "hint1"
			setAbstract(true)
			notOptimisticLocking = true
			notAuditable = true
			cache = false
			databaseTable = "SOME_TABLE"
			belongsTo = null
			notAggregateRoot = false
			validate = "validator1"
			gapClass = true
			discriminatorValue = "disc1"
			inheritanceType = DslInheritanceType::JOINED
		]

		val vo1 = FACTORY.createDslValueObject => [
			name = "ValueObject1"
			doc = "ValueObject doc1"
			setPackage("some.com.package")
			hint = "vohint"
			
			// TODO
		]
		
		
		val module1 = FACTORY.createDslModule
		module1.setBasePackage("com.acme.module1")
		module1.setName("module1Name")
		module1.setDoc("module1Doc")
		module1.setHint("key1 = module1Value1 , key2 = module1Value2 , key3")
		module1.services.add(service1)
		module1.domainObjects.addAll(entity1, vo1)

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