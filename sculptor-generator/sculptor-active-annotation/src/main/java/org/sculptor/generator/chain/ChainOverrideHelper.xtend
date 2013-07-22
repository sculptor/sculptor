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

import java.util.List
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.Visibility

class ChainOverrideHelper {
	
	protected static def addGetOverridesDispatchArrayMethod(
		MutableClassDeclaration annotatedClass,
		Type overrideableClass,
		extension TransformationContext context,
		List<String> overrideMethodIndexNames
	) {
		annotatedClass.addMethod("_getOverridesDispatchArray") [
			visibility = Visibility::PUBLIC
			//			static = true
			final = false
			returnType = overrideableClass.newTypeReference.newArrayTypeReference
			val methodIndexesName = overrideableClass.methodIndexesName
			body = [
				'''
					«overrideableClass.qualifiedName»[] result = new «overrideableClass.qualifiedName»[«overrideableClass.methodIndexesName».NUM_METHODS];
					«FOR m : overrideMethodIndexNames»
						result[«methodIndexesName».«m»] = this; 
					«ENDFOR»
					return result;
				''']
		]
	}

	
	protected static def getIndexName(MutableMethodDeclaration methodDecl) {
		val sb = new StringBuilder(methodDecl.simpleName.toUpperCase)
		methodDecl.parameters.forEach [ param |
			sb.append("_")
			sb.append(param.type.simpleName.toUpperCase)
		]
		sb.toString
	}

	protected static def getMethodIndexesName(Type overrideableClass) {
		overrideableClass.qualifiedName + "MethodIndexes"
	}

	protected static def getOverrideableMethods(MutableClassDeclaration annotatedClass) {
		annotatedClass.declaredMethods.filter[visibility == Visibility::PUBLIC && static == false].toList
	}

	protected static def getOverrideableMethodIndexNames(MutableClassDeclaration annotatedClass) {
		val overrideableMethods = annotatedClass.getOverrideableMethods()

		val List<String> overrideMethodIndexNames = newArrayList()
		overrideMethodIndexNames.addAll(overrideableMethods.map[m|m.indexName])
		overrideMethodIndexNames
	}
}
