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

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.resource.URIConverter;
import org.eclipse.jface.text.Region;
import org.eclipse.xtext.RuleCall;
import org.eclipse.xtext.nodemodel.INode;
import org.eclipse.xtext.nodemodel.util.NodeModelUtils;
import org.eclipse.xtext.resource.XtextResource;
import org.eclipse.xtext.scoping.impl.ImportUriGlobalScopeProvider;
import org.eclipse.xtext.scoping.impl.ImportUriResolver;
import org.eclipse.xtext.ui.editor.hyperlinking.HyperlinkHelper;
import org.eclipse.xtext.ui.editor.hyperlinking.IHyperlinkAcceptor;
import org.eclipse.xtext.ui.editor.hyperlinking.XtextHyperlink;
import org.sculptor.dsl.sculptordsl.DslImport;
import org.sculptor.dsl.services.SculptordslGrammarAccess;

import com.google.common.collect.Lists;
import com.google.inject.Inject;
import com.google.inject.Provider;

/**
 * This extension of Xtexts default {@link HyperlinkHelper} adds support for
 * additional language features, e.g. import URIs.
 * 
 * @since 3.0.1
 */
public class SculptordslHyperlinkHelper extends HyperlinkHelper {

	@Inject
	SculptordslGrammarAccess grammarAccess;

	@Inject
	protected Provider<XtextHyperlink> hyperlinkProvider;

	@Inject
	protected ImportUriResolver uriResolver;

	@Inject
	ImportUriGlobalScopeProvider scopeProvider;

	@Override
	public void createHyperlinksByOffset(XtextResource resource, int offset, IHyperlinkAcceptor acceptor) {
		INode node = NodeModelUtils.findLeafNodeAtOffset(resource.getParseResult().getRootNode(), offset);
		if (node != null && node.getGrammarElement() instanceof RuleCall
				&& node.getSemanticElement() instanceof DslImport) {
			if (grammarAccess.getSTRINGRule().equals(((RuleCall) node.getGrammarElement()).getRule())) {
				DslImport iimport = (DslImport) node.getSemanticElement();
				String uriString = iimport.getImportURI();
				URI uri = URI.createURI(uriString);
				final URIConverter uriConverter = resource.getResourceSet().getURIConverter();
				final URI normalized = uri.isPlatformResource() ? uri : uriConverter.normalize(uri);
				final URI targetURI = scopeProvider.getResourceDescriptions(resource, Lists.newArrayList(normalized))
						.getResourceDescription(normalized).getURI();
				XtextHyperlink result = hyperlinkProvider.get();
				result.setURI(targetURI);
				Region region = new Region(node.getOffset(), node.getLength());
				result.setHyperlinkRegion(region);
				result.setHyperlinkText(uriString);
				acceptor.accept(result);
			}
		}
		super.createHyperlinksByOffset(resource, offset, acceptor);
	}

}
