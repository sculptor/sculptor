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

import java.lang.annotation.Target
import java.lang.annotation.ElementType
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.RegisterGlobalsContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.sculptor.generator.util.ChainLink

/**
 * Extracts super class, chain interface for all locally declared public methods.
 */
@Target(ElementType::TYPE)
@Active(typeof(SupportChainOverridingProcessor))
public annotation SupportChainOverriding {}

class SupportChainOverridingProcessor extends AbstractClassProcessor {
	val String baseClassNameSuffix = 'Extension'

	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		context.registerClass(annotatedClass.baseClassName)
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		if (validate(annotatedClass, context)) {
			val baseClass = createBaseClass(annotatedClass, context)
			transformAnnotatedClass(annotatedClass, baseClass, context)
		}
	}

	private def getBaseClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName + baseClassNameSuffix
	}

	private def boolean validate(MutableClassDeclaration annotatedClass, extension TransformationContext context) {

		// Check if annotated class does extend another class
		if (annotatedClass.extendedClass?.name != 'java.lang.Object') {
			annotatedClass.addError('Annotated class must not extend a class')
			return false
		}
		true
	}

	private def createBaseClass(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val baseClass = findClass(annotatedClass.baseClassName)
		val baseClassRef = baseClass.newTypeReference
		baseClass.extendedClass = typeof(ChainLink).newTypeReference(baseClassRef)
		baseClass.simpleName = annotatedClass.simpleName

		// add constructor
		baseClass.addConstructor[
			addParameter("next", baseClassRef)
			body = ['''super(next);''']
		]

		// add the public methods of the annotated class
		for (method : annotatedClass.declaredMethods) {
			if (method.visibility == Visibility::PUBLIC && !method.final) {
				baseClass.addMethod(method.simpleName) [
					docComment = method.docComment
					returnType = method.returnType
					for (p : method.parameters) {
						addParameter(p.simpleName, p.type)
					}
					exceptions = method.exceptions
					body = ['''
						return getNext().«method.simpleName»(«FOR p : method.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);'''
					]
				]
			}
		}
		baseClass
	}

	private def transformAnnotatedClass(MutableClassDeclaration annotatedClass, MutableClassDeclaration baseClass, extension TransformationContext context) {

		// change class name and use base class as new superclass
		annotatedClass.simpleName = annotatedClass.simpleName + baseClassNameSuffix
		annotatedClass.extendedClass = baseClass.newTypeReference

		// add protected default constructor
		annotatedClass.addConstructor[
			body = ['''super(null);''']
		]
	}
	
}