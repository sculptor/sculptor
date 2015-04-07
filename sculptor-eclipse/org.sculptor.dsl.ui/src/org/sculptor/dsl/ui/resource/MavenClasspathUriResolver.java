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

import static org.eclipse.xtext.util.Strings.isEmpty;

import org.eclipse.core.resources.IContainer;
import org.eclipse.core.resources.IFile;
import org.eclipse.core.resources.IResource;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.IPath;
import org.eclipse.core.runtime.Path;
import org.eclipse.emf.common.util.URI;
import org.eclipse.jdt.core.IJavaProject;
import org.eclipse.jdt.core.IPackageFragment;
import org.eclipse.jdt.core.IPackageFragmentRoot;
import org.eclipse.jdt.core.JavaModelException;
import org.eclipse.jdt.internal.core.util.Util;
import org.eclipse.xtext.ui.util.JdtClasspathUriResolver;

/**
 * This extension of Xtexts {@link JdtClasspathUriResolver} overrides
 * {@link #findResourceInWorkspace(IJavaProject, URI)} to mitigate the <a
 * href="http://www.eclipse.org/m2e/">M2E Maven Integration Eclipse plugin</a>
 * behaviour of <a href=
 * "http://wiki.eclipse.org/M2E_FAQ#Why_resource_folders_in_Java_project_have_excluded.3D.22.2A.22"
 * >excluding the resource folders from JDT classpath by adding the exclusion
 * pattern "**"</a>. This method doesn't use {@link IPackageFragment#exists()}
 * but checks "manually" if the {@link IPackageFragment} contains source files
 * and its underlying {@link IResource} is accessible and it is excluded from
 * its root's classpath.
 * 
 * @see MavenProjectResourceSetInitializer
 * 
 * @since 3.0.1
 */
@SuppressWarnings("restriction")
public class MavenClasspathUriResolver extends JdtClasspathUriResolver {

	/**
	 * Before forwarding to
	 * {@link JdtClasspathUriResolver#findResourceInWorkspace(IJavaProject, URI)}
	 * this methods uses {@link #isMavenResourceDirectory(IPackageFragment)} to
	 * check if the given classpath URI references a resource in an excluded
	 * Maven resource directory.
	 */
	@Override
	protected URI findResourceInWorkspace(IJavaProject javaProject, URI classpathUri) throws CoreException {
		if (javaProject.exists()) {
			String packagePath = classpathUri.trimSegments(1).path();
			String fileName = classpathUri.lastSegment();
			IPath filePath = new Path(fileName);
			String packageName = isEmpty(packagePath) ? "" : packagePath.substring(1).replace('/', '.');
			for (IPackageFragmentRoot packageFragmentRoot : javaProject.getAllPackageFragmentRoots()) {
				IPackageFragment packageFragment = packageFragmentRoot.getPackageFragment(packageName);
				if (isMavenResourceDirectory(packageFragment)) {
					IResource packageFragmentResource = packageFragment.getResource();
					if (packageFragmentResource instanceof IContainer) {
						IFile file = ((IContainer) packageFragmentResource).getFile(filePath);
						if (file.exists()) {
							return createPlatformResourceURI(file);
						}
					}
				}
			}
		}
		return super.findResourceInWorkspace(javaProject, classpathUri);
	}

	/**
	 * Returns <code>true</code> if the given {@link IPackageFragment} contains
	 * source files, its underlying {@link IResource} is accessible and it is
	 * excluded from its root's classpath.
	 */
	protected boolean isMavenResourceDirectory(IPackageFragment packageFragment) throws JavaModelException {
		if (packageFragment.getKind() == IPackageFragmentRoot.K_SOURCE) {
			// check whether this pkg can be opened
			try {
				IResource underlyingResource = packageFragment
						.getUnderlyingResource();
				if (underlyingResource != null
						&& underlyingResource.isAccessible()) {
					return Util.isExcluded(packageFragment);
				}
			} catch (JavaModelException e) {
				// resource not available
			}
		}
		return false;
	}

}
