package org.sculptor.generator.mwe2;

import java.util.ArrayList;
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
import org.sculptor.dsl.sculptordsl.DslImport;
import org.sculptor.dsl.sculptordsl.DslModel;

import com.google.common.collect.Lists;

public class ImportAwareUriBaseReader extends UriBasedReader {
	private List<String> uris = Lists.newArrayList();

	public void addUri(String uri) {
		super.addUri(uri);
		this.uris.add(uri);
	}

	@Override
	protected void checkConfigurationInternal(Issues issues) {
		super.checkConfigurationInternal(issues);
		if (uris.isEmpty())
			issues.addError(this, "No resource uri configured (property 'uri')");
	}

	@Override
	protected void invokeInternal(WorkflowContext ctx, ProgressMonitor monitor, Issues issues) {
		ResourceSet resourceSet = getResourceSet();

		String mainBasePackage=null;
		List<String> newUris=uris;
		int lastResSize=-1;
		while (newUris.size() > 0 && lastResSize != resourceSet.getResources().size()) {
			List<URI> realUris = Lists.newArrayList();
			for (String uri : newUris) {
				try {
					realUris.add(URI.createURI(uri));
				} catch (Exception e) {
					issues.addError(this, "Invalid URI '" + uri + "' (" + e.getMessage() + ")");
				}
			}

			lastResSize = resourceSet.getResources().size();
			newUris = new ArrayList<String>();
			for (URI uri : realUris) {
				Resource resource = resourceSet.getResource(uri, true);
				for (EObject obj : resource.getContents()) {
					if (obj instanceof DslModel) {
						DslModel dslModel = (DslModel) obj;
						if (mainBasePackage == null) {
							mainBasePackage = dslModel.getApp().getBasePackage();
						} else {
							dslModel.getApp().setBasePackage(mainBasePackage);
						}
						for (DslImport imp : dslModel.getImports()) {
							newUris.add(imp.getImportURI());
						}
					}
				}
			}
		}
		for (Resource r : resourceSet.getResources()) {
			int numberResources;
			do {
				numberResources = resourceSet.getResources().size();
				EcoreUtil.resolveAll(r);
			} while (numberResources!=resourceSet.getResources().size());
		}

		getValidator().validate(resourceSet, getRegistry(), issues);
		addModelElementsToContext(ctx, resourceSet);
	}

}
