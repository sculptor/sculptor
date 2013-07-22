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
import org.sculptor.generator.template.TestTemplate

import static org.junit.Assert.*

class ChainOverrideAwareModuleTest {

	val templateClass = typeof(TestTemplate)

	@Test
	def void testTmplateExtensions() {
		val injector = Guice::createInjector(new ChainOverrideAwareModule(templateClass));

		val templateOverride = injector.getInstance(templateClass);
		val templateExtension = templateOverride.next
		val template = templateExtension.next

		// Head of chain - the override class
		assertNotNull(templateOverride);
		assertEquals("No override class", typeof(TestTemplateOverride), templateOverride.^class)
		assertNotNull(templateOverride.getMethodsDispatchNext)
		assertEquals(3, templateOverride.getMethodsDispatchNext.size)
		assertSame(templateExtension, templateOverride.getMethodsDispatchNext.get(0))
		assertSame(template, templateOverride.getMethodsDispatchNext.get(1))
		assertSame(template, templateOverride.getMethodsDispatchNext.get(2))
		
		val methodDispatchHead = templateOverride.getMethodsDispatchHead()
		assertNotNull(methodDispatchHead)
		assertSame(templateExtension, methodDispatchHead.get(0))
		assertSame(template, methodDispatchHead.get(1))
		assertSame(templateOverride, methodDispatchHead.get(2))

		assertSame("No cartridge extension class", typeof(TestTemplateExtension),
			templateExtension.^class)
		assertEquals(3, templateExtension.getMethodsDispatchNext.size)
		assertSame(template, templateExtension.getMethodsDispatchNext.get(0))
		assertSame(template, templateExtension.getMethodsDispatchNext.get(1))
		assertSame(template, templateExtension.getMethodsDispatchNext.get(2))
		assertSame(methodDispatchHead, templateExtension.getMethodsDispatchHead)

		// End of chain - the original template class
		assertSame("No original template class", templateClass, template.^class)
		assertNull(template.next)
		assertNull(template.getMethodsDispatchNext)
		assertSame(methodDispatchHead, template.getMethodsDispatchHead)
		
	}
}
