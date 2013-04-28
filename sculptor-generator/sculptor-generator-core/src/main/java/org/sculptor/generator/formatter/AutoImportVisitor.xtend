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
import org.eclipse.jdt.internal.compiler.ast.ImportReference
import org.eclipse.jdt.internal.compiler.ast.ParameterizedQualifiedTypeReference
import org.eclipse.jdt.internal.compiler.ast.QualifiedTypeReference
import org.eclipse.jdt.internal.compiler.lookup.BlockScope
import org.eclipse.jdt.internal.compiler.lookup.ClassScope
import org.eclipse.text.edits.DeleteEdit
import org.eclipse.text.edits.MultiTextEdit
import org.eclipse.text.edits.TextEdit
import org.eclipse.text.edits.InsertEdit

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
		additionalImports.forEach[importName|textEdit.addChild(new InsertEdit(pos, 'import ' + importName + ';\n'))]
		textEdit
	}

	override visit(QualifiedTypeReference typeReference, BlockScope scope) {
		autoImport(typeReference)
		return false
	}

	override visit(QualifiedTypeReference typeReference, ClassScope scope) {
		autoImport(typeReference)
		return false
	}

	override visit(ParameterizedQualifiedTypeReference typeReference, BlockScope scope) {
		autoImport(typeReference)
		return false
	}

	override visit(ParameterizedQualifiedTypeReference typeReference, ClassScope scope) {
		autoImport(typeReference)
		return false
	}

	private def autoImport(QualifiedTypeReference typeReference) {

		// Check if import already defined 
		if (imports.contains(typeReference.qualifiedName)) {
			renameQualifiedType(typeReference)
		} else // Check if this types short name collides with an already used short name
		if (!importShortNames.contains(typeReference.shortName)) {
			renameQualifiedType(typeReference)
			addImport(typeReference)
		}
	}

	def autoImport(ParameterizedQualifiedTypeReference typeReference) {
		autoImport(typeReference as QualifiedTypeReference)
		typeReference.typeArguments.forEach [ typeArgumentTypeReferences |
			if (typeArgumentTypeReferences != null) {
				typeArgumentTypeReferences.forEach [ typeArgumentTypeReference |
					if (typeArgumentTypeReference instanceof QualifiedTypeReference) {
						autoImport(typeArgumentTypeReference as QualifiedTypeReference)
					}
				]
			}
		]
	}

	private def renameQualifiedType(QualifiedTypeReference reference) {
		textEdit.addChild(
			new DeleteEdit(reference.sourceStart, reference.qualificationLenth)
		)
	}

	private def addImport(QualifiedTypeReference typeReference) {
		additionalImports += typeReference.qualifiedName
		imports += typeReference.qualifiedName
		importShortNames += typeReference.shortName
	}

	private def qualifiedName(ImportReference importReference) {
		importReference.print(0, new StringBuffer(), false).toString
	}

	private def shortName(ImportReference importReference) {
		importReference.tokens.last.toString
	}

	private def qualifiedName(QualifiedTypeReference typeReference) {
		val buf = new StringBuffer
		for (i : 0 ..< typeReference.tokens.length) {
			if(i > 0) buf.append('.');
			buf.append(typeReference.tokens.get(i));
		}
		buf.toString
	}

	private def qualificationLenth(QualifiedTypeReference typeReference) {
		typeReference.qualifiedName.length - typeReference.shortName.length
	}

	private def shortName(QualifiedTypeReference typeReference) {
		typeReference.tokens.last.toString
	}

}
