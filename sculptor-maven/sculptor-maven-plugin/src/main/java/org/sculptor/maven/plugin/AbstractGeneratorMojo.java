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
	@Parameter(defaultValue = "src/main/java", required = true)
	protected File outletSrcOnceDir;

	/**
	 * Directory for non-source-code artifacts. If an artifact with the same
	 * name already exists, the generation of the artifact will be skipped.
	 */
	@Parameter(defaultValue = "src/main/resources", required = true)
	protected File outletResOnceDir;

	/**
	 * Directory for source-code artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue = "src/generated/java", required = true)
	protected File outletSrcDir;

	/**
	 * Directory for non-source-code artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue = "src/generated/resources", required = true)
	protected File outletResDir;

	/**
	 * Directory for Webapp artifacts. If an artifact with the same name already
	 * exists, the generation of the artifact will be skipped.
	 */
	@Parameter(defaultValue = "src/main/webapp", required = true)
	protected File outletWebrootDir;

	/**
	 * Directory for test source-code artifacts. If an artifact with the same
	 * name already exists, the generation of the artifact will be skipped.
	 */
	@Parameter(defaultValue = "src/test/java", required = true)
	protected File outletSrcTestOnceDir;

	/**
	 * Directory for test non-source-code artifacts. Existings artifacts will
	 * not be overwritten.
	 */
	@Parameter(defaultValue = "src/test/resources", required = true)
	protected File outletResTestOnceDir;

	/**
	 * Directory for source-code test-artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue = "src/test/generated/java", required = true)
	protected File outletSrcTestDir;

	/**
	 * Directory for non-source-code test-artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue = "src/test/generated/resources", required = true)
	protected File outletResTestDir;

	/**
	 * Directory for documentation artifacts. Existings artifacts will be
	 * overwritten.
	 */
	@Parameter(defaultValue = "src/site", required = true)
	protected File outletDocDir;

	/**
	 * File holding the status of the last code generator execution.
	 */
	@Parameter(defaultValue = ".sculptor-status", required = true)
	protected File statusFile;

	/**
	 * Verbose logging.
	 * <p>
	 * Can be set from command line using '-Dverbose=true'.
	 */
	@Parameter(property = "verbose", defaultValue = "false")
	private boolean verbose;

	/**
	 * Returns enclosing {@link MavenProject}.
	 */
	protected MavenProject getProject() {
		return project;
	}

	/**
	 * Check if the logging should be verbose.
	 * <p>
	 * If Maven debug logging is requested "mvn -X" the verbose logging is active
	 * as well.
	 * 
	 * @return true to verbose logging
	 */
	protected boolean isVerbose() {
		return verbose || getLog().isDebugEnabled();
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
	 * Deletes the files in the directories marked as 'generated' and the
	 * unmodified one-shot generated files.
	 * <p>
	 * The list of all previously generated files is retrieved from the StatusFile
	 * (defined via {@link #statusFile}). Modified one-shot generated files are
	 * detected by a changed file checksum.
	 */
	protected boolean deleteGeneratedFiles() {
		boolean success;
		
		// First delete all files in the directories marked as 'generated'
		cleanDirectory(outletSrcDir);
		cleanDirectory(outletResDir);
		cleanDirectory(outletSrcTestDir);
		cleanDirectory(outletResTestDir);

		// Finally delete the non-modified one-shot generated files in the other folders
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
										.startsWith(getProjectRelativePath(outletWebrootDir))
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
							delete = false;
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
	 * Deletes all files within the given directory.
	 */
	private void cleanDirectory(File dir) {
		if (isVerbose() || getLog().isDebugEnabled()) {
			getLog().info("Deleting previously generated files in directory: " + dir.getPath());
		}
		if (dir.exists()) {
			try {
				FileUtils.cleanDirectory(dir);
			} catch (IOException e) {
				getLog().warn("Cleaning directory failed: " + e.getMessage());
			}
		}
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
