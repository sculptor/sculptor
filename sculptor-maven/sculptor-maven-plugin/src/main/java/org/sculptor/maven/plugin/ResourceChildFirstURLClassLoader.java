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

package org.sculptor.maven.plugin;

import java.net.URL;
import java.net.URLClassLoader;
import java.util.Set;

/**
 * This {@link URLClassLoader} alters regular class loader delegation and will
 * check the URLs used in its initialization for matching resoures before
 * delegating to its parent.
 */
public class ResourceChildFirstURLClassLoader extends URLClassLoader {

	public ResourceChildFirstURLClassLoader(Set<URL> urls, ClassLoader parentClassLoader) {
		super(urls.toArray(new URL[0]), parentClassLoader);
	}

	@Override
	public URL getResource(final String name) {
		URL resource = findResource(name);
		if (resource == null) {
			ClassLoader parent = getParent();
			if (parent != null) {
				resource = parent.getResource(name);
			}
		}
		return resource;
	}

}
