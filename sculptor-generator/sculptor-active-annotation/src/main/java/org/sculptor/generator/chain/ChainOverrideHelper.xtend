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

import java.util.ArrayList
import java.util.List
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.Visibility

class ChainOverrideHelper {

	public static final String RENAMED_METHOD_NAME_PREFIX = '_chained_'

	/**
	 * Add a method to get the dispatch array for each overrideable method for classToModify
	 */
	protected static def addGetOverridesDispatchArrayMethod(
		MutableClassDeclaration classToModify,
		Type overrideableClass,
		extension TransformationContext context,
		List<OverridableMethodInfo> overridableMethodsInfo
	) {
		classToModify.addMethod("_getOverridesDispatchArray") [
			visibility = Visibility::PUBLIC
			final = false
			returnType = overrideableClass.newTypeReference.newArrayTypeReference
			val methodIndexesName = overrideableClass.methodIndexesName
			body = ['''
				«overrideableClass.qualifiedName»[] result = new «overrideableClass.qualifiedName»[«overrideableClass.methodIndexesName».NUM_METHODS];
				«FOR m : overridableMethodsInfo»
					result[«methodIndexesName».«m.methodIndexName»] = this; 
				«ENDFOR»
				return result;
			''']
		]
	}

	/**
	 * @return Name of index constant for the given method
	 */
	protected static def getIndexName(MutableMethodDeclaration methodDecl) {
		val sb = new StringBuilder(methodDecl.simpleName.toUpperCase)
		methodDecl.parameters.forEach [ param |
			sb.append("_")
			sb.append(param.type.simpleName.replaceAll("[<>]", "").toUpperCase)
		]
		sb.toString
	}

	/**
	 * @return Fully qualified name of method indexes interface
	 */
	protected static def getMethodIndexesName(Type overrideableClass) {
		overrideableClass.qualifiedName + "MethodIndexes"
	}

	/**
	 * @return Fully qualified name of dispatch class
	 */
	protected static def getDispatchClassName(Type overrideableClass) {
		overrideableClass.qualifiedName + "MethodDispatch"
	}

	protected static def getOverrideableMethods(MutableClassDeclaration annotatedClass) {
		val dispatchMethods=annotatedClass.declaredMethods.filter[it.simpleName.startsWith("_")].map[it.simpleName.substring(1)].toSet
		annotatedClass.declaredMethods.filter[!dispatchMethods.exists[dm | simpleName == dm] && visibility == Visibility::PUBLIC && static == false && final == false && !returnType.inferred].toList
	}

	protected static def getOverrideableMethodsInfo(MutableClassDeclaration annotatedClass) {
		val result = new ArrayList<OverridableMethodInfo>()
		result.addAll(annotatedClass.overrideableMethods.map[method|
			new OverridableMethodInfo(method.indexName, method, new String(method.simpleName))
		])
		result
	}

	/**
	 * Modify the identified overrideable method, renaming the actual method, and replacing it with a public method that
	 * delegates to the head of the chain.
	 */
	protected static def modifyOverrideableMethod(MutableClassDeclaration annotatedClass, Type originalTmplClass,
			OverridableMethodInfo methodInfo, extension TransformationContext context) {
		val publicMethod = methodInfo.publicMethod
		val methodName = methodInfo.methodName
		publicMethod.simpleName = RENAMED_METHOD_NAME_PREFIX + methodName
		publicMethod.visibility = Visibility::PUBLIC

		// add new public delegate method
		annotatedClass.addMethod(methodName) [ delegateMethod |
			delegateMethod.returnType = publicMethod.returnType
			delegateMethod.^default = publicMethod.^default
			delegateMethod.varArgs = publicMethod.varArgs
			delegateMethod.exceptions = publicMethod.exceptions
			publicMethod.parameters.forEach[delegateMethod.addParameter(simpleName, type)]
			delegateMethod.docComment = publicMethod.docComment
			delegateMethod.body = ['''
				«originalTmplClass.simpleName» headObj = getMethodsDispatchHead()[«originalTmplClass.methodIndexesName».«methodInfo.
					methodIndexName»];
				«IF !publicMethod.returnType.isVoid»return «ENDIF»headObj.«RENAMED_METHOD_NAME_PREFIX + methodName»(«FOR p : publicMethod.
					parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
			''']
		]
	}
}
