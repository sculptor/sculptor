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
	private val chainLinkBase = typeof(ChainLink)
	
	override doRegisterGlobals(ClassDeclaration annotatedClass, RegisterGlobalsContext context) {
		context.registerClass(annotatedClass.baseClassName)
	}

	def getBaseClassName(ClassDeclaration annotatedClass) {
		annotatedClass.qualifiedName+"Base"
	}
	
	override doTransform(MutableClassDeclaration annotatedClass, extension TransformationContext context) {
		val originName = annotatedClass.simpleName
		val classDecl = findClass(annotatedClass.baseClassName)
		val classDeclRef = classDecl.newTypeReference
		val tRef = chainLinkBase.newTypeReference(classDeclRef)
		classDecl.extendedClass = tRef

		// Process ...Tmpl class

		// set superclass on annotatedClass
		annotatedClass.simpleName = annotatedClass.simpleName+"Extension"
		annotatedClass.extendedClass = classDecl.newTypeReference
		// add constructor
		annotatedClass.addConstructor[
			body = ['''super(null);''']
		]

		// Process new ...TmplBase class

		classDecl.simpleName = originName
		// add constructor
		classDecl.addConstructor[
			addParameter("next", classDeclRef)
			body = ['''super(next);''']
		]

		// add the public methods to the interface
		for (method : annotatedClass.declaredMethods) {
			if (method.visibility == Visibility::PUBLIC) {
				classDecl.addMethod(method.simpleName) [
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
	}
	
}