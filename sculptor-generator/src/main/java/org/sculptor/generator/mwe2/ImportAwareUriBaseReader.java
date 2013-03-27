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

package org.sculptor.generator.mwe2;

import java.util.List;

import org.eclipse.emf.common.util.URI;
import org.eclipse.emf.ecore.EObject;
import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.emf.ecore.util.EcoreUtil;
import org.eclipse.emf.mwe.core.WorkflowContext;
import org.eclipse.emf.mwe.core.issues.Issues;
import org.eclipse.emf.mwe.core.monitor.ProgressMonitor;
import org.eclipse.xtext.mwe.UriBasedReader;
import org.sculptor.dsl.sculptordsl.DslApplication;
import org.sculptor.dsl.sculptordsl.DslImport;
import org.sculptor.dsl.sculptordsl.DslModel;
import org.sculptor.generator.SculptorRunner;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.google.common.collect.Lists;

public class ImportAwareUriBaseReader extends UriBasedReader {

	private static final Logger LOGGER = LoggerFactory.getLogger(SculptorRunner.class);

	private final List<String> uris = Lists.newArrayList();

	@Override
	public void addUri(String uri) {
		super.addUri(uri);
		this.uris.add(uri);
	}

	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor monitor, Issues issues) {
		ResourceSet resourceSet = getResourceSet();

		// Read all the models from given URIs and check for imports 
		List<String> newUris = this.uris;
		int numberResources;
		do {

			// Remember the current number of resources in the resource set 
			numberResources = resourceSet.getResources().size();

			// Convert given text into URIs
			List<URI> realUris = Lists.newArrayList();
			for (String uri : newUris) {
				try {
					realUris.add(URI.createURI(uri));
				} catch (Exception e) {
					issues.addError(this, "Invalid URI '" + uri + "' (" + e.getMessage() + ")");
				}
			}

			// Check the exising URIs for new URIs from imports
			newUris = Lists.newArrayList();
			for (URI uri : realUris) {
				Resource resource = resourceSet.getResource(uri, true);
				for (EObject obj : resource.getContents()) {
					if (obj instanceof DslModel) {
						DslModel dslModel = (DslModel) obj;
						for (DslImport imp : dslModel.getImports()) {
							DslApplication app = dslModel.getApp();
							LOGGER.debug("Application"
									+ (app.getBasePackage() != null && !app.getBasePackage().isEmpty() ? "" : "Part")
									+ " '{}' imports resource URI '{}'", app.getName(), imp.getImportURI());
							newUris.add(imp.getImportURI());
						}
					}
				}
			}
		} while (!newUris.isEmpty() && numberResources != resourceSet.getResources().size());

		// Resolve all resources in the resource set
		for (Resource r : resourceSet.getResources()) {
			do {
				numberResources = resourceSet.getResources().size();
				EcoreUtil.resolveAll(r);
			} while (numberResources != resourceSet.getResources().size());
		}

		// Validate all resources in the resource set
		getValidator().validate(resourceSet, getRegistry(), issues);
		addModelElementsToContext(ctx, resourceSet);
	}

}
