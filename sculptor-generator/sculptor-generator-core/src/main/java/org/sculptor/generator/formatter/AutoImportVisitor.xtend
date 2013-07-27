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
package org.sculptor.generator.formatter

import java.util.HashSet
import java.util.Set
import org.eclipse.jdt.internal.compiler.ASTVisitor
import org.eclipse.jdt.internal.compiler.ast.CompilationUnitDeclaration
import org.eclipse.jdt.internal.compiler.ast.ParameterizedQualifiedTypeReference
import org.eclipse.jdt.internal.compiler.ast.QualifiedNameReference
import org.eclipse.jdt.internal.compiler.ast.QualifiedTypeReference
import org.eclipse.jdt.internal.compiler.lookup.BlockScope
import org.eclipse.jdt.internal.compiler.lookup.ClassScope
import org.eclipse.text.edits.InsertEdit
import org.eclipse.text.edits.MultiTextEdit
import org.eclipse.text.edits.TextEdit

import static extension org.sculptor.generator.formatter.ASTNodeHelper.*

/**
 * This {@link ASTVisitor} provides {@link TextEdit} instances to replace all
 * fully qualified type names (as long as there is no conflict) by their short
 * name and to add the corresponding import statements for a
 * parsed {@ CompilationUnitDeclaration}.
 */
class AutoImportVisitor extends ASTVisitor {

	private val CompilationUnitDeclaration compilationUnit
	private val Set<String> imports = new HashSet
	private val Set<String> importShortNames = new HashSet
	private val Set<String> additionalImports = new HashSet
	private var TextEdit textEdit = new MultiTextEdit

	new(CompilationUnitDeclaration compilationUnit) {
		this.compilationUnit = compilationUnit
		if (compilationUnit.imports != null) {
			compilationUnit.imports.forEach [ importRef |
				imports += importRef.qualifiedName
				importShortNames += importRef.shortName
			]

		}
	}

	def TextEdit replaceQualifiedTypes() {
		compilationUnit.traverse(this, compilationUnit.scope)
		textEdit
	}

	def TextEdit insertAdditionalImports(int pos) {
		val textEdit = new MultiTextEdit
		additionalImports.sort.forEach[importName|textEdit.addChild(new InsertEdit(pos, 'import ' + importName + ';\n'))]
		textEdit
	}

	override visit(QualifiedTypeReference typeReference, BlockScope scope) {
		autoImport(typeReference)
		return false
	}

	override visit(QualifiedTypeReference reference, ClassScope scope) {
		autoImport(reference)
		return false
	}

	override visit(ParameterizedQualifiedTypeReference reference, BlockScope scope) {
		autoImport(reference)
		return false
	}

	override visit(ParameterizedQualifiedTypeReference reference, ClassScope scope) {
		autoImport(reference)
		return false
	}

	override boolean visit(QualifiedNameReference reference, BlockScope scope) {
		autoImport(reference)
		return false
	}

	override boolean visit(QualifiedNameReference reference, ClassScope scope) {
		autoImport(reference)
		return false
	}

	private def autoImport(QualifiedTypeReference reference) {

		// Check if import already defined 
		if (imports.contains(reference.qualifiedName)) {
			textEdit.addChild(reference.renameTextEdit)
		} else // Check if this types short name collides with an already used short name
		if (!importShortNames.contains(reference.shortName)) {
			textEdit.addChild(reference.renameTextEdit)
			addImport(reference)
		}
	}

	private def autoImport(ParameterizedQualifiedTypeReference reference) {
		autoImport(reference as QualifiedTypeReference)
		reference.typeArguments.forEach [ referenceTypeArguments |
			if (referenceTypeArguments != null) {
				referenceTypeArguments.forEach [ referenceTypeArgument |
					if (referenceTypeArgument instanceof QualifiedTypeReference) {
						autoImport(referenceTypeArgument as QualifiedTypeReference)
					}
				]
			}
		]
	}

	private def addImport(QualifiedTypeReference reference) {
		additionalImports += reference.qualifiedName
		imports += reference.qualifiedName
		importShortNames += reference.shortName
	}

	private def autoImport(QualifiedNameReference reference) {
		if (reference.fullyQualified && (reference.isType || reference.variable)) {

			// reference.shortName for constants is in form 'CascadeType.DELETE_ORPHAN' we have to cut only class name
			val refShortName = reference.shortName
			val dotPos = refShortName.indexOf('.')
			val shortName = if(dotPos == -1) refShortName else refShortName.substring(0, dotPos) // skip unqualified type references

			// Check if import already defined
			if (imports.contains(reference.qualifiedName)) {
				textEdit.addChild(reference.renameTextEdit)
			} else // Check if this types short name collides with an already used short name
			if (!importShortNames.contains(shortName)) {
				textEdit.addChild(reference.renameTextEdit)
				addImport(reference, shortName)
			}
		}
	}

	private def addImport(QualifiedNameReference reference, String shortName) {
		additionalImports += reference.qualifiedName
		imports += reference.qualifiedName
		importShortNames += shortName
	}

}
