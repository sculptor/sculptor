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

import java.io.IOException;

import org.apache.maven.plugin.MojoExecutionException;
import org.apache.maven.plugin.MojoFailureException;
import org.apache.maven.plugins.annotations.LifecyclePhase;
import org.apache.maven.plugins.annotations.Mojo;
import org.apache.maven.plugins.annotations.Parameter;
import org.codehaus.plexus.util.FileUtils;

/**
 * This plugin deletes all files created by a previous run of the Sculptor code
 * generator. The {@link AbstractGeneratorMojo#statusFile} is deleted as well.
 */
@Mojo(name = "clean", defaultPhase = LifecyclePhase.CLEAN)
public class CleanMojo extends AbstractGeneratorMojo {

	/**
	 * Skip the clean-up of previously generated files.
	 * <p>
	 * Can be set from command line using '-Dsculptor.clean.skip=true'.
	 */
	@Parameter(property="sculptor.clean.skip", defaultValue="false")
	private boolean skip;

	/**
	 * Check if the execution should be skipped.
	 * 
	 * @return true to skip
	 */
	protected boolean isSkip() {
		return skip;
	}

	public final void execute() throws MojoExecutionException,
			MojoFailureException {

		// If skip flag set then omit clean-up
		if (isSkip()) {
			getLog().info("Skipping deletion of previously generated files");
		} else {

			// First delete all the previously generated files
			deleteGeneratedFiles();

			// Finally delete the status file
			if (statusFile.exists()) {
				try {
					// We have to make sure the file is deleted on Windows as
					// well
					FileUtils.forceDelete(statusFile);
				} catch (IOException e) {
					throw new MojoExecutionException(
							"Deleting status file failed", e);
				}
				if (isVerbose()) {
					getLog().info("Deleted status file: " + statusFile);
				}
			}
		}
	}

}
