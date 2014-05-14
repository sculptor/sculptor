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