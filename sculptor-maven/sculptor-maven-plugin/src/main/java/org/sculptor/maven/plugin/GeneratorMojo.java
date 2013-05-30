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
import java.io.PrintStream;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLClassLoader;
import java.text.MessageFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Date;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.maven.execution.MavenSession;
import org.apache.maven.model.FileSet;
import org.apache.maven.model.Resource;
import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugins.annotations.Component;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.apache.maven.project.MavenProject;
import org.codehaus.plexus.util.FileUtils;
import org.sculptor.generator.SculptorGeneratorRunner;
import org.sonatype.plexus.build.incremental.BuildContext;

/**
 * This plugin starts the Sculptor code generator by launching an Eclipse MWE2
 * workflow.
 * <p>
 * You can configure resources that should be checked if they are up to date to
 * avoid needless generator runs and optimize build execution time.
 */
@Mojo(name = "generate", defaultPhase = LifecyclePhase.GENERATE_SOURCES)
public class GeneratorMojo extends AbstractGeneratorMojo {

	protected static final String LOGBACK_CONFIGURATION_FILE_PROPERTY = "logback.configurationFile";

	protected static final String MWE2_WORKFLOW_LAUNCHER = "org.eclipse.emf.mwe2.launch.runtime.Mwe2Launcher";

	protected static final String LOGBACK_NORMAL_CONFIGURATION_FILE_NAME = "logback-normal-sculptor-maven-plugin.xml";
	protected static final String LOGBACK_VERBOSE_CONFIGURATION_FILE_NAME = "logback-verbose-sculptor-maven-plugin.xml";

	protected static final String OUTPUT_SLOT_PATH_PREFIX = "outputSlot.path.";

	/**
	 * The current build session instance. This is used for toolchain manager
	 * API calls.
	 */
	@Component
	private MavenSession session;

	/**
	 * Eclipse M2E integration.
	 */
	@Component
	private BuildContext buildContext;

	/**
	 * Relative path of model file.
	 */
	@Parameter(defaultValue = "src/main/resources/model.btdesign", required = true)
	private String model;

	/**
	 * A <code>java.util.List</code> of {@link FileSet}s that will be checked on
	 * up to date. If all resources are up to date the plugin stops the
	 * execution, because there are no files to regenerate. <br/>
	 * The entries of this list can be relative path to the project root or
	 * absolute path.
	 * <p>
	 * If not specified then a fileset with the default value of
	 * <code>"src/main/resources/*.btdesign"</code> is used.
	 */
	@Parameter
	private FileSet[] checkFileSets;

	/**
	 * Skip the execution.
	 * <p>
	 * Can be set from command line using '-Dsculptor.generator.skip=true'.
	 */
	@Parameter(property = "sculptor.generator.skip", defaultValue = "false")
	private boolean skip;

	/**
	 * Don't try to detect if Sculptor code generation is up-to-date and can be
	 * skipped.
	 * <p>
	 * Can be set from command line using '-Dsculptor.generator.force=true'.
	 */
	@Parameter(property = "sculptor.generator.force", defaultValue = "false")
	private boolean force;

	/**
	 * Delete all previously generated files before starting code generation.
	 * <p>
	 * Can be set from command line using '-Dsculptor.generator.clean=false'.
	 */
	@Parameter(property = "sculptor.generator.clean", defaultValue = "true")
	private boolean clean;

	/**
	 * Properties used to define system properties (like
	 * <code>"sculptor.generatorPropertiesLocation"</code>) or to overrride the
	 * settings rettrieved from
	 * <code>"default-sculptor-generator.properties"</code>.
	 * <p>
	 * <b>Sample:</b>
	 * 
	 * <pre>
	 * &lt;properties&gt;
	 *   &lt;sculptor.generatorPropertiesLocation&gt;${basedir}/src/sculptor/generator.properties&lt;sculptor.generatorPropertiesLocation&gt;
	 * &lt;/properties&gt;
	 * </pre>
	 */
	@Parameter
	private Map<String, String> properties;

	/**
	 * Returns <code>model</code> file.
	 */
	protected File getModelFile() {
		return new File(project.getBasedir(), model);
	}

	/**
	 * Check if the execution should be skipped.
	 * 
	 * @return true to skip
	 */
	protected boolean isSkip() {
		return skip;
	}

	/**
	 * Check if the execution should be forced.
	 * 
	 * @return true to force
	 */
	protected boolean isForce() {
		return force;
	}

	/**
	 * Check if the previously generated files should be deleted before starting
	 * the code generator.
	 * 
	 * @return true to delete
	 */
	protected boolean isClean() {
		return clean;
	}

