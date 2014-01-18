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

import org.eclipse.xtext.ui.resource.IResourceSetInitializer;
import org.sculptor.dsl.ui.resource.MavenProjectResourceSetInitializer;

import com.google.inject.Binder;
import com.google.inject.Module;

/**
 * This Guice {@link Module} is used with the extension point
 * <code>org.eclipse.xtext.ui.shared.sharedStateContributingModule</code> to
 * contribute Sculptor-related features to the Xtext UI.
 * 
 * @see MavenProjectResourceSetInitializer
 * 
 * @since 3.0.1
 */
public class SculptordslSharedContribution implements Module {

	@Override
	public void configure(Binder binder) {
		binder.bind(IResourceSetInitializer.class).to(MavenProjectResourceSetInitializer.class);
	}

}
