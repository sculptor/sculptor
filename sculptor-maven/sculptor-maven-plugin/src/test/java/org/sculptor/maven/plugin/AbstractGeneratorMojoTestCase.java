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

import org.apache.maven.project.MavenProject;

public abstract class AbstractGeneratorMojoTestCase<T extends AbstractGeneratorMojo>
		extends AbstractBaseMojoTestCase<T> {

	public void setUp() throws Exception {
		// required for mojo lookups to work
		super.setUp();
	}

	/**
	 * Returns Mojo instance for the given goal. The Mojo instance is
	 * initialized with a {@link MavenProject} created from the test projects in
	 * <code>"src/test/projects/"</code> by given project name.
	 */
	protected T createMojo(MavenProject project, String goal) throws Exception {
		T mojo = super.createMojo(project, goal);

		// Set default values on mojo
		setVariableValueToObject(mojo, "outletSrcOnceDir",
				new File(project.getBasedir(), "src/main/java"));
		setVariableValueToObject(mojo, "outletResOnceDir",
				new File(project.getBasedir(), "src/main/resources"));
		setVariableValueToObject(mojo, "outletSrcDir",
				new File(project.getBasedir(), "src/generated/java"));
		setVariableValueToObject(mojo, "outletResDir",
				new File(project.getBasedir(), "src/generated/resources"));
		setVariableValueToObject(mojo, "outletSrcTestOnceDir",
				new File(project.getBasedir(), "src/test/java"));
		setVariableValueToObject(mojo, "outletResTestOnceDir",
				new File(project.getBasedir(), "src/test/resources"));
		setVariableValueToObject(mojo, "outletSrcTestDir",
				new File(project.getBasedir(), "src/test/generated/java"));
		setVariableValueToObject(mojo, "outletResTestDir",
				new File(project.getBasedir(), "src/test/generated/resources"));
		setVariableValueToObject(mojo, "statusFile",
				new File(project.getBasedir(), ".sculptor-status"));
		return mojo;
	}

}