	/**
	 * Strategy implementation of running the code generator:
	 * <ol>
	 * <li>check the <code>skip</code> flag
	 * <li>check the specified <code>workflowDescriptor</code> file
	 * <li>get a list of modified files from <code>checkFileSets</code>
	 * <li>run the code generator
	 * <li>update the <code>statusFile</code>
	 * <li>extend the compile roots and resources of the enclosing Maven project
	 * with the output directories of the code generator
	 * </ol>
	 */
	public final void execute() throws MojoExecutionException {

		// Initialize missing Mojo parameters
		initMojoMultiValueParameters();

		// If skip flag set then omit code generator execution
		if (isSkip()) {
			getLog().info("Skipping code generator execution");
			return;
		}

		// Check model file
		File modelFile = getModelFile();
		if (!modelFile.exists() || !modelFile.isFile()) {
			throw new MojoExecutionException("Model file '" + model + "' specified in <model/> does not exists");
		}

		// If not forced flag set the check for modified source files
		Set<String> changedFiles;
		if (isForce()) {
			getLog().info("Forced code generator execution");
			changedFiles = null;
		} else {
			changedFiles = getChangedFiles();
		}

		// Code generator is only executed if force flag is set or source files
		// are modified
		if (changedFiles == null || !changedFiles.isEmpty()) {

			// If clean flag set then delete the previously generated files
			if (isClean()) {
				deleteGeneratedFiles();
			} else {
				getLog().info("Automatic cleanup disabled - keeping " + "previously generated files");
			}

			// Execute Sculptor code generator and update status file
			List<File> createdFiles = executeGenerator(changedFiles);
			if (createdFiles != null) {
				updateStatusFile(createdFiles);

				// Refresh Eclipse workspace
				if (createdFiles.size() > 0) {
					buildContext.refresh(outletSrcOnceDir);
					buildContext.refresh(outletResOnceDir);
					buildContext.refresh(outletSrcDir);
					buildContext.refresh(outletResDir);
					buildContext.refresh(outletSrcTestOnceDir);
					buildContext.refresh(outletResTestOnceDir);
					buildContext.refresh(outletSrcTestDir);
					buildContext.refresh(outletResTestDir);
				}
			} else {
				throw new MojoExecutionException("Sculptor code generator failed");
			}
		}

		// Extend the Maven projects compile source roots and resource
		// directories with the generators directories
		extendProjectCompileRootsAndResources();
	}

	/**
	 * Initialize default values for the multi-value Mojo parameter
	 * <code>checkFileSets</code>.
	 */
	protected void initMojoMultiValueParameters() {

		// Set default values for 'checkFileSets' to
		// "src/main/resources/*.btdesign"
		if (checkFileSets == null) {
			FileSet defaultFileSet = new FileSet();
			defaultFileSet.setDirectory(project.getBasedir() + "/src/main/resources");
			defaultFileSet.addInclude("*.btdesign");
			checkFileSets = new FileSet[] { defaultFileSet };
		}
	}

	/**
	 * Extends {@link MavenProject}s compile source roots and resource
	 * directories with the directories holding the generated artifacts.
	 * <p>
	 * There's no problem to call this method multiple time. The corresponding
	 * directories are added only once.
	 */
	protected void extendProjectCompileRootsAndResources() throws MojoExecutionException {
		if (project != null) {
			try {
				extendCompileSourceRoots();
				extendResources(outletResDir, false);
				extendResources(outletResOnceDir, false);
				extendResources(outletResTestDir, true);
				extendResources(outletResTestOnceDir, true);
			} catch (Exception ex) {
				throw new MojoExecutionException("Could not extend the " + "projects compile paths", ex);
			}
		}
	}

	/**
	 * Extends {@link MavenProject}s <code>CompileSourceRoots</code> and
	 * <code>TestCompileSourceRoots</code> with the directories holding the
	 * generated source code artifacts.
	 * <p>
	 * There's no problem in adding the same directory multiple times because
	 * this is handled by {@link MavenProject}.
	 */
	private void extendCompileSourceRoots() {

		// Add source artifacts
		if (isVerbose() || getLog().isDebugEnabled()) {
			getLog().info("Adding compile source directory '" + outletSrcDir + "'");
		}
		project.addCompileSourceRoot(outletSrcDir.getAbsolutePath());
		if (isVerbose() || getLog().isDebugEnabled()) {
			getLog().info("Adding compile source directory '" + outletSrcOnceDir + "'");
		}
		project.addCompileSourceRoot(outletSrcOnceDir.getAbsolutePath());

		// Add test source artifacts
		if (isVerbose() || getLog().isDebugEnabled()) {
			getLog().info("Adding test compile source directory '" + outletSrcTestDir + "'");
		}
		project.addTestCompileSourceRoot(outletSrcTestDir.getAbsolutePath());
		if (isVerbose() || getLog().isDebugEnabled()) {
			getLog().info("Adding test compile source directory '" + outletSrcTestOnceDir + "'");
		}
		project.addTestCompileSourceRoot(outletSrcTestOnceDir.getAbsolutePath());
	}

