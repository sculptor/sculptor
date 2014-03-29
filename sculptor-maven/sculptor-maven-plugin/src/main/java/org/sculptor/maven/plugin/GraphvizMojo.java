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
import java.io.IOException;
import java.text.MessageFormat;
import java.util.HashSet;
import java.util.Set;

import org.apache.commons.exec.CommandLine;
import org.apache.commons.exec.DefaultExecutor;
import org.apache.commons.exec.ExecuteException;
import org.apache.commons.exec.Executor;
import org.apache.commons.exec.PumpStreamHandler;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;

/**
 * This plugin uses the commandline tool <a
 * href="http://www.graphviz.org/doc/info/command.html">dot</a> from the open
 * source graph visualization software <a
 * href="http://www.graphviz.org/">Graphviz</a> to generate images (PNG format)
 * for all graph files (<code>src/generated/resources/*.dot</code>) created
 * during the previous run of the Sculptor code generator.
 */
@Mojo(name = "generate-images", defaultPhase = LifecyclePhase.GENERATE_RESOURCES)
public class GraphvizMojo extends AbstractGeneratorMojo {

	/**
	 * Command to execute to generate the images. Default is <a
	 * href="http://www.graphviz.org/doc/info/command.html">dot</a>.
	 * <p>
	 * Can be set from command line using '-Dsculptor.graphviz.command=<command>'.
	 * <p>
	 * Don't include any command line arguments, e.g.image format or input
	 * files. These are handled by the mojo.
	 */
	@Parameter(property = "sculptor.graphviz.command", defaultValue = "dot")
	private String command;

	/**
	 * Skip the generation of image files.
	 * <p>
	 * Can be set from command line using '-Dsculptor.graphviz.skip=true'.
	 */
	@Parameter(property = "sculptor.graphviz.skip", defaultValue = "false")
	private boolean skip;

	/**
	 * Check if the execution should be skipped.
	 * 
	 * @return true to skip
	 */
	protected boolean isSkip() {
		return skip;
	}

	/**
	 * Strategy implementation of running the command line tool <code>dot</code>
	 * :
	 * <ol>
	 * <li>check the <code>skip</code> flag
	 * <li>get a list of modified dot files from the StatusFile
	 * <li>run the dot command
	 * </ol>
	 */
	public final void execute() throws MojoExecutionException,
			MojoFailureException {

		// If skip flag set then omit image generation
		if (isSkip()) {
			getLog().info("Skipping creation of image files");
		} else {

			// Run the dot command only if dot files have been changed
			Set<String> changedDotFiles = getChangedDotFiles();
			if (changedDotFiles != null && !changedDotFiles.isEmpty()) {
				if (!executeDot(changedDotFiles)) {
					throw new MojoExecutionException("Executing '" + command
							+ "' command failed");
				}
			}
		}
	}

	/**
	 * Returns a list with file names of dot files that have been changed since
	 * previous image generation run. Empty if no files changed or
	 * <code>null</code> if there is no status file to compare against.
	 */
	protected Set<String> getChangedDotFiles() {
		Set<String> generatedFiles = getGeneratedFiles();

		// If there is no status file to compare against or no files are
		// generated then skip image generation
		if (generatedFiles == null || generatedFiles.isEmpty()) {
			return null;
		}

		// Check if images for generated dot files are missing or outdated
		Set<String> changedDotFiles = new HashSet<String>();
		for (String generatedFile : generatedFiles) {
			if (generatedFile.endsWith(".dot")) {
				File dotFile = new File(getProject().getBasedir(),
						generatedFile);
				File imageFile = new File(getProject().getBasedir(),
						generatedFile + ".png");
				if (!imageFile.exists()
						|| imageFile.lastModified() < dotFile.lastModified()) {
					changedDotFiles.add(generatedFile);
				}
			}
		}

		// Print info of result
		if (changedDotFiles.size() == 1) {
			String fileName = changedDotFiles.iterator().next();
			if (fileName.startsWith(project.getBasedir().getAbsolutePath())) {
				fileName = fileName.substring(project.getBasedir()
						.getAbsolutePath().length() + 1);
			}
			final String message = MessageFormat.format(
					"\"{0}\" has been changed", fileName);
			getLog().info(message);
		} else if (changedDotFiles.size() > 1) {
			final String message = MessageFormat.format(
					"{0} dot files have been changed", changedDotFiles.size());
			getLog().info(message);
		} else {
			getLog().info(
					"Everything is up to date - no image generation is needed");
		}
		return changedDotFiles;
	}

	/**
	 * Executes the command line tool <code>dot</code>.
	 * 
	 * @param dotFiles
	 *            list of dot files from the
	 *            {@link AbstractGeneratorMojo#statusFile}
	 */
	protected boolean executeDot(Set<String> dotFiles)
			throws MojoExecutionException {

		// Build executor for projects base directory
		MavenLogOutputStream stdout = getStdoutStream();
		MavenLogOutputStream stderr = getStderrStream();
		Executor exec = getExecutor();
		exec.setWorkingDirectory(project.getBasedir());
		exec.setStreamHandler(new PumpStreamHandler(stdout, stderr, System.in));

		// Execute commandline and check return code
		try {
			int exitValue = exec.execute(getDotCommandLine(dotFiles));
			if (exitValue == 0 && stdout.getErrorCount() == 0) {
				return true;
			}
		} catch (ExecuteException e) {
			// ignore
		} catch (IOException e) {
			// ignore
		}
		return false;
	}

	/**
	 * Returns {@link MavenLogOutputStream} implementation for stdout.
	 * <p>
	 * Can be overriden to replace the default implementation of
	 * <code>MavenLogOutputStream(getLog())</code>.
	 */
	protected MavenLogOutputStream getStdoutStream() {
		return new MavenLogOutputStream(getLog());
	}

	/**
	 * Returns {@link MavenLogOutputStream} implementation for stderr.
	 * <p>
	 * Can be overriden to replace the default implementation of
	 * <code>MavenLogOutputStream(getLog(), true)</code>.
	 */
	protected MavenLogOutputStream getStderrStream() {
		return new MavenLogOutputStream(getLog(), true);
	}

	/**
	 * Returns {@link Executor} implementation.
	 * <p>
	 * Can be overriden to replace the default implementation of
	 * {@link DefaultExecutor}.
	 */
	protected Executor getExecutor() {
		return new DefaultExecutor();
	}

	/**
	 * Builds command line for starting the <code>dot</code>.
	 * 
	 * @param generatedFiles
	 *            list of generated files from the
	 *            {@link AbstractGeneratorMojo#statusFile}
	 */
	protected CommandLine getDotCommandLine(Set<String> generatedFiles)
			throws MojoExecutionException {
		CommandLine cl = new CommandLine(command);
		if (isVerbose()) {
			cl.addArgument("-v");
		}
		cl.addArgument("-Tpng");
		cl.addArgument("-O");
		for (String generatedFile : generatedFiles) {
			if (generatedFile.endsWith(".dot")) {
				cl.addArgument(generatedFile);
			}
		}
		if (isVerbose()) {
			getLog().info("Commandline: " + cl);
		}
		return cl;
	}

}
