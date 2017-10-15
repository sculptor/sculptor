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
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtend.lib.macro.services.Problem.Severity
import org.junit.Ignore
import org.junit.Test

import static org.junit.Assert.*
import static org.sculptor.generator.chain.ChainOverrideTestHelper.*

class ChainOverrideTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester.newXtendCompilerTester(ChainOverride.classLoader)

	@Test
	def void testGeneratedCode() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends ChainOverrideTestTemplate {
			}
			
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverrideTestTemplate {
			}
		'''.compile[
			val extension ctx = transformationContext

			 // Check the AST if the annotated class has the generated constructor
			val clazz = findClass('ChainOverrideTestTemplateOverride')
			assertNotNull(clazz)
			assertTrue(
				clazz.declaredConstructors.exists[
					parameters.size == 2 && parameters.get(0).simpleName == 'next' && parameters.get(1).simpleName == 'methodsDispatchNext']
			)

			assertNotNull("_getOverridesDispatchArray should be generated", clazz.findDeclaredMethod("_getOverridesDispatchArray"))
						
			assertNull("_getOverridesDispatchArray shouldn't get chained", clazz.findDeclaredMethod("_chained__getOverridesDispatchArray"))			
		]
	}

	@Test
	def void testGeneratedCodeForDispatchMethods() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends ChainOverrideTestTemplate {
				override dispatch create Boolean.TRUE dispatchCreateMethod(String s) {}
			}
			
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverrideTestTemplate {
				def dispatch create Boolean.TRUE dispatchCreateMethod(Object o) {}
				def dispatch create Boolean.TRUE dispatchCreateMethod(String s) {}
				def dispatch create Boolean.TRUE dispatchCreateMethod(Integer i) {}
				
				def dispatch String doDispatch(String a) {a}

				def dispatch Integer doDispatch(int i) {i}
				
			}
		'''.compile[
			val extension ctx = transformationContext

			val tmplClazz = findClass('ChainOverrideTestTemplate')
			assertNotNull(tmplClazz)
			assertMethodInfo('Dispatch method renamed', tmplClazz, ChainOverrideHelper.RENAMED_METHOD_NAME_PREFIX + '_doDispatch', Visibility.PUBLIC, newTypeReference(typeof(String)))
			assertMethodInfo('Dispatch method renamed', tmplClazz, '_doDispatch', Visibility.PUBLIC, newTypeReference(typeof(String)))
			assertMethodInfo('Dispatch method renamed', tmplClazz, '_doDispatch', Visibility.PUBLIC, newTypeReference(typeof(int)))
			assertMethodInfo('Dispatch method renamed', tmplClazz, 'doDispatch', Visibility.PUBLIC, newTypeReference(typeof(Object)))
			
			val overrideClazz = findClass('ChainOverrideTestTemplateOverride')
			assertNotNull(overrideClazz)

			val ovMethods = overrideClazz.declaredMethods
			assertEquals(4, ovMethods.size)
			assertMethodInfo("", overrideClazz, "_dispatchCreateMethod", Visibility.PROTECTED, newTypeReference(typeof(String)))
			assertMethodInfo("", overrideClazz, "dispatchCreateMethod", Visibility.PUBLIC, newTypeReference(typeof(Object)))
			assertMethodInfo("", overrideClazz, "_getOverridesDispatchArray", Visibility.PUBLIC)
		]
	}

	@Test
	def void testNoOverrideKeyword() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends ChainOverrideTestTemplate {
				def String test2(String foo) {
					"code2"
				}
				override def String test2() {
					"foo"
				}
			}
			
			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverrideTestTemplate {
				def String test2() {
					"bar"
				}
				
			}
		'''.compile[
			val extension ctx = transformationContext

			 // Check the AST if the annotated class has the generated constructor
			val clazz = findClass('ChainOverrideTestTemplateOverride')
			assertNotNull(clazz)

			val methods = clazz.declaredMethods
			assertEquals(4, methods.size)
			assertTrue(methods.exists[m|m.simpleName == "_chained_test2" && m.parameters.size == 0])
			assertTrue(methods.exists[m|m.simpleName == "test2" && m.parameters.size == 0])
			assertTrue(methods.exists[m|m.simpleName == "test2" && m.parameters.size == 1])
			assertNotNull("_getOverridesDispatchArray should be generated", clazz.findDeclaredMethod("_getOverridesDispatchArray"))
						
		]
	}

	@Test(expected=typeof(RuntimeException))
	@Ignore
	def void testInferredReturnType() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends ChainOverrideTestTemplate {
				override test() {
					""
				}
			}

			@org.sculptor.generator.chain.ChainOverridable
			class ChainOverrideTestTemplate {
				def String test() {
					""
				}
			}
		'''.compile[]
	}

	@Test
	def void testNoExtendedClass() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride {
			}
		'''.compile[
				val extension ctx = transformationContext

				 // Check the AST if the annotated class has the error problem
				val clazz = findClass('ChainOverrideTestTemplateOverride')
				assertNotNull(clazz)
				assertEquals(1, clazz.problems.size)
				val problem = clazz.problems.get(0)
				assertEquals(Severity.ERROR, problem.severity)
			]
	}

	@Test
	def void testUndeclaredExtendedClass() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends Undeclared {
			}
		'''.compile[
				val extension ctx = transformationContext

				 // Check the AST if the annotated class has the error problem
				val clazz = findClass('ChainOverrideTestTemplateOverride')
				assertNotNull(clazz)
				assertEquals(1, clazz.problems.size)
				val problem = clazz.problems.get(0)
				assertEquals(Severity.ERROR, problem.severity)
			]
	}

	@Test
	@Ignore
	def void testNoXtendClass() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends org.sculptor.generator.chain.TestTemplate {
			}
		'''.compile[
			val extension ctx = transformationContext

			 // Check the AST if the annotated class has the warning problem
			val clazz = findClass('ChainOverrideTestTemplateOverride')
			assertNotNull(clazz)
			assertTrue(
				clazz.problems.exists[
					message.endsWith('must be an Xtend class')]
			)]
	}

	@Test
	@Ignore
	def void testNoSupportChainOverridingAnnotation() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends ChainOverrideTestTemplate {
			}
			
			class ChainOverrideTestTemplate {
			}
		'''.compile[
			val extension ctx = transformationContext

			 // Check the AST if the annotated class has the warning problem
			val clazz = findClass('ChainOverrideTestTemplateOverride')
			assertNotNull(clazz)
			assertTrue(
				clazz.problems.exists[
					message.endsWith('is not annotated with ChainOverridable')]
			)]
	}

}