	/**
	 * Extends {@link MavenProject}s <code>Resources</code> and
	 * <code>TestResources</code> (depending on <code>isTest</code>) with the
	 * directories holding the generated resource artifacts.
	 * <p>
	 * There's no problem in adding the same directory multiple times.
	 * 
	 * @param resourceDir
	 *            resource directory to be added
	 * @param isTest
	 *            if <code>true</code> then then given directory is added to the
	 *            test resources otherwise it's added to the source resources
	 */
	private void extendResources(File resourceDir, boolean isTest) {
		List<Resource> resources = (isTest ? project.getTestResources() : project.getResources());

		// Check if resource directory is already added
		for (Resource resource : resources) {
			if (resource.getDirectory().equalsIgnoreCase(resourceDir.getAbsolutePath())) {
				return;
			}
		}

		// Add new resource to list of resources
		if (isVerbose() || getLog().isDebugEnabled()) {
			getLog().info("Adding resource directory '" + resourceDir + "'");
		}
		Resource resource = new Resource();
		resource.setDirectory(resourceDir.getAbsolutePath());
		resources.add(resource);
	}

	/**
	 * Returns a list with file names from the <code>checkFileSets</code>
	 * parameter that have been modified since previous generator run. Empty if
	 * no files changed or <code>null</code> if there is no status file to
	 * compare against, i.e. always run the generator.
	 */
	protected Set<String> getChangedFiles() {

		// If there is no status file to compare against then always run the
		// generator
		if (!statusFile.exists()) {
			return null;
		}
		final long statusFileLastModified = statusFile.lastModified();
		final SimpleDateFormat df = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		if (isVerbose() || getLog().isDebugEnabled()) {
			getLog().info("Last code generator execution: " + df.format(new Date(statusFileLastModified)));
		}

		// Create list of files to check - start with project pom.xml and
		// generator config files
		List<File> filesToCheck = new ArrayList<File>();
		filesToCheck.add(new File(project.getBasedir(), "pom.xml"));

		// Now add generator config files
		FileSet generatorFileSet = new FileSet();
		generatorFileSet.setDirectory(project.getBasedir() + "/src/main/resources/generator");
		generatorFileSet.addInclude("*");
		filesToCheck.addAll(toFileList(generatorFileSet));

		// Finally add files from configured filesets in 'checkFileSets'
		for (FileSet fs : checkFileSets) {
			filesToCheck.addAll(toFileList(fs));
		}

		// Check files for modification
		Set<String> changedFiles = new HashSet<String>();
		for (File checkFile : filesToCheck) {
			if (!checkFile.isAbsolute()) {
				checkFile = new File(project.getBasedir(), checkFile.getPath());
			}
			final boolean isModified = checkFile.lastModified() > statusFileLastModified;
			if (isModified) {
				changedFiles.add(checkFile.getAbsolutePath());
			}
			if (isVerbose() || getLog().isDebugEnabled()) {
				getLog().info(
						"File '" + checkFile.getAbsolutePath() + "': " + (isModified ? "outdated" : "up-to-date")
								+ " (" + " " + df.format(new Date(checkFile.lastModified())) + ")");
			}
		}

		// Print info of result
		if (changedFiles.size() == 1) {
			String fileName = changedFiles.iterator().next();
			if (fileName.startsWith(project.getBasedir().getAbsolutePath())) {
				fileName = fileName.substring(project.getBasedir().getAbsolutePath().length() + 1);
			}
			final String message = MessageFormat.format("\"{0}\" has been modified since last generator "
					+ "run at {1}", fileName, df.format(new Date(statusFileLastModified)));
			getLog().info(message);
		} else if (changedFiles.size() > 1) {
			final String message = MessageFormat.format("{0} checked resources have been modified since "
					+ "last generator run at {1}", changedFiles.size(), df.format(new Date(statusFileLastModified)));
			getLog().info(message);
		} else {
			getLog().info("Everything is up to date - no generator run is needed");
		}
		return changedFiles;
	}

