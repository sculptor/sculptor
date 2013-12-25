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

package org.sculptor.dsl.ui.quickfix

import com.google.inject.Inject
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.IGrammarAccess
import org.eclipse.xtext.ui.editor.model.edit.IModificationContext
import org.eclipse.xtext.ui.editor.quickfix.DefaultQuickfixProvider
import org.eclipse.xtext.ui.editor.quickfix.Fix
import org.eclipse.xtext.ui.editor.quickfix.IssueResolutionAcceptor
import org.eclipse.xtext.validation.Issue
import org.sculptor.dsl.validation.IssueCodes

/**
 * Custom quickfixes.
 * <p>
 * see http://www.eclipse.org/Xtext/documentation.html#quickfixes
 */
class SculptordslQuickfixProvider extends DefaultQuickfixProvider {

	@Inject IGrammarAccess grammarAccess

	@Fix(IssueCodes::CAPITALIZED_NAME)
	def capitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, "Capitalize name", "Capitalize the name.", "uppercase.gif") [
			context |
			val xtextDocument = context.xtextDocument
			val firstLetter = xtextDocument.get(issue.offset, 1)
			xtextDocument.replace(issue.getOffset(), 1, firstLetter.toUpperCase)
		]
	}

	@Fix(IssueCodes::UNCAPITALIZED_NAME)
	def uncapitalizeName(Issue issue, IssueResolutionAcceptor acceptor) {
		acceptor.accept(issue, "Uncapitalize name", "Uncapitalize the name.", "lowercase.gif") [
			context |
			val xtextDocument = context.xtextDocument
			val firstLetter = xtextDocument.get(issue.offset, 1)
			xtextDocument.replace(issue.getOffset(), 1, firstLetter.toLowerCase)
		]
	}

	@Fix(IssueCodes::USED_RESERVED_KEYWORD)
	def reservedKeywordWithPrefix(Issue issue, IssueResolutionAcceptor acceptor) {
		val keyword = issue.data.get(0)
		val keywordReplacement = keyword.generateUniqueIdentifier(false)
		acceptor.accept(issue, "Change '" + keyword + "' to '" + keywordReplacement + "'.",
			"Change '" + keyword + "' to '" + keywordReplacement + "', " +
				"which is not a reserved keyword.", "rename.gif",
			[ IModificationContext context |
				val xtextDocument = context.getXtextDocument
				xtextDocument.replace(issue.offset, issue.length, keywordReplacement)
			])
	}

	@Fix(IssueCodes::USED_RESERVED_KEYWORD)
	def reservedKeywordWithCamelCasePrefix(Issue issue, IssueResolutionAcceptor acceptor) {
		val keyword = issue.data.get(0)
		val keywordReplacement = keyword.generateUniqueIdentifier(true)
		acceptor.accept(issue, "Change '" + keyword + "' to '" + keywordReplacement + "'.",
			"Change '" + keyword + "' to '" + keywordReplacement + "', " +
				"which is not a reserved keyword.", "rename.gif",
			[ IModificationContext context |
				val xtextDocument = context.getXtextDocument
				xtextDocument.replace(issue.offset, issue.length, keywordReplacement)
			])
	}

	def String generateUniqueIdentifier(String it, boolean camelCase) {
		val candidate = 'my' + if (camelCase) it.toFirstUpper else it
		var count = 1
		val reserved = GrammarUtil::getAllKeywords(grammarAccess.getGrammar())
		if (reserved.contains(candidate)) {
			while (reserved.contains(candidate + count)) {
				count = count + 1
			}
			return candidate + count
		}
		return candidate
	}

	@Fix(IssueCodes::USED_RESERVED_KEYWORD)
	def reservedKeywordWithEscape(Issue issue, IssueResolutionAcceptor acceptor) {
		val keyword = issue.data.get(0)
		val keywordReplacement = '^' + keyword
		acceptor.accept(issue, "Change '" + keyword + "' to '^" + keyword + "'.",
			"Change '" + keyword + "' to '" + keyword + "', " + "which is the escaped keyword.", "rename.gif",
			[ IModificationContext context |
				val xtextDocument = context.getXtextDocument
				xtextDocument.replace(issue.offset, issue.length, keywordReplacement)
			])
	}

	@Fix(IssueCodes::ALL_LOWERCASE_NAME)
	def lowercaseName(Issue issue, IssueResolutionAcceptor acceptor) {
		val name = issue.data.get(0)
		acceptor.accept(issue, "Lowercase name", "Lowercase the name.", "lowercase.gif") [
			context |
			val xtextDocument = context.xtextDocument
			xtextDocument.replace(issue.offset, name.length, name.toLowerCase)
		]
	}

}
