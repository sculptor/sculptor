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
import org.eclipse.xtend.lib.macro.declaration.MutableMethodDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.eclipse.xtext.xtype.XComputedTypeReference
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static extension org.sculptor.generator.chain.ChainOverrideHelper.*

/**
 * Adds chain interface und delegate methods for all public methods.
 */
@Target(ElementType::TYPE)
@Active(typeof(ChainOverridableProcessor))
public annotation ChainOverridable {}

class ChainOverridableProcessor extends AbstractClassProcessor {

	private static final Logger LOG = LoggerFactory::getLogger(typeof(ChainOverridableProcessor))

	public static final String RENAMED_METHOD_NAME_PREFIX = '_chained_'

	public static final String NEXT_METHOD_NAME_PREFIX = 'next_'
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		context.registerInterface(annotatedClass.methodIndexesName)
	}

  
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		
		LOG.debug("Processing class '" + annotatedClass.qualifiedName + "'")
		if (validate(annotatedClass, context)) {

			val overrideableMethodIndexNames = annotatedClass.getOverrideableMethodIndexNames()
			buildMethodNamesInterface(annotatedClass, context, overrideableMethodIndexNames)

			transformAnnotatedClass(annotatedClass, context, overrideableMethodIndexNames)

		}
	}
	
	 private def buildMethodNamesInterface(MutableClassDeclaration annotatedClass,
		extension TransformationContext context, List<String> overrideMethodIndexNames) {
		val methodIndexesInterface = findInterface(annotatedClass.methodIndexesName)
		methodIndexesInterface.setDocComment(
			'''Constants for methods in «annotatedClass.simpleName», used for dispatching for overrideable methods''')

		// add the public methods to the interface
		//		val methodsList = annotatedClass.declaredMethods.toList
		//val overrideMethods = annotatedClass.getOverrideableMethods()
		overrideMethodIndexNames.forEach [ methodIndexName, methodIx |
			methodIndexesInterface.addField(methodIndexName) [
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
			initializer = ['''«overrideMethodIndexNames.size»''']
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

	
	/**
	 * Add new method that dispatches to the same method that is 'next' in the chain & implemented
	 */
	private def addNextDispatchMethod(MutableClassDeclaration annotatedClass, MutableClassDeclaration overrideableClass, MutableMethodDeclaration publicMethod) {
		
		// Copy these values early, because body block below gets evaluated later, after publicMethod has been renamed
		val methodName = publicMethod.simpleName
		val methodIndexName = publicMethod.indexName
		
			// Add new next method
			annotatedClass.addMethod(NEXT_METHOD_NAME_PREFIX + methodName) [ nextMethod |
				nextMethod.final = true
				nextMethod.returnType = publicMethod.returnType
				nextMethod.^default = publicMethod.^default
				nextMethod.varArgs = publicMethod.varArgs
				nextMethod.exceptions = publicMethod.exceptions
				publicMethod.parameters.forEach[nextMethod.addParameter(simpleName, type)]
				nextMethod.docComment = publicMethod.docComment
				nextMethod.body = [
					'''
					
						if (getMethodsDispatchNext() != null) {
							«annotatedClass.simpleName» nextObj = getMethodsDispatchNext()[«overrideableClass.methodIndexesName».«methodIndexName»];
							// If nextObj is the end of the chain, call the renamed method because it is the overrideable class,
							// otherwise, call the regular method name
							if(nextObj.getNext() == null) {
								«IF !publicMethod.returnType.isVoid»return«ENDIF» nextObj.«RENAMED_METHOD_NAME_PREFIX + methodName»(«FOR p : publicMethod.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
							} else {
								«IF !publicMethod.returnType.isVoid»return«ENDIF» nextObj.«methodName»(«FOR p : publicMethod.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);								
							}
							
						} else {
							// This is the end of the chain, so it doesn't make sense that «NEXT_METHOD_NAME_PREFIX + methodName» was explicitly called
							throw new IllegalArgumentException("«NEXT_METHOD_NAME_PREFIX + methodName» called from ChainOverrideable class, which is the end of the chain and has no other object to delegate to");
						}
					'''
				]
				
			]

	}
	
	private def transformAnnotatedClass(MutableClassDeclaration annotatedClass, extension TransformationContext context,
		List<String> overrideMethodIndexNames
	) {
		LOG.debug("Transforming annotated class '" + annotatedClass.qualifiedName + "'")

		
		// Extend from chain link class referencing the annotated class
		val annotatedClassRef = annotatedClass.newTypeReference
		annotatedClass.extendedClass = typeof(ChainLink).newTypeReference(annotatedClassRef)

		val arrTypeReference = annotatedClass.newTypeReference.newArrayTypeReference

		// add constructor for chaining
		annotatedClass.addConstructor [
			addParameter("next", annotatedClassRef)
			addParameter('methodsDispatchNext', arrTypeReference)

			body = ['''super(next, methodsDispatchNext);''']
		]

		
		// add methods delegating to the given extension class' public non-final methods  
		annotatedClass.declaredMethods.filter [
			visibility == Visibility::PUBLIC && !final && !static // && !(returnType instanceof XComputedTypeReference)
		].forEach [ publicMethod |
			
			val returnType = publicMethod.returnType
			annotatedClass.addNextDispatchMethod(annotatedClass, publicMethod)

			// Copy these values early, because body block below gets evaluated later, after publicMethod has been renamed
			val methodName = publicMethod.simpleName
			val methodIndexName = publicMethod.indexName


			// rename and hide public method
			publicMethod.simpleName = RENAMED_METHOD_NAME_PREFIX + methodName
			publicMethod.visibility = Visibility::PUBLIC

			
			// add new public delegate method
			annotatedClass.addMethod(methodName) [ delegateMethod |
				delegateMethod.returnType = publicMethod.returnType
				//delegateMethod.final = true
				delegateMethod.^default = publicMethod.^default
				delegateMethod.varArgs = publicMethod.varArgs
				delegateMethod.exceptions = publicMethod.exceptions
				publicMethod.parameters.forEach[delegateMethod.addParameter(simpleName, type)]
				delegateMethod.docComment = publicMethod.docComment
				delegateMethod.body = [
					'''
						«annotatedClass.simpleName» headObj = getMethodsDispatchHead()[«annotatedClass.methodIndexesName».«methodIndexName»];
						// If headObj is the end of the chain, call the renamed method because it is the overrideable class,
						// otherwise, call the regular method name
						if(headObj.getNext() == null) {
							«IF !publicMethod.returnType.isVoid»return«ENDIF» headObj.«RENAMED_METHOD_NAME_PREFIX + methodName»(«FOR p : publicMethod.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
						} else {
							«IF !publicMethod.returnType.isVoid»return«ENDIF» headObj.«methodName»(«FOR p : publicMethod.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);							
						}
					'''
				]
			]
		]
		
		annotatedClass.addGetOverridesDispatchArrayMethod(annotatedClass, context, overrideMethodIndexNames)
		
	}
	
}