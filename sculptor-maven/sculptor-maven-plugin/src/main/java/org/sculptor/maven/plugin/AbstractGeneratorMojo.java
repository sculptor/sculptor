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
import java.io.FileInputStream;
import java.io.FileReader;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStream;
import java.util.List;
import java.util.Properties;
import java.util.Set;

import org.apache.commons.codec.digest.DigestUtils;
import org.apache.maven.plugin.AbstractMojo;
import org.apache.maven.plugin.Mojo;
import org.apache.maven.plugins.annotations.Component;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.project.MavenProject;
import org.codehaus.plexus.util.FileUtils;

/**
 * Base class for all code generator-related {@link Mojo}s of this plugin. It
 * provides common properties (like the outlet directories for the code
 * generator) and shared code (like handling of the generated files).
 */
public abstract class AbstractGeneratorMojo extends AbstractMojo {

	/**
	 * The enclosing project.
	 */
	@Component
	protected MavenProject project;

	/**
	 * Directory for source-code artifacts. If an artifact with the same name
	 * already exists, the generation of the artifact will be skipped.
	 */
	@Parameter(defaultValue="src/main/java", required=true)
	protected File outletSrcOnceDir;

	/**
	 * Directory for non-source-code artifacts. If an artifact with the same
	 * name already exists, the generation of the artifact will be skipped.
	 */
	@Parameter(defaultValue="src/main/resources", required=true)
	protected File outletResOnceDir;

	/**
	 * Directory for source-code artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue="src/generated/java", required=true)
	protected File outletSrcDir;

	/**
	 * Directory for non-source-code artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue="src/generated/resources", required=true)
	protected File outletResDir;

	/**
	 * Directory for Webapp artifacts. If an artifact with the same
	 * name already exists, the generation of the artifact will be skipped.
	 */
	@Parameter(defaultValue="src/main/webapp", required=true)
	protected File outletWebrootDir;

	/**
	 * Directory for source-code artifacts. If an artifact with the same name
	 * already exists, the generation of the artifact will be skipped.
	 */
	@Parameter(defaultValue="src/test/java", required=true)
	protected File outletSrcTestOnceDir;

	/**
	 * Directory for source-code test-artifacts. Existings artifacts will not be
	 * overwritten.
	 */
	@Parameter(defaultValue="src/test/resources", required=true)
	protected File outletResTestOnceDir;

	/**
	 * Directory for source-code test-artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue="src/test/generated/java", required=true)
	protected File outletSrcTestDir;

	/**
	 * Directory for non-source-code test-artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue="src/test/generated/resources", required=true)
	protected File outletResTestDir;

	/**
	 * File holding the status of the last code generator execution.
	 */
	@Parameter(defaultValue=".sculptor-status", required=true)
	protected File statusFile;

	/**
	 * Verbose logging.
	 * <p>
	 * Can be set from command line using '-Dverbose=true'.
	 */
	@Parameter(property="verbose", defaultValue="false")
	private boolean verbose;

	/**
	 * Returns enclosing {@link MavenProject}.
	 */
	protected MavenProject getProject() {
		return project;
	}

	/**
	 * Check if the logging should be verbose.
	 * 
	 * @return true to verbose logging
	 */
	protected boolean isVerbose() {
		return verbose;
	}

	/**
	 * Returns the StatusFile (defined via {@link #statusFile}) or
	 * <code>null</code> if none exists.
	 */
	protected File getStatusFile() {
		return (statusFile.exists() ? statusFile : null);
	}

	/**
	 * Updates the StatusFile (defined via {@link #statusFile}). This file
	 * indicates the last successful execution of the code generator and is used
	 * to check the state of the source files.
	 * 
	 * @param createdFiles
	 *            list of files created by the code generator
	 */
	protected boolean updateStatusFile(List<File> createdFiles) {
		boolean success;
		Properties statusProperties = new Properties();
		try {
			for (File createdFile : createdFiles) {
				try {
					statusProperties.setProperty(
							getProjectRelativePath(createdFile),
							calculateChecksum(createdFile));
				} catch (IOException e) {
					getLog().warn(
							"Checksum calculation failed: " + e.getMessage());
				}
			}
			statusProperties.store(new FileWriter(statusFile),
					"Sculptor created the following " + createdFiles.size()
							+ " files");
			success = true;
		} catch (IOException e) {
			getLog().warn("Updating status file failed: " + e.getMessage());
			success = false;
		}
		return success;
	}

