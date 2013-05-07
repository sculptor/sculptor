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

import org.apache.maven.plugin.logging.Log;

/**
 * {@link AbstractLogOutputStream} which redirects the output or error stream to the
 * plugins Maven {@link Log} and increases the correspondig counters (
 * <code>lineCount</code> and <code>errorCount</code>).
 */
public class MavenLogOutputStream extends AbstractLogOutputStream {

	private Log log;

	/**
	 * Creates a new output stream for stdout.
	 * 
	 * @param log
	 *            plugins {@link Log}
	 */
	public MavenLogOutputStream(Log log) {
		this(log, false);
	}

	/**
	 * Creates a new output stream for stdout or stderr.
	 * 
	 * @param log
	 *            plugins {@link Log}
	 * @param isErrorStream
	 *            if <code>true</code> then every line sen to this output stream
	 *            increases the error count
	 */
	public MavenLogOutputStream(Log log, boolean isErrorStream) {
		super(isErrorStream);
		this.log = log;
	}

	@Override
	protected boolean doProcessLine(String line, int level) {
		if (isErrorStream) {
			log.error(line);
		} else {
			log.info(line);
		}
		return false;
	}

}
