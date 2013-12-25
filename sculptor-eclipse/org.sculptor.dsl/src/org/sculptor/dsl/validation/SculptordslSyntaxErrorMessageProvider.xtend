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
package org.sculptor.dsl.validation

import com.google.inject.Inject
import org.eclipse.xtext.GrammarUtil
import org.eclipse.xtext.IGrammarAccess
import org.eclipse.xtext.nodemodel.SyntaxErrorMessage
import org.eclipse.xtext.parser.antlr.SyntaxErrorMessageProvider
import org.eclipse.xtext.parser.antlr.ISyntaxErrorMessageProvider.IParserErrorContext
import org.antlr.runtime.MissingTokenException
import org.antlr.runtime.MismatchedTokenException

/**
 * Customizes syntax error message of the ANTLR lexer / parser.
 * <p>
 * see http://zarnekow.blogspot.com/2010/06/customizing-error-messages-in-xtext-10.html
 */
class SculptordslSyntaxErrorMessageProvider extends SyntaxErrorMessageProvider {

	@Inject IGrammarAccess grammarAccess

	/**
     * Customizes error message for reserved keywords "mismatched input 'xxx' expecting RULE_ID".
     */
	override getSyntaxErrorMessage(IParserErrorContext context) {
		if ((context.recognitionException instanceof MissingTokenException) ||
			(context.recognitionException instanceof MismatchedTokenException)) {
			val missingTokenText = context.recognitionException.token.text
			if (GrammarUtil::getAllKeywords(grammarAccess.getGrammar()).contains(missingTokenText)) {
				return new SyntaxErrorMessage(
					"'" + missingTokenText + "' is a reserved keyword which is not allowed as Identifier. " +
						"Please choose another word or alternatively escape it with the caret (^) character, e.g. '^" +
						missingTokenText + "'", IssueCodes::USED_RESERVED_KEYWORD, #[missingTokenText])
			}
		}
		super.getSyntaxErrorMessage(context)
	}

}
