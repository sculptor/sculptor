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
 * code generator.
 * 
 * <strong>After finshings with the file list call {@link #close()} to remove
 * the file list from the current thread. Otherwise this class is leaking
 * memory!!!</strong>
 */
public class GeneratorContext {

	private static final ThreadLocal<List<File>> generatedFilesHolder = new ThreadLocal<List<File>>() {
		@Override
		protected List<File> initialValue() {
			return new ArrayList<File>();
		}
	};

	public static void addGeneratedFile(File file) {
		generatedFilesHolder.get().add(file);
	}

	public static List<File> getGeneratedFiles() {
		return generatedFilesHolder.get();
	}

	public static void close() {
		generatedFilesHolder.remove();
	}

}
