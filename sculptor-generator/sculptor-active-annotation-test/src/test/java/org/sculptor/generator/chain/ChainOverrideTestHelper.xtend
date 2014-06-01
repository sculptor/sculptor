/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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

import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.TypeReference
import org.eclipse.xtend.lib.macro.declaration.Visibility

import static org.junit.Assert.*

class ChainOverrideTestHelper {
	
	public static def assertMethodInfo(String msg, ClassDeclaration clazz, String methodName,
		Visibility expectedVisibility, TypeReference... parameterTypes
	) {
		val foundMethod = clazz.findDeclaredMethod(methodName, parameterTypes)
		if (foundMethod == null) {
			val matchingName = clazz.declaredMethods.findFirst[m|m.simpleName == methodName]
			assertTrue('''«msg»: Could not find method «methodName» matching criteria.  Method matching name only: «matchingName»''', false)
		}
		else {
			assertEquals(expectedVisibility, foundMethod.visibility)
		}
	}

}
