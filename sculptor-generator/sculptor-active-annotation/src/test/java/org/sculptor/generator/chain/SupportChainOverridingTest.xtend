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

class SupportChainOverridingTest {

	extension XtendCompilerTester compilerTester = XtendCompilerTester::newXtendCompilerTester(typeof(SupportChainOverriding))

	@Test
	def void testGeneratedCode() {
		'''
			@org.sculptor.generator.chain.SupportChainOverriding
			class SupportChainOverridingTestTemplate {
				def overridableMethod() {}
				final def finalMethod() {}
			}

		'''.compile[
			val extension ctx = transformationContext

			 // Check the AST if the annotated class (now the base class) has the generated constructor
			val annotatedClass = findClass('SupportChainOverridingTestTemplate')
			assertNotNull('No base class generated', annotatedClass)
			assertFalse('No default constructor',
				annotatedClass.declaredConstructors.exists[parameters.empty]
			)

			// Check the AST if the generated base class has the chaining constructor and
			// the public methods of the annotated class
			val baseClass = findClass('SupportChainOverridingTestTemplate')
			assertNotNull(baseClass)
			assertTrue('No chaining constructor',
				baseClass.declaredConstructors.exists[
					parameters.size == 1 && parameters.get(0).simpleName == 'next']
			)

			// Check the AST if the generated base class has the public non-final methods of the annotated class
			assertTrue('No overriden method',
				baseClass.declaredMethods.exists[simpleName == 'overridableMethod']
			)

			// Check the AST if the generated base class has no public final methods of the annotated class
			assertTrue('Final method overriden',
				baseClass.declaredMethods.exists[simpleName == 'finalMethod']
			)]
	}

	@Test(expected=typeof(RuntimeException))
	def void testWithExtension() {
		'''
			@org.sculptor.generator.chain.SupportChainOverriding
			class SupportChainOverridingTestTemplateOverride extends org.sculptor.generator.chain.TestTemplate {
			}
		'''.compile[]
	}

}