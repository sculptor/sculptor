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
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

class ChainOverridableTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(ChainOverridable.classLoader)

	@Test
	def void testGeneratedCode() {
		'''
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverridableTestTemplate {
				def void overridableMethod() {}

				final def finalMethod() {}

				def inferredMethod() { "" }

				def dispatch String dispatchMethod(long i) {}
				def dispatch String dispatchMethod(int i) {}

				def dispatch create Boolean.TRUE dispatchCreateMethod(long i) {}
				def dispatch create Boolean.TRUE dispatchCreateMethod(int i) {}
				
			}
		'''.compile[
			val extension ctx = transformationContext

			// Check the AST if the annotated class has the generated constructor
			val annotatedClass = findClass('ChainOverridableTestTemplate')
			assertNotNull(annotatedClass)
			assertTrue(annotatedClass.declaredConstructors.exists[
					parameters.size == 1 && parameters.get(0).simpleName == 'next'
				], 'No chaining constructor'
			)

			// Check the AST if the generated extension class has the overriden methods of the annotated class
			assertNotNull(annotatedClass.findDeclaredMethod('overridableMethod'), 'No public method')
			assertNotNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + 'overridableMethod'), 'No overriden method')

			// Check the AST if the generated extension class has no non-overridable methods of the annotated class
			assertNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + 'finalMethod'), 'Final method renamed')
			assertNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + 'inferredMethod'), 'Inferred method renamed')

			assertNotNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + '_dispatchMethod', newTypeReference(typeof(long))), 'Dispatch method renamed')
			assertNotNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + '_dispatchMethod', newTypeReference(typeof(int))), 'Dispatch method renamed')
			assertNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + 'dispatchCreateMethod', newTypeReference(typeof(long))), 'Dispatch create method renamed')
			assertNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + 'dispatchCreateMethod', newTypeReference(typeof(int))), 'Dispatch create method renamed')

			assertNotNull(annotatedClass.findDeclaredMethod("_getOverridesDispatchArray"), "_getOverridesDispatchArray should be generated")
			assertNull(annotatedClass.findDeclaredMethod(ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + "_getOverridesDispatchArray"), "_getOverridesDispatchArray shouldn't get chained")
						
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

	@Test
	def void testWithExtension() {
		'''
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverridableTestTemplateOverride extends org.sculptor.generator.chain.ChainOverridableTest {
			}
		'''.compile[
				val extension ctx = transformationContext

				 // Check the AST if the annotated class has the error problem
				val clazz = findClass('ChainOverridableTestTemplateOverride')
				assertNotNull(clazz)
				assertEquals(1, clazz.problems.size)
				val problem = clazz.problems.get(0)
				assertEquals(Severity.ERROR, problem.severity)
			]
	}

}