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

import junit.framework.TestCase;

import org.apache.maven.plugin.testing.SilentLog;

public class MavenLogOutputStreamTest extends TestCase {

	public void testLineCount() {
		@SuppressWarnings("resource")
		MavenLogOutputStream outputStream = new MavenLogOutputStream(
				new SilentLog());
		outputStream.processLine("test", 0);
		outputStream.processLine("test", 0);
		outputStream.processLine("test", 0);
		assertEquals(3, outputStream.getLineCount());
	}

	public void testErrorStreamLineCount() {
		@SuppressWarnings("resource")
		MavenLogOutputStream outputStream = new MavenLogOutputStream(
				new SilentLog(), true);
		outputStream.processLine("test", 0);
		outputStream.processLine("test", 0);
		outputStream.processLine("test", 0);
		assertEquals(3, outputStream.getLineCount());
	}

}
