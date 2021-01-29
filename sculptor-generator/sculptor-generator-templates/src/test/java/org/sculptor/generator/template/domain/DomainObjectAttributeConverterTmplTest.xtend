/*
 * Copyright 2019 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.domain

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class DomainObjectAttributeConverterTmplTest extends GeneratorTestBase {

	static val TEST_NAME = "library"

	new() {
		super(TEST_NAME)
	}

	@BeforeAll
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertConverter() {
		val code = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/person/domain/CountryConverter.java");
		assertContainsConsecutiveFragments(code, #['@Converter', 'public class CountryConverter implements AttributeConverter<Country, String> {'])
		assertContainsConsecutiveFragments(code, #['@Override', 'public String convertToDatabaseColumn(Country country) {', 'return country == null ? null : country.getAlpha2();', '}'])
		assertContainsConsecutiveFragments(code, #['@Override', 'public Country convertToEntityAttribute(String alpha2) {', 'return alpha2 == null ? null : Country.fromAlpha2(alpha2);', '}'])
	}

	@Test
	def void assertJpaAnnotations() {
		val code = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/person/domain/PersonBase.java");
		assertContainsConsecutiveFragments(code, #['@Column(name = "SEX", nullable = false, length = 1)', '@Convert(converter = GenderConverter.class)'])
	}

}
	