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

import static org.mockito.Mockito.doThrow;
import static org.mockito.Mockito.spy;

import java.io.File;
import java.util.LinkedHashSet;
import java.util.Set;

import junit.framework.AssertionFailedError;

import org.apache.commons.exec.CommandLine;
import org.apache.maven.project.MavenProject;

public class GraphvizMojoTest extends
		AbstractGeneratorMojoTestCase<GraphvizMojo> {

	private static final String GENERATED_FILE = "src/generated/resources/umlgraph-dependencies.dot";

	public void testChangedDotFilesNoStatusFile() throws Exception {
		GraphvizMojo mojo = createMojo(createProject("test1"));

		Set<String> changedDotFiles = mojo.getChangedDotFiles();
		assertNull(changedDotFiles);
	}

	public void testChangedDotFilesUpdatedImageFile() throws Exception {
		GraphvizMojo mojo = createMojo(createProject("test2"));
		File dotFile = new File(mojo.getProject().getBasedir(), GENERATED_FILE);
		dotFile.setLastModified(System.currentTimeMillis() + 1000);

		Set<String> changedDotFiles = mojo.getChangedDotFiles();
		assertNotNull(changedDotFiles);
		assertEquals(3, changedDotFiles.size());
	}

	public void testChangedDotFilesMissingImageFiles() throws Exception {
		GraphvizMojo mojo = createMojo(createProject("test2"));
		mojo.getStatusFile().setLastModified(0);

		Set<String> changedDotFiles = mojo.getChangedDotFiles();
		assertNotNull(changedDotFiles);
		assertEquals(2, changedDotFiles.size());
	}

	public void testDotCommandLine() throws Exception {
		GraphvizMojo mojo = createMojo(createProject("test1"));
		setVariableValueToObject(mojo, "verbose", false);

		Set<String> changedDotFiles = new LinkedHashSet<String>();
		changedDotFiles.add("file1.dot");
		changedDotFiles.add("file2.dot");
		changedDotFiles.add("file3.dot");

		CommandLine commandline = mojo.getDotCommandLine(changedDotFiles);
		assertNotNull(commandline);
		String[] arguments = commandline.getArguments();
		assertEquals(5, arguments.length);
		assertEquals("-Tpng", arguments[0]);
		assertEquals("-O", arguments[1]);
		assertEquals("file1.dot", arguments[2]);
		assertEquals("file2.dot", arguments[3]);
		assertEquals("file3.dot", arguments[4]);
	}

	public void testVerboseDotCommandLine() throws Exception {
		GraphvizMojo mojo = createMojo(createProject("test1"));
		setVariableValueToObject(mojo, "verbose", true);

		Set<String> changedDotFiles = new LinkedHashSet<String>();
		changedDotFiles.add("file1.dot");
		changedDotFiles.add("file2.dot");
		changedDotFiles.add("file3.dot");

		CommandLine commandline = mojo.getDotCommandLine(changedDotFiles);
		assertNotNull(commandline);
		String[] arguments = commandline.getArguments();
		assertEquals(6, arguments.length);
		assertEquals("-v", arguments[0]);
		assertEquals("-Tpng", arguments[1]);
		assertEquals("-O", arguments[2]);
		assertEquals("file1.dot", arguments[3]);
		assertEquals("file2.dot", arguments[4]);
		assertEquals("file3.dot", arguments[5]);
	}

	public void testExecuteSkip() throws Exception {
		GraphvizMojo mojo = spy(createMojo(createProject("test1")));
		doThrow(AssertionFailedError.class).when(mojo).getChangedDotFiles();
		setVariableValueToObject(mojo, "skip", true);

		mojo.execute();
	}

	/**
	 * Returns Mojo instance initialized with a {@link MavenProject} created
	 * from the test projects in <code>"src/test/projects/"</code> by given
	 * project name.
	 */
	protected GraphvizMojo createMojo(MavenProject project) throws Exception {

		// Create spied mojo
		GraphvizMojo mojo = super.createMojo(project, "generate-images");

		// Set default values on mojo
		setVariableValueToObject(mojo, "command", "dot");
		return mojo;
	}

}