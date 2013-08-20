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
		
		val templateExtension = templateOverride.next.next as TestTemplateExtension
		
		val template = templateExtension.next.next as TestTemplate

		// Head of chain - the override class
		assertNotNull(templateOverride)
		val templateOverrideNextObj = templateOverride.next as TestTemplateMethodDispatch
		assertEquals(5, templateOverrideNextObj.methodsDispatchTable.size)	
		
		
		assertSame(templateExtension, templateOverrideNextObj.methodsDispatchTable.get(0))
		assertSame(template, templateOverrideNextObj.methodsDispatchTable.get(1))
		assertSame(template, templateOverrideNextObj.methodsDispatchTable.get(2))
		
		val methodDispatchHead = template.methodsDispatchHead
		assertNotNull(methodDispatchHead)

		assertSame(templateExtension, methodDispatchHead.get(0))
		assertSame(template, methodDispatchHead.get(1))
		assertSame(templateOverride, methodDispatchHead.get(2))

		val templateExtensionNextObj = templateExtension.next as TestTemplateMethodDispatch
		
		assertEquals(5, templateExtensionNextObj.methodsDispatchTable.size)
		assertSame(template, templateExtensionNextObj.methodsDispatchTable.get(0))
		assertSame(template, templateExtensionNextObj.methodsDispatchTable.get(1))
		assertSame(template, templateExtensionNextObj.methodsDispatchTable.get(2))
		
	}
}
