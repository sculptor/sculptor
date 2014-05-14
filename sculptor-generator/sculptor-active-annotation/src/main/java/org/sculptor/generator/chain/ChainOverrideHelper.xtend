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
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Type
import org.eclipse.xtend.lib.macro.declaration.Visibility

class ChainOverrideHelper {

	public static final String RENAMED_METHOD_NAME_PREFIX = '_chained_'

	/**
	 * Add a method to get the dispatch array for each overrideable method for classToModify
	 */
	static def addGetOverridesDispatchArrayMethod(
		MutableClassDeclaration classToModify,
		Type overrideableClass,
		extension TransformationContext context,
		List<OverridableMethodInfo> overridableMethodsInfo
	) {
		classToModify.addMethod("_getOverridesDispatchArray") [
			visibility = Visibility.PUBLIC
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
	static def getIndexName(MethodDeclaration methodDecl) {
		val sb = new StringBuilder(methodDecl.simpleName.toUpperCase)
		methodDecl.parameters.forEach [ param |
			sb.append("_")
			sb.append(param.type.simpleName.replaceAll("[<>]", "").toUpperCase)
		]
		sb.toString
	}

	/**
	 * @return List of overridable methods (including the ones with inferred return types!!!) of the given class.   
	 * @TODO: This should probably be optimized
	 */
	static def getOverrideableMethods(ClassDeclaration annotatedClass) {
		val dispatchMethodNames = annotatedClass.dispatchMethodNames
		
		val nonDispatchOvMethods = annotatedClass.declaredMethods.filter[
			visibility == Visibility.PUBLIC && !static && !final && !abstract &&
				hasInferredTypes == false &&
				!dispatchMethodNames.contains(simpleName)]
		// TODO: Do we need to get more precise about picking out these dispatch methods?
		val dispatchOvMethods = annotatedClass.declaredMethods.filter[
			simpleName.startsWith("_") &&
			visibility == Visibility.PROTECTED && !static && !final && !abstract
		]
		(nonDispatchOvMethods + dispatchOvMethods).toList
	}
	
	/**
	 * @return true if the given method has an inferred type either in the return type or a parameter
	 */
	static def hasInferredTypes(MethodDeclaration meth) {
		meth.returnType.inferred ||
			meth.parameters.exists[param|param.type.inferred]
	}

	/**
	 * @return List with names of dispatch methods in the given class.   
	 */
	static def getDispatchMethodNames(ClassDeclaration annotatedClass) {
		annotatedClass.declaredMethods.filter[simpleName.startsWith("_") && visibility == Visibility.PROTECTED].map[
			simpleName.substring(1)].toSet
	}

	/**
	 * @return List of OverridableMethodInfo instances created for all overridable methods (excluding the ones with inferred return types!!!) of the given class.  
	 */
	static def getOverrideableMethodsInfo(MutableClassDeclaration annotatedClass) {
		annotatedClass.overrideableMethods.filter[!returnType.inferred].map[method|
			new OverridableMethodInfo(method.indexName, method, new String(method.simpleName))].toList
	}

	/**
	 * Modify the identified overrideable method, modifying the body of the method to delegate to the head of the chain, and
	 * create  a new method to hold the original implementation.
	 */
	static def modifyOverrideableMethod(MutableClassDeclaration annotatedClass, Type originalTmplClass,
			OverridableMethodInfo methodInfo, extension TransformationContext context) {
		val publicMethod = methodInfo.publicMethod as MutableMethodDeclaration
		val methodName = methodInfo.methodName

		// add new public method to hold original implementation
		annotatedClass.addMethod(RENAMED_METHOD_NAME_PREFIX + methodName) [ delegateMethod |
			delegateMethod.visibility = Visibility.PUBLIC
			delegateMethod.returnType = publicMethod.returnType
			delegateMethod.^default = publicMethod.^default
			delegateMethod.varArgs = publicMethod.varArgs
			delegateMethod.exceptions = publicMethod.exceptions
			publicMethod.parameters.forEach[delegateMethod.addParameter(simpleName, type)]
			delegateMethod.docComment = publicMethod.docComment
			delegateMethod.body = publicMethod.body 
		]

		// Change the original method to now do delegation to head of chain
		publicMethod.visibility = Visibility.PUBLIC
			publicMethod.body = ['''
				«originalTmplClass.simpleName» headObj = getMethodsDispatchHead()[«originalTmplClass.methodIndexesName».«methodInfo.
					methodIndexName»];
				«IF !publicMethod.returnType.isVoid»return «ENDIF»headObj.«RENAMED_METHOD_NAME_PREFIX + methodName»(«FOR p : publicMethod.
					parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
			''']

	}

	//
	// Naming convention generators
	//

	/**
	 * @return Fully qualified name of method indexes interface
	 */
	static def getMethodIndexesName(Type overrideableClass) {
		overrideableClass.qualifiedName + "MethodIndexes"
	}

	/**
	 * @return Fully qualified name of dispatch class
	 */
	static def getDispatchClassName(Type overrideableClass) {
		overrideableClass.qualifiedName + "MethodDispatch"
	}
}
