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

import java.util.HashMap
import java.util.Map
import java.util.regex.Pattern
import org.eclipse.jdt.internal.compiler.impl.CompilerOptions
import org.eclipse.jdt.internal.core.util.CodeSnippetParsingUtil
import org.eclipse.jface.text.Document
import org.eclipse.jface.text.IDocument
import org.eclipse.text.edits.DeleteEdit
import org.eclipse.text.edits.MultiTextEdit

/**
 * Uses the JDT compiler to replace all fully qualified class names (as long as there is
 * no conflict) by their short name and adds the corresponding import statement.
 * <p>
 * The imports are placed in the source code at a position specified via regexp pattern
 * (parameter <code>importMarkerPattern</code>).
 * 
 * @see CodeSnippetParsingUtil
 * @see AutoImportVisitor
 */
class JavaCodeAutoImporter {

	def String replaceQualifiedTypes(String source, String importMarkerPattern) {

		// First check if given marker can be found in source  
		val importMarkerMatcher = Pattern::compile(importMarkerPattern).matcher(source)
		if (importMarkerMatcher.find) {
			val parser = new CodeSnippetParsingUtil
			val compilationUnit = parser.parseCompilationUnit(source.toCharArray(), compilerOptions, true)
			if (compilationUnit != null && !compilationUnit.hasErrors) {
				val IDocument doc = new Document(source)
				try {
					val visitor = new AutoImportVisitor(compilationUnit)
					val textEdit = new MultiTextEdit(0, source.length)
					textEdit.addChild(visitor.replaceQualifiedTypes())
					textEdit.addChild(
						new DeleteEdit(importMarkerMatcher.start, importMarkerMatcher.end - importMarkerMatcher.start))
					textEdit.addChild(visitor.insertAdditionalImports(importMarkerMatcher.start))
					textEdit.apply(doc)
					return doc.get()
				} catch (Exception e) {
					e.printStackTrace
				}
			}
		}
		return source
	}

	private var Map<String, String> compilerOptionsMap

	def getCompilerOptions() {
		if (compilerOptionsMap == null) {
			val optionsMap = new HashMap(30)
			optionsMap.put(CompilerOptions::OPTION_LocalVariableAttribute, CompilerOptions::DO_NOT_GENERATE)
			optionsMap.put(CompilerOptions::OPTION_LineNumberAttribute, CompilerOptions::DO_NOT_GENERATE)
			optionsMap.put(CompilerOptions::OPTION_SourceFileAttribute, CompilerOptions::DO_NOT_GENERATE)
			optionsMap.put(CompilerOptions::OPTION_PreserveUnusedLocal, CompilerOptions::PRESERVE)
			optionsMap.put(CompilerOptions::OPTION_DocCommentSupport, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportMethodWithConstructorName, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportOverridingPackageDefaultMethod, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportOverridingMethodWithoutSuperInvocation, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportDeprecation, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportDeprecationInDeprecatedCode, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportDeprecationWhenOverridingDeprecatedMethod,
				CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportHiddenCatchBlock, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedLocal, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedObjectAllocation, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedParameter, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedImport, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportSyntheticAccessEmulation, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportNoEffectAssignment, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportNonExternalizedStringLiteral, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportNoImplicitStringConversion, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportNonStaticAccessToStatic, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportIndirectStaticAccess, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportIncompatibleNonInheritedInterfaceMethod,
				CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedPrivateMember, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportLocalVariableHiding, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportFieldHiding, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportPossibleAccidentalBooleanAssignment, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportEmptyStatement, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportAssertIdentifier, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportEnumIdentifier, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUndocumentedEmptyBlock, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnnecessaryTypeCheck, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportInvalidJavadoc, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportInvalidJavadocTagsVisibility, CompilerOptions::PUBLIC)
			optionsMap.put(CompilerOptions::OPTION_ReportInvalidJavadocTags, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportMissingJavadocTagDescription, CompilerOptions::RETURN_TAG)
			optionsMap.put(CompilerOptions::OPTION_ReportInvalidJavadocTagsDeprecatedRef, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportInvalidJavadocTagsNotVisibleRef, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportMissingJavadocTags, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportMissingJavadocTagsVisibility, CompilerOptions::PUBLIC)
			optionsMap.put(CompilerOptions::OPTION_ReportMissingJavadocTagsOverriding, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportMissingJavadocComments, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportMissingJavadocCommentsVisibility, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportMissingJavadocCommentsOverriding, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportFinallyBlockNotCompletingNormally, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedDeclaredThrownException, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedDeclaredThrownExceptionWhenOverriding,
				CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportUnqualifiedFieldAccess, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_Compliance, CompilerOptions::VERSION_1_6)
			optionsMap.put(CompilerOptions::OPTION_Source, CompilerOptions::VERSION_1_6)
			optionsMap.put(CompilerOptions::OPTION_TargetPlatform, CompilerOptions::VERSION_1_6)
			optionsMap.put(CompilerOptions::OPTION_TaskTags, '')
			optionsMap.put(CompilerOptions::OPTION_TaskPriorities, '')
			optionsMap.put(CompilerOptions::OPTION_TaskCaseSensitive, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedParameterWhenImplementingAbstract,
				CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportUnusedParameterWhenOverridingConcrete,
				CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportSpecialParameterHidingField, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportUnavoidableGenericTypeProblems, CompilerOptions::ENABLED)
			optionsMap.put(CompilerOptions::OPTION_MaxProblemPerUnit, String::valueOf(100))
			optionsMap.put(CompilerOptions::OPTION_InlineJsr, CompilerOptions::DISABLED)
			optionsMap.put(CompilerOptions::OPTION_ReportMethodCanBeStatic, CompilerOptions::IGNORE)
			optionsMap.put(CompilerOptions::OPTION_ReportMethodCanBePotentiallyStatic, CompilerOptions::IGNORE)
			compilerOptionsMap = optionsMap
		}
		compilerOptionsMap
	}

}
