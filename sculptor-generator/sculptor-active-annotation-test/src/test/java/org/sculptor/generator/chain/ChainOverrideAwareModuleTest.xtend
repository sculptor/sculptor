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

		var template = injector.getInstance(templateClass);
		assertNotNull(template);
		assertEquals("No override class", typeof(TestTemplateOverride), template.^class)

		template = template.next
		assertSame("No cartridge extension class", typeof(TestTemplateExtension),
			template.^class)

		template = template.next
		assertSame("No original template class", templateClass, template.^class)
		assertNull(template.next)
	}
}
