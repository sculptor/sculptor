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

import org.eclipse.jdt.internal.compiler.ast.ImportReference
import org.eclipse.jdt.internal.compiler.ast.QualifiedNameReference
import org.eclipse.jdt.internal.compiler.ast.QualifiedTypeReference
import org.eclipse.text.edits.DeleteEdit
import org.eclipse.jdt.internal.compiler.lookup.Binding
import org.eclipse.jdt.internal.compiler.ast.ASTNode

class ASTNodeHelper {

	//// Qualified Type References

	static def shortTypeName(QualifiedTypeReference reference) {
		String.valueOf(reference.tokens.last)
	}

	static def qualifiedTypeName(QualifiedTypeReference reference) {
		val buf = new StringBuffer
		for (i : 0 ..< reference.tokens.length) {
			if (i > 0) buf.append('.')
			buf.append(reference.tokens.get(i))
		}
		buf.toString
	}

	static def qualificationLenth(QualifiedTypeReference reference) {
		reference.qualifiedTypeName.length - reference.shortTypeName.length
	}

	static def renameTextEdit(QualifiedTypeReference reference) {
		new DeleteEdit(reference.sourceStart, reference.qualificationLenth)
	}

	//// Qualified Name References

	static def shortTypeName(QualifiedNameReference reference) {
		for (i : 0 ..< reference.tokens.length) {
			val token = reference.tokens.get(i)
			if (Character.isUpperCase(token.get(0))) {
				return new String(token)
			}
		}
	}

	static def isFullyQualified(QualifiedNameReference reference) {
		val typeTokens = reference.tokens.length - if (reference.isVariable) 1 else 0
		typeTokens > 1
	}

	static def qualifiedTypeName(QualifiedNameReference reference) {
		val buf = new StringBuffer
		for (i : 0 ..< reference.tokens.length) {
			val token = reference.tokens.get(i)
			if (i > 0) buf.append('.')
			buf.append(token)
			if (Character.isUpperCase(token.get(0))) {
				return buf.toString
			}
		}
	}

	static def qualificationLenth(QualifiedNameReference reference) {
		var length = 0
		for (i : 0 ..< reference.tokens.length) {
			val token = reference.tokens.get(i)
			if (Character.isLowerCase(token.get(0))) {
				length = length + token.length
				if (i > 0) length = length + 1
			} else {
				return length + 1
			}
		}
	}

	static def isType(QualifiedNameReference reference) {
		reference.bits.bitwiseAnd(Binding.TYPE) == Binding.TYPE
	}

	static def isVariable(QualifiedNameReference reference) {
		reference.bits.bitwiseAnd(ASTNode.RestrictiveFlagMASK) == Binding.VARIABLE
	}

	static def renameTextEdit(QualifiedNameReference reference) {
		new DeleteEdit(reference.sourceStart, reference.qualificationLenth)
	}

	//// Import References

	static def shortTypeName(ImportReference reference) {
		String.valueOf(reference.tokens.last)
	}

	static def qualifiedTypeName(ImportReference reference) {
		reference.print(0, new StringBuffer(), false).toString
	}

}
