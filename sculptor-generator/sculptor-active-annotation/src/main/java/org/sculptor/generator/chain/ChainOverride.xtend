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
import org.eclipse.xtend.lib.macro.declaration.ClassDeclaration
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration
import org.slf4j.Logger
import org.slf4j.LoggerFactory

import static extension org.sculptor.generator.chain.ChainOverrideHelper.*

/**
 * This active annotation does the following modifications in order to support chain overriding:
 * <ol>
 * <li>Adds an additional constructor used for chainining.
 * <li>Modifies the overrideable methods by renaming the actual method and replacing it with a public method that delegates to the head of the chain.
 * <li>Add a method to get the dispatch array for each overrideable method.
 * </ol>
 * @see ChainOverridable
 * @see ChainLink
 */
@Target(ElementType.TYPE)
@Active(typeof(ChainOverrideProcessor))
annotation ChainOverride {
}

class ChainOverrideProcessor extends AbstractClassProcessor {

	static final Logger LOG = LoggerFactory.getLogger(typeof(ChainOverrideProcessor))

	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		LOG.debug("Processing class '" + annotatedClass.qualifiedName + "'")
		if (validate(annotatedClass, context)) {
			
			// Add constructor needed for chaining
			annotatedClass.addConstructor [
				addParameter('next', annotatedClass.extendedClass)
				addParameter('methodsDispatchNext', annotatedClass.extendedClass.newArrayTypeReference)
				body = ['''super(next);''']
			]

			val originalTmplMethodsMap = annotatedClass.baseClassOverrideableMethodsMap

			val originalTmplClass = annotatedClass.extendedClass.type as ClassDeclaration
						
			// Modify the overrideable methods, modify the original method todelegates to the head of the chain and
			// create a new method with the original method body.
			// Filter out non-override methods.  MethodDeclaration doesn't carry an override indicator,
			// so instead we look for methods with the same signature in base class to detect an override.
			val overrideableMethodsInfo = annotatedClass.overrideableMethodsInfo
				.filter[methodInfo | originalTmplMethodsMap.containsKey(methodInfo.publicMethod.indexName)].toList
			overrideableMethodsInfo.forEach [ methodInfo |
				annotatedClass.modifyOverrideableMethod(originalTmplClass, methodInfo, context)
			]

			// Add a method to get the dispatch array for each overrideable method
			annotatedClass.addGetOverridesDispatchArrayMethod(originalTmplClass, context, overrideableMethodsInfo)
		}
	}

	/**
	 * @return Map of method index name to MethodDeclaration for base class
	 */
	private def getBaseClassOverrideableMethodsMap(MutableClassDeclaration annotatedClass) {
		val originalTmplClass = annotatedClass.extendedClass.type as ClassDeclaration

		val originalTmplMethodsMap = originalTmplClass.overrideableMethods.toMap[method| method.indexName]
		originalTmplMethodsMap
	}
	
	private def validate(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val extendedClass = annotatedClass.extendedClass

		// Check if annotated class does extend another class
		if (extendedClass === null || extendedClass.name == 'java.lang.Object') {
			annotatedClass.addError('Annotated class must extend a class')
			return false
		}

//		// Check for inferred override method
//		annotatedClass.overrideableMethods.forEach [
//			if (returnType.inferred) {
//				addError("Methods with inferred return type are not supported by ChainOverride")
//			}
//		]

		// If the extended class is on the classpath than the corresponding Xtend class is checked
		// for the ChainOverridable annotation  
//		if (findTypeGlobally(extendedClass.name) != null) {
//			val extendedClassDeclaration = findClass(extendedClass.name)
//			if (extendedClassDeclaration == null) {
//				annotatedClass.addWarning("Extended class '" + extendedClass.name + "' must be an Xtend class")
//			} else {
//				val annotation = extendedClassDeclaration.findAnnotation(
//					typeof(ChainOverridable).newTypeReference()?.type)
//				if (annotation == null) {
//					annotatedClass.addWarning(
//						"Extended class '" + extendedClass.name + "' is not annotated with ChainOverridable")
//				}
//			}
//		}
		true
	}

}