	/**
	 * Returns the list of generated files from the StatusFile (defined via
	 * {@link #statusFile}) or <code>null</code> if no StatusFile exists.
	 */
	protected Set<String> getGeneratedFiles() {
		File statusFile = getStatusFile();
		if (statusFile != null) {
			try {
				// Read status file and return the list of generated files
				Properties statusFileProps = new Properties();
				statusFileProps.load(new FileReader(statusFile));
				return statusFileProps.stringPropertyNames();
			} catch (IOException e) {
				getLog().warn("Reading status file failed: " + e.getMessage());
			}
		}
		return null;
	}

	/**
	 * Reads the list of generated files from the StatusFile (defined via
	 * {@link #statusFile}) and deletes all but the modified one-shot generated
	 * files (different file checksum).
	 */
	protected boolean deleteGeneratedFiles() {
		boolean success;
		File statusFile = getStatusFile();
		if (statusFile == null) {

			// No status file - we can't delete any previously generated files
			success = true;
		} else {
			try {
				// Read status file and iterate through the list of generated
				// files
				Properties statusFileProps = new Properties();
				statusFileProps.load(new FileReader(statusFile));
				for (String fileName : statusFileProps.stringPropertyNames()) {
					File file = new File(getProject().getBasedir(), fileName);
					if (file.exists()) {

						// For one-shot generated files compare checksum before
						// deleting
						boolean delete;
						if (fileName
								.startsWith(getProjectRelativePath(outletSrcOnceDir))
								|| fileName
										.startsWith(getProjectRelativePath(outletResOnceDir))
								|| fileName
										.startsWith(getProjectRelativePath(outletSrcTestOnceDir))
								|| fileName
										.startsWith(getProjectRelativePath(outletResTestOnceDir))) {
							delete = calculateChecksum(file).equals(
									statusFileProps.getProperty(fileName));
							if (!delete
									&& (isVerbose() || getLog()
											.isDebugEnabled())) {
								getLog().info(
										"Keeping previously generated modified"
												+ " file: " + file);
							}
						} else {
							delete = true;
						}
						if (delete) {
							if (isVerbose() || getLog().isDebugEnabled()) {
								getLog().info(
										"Deleting previously generated file: "
												+ file);
							}
							// We have to make sure the file is deleted on
							// Windows as well
							FileUtils.forceDelete(file);

							// Delete image file generated from dot file
							if (fileName.endsWith(".dot")) {
								File imageFile = new File(getProject()
										.getBasedir(), fileName + ".png");
								if (imageFile.exists()) {
									if (isVerbose()
											|| getLog().isDebugEnabled()) {
										getLog().info(
												"Deleting previously generated file: "
														+ imageFile);
									}
									// We have to make sure the file is deleted
									// on Windows as well
									FileUtils.forceDelete(imageFile);
								}
							}
						}
					}
				}
				success = true;
			} catch (IOException e) {
				getLog().warn("Reading status file failed: " + e.getMessage());
				success = false;
			}
		}
		return success;
	}

	/**
	 * Returns the path of given file relative to the enclosing Maven project.
	 */
	protected String getProjectRelativePath(File file) {
		String path = file.getAbsolutePath();
		String prefix = project.getBasedir().getAbsolutePath();
		if (path.startsWith(prefix)) {
			path = path.substring(prefix.length() + 1);
		}
		if (File.separatorChar != '/') {
			path = path.replace(File.separatorChar, '/');
		}
		return path;
	}

	/**
	 * Returns a hex representation of the MD5 checksum from given file.
	 */
	private String calculateChecksum(File file) throws IOException {
		InputStream is = new FileInputStream(file);
		return DigestUtils.md5Hex(is);
	}

}
