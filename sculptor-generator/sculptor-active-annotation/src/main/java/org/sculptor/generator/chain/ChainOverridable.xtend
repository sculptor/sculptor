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
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Adds chain interface und delegate methods for all public methods.
 */
@Target(ElementType::TYPE)
@Active(typeof(ChainOverridableProcessor))
public annotation ChainOverridable {}

class ChainOverridableProcessor extends AbstractClassProcessor {

	private static final Logger LOG = LoggerFactory::getLogger(typeof(ChainOverridableProcessor))

	public static final String RENAMED_METHOD_NAME_PREFIX = '_chained_'

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		LOG.debug("Processing class '" + annotatedClass.qualifiedName + "'")
		if (validate(annotatedClass, context)) {
			transformAnnotatedClass(annotatedClass, context)
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

	private def transformAnnotatedClass(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		LOG.debug("Transforming annotated class '" + annotatedClass.qualifiedName + "'")

		// Extend from chain link class referencing the annotated class
		val annotatedClassRef = annotatedClass.newTypeReference
		annotatedClass.extendedClass = typeof(ChainLink).newTypeReference(annotatedClassRef)

		// add constructor for chaining
		annotatedClass.addConstructor [
			addParameter("next", annotatedClassRef)
			body = ['''super(next);''']
		]

		// add methods delegating to the given extension class' public non-final methods  
		annotatedClass.declaredMethods.filter [
			visibility == Visibility::PUBLIC && !final && !static
		].forEach [ publicMethod |
			val methodName = publicMethod.simpleName

			// rename and hide public method
			publicMethod.simpleName = RENAMED_METHOD_NAME_PREFIX + methodName
			publicMethod.visibility = Visibility::PRIVATE

			// add new public delegate method
			annotatedClass.addMethod(methodName) [ delegateMethod |
				delegateMethod.returnType = publicMethod.returnType
				delegateMethod.^default = publicMethod.^default
				delegateMethod.varArgs = publicMethod.varArgs
				delegateMethod.exceptions = publicMethod.exceptions
				publicMethod.parameters.forEach[delegateMethod.addParameter(simpleName, type)]
				delegateMethod.docComment = publicMethod.docComment
				delegateMethod.body = [
					'''
						if (getNext() != null) {
							return getNext().«methodName»(«FOR p : publicMethod.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
						} else {
							return «publicMethod.simpleName»(«FOR p : publicMethod.parameters SEPARATOR ", "»«p.simpleName»«ENDFOR»);
						}
					'''
				]
			]
		]
	}
	
}