	/**
	 * Executes the commandline running the Eclipse MWE2 launcher and returns
	 * the commandlines exit value.
	 * 
	 * @param changedFiles
	 *            list of files from <code>checkFileSets</code> which are
	 *            modified since last generator execution or <code>null</code>
	 *            if code generation is enforced
	 */
	protected List<File> executeGenerator(Set<String> changedFiles) throws MojoExecutionException {
		List<File> createdFiles = null;

		// Add resources and output directory to plugins classpath
		List<Object> classpathEntries = new ArrayList<Object>();
		classpathEntries.addAll(project.getResources());
		classpathEntries.add(project.getBuild().getOutputDirectory());
		extendPluginClasspath(classpathEntries);

		// Redirect system.out and system.err
		PrintStream oldSystemOut = System.out;
		ScanningOutputStream stdout = new ScanningOutputStream(oldSystemOut, isVerbose() || getLog().isDebugEnabled());
		System.setOut(new PrintStream(stdout));
		PrintStream oldSystemErr = System.err;
		ScanningOutputStream stderr = new ScanningOutputStream(oldSystemErr, isVerbose() || getLog().isDebugEnabled(),
				true);
		System.setErr(new PrintStream(stderr));

		// Prepare logback configuration
		String logbackConfig = (isVerbose() ? LOGBACK_VERBOSE_CONFIGURATION_FILE_NAME
				: LOGBACK_NORMAL_CONFIGURATION_FILE_NAME);
		System.setProperty(LOGBACK_CONFIGURATION_FILE_PROPERTY, logbackConfig);

		// Set system properties defined properties in the plugins
		if (properties != null) {
			for (String key : properties.keySet()) {
				System.setProperty(key, properties.get(key));
			}
		}

		// Set system properties with output slot paths
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_SRC", outletSrcOnceDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_RESOURCES", outletResOnceDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_GEN_SRC", outletSrcDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_GEN_RESOURCES", outletResDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_WEBROOT", outletWebrootDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_SRC_TEST", outletSrcTestOnceDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_RESOURCES_TEST", outletResTestOnceDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_GEN_SRC_TEST", outletSrcTestDir.toString());
		System.setProperty(OUTPUT_SLOT_PATH_PREFIX + "TO_GEN_RESOURCES_TEST", outletResTestDir.toString());

		// Execute commandline and check return code
		Exception exception = null;
		try {
			doRunGenerator();
		} catch (Exception e) {
			exception = e;
		} finally {
			// Restore original system.out and system.err
			System.setOut(oldSystemOut);
			System.setErr(oldSystemErr);
		}

		// Check exception and output streams for errors
		if (exception != null) {
			getLog().error("Executing generator workflow failed", exception);
		} else if (stdout.getErrorCount() == 0 && stderr.getLineCount() == 0) {

			// Return list of created files
			createdFiles = stdout.getCreatedFiles();
			getLog().info("Generated " + createdFiles.size() + " files");
		}
		return createdFiles;
	}

	protected void doRunGenerator() {
		SculptorGeneratorRunner.run(getModelFile().toString());
	}

	public void extendPluginClasspath(List<Object> classpathEntries) throws MojoExecutionException {
		Set<URL> urls = new HashSet<URL>();
		for (Object classpathEntry : classpathEntries) {
			if (classpathEntry instanceof Resource) {
				File resourceFile = new File(((Resource) classpathEntry).getDirectory());
				if (resourceFile.exists()) {
					getLog().debug("Adding resource to plugin classpath: " + resourceFile.getPath());
					try {
						urls.add(resourceFile.toURI().toURL());
					} catch (MalformedURLException e) {
						throw new MojoExecutionException(e.getMessage(), e);
					}
				}
			} else if (classpathEntry instanceof String) {
				File path = new File((String) classpathEntry);
				if (path.exists()) {
					getLog().debug("Adding path to plugin classpath: " + path.getPath());
					try {
						urls.add(path.toURI().toURL());
					} catch (MalformedURLException e) {
						throw new MojoExecutionException(e.getMessage(), e);
					}
				}
			} else {
				throw new IllegalArgumentException("Unsupported classpathentry: " + classpathEntry);
			}
		}
		ClassLoader classLoader = URLClassLoader.newInstance(urls.toArray(new URL[0]), Thread.currentThread()
				.getContextClassLoader());
		Thread.currentThread().setContextClassLoader(classLoader);
	}

	@SuppressWarnings("unchecked")
	private List<File> toFileList(FileSet fileSet) {
		File directory = new File(fileSet.getDirectory());
		String includes = toCommaSeparatedString(fileSet.getIncludes());
		String excludes = toCommaSeparatedString(fileSet.getExcludes());
		try {
			return FileUtils.getFiles(directory, includes, excludes);
		} catch (IllegalStateException e) {
			getLog().warn(e.getMessage() + ". Ignoring fileset.");
		} catch (IOException e) {
			getLog().warn(e);
		}
		return Collections.emptyList();
	}

	private String toCommaSeparatedString(Collection<String> strings) {
		StringBuilder sb = new StringBuilder();
		for (String string : strings) {
			if (sb.length() > 0) {
				sb.append(",");
			}
			sb.append(string);
		}
		return sb.toString();
	}

}
