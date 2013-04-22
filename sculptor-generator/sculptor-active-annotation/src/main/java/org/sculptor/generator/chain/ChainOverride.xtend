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
import org.sculptor.generator.util.ChainLink

/**
 * Adds additional constructor used for chainining.
 * @see ChainLink
 */
@Target(ElementType::TYPE)
@Active(typeof(ChainOverrideProcessor))
annotation ChainOverride {
}

class ChainOverrideProcessor extends AbstractClassProcessor {

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		if (validate(annotatedClass, context)) {

			// Add constructor needed for chaining
			annotatedClass.addConstructor [
				addParameter('name', annotatedClass.extendedClass)
				body = ['''super(name);''']
			]
		}
	}

	private def validate(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val extendedClass = annotatedClass.extendedClass

		// A missing superclass is already validated by the Xtend compiler 
		if (extendedClass == null) {
			return false
		}

		// Check if annotated class does extend another class
		if (extendedClass.name == 'java.lang.Object') {
			annotatedClass.addError('Annotated class must extend a class')
			return false
		}

		// If the extended class is on the classpath than the corresponding Xtend class is checked
		// for the SupportChainOverriding annotation  
//		if (findTypeGlobally(extendedClass.name) != null) {
//			val extendedClassDeclaration = findClass(extendedClass.name)
//			if (extendedClassDeclaration == null) {
//				annotatedClass.addWarning("Extended class '" + extendedClass.name + "' must be an Xtend class")
//			} else {
//				val annotation = extendedClassDeclaration.findAnnotation(
//					typeof(SupportChainOverriding).newTypeReference()?.type)
//				if (annotation == null) {
//					annotatedClass.addWarning(
//						"Extended class '" + extendedClass.name + "' is not annotated with SupportChainOverriding")
//				}
//			}
//		}
		true
	}

}
