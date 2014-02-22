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

class ChainOverrideTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(typeof(ChainOverride))

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
	def void testInferredReturnCode() {
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
		'''.compile[
			val extension ctx = transformationContext

			 // Check the AST if the annotated class has the warning problem
			val clazz = findClass('ChainOverrideTestTemplateOverride')
			assertNotNull(clazz)
			val method = clazz.findDeclaredMethod('test')
			assertNotNull(method)
			assertTrue(
				method.problems.exists[
					message.startsWith('Inferred return types')]
			)]
	}

	@Test(expected=typeof(RuntimeException))
	def void testNoExtendedClass() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride {
			}
		'''.compile[]
	}

	@Test(expected=typeof(RuntimeException))
	def void testUndeclaredExtendedClass() {
		'''
			@org.sculptor.generator.chain.ChainOverride
			class ChainOverrideTestTemplateOverride extends Undeclared {
			}
		'''.compile[]
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
