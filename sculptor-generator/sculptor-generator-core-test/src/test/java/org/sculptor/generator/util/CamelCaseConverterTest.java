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
package org.sculptor.generator.util;

import static org.junit.Assert.assertEquals;

import org.junit.Test;

public class CamelCaseConverterTest {

	@Test
	public void testCamelCaseToWordsSimple() {
		String result = CamelCaseConverter.camelCaseToWords("CamelCase");
		assertEquals("Camel Case", result);
	}

	@Test
	public void testCamelCaseToWordsOneChar() {
		String result = CamelCaseConverter.camelCaseToWords("a");
		assertEquals("a", result);
	}

	@Test
	public void testCamelCaseToWordsTwoChars() {
		String result = CamelCaseConverter.camelCaseToWords("ab");
		assertEquals("ab", result);
	}

	@Test
	public void testCamelCaseToWordsThreeChars() {
		String result = CamelCaseConverter.camelCaseToWords("abc");
		assertEquals("abc", result);
		result = CamelCaseConverter.camelCaseToWords("aBc");
		assertEquals("a Bc", result);
		result = CamelCaseConverter.camelCaseToWords("abC");
		assertEquals("ab C", result);
	}

	@Test
	public void testCamelCaseToWordsSeveralUpper() {
		String result = CamelCaseConverter.camelCaseToWords("AbcDEF");
		assertEquals("Abc DEF", result);
		result = CamelCaseConverter.camelCaseToWords("AbcDEFefGh");
		assertEquals("Abc DE Fef Gh", result);
		result = CamelCaseConverter.camelCaseToWords("AbcDEFefGH");
		assertEquals("Abc DE Fef GH", result);
		result = CamelCaseConverter.camelCaseToWords("AbcDEFefGHi");
		assertEquals("Abc DE Fef G Hi", result);
	}

	@Test
	public void testCamelCaseTwice() {
		String result1 = CamelCaseConverter.camelCaseToWords("CamelCase");
		assertEquals("Camel Case", result1);
		String result2 = CamelCaseConverter.camelCaseToWords(result1);
		assertEquals(result1, result2);
	}

	@Test
	public void testCamelCaseFirstAlreadySeparator() {
		String result = CamelCaseConverter.camelCaseToWords(" CamelCase");
		assertEquals(" Camel Case", result);
	}

}