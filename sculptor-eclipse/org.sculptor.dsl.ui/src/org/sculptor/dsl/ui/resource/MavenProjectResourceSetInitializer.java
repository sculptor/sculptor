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

package org.sculptor.dsl.ui.resource;

import org.eclipse.core.resources.IProject;
import org.eclipse.emf.ecore.resource.ResourceSet;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.JavaCore;
import org.eclipse.xtext.resource.XtextResourceSet;
import org.eclipse.xtext.ui.resource.IResourceSetInitializer;
import org.eclipse.xtext.ui.util.JdtClasspathUriResolver;
import org.sculptor.dsl.ui.SculptordslSharedContribution;

/**
 * This implementation of {@link IResourceSetInitializer} replaces Xtexts own
 * {@link JdtClasspathUriResolver} with Sculptors
 * {@link MavenClasspathUriResolver} in Xtexts internally used
 * {@link XtextResourceSet}.
 * <p>
 * This class is integrated by {@link SculptordslSharedContribution} into the
 * Xtext UI.
 * 
 * @see MavenClasspathUriResolver
 * @see SculptordslSharedContribution
 * 
 * @since 3.0.1
 */
public class MavenProjectResourceSetInitializer implements IResourceSetInitializer {

	public void initialize(ResourceSet resourceSet, IProject project) {
		if (resourceSet instanceof XtextResourceSet) {
			XtextResourceSet xtextResourceSet = (XtextResourceSet) resourceSet;
			IJavaProject javaProject = JavaCore.create(project);
			if (javaProject != null && javaProject.exists()) {
				xtextResourceSet.setClasspathUriResolver(new MavenClasspathUriResolver());
			}
		}
	}

}
