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
package org.sculptor.dsl.ui;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.xtext.ide.editor.syntaxcoloring.DefaultSemanticHighlightingCalculator;
import org.eclipse.xtext.ide.editor.syntaxcoloring.IHighlightedPositionAcceptor;
import org.eclipse.xtext.nodemodel.ILeafNode;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.ui.editor.syntaxcoloring.DefaultHighlightingConfiguration;
import org.eclipse.xtext.util.CancelIndicator;

public class SculptordslSemanticHighlightingCalculator extends DefaultSemanticHighlightingCalculator {

	private static final Set<String> TERMINAL_KEYWORDS = new HashSet<String>();

	{
		TERMINAL_KEYWORDS.add("=>");
		TERMINAL_KEYWORDS.add("delegates to");
		TERMINAL_KEYWORDS.add("<->");
		TERMINAL_KEYWORDS.add("opposite");
		TERMINAL_KEYWORDS.add("!");
		TERMINAL_KEYWORDS.add("not");
		TERMINAL_KEYWORDS.add("-");
		TERMINAL_KEYWORDS.add("reference");
		TERMINAL_KEYWORDS.add("Map");
	}

	public void provideHighlightingFor(XtextResource resource, IHighlightedPositionAcceptor acceptor,
			CancelIndicator cancelIndicator) {
		if (resource == null)
			return;

		if (resource.getContents().size() > 0) {
			Iterable<INode> allNodes = resource.getParseResult().getRootNode().getAsTreeIterable();
			for (INode node : allNodes) {
				if (node instanceof ILeafNode) {
					ILeafNode leafNode = (ILeafNode) node;
					// TODO check returned values of GrammarElement
					if ("doc".equals(leafNode.getGrammarElement())) {
						acceptor.addPosition(node.getOffset(), node.getLength(),
								DefaultHighlightingConfiguration.COMMENT_ID);
					} else if (TERMINAL_KEYWORDS.contains(leafNode.getText())) {
						acceptor.addPosition(node.getOffset(), node.getLength(),
								DefaultHighlightingConfiguration.KEYWORD_ID);
					}
				}
			}
		}
	}

}
