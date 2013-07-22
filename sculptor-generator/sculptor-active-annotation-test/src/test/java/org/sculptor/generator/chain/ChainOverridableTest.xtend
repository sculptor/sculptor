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

import org.eclipse.xtend.core.compiler.batch.XtendCompilerTester
import org.junit.Test

import static org.junit.Assert.*

class ChainOverridableTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(typeof(ChainOverridable))

	@Test
	def void testGeneratedCode() {
		'''
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverridableTestTemplate {
				def overridableMethod() {}
				final def finalMethod() {}
			}
		'''.compile[
			val extension ctx = transformationContext

			// Check the AST if the annotated class has the generated constructor
			val annotatedClass = findClass('ChainOverridableTestTemplate')
			assertNotNull(annotatedClass)
			assertTrue('No chaining constructor',
				annotatedClass.declaredConstructors.exists[
					parameters.size == 2 && parameters.get(0).simpleName == 'next' && parameters.get(1).simpleName == 'methodsDispatchNext']
			)

			// Check the AST if the generated extension class has the public non-final methods of the annotated class
			assertNotNull('No public method', annotatedClass.findMethod('overridableMethod'))
			assertNotNull('No overriden method', annotatedClass.findMethod(ChainOverridableProcessor::RENAMED_METHOD_NAME_PREFIX + 'overridableMethod'))

			assertNotNull('No next dispatch method', annotatedClass.findMethod('next_overridableMethod'))

			// Check the AST if the generated extension class has no public final methods of the annotated class
			assertNull('Final method renamed', annotatedClass.findMethod(ChainOverridableProcessor::RENAMED_METHOD_NAME_PREFIX + 'finalMethod'))

			assertNotNull("_getOverridesDispatchArray should be generated", annotatedClass.findMethod("_getOverridesDispatchArray"))
						
			assertNull("_getOverridesDispatchArray shouldn't get chained", annotatedClass.findMethod("_chained__getOverridesDispatchArray"))
						
			val indexInterface = findInterface('ChainOverridableTestTemplateMethodIndexes')
			assertNotNull(indexInterface)
			val fields = indexInterface.declaredFields.toList
			assertEquals(3, fields.size)
			assertEquals("OVERRIDABLEMETHOD", fields.get(0).simpleName)
			assertEquals("int", fields.get(0).type.simpleName)
			
			assertEquals("NUM_METHODS", fields.get(2).simpleName)
			assertEquals("int", fields.get(2).type.simpleName)
			
			//"_chained__getOverridesDispatchArray"
		]
	}

	@Test(expected=typeof(RuntimeException))
	def void testWithExtension() {
		'''
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverridableTestTemplateOverride extends org.sculptor.generator.chain.ChainOverridableTest {
			}
		'''.compile[]
	}

}