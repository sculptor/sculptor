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

import org.apache.commons.exec.LogOutputStream;
import org.apache.maven.plugin.logging.Log;

/**
 * {@link LogOutputStream} which redirects the output or error stream and
 * increases the correspondig counters ( <code>lineCount</code> and
 * <code>errorCount</code>).
 */
public abstract class AbstractLogOutputStream extends LogOutputStream {

	protected final boolean isErrorStream;
	private int lineCount = 0;
	private int errorCount = 0;

	/**
	 * Creates a new output stream for stdout or stderr.
	 * 
	 * @param log
	 *            plugins {@link Log}
	 * @param isErrorStream
	 *            if <code>true</code> then every line sent to this output
	 *            stream increases the error count
	 */
	public AbstractLogOutputStream(boolean isErrorStream) {
		this.isErrorStream = isErrorStream;
	}

	public final int getLineCount() {
		return lineCount;
	}

	public final int getErrorCount() {
		return errorCount;
	}

	/**
	 * Depending on stream type the given line is logged and the correspondig
	 * counter is increased.
	 */
	@Override
	protected final void processLine(String line, int level) {
		boolean isError = doProcessLine(line, level);
		if (isErrorStream || isError) {
			errorCount++;
		}
		lineCount++;
	}

	/**
	 * Logs a line to the log system of the user and reports if the line
	 * indicates an error.
	 * 
	 * @param line
	 *            the line to log
	 * @param level
	 *            the log level to use
	 * @return if <code>true</code> then the logged line indicates an error
	 */
	abstract boolean doProcessLine(final String line, final int level);

}
