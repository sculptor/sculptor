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
import org.junit.Ignore
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
					parameters.size == 1 && parameters.get(0).simpleName == 'next']
			)

			// Check the AST if the generated extension class has the public non-final methods of the annotated class
			assertNotNull('No public method', annotatedClass.findDeclaredMethod('overridableMethod'))
			assertNotNull('No overriden method', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + 'overridableMethod'))

			// Check the AST if the generated extension class has no public final methods of the annotated class
			assertNull('Final method renamed', annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + 'finalMethod'))

			assertNotNull("_getOverridesDispatchArray should be generated", annotatedClass.findDeclaredMethod("_getOverridesDispatchArray"))
						
			assertNull("_getOverridesDispatchArray shouldn't get chained", annotatedClass.findDeclaredMethod("_chained__getOverridesDispatchArray"))
						
			val indexInterface = findInterface('ChainOverridableTestTemplateMethodIndexes')
			assertNotNull(indexInterface)
			val fields = indexInterface.declaredFields.toList
			assertEquals(2, fields.size)
			assertEquals("OVERRIDABLEMETHOD", fields.get(0).simpleName)
			assertEquals("int", fields.get(0).type.simpleName)
			
			assertEquals("NUM_METHODS", fields.get(1).simpleName)
			assertEquals("int", fields.get(1).type.simpleName)
			
		]
	}
	
	@Test
	def void testGeneratedMethodDispatchClass() {
		'''
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverridableTestTemplate {
				def overridableMethod() {}
				final def finalMethod() {}
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
			assertEquals(2, methods.size)
			
			assertEquals("getMethodsDispatchTable", methods.get(0).simpleName)
			assertEquals("overridableMethod", methods.get(1).simpleName)
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
	
	
	@Ignore("ignore until dispatch methods can be skipped or supported in overrideable classes")
	@Test
	def void testWithDispatch() {
		'''
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverridableDispatchTestTemplate {
				def dispatch Integer dispatchTest(String aString) {noDispatch()}
				def dispatch Integer dispatchTest(Boolean aBoolean) {noDispatch()}
				
				def String noDispatch() {}
			}
		'''.compile[
			val extension ctx = transformationContext

			// Check the AST if the annotated class has the generated constructor
			val annotatedClass = findClass('ChainOverridableDispatchTestTemplate')
			assertNotNull(annotatedClass)

			val pubMethod = annotatedClass.findDeclaredMethod("dispatchTest", typeof(Object).newTypeReference())
			assertNotNull(pubMethod)
			assertFalse(pubMethod.returnType.isVoid)
			assertEquals("java.lang.Integer", pubMethod.returnType.name)
			
			val strMethod = annotatedClass.findDeclaredMethod(ChainOverrideHelper::RENAMED_METHOD_NAME_PREFIX + "dispatchTest", typeof(Object).newTypeReference())
			assertNotNull(strMethod)
			assertFalse(strMethod.returnType.isVoid)
			assertEquals("Integer", strMethod.returnType.name)
			
//			// Check the AST if the generated extension class has the public non-final methods of the annotated class
//			assertNotNull('No public method', annotatedClass.findDeclaredMethod('overridableMethod'))
//			assertNotNull('No overriden method', annotatedClass.findDeclaredMethod(ChainOverridableProcessor::RENAMED_METHOD_NAME_PREFIX + 'overridableMethod'))
//
//			assertNotNull('No next dispatch method', annotatedClass.findDeclaredMethod('next_overridableMethod'))
//
//			// Check the AST if the generated extension class has no public final methods of the annotated class
//			assertNull('Final method renamed', annotatedClass.findDeclaredMethod(ChainOverridableProcessor::RENAMED_METHOD_NAME_PREFIX + 'finalMethod'))
//
//			assertNotNull("_getOverridesDispatchArray should be generated", annotatedClass.findDeclaredMethod("_getOverridesDispatchArray"))
//						
//			assertNull("_getOverridesDispatchArray shouldn't get chained", annotatedClass.findDeclaredMethod("_chained__getOverridesDispatchArray"))
//						
//			val indexInterface = findInterface('ChainOverridableTestTemplateMethodIndexes')
//			assertNotNull(indexInterface)
//			val fields = indexInterface.declaredFields.toList
//			assertEquals(3, fields.size)
//			assertEquals("OVERRIDABLEMETHOD", fields.get(0).simpleName)
//			assertEquals("int", fields.get(0).type.simpleName)
//			
//			assertEquals("NUM_METHODS", fields.get(2).simpleName)
//			assertEquals("int", fields.get(2).type.simpleName)
		]
	}

}