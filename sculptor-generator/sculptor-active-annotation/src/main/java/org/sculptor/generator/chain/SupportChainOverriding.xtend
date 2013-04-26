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
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.Visibility
import org.sculptor.generator.util.ChainLink

/**
 * Extracts super class, chain interface for all locally declared public methods.
 */
@Target(ElementType::TYPE)
@Active(typeof(SupportChainOverridingProcessor))
public annotation SupportChainOverriding {}

class SupportChainOverridingProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		if (validate(annotatedClass, context)) {
			createBaseClass(annotatedClass, context)

		}
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
		annotatedClass.extendedClass = typeof(ChainLink).newTypeReference(annotatedClass.newTypeReference)

		// add constructor
		annotatedClass.addConstructor[
			addParameter("next", annotatedClass.newTypeReference)
			body = ['''super(next);''']
		]

		// add the public methods of the annotated class
		for (method : annotatedClass.declaredMethods) {
			if (method.visibility == Visibility::PUBLIC && !method.final) {
				val mName = method.simpleName
				method.simpleName = "xXx" + mName
				method.visibility = Visibility::PRIVATE
				annotatedClass.addMethod(mName) [
					docComment = method.docComment
					returnType = method.returnType
					for (p : method.parameters) {
						addParameter(p.simpleName, p.type)
					}
					exceptions = method.exceptions
					body = ['''
						if (getNext() != null) {
							return getNext().«mName»(«FOR p : method.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
						} else {
							return «method.simpleName»(«FOR p : method.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
						}
						'''
					]
				]
			}
		}
		annotatedClass
	}
}
