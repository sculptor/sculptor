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

/**
 * This exception is used to indicate that the code generation failed.
 * 
 * @since 3.0.1
 */
public class SculptorGeneratorException extends RuntimeException {

	private static final long serialVersionUID = 1L;

	public SculptorGeneratorException() {
		super();
	}

	public SculptorGeneratorException(String message, Throwable cause) {
		super(message, cause);
	}

	public SculptorGeneratorException(String message) {
		super(message);
	}

	public SculptorGeneratorException(Throwable cause) {
		super(cause);
	}

}
