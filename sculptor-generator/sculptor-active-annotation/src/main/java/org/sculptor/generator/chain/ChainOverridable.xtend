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

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import java.util.List
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static extension org.sculptor.generator.chain.ChainOverrideHelper.*

/**
 * Adds chain interface and delegate methods for all public methods.
 */
@Target(ElementType::TYPE)
@Active(typeof(ChainOverridableProcessor))
public annotation ChainOverridable {}

class ChainOverridableProcessor extends AbstractClassProcessor {

	private static final Logger LOG = LoggerFactory::getLogger(typeof(ChainOverridableProcessor))

	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		context.registerInterface(annotatedClass.methodIndexesName)
		context.registerClass(annotatedClass.dispatchClassName)
	}

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		LOG.debug("Processing class '" + annotatedClass.qualifiedName + "'")
		if (validate(annotatedClass, context)) {
			val overrideableMethodsInfo = annotatedClass.overrideableMethodsInfo

			buildMethodNamesInterface(annotatedClass, context, overrideableMethodsInfo)

			transformAnnotatedClass(annotatedClass, context, overrideableMethodsInfo)

			buildMethodDispatchClass(annotatedClass, context, overrideableMethodsInfo)
		}
	}

	/**
	 * Build interface of constants for the method indexes
	 */
	private def buildMethodNamesInterface(MutableClassDeclaration annotatedClass,
		extension TransformationContext context, List<OverridableMethodInfo> overridableMethodsInfo) {
		val methodIndexesInterface = findInterface(annotatedClass.methodIndexesName)
		methodIndexesInterface.setDocComment(
			'''Constants for methods in «annotatedClass.simpleName», used for dispatching for overrideable methods''')

		overridableMethodsInfo.forEach [ methodInfo, methodIx |
			methodIndexesInterface.addField(methodInfo.methodIndexName) [
				static = true
				visibility = Visibility::PUBLIC
				final = true
				type = primitiveInt
				initializer = ['''«methodIx»''']
			]
		]

		methodIndexesInterface.addField("NUM_METHODS") [
			static = true
			visibility = Visibility::PUBLIC
			final = true
			type = primitiveInt
			initializer = ['''«overridableMethodsInfo.size»''']
		]
	}

	/**
	 * @return Method dispatch class, which dispatches to another objects for each method, for annotatedClass
	 */
	private def buildMethodDispatchClass(MutableClassDeclaration annotatedClass,
		extension TransformationContext context, List<OverridableMethodInfo> overridableMethodsInfo) {
			
		val dispatchClass = findClass(annotatedClass.dispatchClassName)
		dispatchClass.setDocComment(
			'''Method dispatch class for «annotatedClass.simpleName», used for dispatching to overrideable methods''')
		
		dispatchClass.modifyAddMethodDispatchBaseClass(annotatedClass, context)
				
		dispatchClass.addField("methodsDispatchTable")  [
			static = false
			visibility = Visibility::PRIVATE
			final = true
			type = annotatedClass.newTypeReference().newArrayTypeReference()
		]
		
		dispatchClass.addMethod("getMethodsDispatchTable") [
			static = false
			visibility = Visibility::PUBLIC
			final = true
			returnType = annotatedClass.newTypeReference().newArrayTypeReference()
			body = [
				'''
					return(methodsDispatchTable);
				'''
			]
		]
		
		overridableMethodsInfo.forEach[methodInfo |

			val publicMethod = methodInfo.publicMethod
			val methodName = methodInfo.methodName

			dispatchClass.addMethod(methodName) [ dispatchMethod |
				dispatchMethod.final = publicMethod.final
				dispatchMethod.returnType = publicMethod.returnType
				dispatchMethod.^default = publicMethod.^default
				dispatchMethod.varArgs = publicMethod.varArgs
				dispatchMethod.exceptions = publicMethod.exceptions
				publicMethod.parameters.forEach[dispatchMethod.addParameter(simpleName, type)]
				dispatchMethod.docComment = publicMethod.docComment
				dispatchMethod.body = ['''
					«annotatedClass.simpleName» nextObj = methodsDispatchTable[«annotatedClass.methodIndexesName».«methodInfo.methodIndexName»];
					«IF !publicMethod.returnType.isVoid»return«ENDIF» nextObj.«RENAMED_METHOD_NAME_PREFIX + methodName»(«FOR p : publicMethod.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
				''']
			]
		]
	}

	private def boolean validate(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		// Check if annotated class does extend another class
		if (annotatedClass.extendedClass?.name != 'java.lang.Object') {
			annotatedClass.addError('Annotated class must not extend a class')
			return false
		}
		true
	}

	private def modifyAddMethodDispatchBaseClass(MutableClassDeclaration classToModify,
		MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		// Extend from original overrideable class
		val annotatedClassRef = annotatedClass.newTypeReference
		classToModify.extendedClass = annotatedClassRef

		val arrTypeReference = annotatedClass.newTypeReference.newArrayTypeReference

		// add constructor taking dispatch table
		classToModify.addConstructor [
			addParameter('methodsDispatchTable', arrTypeReference)

			body = ['''
				super(null);
				this.methodsDispatchTable = methodsDispatchTable; 
			''']
		]

		// add constructor taking dispatch table and next reference
		classToModify.addConstructor [
			addParameter('next', annotatedClassRef)
			addParameter('methodsDispatchTable', arrTypeReference)

			body = ['''
				super(next);
				this.methodsDispatchTable = methodsDispatchTable; 
			''']
		]
	}

	private def modifyAddChainLinkBaseClass(MutableClassDeclaration classToModify,
		MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		// Extend from chain link class referencing the annotated class
		val annotatedClassRef = annotatedClass.newTypeReference
		classToModify.extendedClass = typeof(ChainLink).newTypeReference(annotatedClassRef)

		// add constructor for chaining
		classToModify.addConstructor [
			addParameter("next", annotatedClassRef)

			body = ['''super(next);''']
		]
	}

	private def transformAnnotatedClass(
		MutableClassDeclaration annotatedClass,
		extension TransformationContext context,
		List<OverridableMethodInfo> overridableMethodsInfo
	) {
		LOG.debug("Transforming annotated class '" + annotatedClass.qualifiedName + "'")

		annotatedClass.modifyAddChainLinkBaseClass(annotatedClass, context)

		// add methods delegating to the given extension class' public non-final methods
		overridableMethodsInfo.forEach [ methodInfo |
			annotatedClass.modifyOverrideableMethod(annotatedClass.newTypeReference.type, methodInfo, context)
		]

		annotatedClass.addGetOverridesDispatchArrayMethod(annotatedClass, context, overridableMethodsInfo)
	}

}