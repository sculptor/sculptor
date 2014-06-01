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
				def void overridableMethod() {}

				final def finalMethod() {}

				def inferredMethod() { "" }

				def dispatch String dispatchMethod(Long i) {}
				def dispatch String dispatchMethod(int i) {}

				def dispatch create Boolean.TRUE dispatchCreateMethod(long i) {}
				def dispatch create Boolean.TRUE dispatchCreateMethod(int i) {}
				
			}
		'''.compile[
			val extension ctx = transformationContext

			// Check the AST if the annotated class has the generated constructor
			val annotatedClass = findClass('ChainOverridableTestTemplate')
			assertNotNull(annotatedClass)
			assertTrue('No chaining constructor',
				annotatedClass.declaredConstructors.exists[
					parameters.size == 1 && parameters.get(0).simpleName == 'next']
			)


			val methods = annotatedClass.declaredMethods
			System.out.println(methods.map[it.simpleName].join(", "))
			
			// Check the AST if the generated extension class has the overriden methods of the annotated class
			assertNotNull('No public method', annotatedClass.findDeclaredMethod('overridableMethod'))
			assertNotNull('No overriden method', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + 'overridableMethod'))

			// Check the AST if the generated extension class has no non-overridable methods of the annotated class
			assertNull('Final method renamed', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + 'finalMethod'))
			assertNull('Inferred method renamed', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + 'inferredMethod'))

			assertNotNull('Dispatch method renamed', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + '_dispatchMethod', newTypeReference(typeof(Long))))
			assertNotNull('Dispatch method renamed', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + '_dispatchMethod', newTypeReference(typeof(Integer))))
			assertNull('Dispatch create method renamed', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + 'dispatchCreateMethod'))

			assertNotNull("_getOverridesDispatchArray should be generated", annotatedClass.findDeclaredMethod("_getOverridesDispatchArray"))
			assertNull("_getOverridesDispatchArray shouldn't get chained", annotatedClass.findDeclaredMethod("_chained__getOverridesDispatchArray"))
						
			val indexInterface = findInterface('ChainOverridableTestTemplateMethodIndexes')
			assertNotNull(indexInterface)
			val fields = indexInterface.declaredFields.toList
			assertEquals(4, fields.size)
			assertEquals("OVERRIDABLEMETHOD", fields.get(0).simpleName)
			assertEquals("int", fields.get(0).type.simpleName)
			
			val numMethodsField = fields.findFirst[simpleName == "NUM_METHODS"]
			assertNotNull(numMethodsField)
			assertEquals("int", numMethodsField.type.simpleName)
		]
	}

	@Test
	def void testGeneratedMethodDispatchClass() {
		'''
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverridableTestTemplate {
				def void overridableVoidMethod() {}
				def String overridableStringMethod() {}
				final def finalMethod() {}
				def inferredMethod() { "" }
			}
		'''.compile[
			val extension ctx = transformationContext

			val methodDispatchClass = findClass('ChainOverridableTestTemplateMethodDispatch')
			assertNotNull(methodDispatchClass)

			val fields = methodDispatchClass.declaredFields.toList
			assertEquals(1, fields.size)
			assertEquals("methodsDispatchTable", fields.get(0).simpleName)
			assertEquals("ChainOverridableTestTemplate[]", fields.get(0).type.simpleName)

			val methods = methodDispatchClass.declaredMethods.toList
			assertEquals(3, methods.size)

			assertEquals("getMethodsDispatchTable", methods.get(0).simpleName)
			assertEquals("overridableVoidMethod", methods.get(1).simpleName)
			assertEquals("overridableStringMethod", methods.get(2).simpleName)
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