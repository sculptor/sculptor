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

public interface SculptorGeneratorIssue {

	Severity getSeverity();

	String getMessage();

	Throwable getThrowable();
	
	public enum Severity {
		ERROR,
		WARNING,
		INFO
	}

	public static final class SculptorGeneratorIssueImpl implements SculptorGeneratorIssue {

		private Severity severity;
		private String message;
		private Throwable throwable;

		public SculptorGeneratorIssueImpl(Severity severity, String message) {
			this(severity, message, null);
		}

		public SculptorGeneratorIssueImpl(Severity severity, String message, Throwable throwable) {
			this.severity = severity;
			this.message = message;
			this.throwable = throwable;
		}

		@Override
		public Severity getSeverity() {
			return severity;
		}

		@Override
		public String getMessage() {
			return message;
		}

		@Override
		public Throwable getThrowable() {
			return throwable;
		}
		
	}

}
