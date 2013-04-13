package org.sculptor.generator.chain

import java.lang.annotation.ElementType
import java.lang.annotation.Target
import org.eclipse.xtend.lib.macro.AbstractClassProcessor
import org.eclipse.xtend.lib.macro.Active
import org.eclipse.xtend.lib.macro.TransformationContext
import org.eclipse.xtend.lib.macro.declaration.MutableClassDeclaration

/**
 * Extracts super class, chain interface for all locally declared public methods.
 */
@Target(ElementType::TYPE)
@Active(typeof(ChainOverrideProcessor))
public annotation ChainOverride {
//	Class<? extends ChainLink<?>> baseClass
}

class ChainOverrideProcessor extends AbstractClassProcessor {
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val extRef = findClass(annotatedClass.extendedClass.name)
		var Class<?> extClass
		try {
			extClass = Class::forName(annotatedClass.extendedClass.name)
		} catch (Throwable th) {
			extClass = null
		}

		if (extRef != null) {
			val support = extRef.findAnnotation(typeof(SupportChainOverriding).newTypeReference()?.type)
			if (support != null) {
			} else {
				annotatedClass.addError("Classes with ChainOverride annotation have to extends original template")
			}
		} else if (extClass != null) {

		} else {
		}

		if (!annotatedClass.extendedClass.simpleName.endsWith("Base")) {
			annotatedClass.addError("Class anottated with ChainOverride have to extends XxxBase class")
		}
		annotatedClass.addConstructor[
			addParameter("name", annotatedClass.extendedClass)
			body = ['''super(name);''']
		]
		
		// add default constructor
		annotatedClass.addConstructor[
			body = ['''super();''']
		]

	}
}