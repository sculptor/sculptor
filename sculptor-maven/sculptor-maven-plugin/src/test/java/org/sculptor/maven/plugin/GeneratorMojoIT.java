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

import java.io.FileReader;
import java.util.Properties;

import org.apache.maven.project.MavenProject;

public class GeneratorMojoIT extends AbstractGeneratorMojoTestCase<GeneratorMojo> {

	public void testExecute() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test1"));
		mojo.execute();
		assertEquals(31, mojo.getGeneratedFiles().size());

		Properties statusFileProps = new Properties();
		statusFileProps.load(new FileReader(mojo.getStatusFile()));
		assertEquals(mojo.getGeneratedFiles().size(), statusFileProps.size());
	}

	/**
	 * Returns Mojo instance initialized with a {@link MavenProject} created
	 * from the test projects in <code>"src/test/projects/"</code> by given
	 * project name.
	 */
	protected GeneratorMojo createMojo(MavenProject project) throws Exception {

		// Create mojo
		GeneratorMojo mojo = super.createMojo(project, "generate");

		// Set default values on mojo
		setVariableValueToObject(mojo, "model", "src/main/resources/model.btdesign");
		setVariableValueToObject(mojo, "clean", true);

		// Set defaults for multi-value parameters in mojo
		mojo.initMojoMultiValueParameters();
		return mojo;
	}

}