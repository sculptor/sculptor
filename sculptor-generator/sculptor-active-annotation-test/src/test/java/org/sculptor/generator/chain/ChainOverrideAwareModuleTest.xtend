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
package org.sculptor.generator.chain

import com.google.inject.Guice
import generator.TestTemplateOverride
import org.junit.Test
import org.sculptor.generator.cartridge.test.TestTemplateExtension

import static org.junit.Assert.*

class ChainOverrideAwareModuleTest {

	val templateClass = typeof(TestTemplate)

	@Test
	def void testTmplateExtensions() {
		val injector = Guice::createInjector(new ChainOverrideAwareModule(templateClass));

		val templateOverride = injector.getInstance(templateClass) as TestTemplateOverride
		assertNotNull(templateOverride)

		val templateExtension = templateOverride.next.next as TestTemplateExtension
		assertNotNull(templateExtension)

		val templateExtension2 = templateExtension.next.next as org.sculptor.generator.cartridge.test2.TestTemplateExtension
		assertNotNull(templateExtension2)

		val template = templateExtension2.next.next
		assertNotNull(template)

		// Head of chain - the override class
		val methodDispatchHead = template.methodsDispatchHead
		assertNotNull(methodDispatchHead)
		assertEquals(5, methodDispatchHead.size)	

		assertSame(template, methodDispatchHead.get(0))
		assertSame(template, methodDispatchHead.get(1))
		assertSame(templateOverride, methodDispatchHead.get(2))
		assertSame(template, methodDispatchHead.get(3))
		assertSame(template, methodDispatchHead.get(4))

		// Next in chain - the first extension
		val templateOverrideNextObj = templateOverride.next as TestTemplateMethodDispatch
		assertEquals(5, templateOverrideNextObj.methodsDispatchTable.size)	

		assertSame(template, templateOverrideNextObj.methodsDispatchTable.get(0))
		assertSame(template, templateOverrideNextObj.methodsDispatchTable.get(1))
		assertSame(templateExtension, templateOverrideNextObj.methodsDispatchTable.get(2))
		assertSame(template, templateOverrideNextObj.methodsDispatchTable.get(3))
		assertSame(template, templateOverrideNextObj.methodsDispatchTable.get(4))

		// Next in chain - the second extension
		val templateExtensionNextObj = templateExtension.next as TestTemplateMethodDispatch
		assertNotNull(templateExtensionNextObj)
		assertEquals(5, templateExtensionNextObj.methodsDispatchTable.size)	

		assertSame(template, templateExtensionNextObj.methodsDispatchTable.get(0))
		assertSame(template, templateExtensionNextObj.methodsDispatchTable.get(1))
		assertSame(templateExtension2, templateExtensionNextObj.methodsDispatchTable.get(2))
		assertSame(template, templateExtensionNextObj.methodsDispatchTable.get(3))
		assertSame(template, templateExtensionNextObj.methodsDispatchTable.get(4))

		// Last in chain - the template
		val templateExtension2NextObj = templateExtension2.next as TestTemplateMethodDispatch
		assertNotNull(templateExtension2NextObj)
		assertEquals(5, templateExtension2NextObj.methodsDispatchTable.size)	

		assertSame(template, templateExtension2NextObj.methodsDispatchTable.get(0))
		assertSame(template, templateExtension2NextObj.methodsDispatchTable.get(1))
		assertSame(template, templateExtension2NextObj.methodsDispatchTable.get(2))
		assertSame(template, templateExtension2NextObj.methodsDispatchTable.get(3))
		assertSame(template, templateExtension2NextObj.methodsDispatchTable.get(4))
	}

	@Test
	def void testCommonProperties() {
		val module = new ChainOverrideAwareModule(templateClass)
		assertNotNull(module)
		assertEquals("test,test2", module.cartridgeNames.join(','))
	}

}
