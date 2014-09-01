/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
import java.util.List;

public class SculptorGeneratorResult {

	private Status status;
	private List<SculptorGeneratorIssue> issues;
	private List<File> generatedFiles;

	/* package */ SculptorGeneratorResult(Status status, List<SculptorGeneratorIssue> issues, List<File> generatedFiles) {
		this.status = status;
		this.issues = issues;
		this.generatedFiles = generatedFiles;
	}

	public Status getStatus() {
		return status;
	}

	public List<SculptorGeneratorIssue> getIssues() {
		return issues;
	}

	public List<File> getGeneratedFiles() {
		return generatedFiles;
	}

	public enum Status {
		SUCCESS, SUCCESS_BUT_WARNINGS, FAILED 
	}

}
