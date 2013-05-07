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

import java.io.File;

import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.testing.AbstractMojoTestCase;
import org.apache.maven.project.MavenProject;
import org.codehaus.plexus.util.FileUtils;

public abstract class AbstractBaseMojoTestCase<T extends AbstractMojo>
		extends AbstractMojoTestCase {

	public static final String TEST_PROJECT_FOLDER = "src/test/projects/";

	public void setUp() throws Exception {
		// required for mojo lookups to work
		super.setUp();
	}

	/**
	 * Returns a {@link MavenProject} created from the test projects in
	 * <code>"src/test/projects/"</code> by given project name.
	 */
	protected MavenProject createProject(String name) throws Exception {

		// Copy test project
		File srcProject = new File(getBasedir(), TEST_PROJECT_FOLDER + name);
		File targetProject = new File(getBasedir(), "target/test-projects/"
				+ name);

		FileUtils.deleteDirectory(targetProject);
		FileUtils.copyDirectoryStructure(srcProject, targetProject);

		// Create Maven project from POM
		return new MojoProjectStub(targetProject);
	}

	/**
	 * Returns Mojo instance for the given goal. The Mojo instance is
	 * initialized with a {@link MavenProject} created from the test projects in
	 * <code>"src/test/projects/"</code> by given project name.
	 */
	protected T createMojo(MavenProject project, String goal) throws Exception {

		// Create mojo
		@SuppressWarnings("unchecked")
		T mojo = (T) lookupMojo(goal, project.getFile());
		assertNotNull(mojo);

		// Set Maven project
		setVariableValueToObject(mojo, "project", project);
		return mojo;
	}

}