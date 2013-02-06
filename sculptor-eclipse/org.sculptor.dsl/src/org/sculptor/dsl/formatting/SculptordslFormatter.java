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

package org.sculptor.dsl.formatting;

import java.util.List;

import org.eclipse.xtext.Keyword;
import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter;
import org.eclipse.xtext.formatting.impl.FormattingConfig;
import org.eclipse.xtext.util.Pair;

/**
 * This class contains custom formatting description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#formatting
 * on how and when to use it
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an
 * example
 */
public class SculptordslFormatter extends AbstractDeclarativeFormatter {

	@Override
	protected void configureFormatting(FormattingConfig c) {
		org.sculptor.dsl.services.SculptordslGrammarAccess f = (org.sculptor.dsl.services.SculptordslGrammarAccess) getGrammarAccess();

		c.setAutoLinewrap(120);

		c.setIndentation(f.getDslApplicationAccess().getLeftCurlyBracketKeyword_1_0_2(), f.getDslApplicationAccess()
				.getRightCurlyBracketKeyword_3());
		List<Pair<Keyword, Keyword>> pairs = f.findKeywordPairs("{", "}");
		for (Pair<Keyword, Keyword> pair : pairs) {
			c.setIndentation(pair.getFirst(), pair.getSecond());
			c.setLinewrap().after(pair.getFirst());
			c.setLinewrap(1, 2, 2).around(pair.getSecond());
		}

		for (Keyword each : f.findKeywords("@")) {
			c.setNoSpace().after(each);
		}
		for (Keyword each : f.findKeywords("!")) {
			c.setNoSpace().after(each);
		}
		for (Keyword each : f.findKeywords(";")) {
			c.setNoSpace().before(each);
			c.setLinewrap(1, 2, 2).after(each);
		}
		for (Keyword each : f.findKeywords(".")) {
			c.setNoSpace().around(each);
		}
		for (Keyword each : f.findKeywords("=")) {
			c.setNoSpace().around(each);
		}
		for (Keyword each : f.findKeywords("<")) {
			c.setNoSpace().around(each);
		}
		for (Keyword each : f.findKeywords(">")) {
			c.setNoSpace().before(each);
		}
		for (Keyword each : f.findKeywords("(")) {
			c.setNoSpace().around(each);
		}
		for (Keyword each : f.findKeywords(")")) {
			c.setNoSpace().before(each);
		}
		for (Keyword each : f.findKeywords(",")) {
			c.setNoSpace().before(each);
			c.setSpace(" ").after(each);
		}
		for (Keyword each : f.findKeywords("gap")) {
			c.setLinewrap().around(each);
		}
		for (Keyword each : f.findKeywords("package")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("scaffold")) {
			c.setLinewrap().around(each);
		}
		for (Keyword each : f.findKeywords("belongsTo")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("aggregateRoot")) {
			c.setLinewrap().after(each);
		}
		for (Keyword each : f.findKeywords("validate")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("databaseTable")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("discriminatorValue")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("discriminatorColumn")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("discriminatorType")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("discriminatorLength")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("inheritanceType")) {
			c.setLinewrap().before(each);
		}
		for (Keyword each : f.findKeywords("subscribe")) {
			c.setLinewrap().before(each);
		}

		c.setLinewrap(1, 2, 2).around(f.getDslImportRule());
		c.setLinewrap(1, 2, 2).before(f.getDslApplicationAccess().getBasePackageKeyword_1_0_3());
		c.setLinewrap(2, 2, 3).around(f.getDslModuleRule());
		c.setLinewrap(2, 2, 3).around(f.getDslEntityRule());
		c.setLinewrap(2, 2, 3).around(f.getDslValueObjectRule());
		c.setLinewrap(2, 2, 3).around(f.getDslBasicTypeRule());
		c.setLinewrap(2, 2, 3).around(f.getDslEnumRule());
		c.setLinewrap(2, 2, 3).around(f.getDslDomainEventRule());
		c.setLinewrap(2, 2, 3).around(f.getDslCommandEventRule());
		c.setLinewrap(2, 2, 3).around(f.getDslServiceRule());
		c.setLinewrap(2, 2, 3).around(f.getDslResourceRule());
		c.setLinewrap(2, 2, 3).around(f.getDslConsumerRule());
		c.setLinewrap(2, 2, 3).around(f.getDslRepositoryRule());
		c.setLinewrap(1, 2, 2).around(f.getDslAttributeRule());
		c.setLinewrap(1, 2, 2).around(f.getDslReferenceRule());
		c.setLinewrap(1, 2, 2).around(f.getDslDomainObjectOperationRule());
		c.setLinewrap(1, 2, 2).around(f.getDslEnumAttributeRule());
		c.setLinewrap(1, 2, 2).around(f.getDslDtoAttributeRule());
		c.setLinewrap(1, 2, 2).around(f.getDslDtoReferenceRule());
		c.setLinewrap(1, 2, 2).around(f.getDslDtoAttributeRule());
		c.setLinewrap(1, 2, 2).around(f.getDslServiceOperationRule());
		c.setLinewrap(1, 2, 2).around(f.getDslResourceOperationRule());
		c.setLinewrap(1, 2, 2).around(f.getDslRepositoryOperationRule());
		c.setLinewrap().around(f.getDslServiceAccess().getWebServiceWebserviceKeyword_4_2_0());
		c.setLinewrap().before(f.getDslServiceAccess().getHintKeyword_4_1_0());
		c.setLinewrap().before(f.getDslResourceAccess().getHintKeyword_4_1_0());
		c.setLinewrap().before(f.getDslConsumerAccess().getHintKeyword_4_0());
		c.setLinewrap().before(f.getDslEntityAccess().getHintKeyword_8_5_0());
		c.setLinewrap().before(f.getDslValueObjectAccess().getHintKeyword_8_5_0());
		c.setLinewrap().before(f.getDslBasicTypeAccess().getHintKeyword_6_2_0());
		c.setLinewrap().before(f.getDslEnumAccess().getHintKeyword_5_0());
		c.setLinewrap().before(f.getDslDomainEventAccess().getHintKeyword_8_3_0());
		c.setLinewrap().before(f.getDslCommandEventAccess().getHintKeyword_8_3_0());
		c.setLinewrap().before(f.getDslConsumerAccess().getQueueNameKeyword_7_0_0_0());
		c.setLinewrap().before(f.getDslConsumerAccess().getTopicNameKeyword_7_0_0_1());
		c.setLinewrap().after(f.getDslEntityAccess().getOptimisticLockingKeyword_8_0_0_1());
		c.setLinewrap().after(f.getDslValueObjectAccess().getOptimisticLockingKeyword_8_0_0_1());
		c.setLinewrap().after(f.getDslEntityAccess().getAuditableKeyword_8_1_0_1());
		c.setLinewrap().around(f.getDslEntityAccess().getCacheKeyword_8_2_1_1());
		c.setLinewrap().around(f.getDslValueObjectAccess().getCacheKeyword_8_2_1_1());
		c.setLinewrap().around(f.getDslModuleAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslEntityAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslValueObjectAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslBasicTypeAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslDataTransferObjectAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslEnumAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslDomainEventAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslCommandEventAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslServiceAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslRepositoryAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslConsumerAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslServiceOperationAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslResourceOperationAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslRepositoryOperationAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslAttributeAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslReferenceAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslDtoAttributeAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslDtoReferenceAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslEnumAttributeAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslEnumValueAccess().getDocAssignment_0());
		c.setLinewrap().around(f.getDslApplicationAccess().getDocAssignment_0());

		c.setLinewrap(0, 1, 2).before(f.getSL_COMMENTRule());
		c.setLinewrap(1, 2, 2).before(f.getML_COMMENTRule());
		c.setLinewrap(1, 1, 1).after(f.getML_COMMENTRule());
	}
}
