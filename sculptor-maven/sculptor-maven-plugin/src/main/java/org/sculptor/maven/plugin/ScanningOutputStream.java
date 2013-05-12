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
import java.io.PrintStream;
import java.util.ArrayList;
import java.util.List;

/**
 * {@link AbstractLogOutputStream} which scans the lines before writing to the
 * wrapped {@link PrintStream}: For the log level <code>ERROR</code> the line is
 * logged as an error.
 * <p>
 * The lines from logger of class <code>org.sculptor.generator.ext.Helper</code>
 * are checked for files created or skipped by the code generator. The list of
 * these {@link File}s can be retrieved by via the corresponding getters.
 */
public class ScanningOutputStream extends AbstractLogOutputStream {

	protected static final String LINE_PREFIX_DEBUG = "[DEBUG] ";
	protected static final String LINE_PREFIX_INFO = "[INFO] ";
	protected static final String LINE_PREFIX_WARN = "[WARN] ";
	protected static final String LINE_PREFIX_ERROR = "[ERROR] ";
	protected static final String LINE_PREFIX_FILE = "[FILE] ";
	protected static final String LINE_PREFIX_FILE_CREATED = LINE_PREFIX_FILE + "Created file : ";
	protected static final String LINE_PREFIX_FILE_SKIPPED = LINE_PREFIX_FILE + "Skipped file : ";

	protected final PrintStream out;
	private boolean isVerbose;

	private List<File> createdFiles = new ArrayList<File>();
	private List<File> skippedFiles = new ArrayList<File>();

	/**
	 * Creates a new output stream for stdout.
	 * 
	 * @param out
	 *            stdout {@link PrintStream} the scanned line are written to
	 * @param isVerbose
	 *            if <code>true</code> then every line is sent to this output stream
	 */
	public ScanningOutputStream(PrintStream out, boolean isVerbose) {
		this(out, isVerbose, false);
	}

	/**
	 * Creates a new output stream for stdout or stderr.
	 * 
	 * @param out
	 *            stdout or stderr {@link PrintStream} the scanned line are written to
	 * @param isVerbose
	 *            if <code>true</code> then every line is sent to this output stream
	 * @param isErrorStream
	 *            if <code>true</code> then every line sent to this output stream
	 *            increases the error count
	 */
	public ScanningOutputStream(PrintStream out, boolean isVerbose, boolean isErrorStream) {
		super(isErrorStream);
		this.out = out;
		this.isVerbose = isVerbose;
	}

	public List<File> getCreatedFiles() {
		return createdFiles;
	}

	public List<File> getSkippedFiles() {
		return skippedFiles;
	}

	/**
	 * For the log level <code>ERROR</code> the line is logged as an error. The
	 * lines from logger of class <code>org.sculptor.generator.ext.Helper</code>
	 * are checked for files created or skipped by the code generator.
	 */
	@Override
	protected boolean doProcessLine(String line, int level) {
		if (line.startsWith(LINE_PREFIX_DEBUG)) {
			if (isVerbose) {
				out.println(line);
			}
		} else if (line.startsWith(LINE_PREFIX_WARN)) {
			out.println("[WARNING] " + line.substring(LINE_PREFIX_WARN.length()));
		} else if (line.startsWith(LINE_PREFIX_ERROR)) {
			out.println(line);
			return true;
		} else if (line.startsWith(LINE_PREFIX_FILE)) {
			if (line.startsWith(LINE_PREFIX_FILE_CREATED)) {
				createdFiles.add(new File(line.substring(LINE_PREFIX_FILE_CREATED.length())));
			} else if (line.startsWith(LINE_PREFIX_FILE_SKIPPED)) {
				skippedFiles.add(new File(line.substring(LINE_PREFIX_FILE_SKIPPED.length())));
			}
			if (isVerbose) {
				out.println("[INFO] " + line.substring(LINE_PREFIX_FILE.length()));
			}
		} else {
			out.println(line);
		}
		return false;
	}

}
