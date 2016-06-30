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
package org.sculptor.generator;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

/**
 * This class uses a {@link ThreadLocal} to hold a list of file created by the
 * code generator and a list of issues which came up during code generation.
 * 
 * <strong>After finishing with the file list call {@link #close()} to remove
 * the file list from the current thread. Otherwise this class is leaking
 * memory!!!</strong>
 */
public final class SculptorGeneratorContext {

	private static final ThreadLocal<SculptorGeneratorContextHolder> threadLocal = new ThreadLocal<SculptorGeneratorContextHolder>() {
		@Override
		protected SculptorGeneratorContextHolder initialValue() {
			return new SculptorGeneratorContextHolder();
		}
	};

	public static void addGeneratedFile(File file) {
		threadLocal.get().generatedFiles.add(file);
	}

	public static List<File> getGeneratedFiles() {
		return threadLocal.get().generatedFiles;
	}

	public static void addIssue(SculptorGeneratorIssue issue) {
		threadLocal.get().issues.add(issue);
	}

	public static List<SculptorGeneratorIssue> getIssues() {
		return threadLocal.get().issues;
	}

	public static void close() {
		threadLocal.remove();
	}

	private static class SculptorGeneratorContextHolder {
		private final List<File> generatedFiles = new ArrayList<File>();
		private final List<SculptorGeneratorIssue> issues = new ArrayList<SculptorGeneratorIssue>();
	}

}
