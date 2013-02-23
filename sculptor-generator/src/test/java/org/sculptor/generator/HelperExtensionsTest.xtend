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

package org.sculptor.generator

import org.junit.Test

import static org.junit.Assert.*
import static org.sculptor.generator.HelperExtensions.*
import org.junit.runners.JUnit4
import org.junit.runner.RunWith

@RunWith(typeof(JUnit4))
class HelperExtensionsTest {

	@Test
	def testGetHint() {
		assertNull(getHint(null, "key2"))
		assertNull(getHint("", "key2"))
		assertEquals("", getHint("key1=value1 , key2 , key3 = value3", "key2"))
		assertEquals("value2", getHint("key1=value1 , key2 = value2 , key3 = value3", "key2"))
		assertEquals("value2", getHint("key1=value1 | key2 = value2 | key3 = value3", "key2", "|"))
	}

	@Test
	def testGetHintWithSeparator() {
		assertNull(getHint(null, "key2", "|"))
		assertNull(getHint("", "key2", "|"))
		assertEquals("", getHint("key1=value1 | key2 | key3 = value3", "key2", "|"))
		assertEquals("value2", getHint("key1=value1 | key2 = value2 | key3 = value3", "key2", "|"))
	}

}