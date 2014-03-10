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

import static org.mockito.Mockito.doReturn;
import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.spy;

import java.io.File;
import java.io.FileReader;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.Set;

import junit.framework.AssertionFailedError;

import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.project.MavenProject;

public class GeneratorMojoTest extends AbstractGeneratorMojoTestCase<GeneratorMojo> {

	private static final String ONE_SHOT_GENERATED_FILE = "src/main/java/com/acme/test/domain/Foo.java";
	private static final String GENERATED_FILE = "src/generated/java/com/acme/test/domain/Bar.java";

	public void testChangedFilesNoStatusFile() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test1"));

		Set<String> changedFiles = mojo.getChangedFiles();
		assertNull(changedFiles);
	}

	public void testChangedFilesNoUpdatedFiles() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));
		mojo.getStatusFile().setLastModified(System.currentTimeMillis() + 1000);

		Set<String> changedFiles = mojo.getChangedFiles();
		assertNotNull(changedFiles);
		assertEquals(0, changedFiles.size());
	}

	public void testChangedFilesOutdatedStatusFile() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));
		mojo.getStatusFile().setLastModified(0);

		Set<String> changedFiles = mojo.getChangedFiles();
		assertNotNull(changedFiles);
		assertEquals(5, changedFiles.size());
	}

	public void testChangedFilesUpdatedWorkflowDescriptor() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));
		mojo.getStatusFile().setLastModified(System.currentTimeMillis() + 1000);
		mojo.getModelFile().setLastModified(System.currentTimeMillis() + 2000);

		Set<String> changedFiles = mojo.getChangedFiles();
		assertNotNull(changedFiles);
		assertEquals(1, changedFiles.size());
	}

	public void testChangedFilesUpdatedGeneratorConfigFiles() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));
		mojo.getStatusFile().setLastModified(System.currentTimeMillis() + 1000);
		new File(mojo.getProject().getBasedir(),
				"/src/main/resources/generator/java-code-formatter.properties")
				.setLastModified(System.currentTimeMillis() + 2000);
		new File(mojo.getProject().getBasedir(),
				"/src/main/resources/generator/sculptor-generator.properties")
				.setLastModified(System.currentTimeMillis() + 2000);

		Set<String> changedFiles = mojo.getChangedFiles();
		assertNotNull(changedFiles);
		assertEquals(2, changedFiles.size());
	}

	public void testUpdateStatusFile() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));

		List<File> files = new ArrayList<File>();
		files.add(new File(mojo.getProject().getBasedir(),
				ONE_SHOT_GENERATED_FILE));
		files.add(new File(mojo.getProject().getBasedir(), GENERATED_FILE));
		assertTrue(mojo.updateStatusFile(files));

		Properties statusFileProps = new Properties();
		statusFileProps.load(new FileReader(mojo.getStatusFile()));

		assertEquals(2, statusFileProps.size());
		assertEquals("e747f800870423a6c554ae2ec80aeeb6",
				statusFileProps.getProperty(ONE_SHOT_GENERATED_FILE));
		assertEquals("7d436134142a2e69dfc98eb9f22f5907",
				statusFileProps.getProperty(GENERATED_FILE));
	}

	@SuppressWarnings("unchecked")
	public void testExecuteSkip() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test1"));
		doThrow(AssertionFailedError.class).when(mojo).executeGenerator();
		setVariableValueToObject(mojo, "skip", true);

		mojo.execute();
	}

	public void testExecuteForce() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));
		doThrow(new RuntimeException("testExecuteForce")).when(mojo).doRunGenerator();

		setVariableValueToObject(mojo, "force", true);
		try {
			mojo.execute();
		} catch (MojoExecutionException e) {
			return;
		}
		fail();
	}

	public void testExecuteWithClean() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));
		doThrow(new RuntimeException("testExecuteWithClean")).when(mojo).doRunGenerator();

		mojo.getStatusFile().setLastModified(System.currentTimeMillis() + 1000);
		mojo.getModelFile().setLastModified(System.currentTimeMillis() + 2000);

		setVariableValueToObject(mojo, "clean", true);
		try {
			mojo.execute();
		} catch (MojoExecutionException e) {
			assertFalse(new File(mojo.getProject().getBasedir(),
					ONE_SHOT_GENERATED_FILE).exists());
			assertFalse(new File(mojo.getProject().getBasedir(), GENERATED_FILE)
					.exists());
			return;
		}
		fail();
	}

	public void testExecuteWithoutClean() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));
		doThrow(new RuntimeException("testExecuteWithoutClean")).when(mojo).doRunGenerator();

		mojo.getStatusFile().setLastModified(System.currentTimeMillis() + 1000);
		mojo.getModelFile().setLastModified(System.currentTimeMillis() + 2000);

		setVariableValueToObject(mojo, "clean", false);
		try {
			mojo.execute();
		} catch (MojoExecutionException e) {
			assertTrue(new File(mojo.getProject().getBasedir(),
					ONE_SHOT_GENERATED_FILE).exists());
			assertTrue(new File(mojo.getProject().getBasedir(), GENERATED_FILE)
					.exists());
			return;
		}
		fail();
	}

	public void testExecuteWithProperties() throws Exception {
		GeneratorMojo mojo = createMojo(createProject("test2"));

		Map<String, String> properties = new HashMap<String, String>();
		properties.put("testExecuteWithProperties", "testExecuteWithProperties-value");
		setVariableValueToObject(mojo, "properties", properties);

		setVariableValueToObject(mojo, "force", true);

		mojo.execute();
		assertEquals("testExecuteWithProperties-value", System.getProperty("testExecuteWithProperties"));
	}

	/**
	 * Returns Mojo instance initialized with a {@link MavenProject} created
	 * from the test projects in <code>"src/test/projects/"</code> by given
	 * project name.
	 */
	protected GeneratorMojo createMojo(MavenProject project) throws Exception {

		// Create mojo
		GeneratorMojo mojo = spy(super.createMojo(project, "generate"));
		doReturn(Boolean.TRUE).when(mojo).doRunGenerator();

		// Set default values on mojo
		setVariableValueToObject(mojo, "model", "src/main/resources/model.btdesign");
		setVariableValueToObject(mojo, "clean", true);

		// Set defaults for multi-value parameters in mojo
		mojo.initMojoMultiValueParameters();
		return mojo;
	}
}