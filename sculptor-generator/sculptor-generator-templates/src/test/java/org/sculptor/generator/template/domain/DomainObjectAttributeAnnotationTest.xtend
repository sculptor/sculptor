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
package org.sculptor.generator.template.domain

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class DomainObjectAttributeAnnotationTest extends GeneratorTestBase {

	static val TEST_NAME = "helloworld"

	new() {
		super(TEST_NAME)
	}

	@BeforeAll
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertValidationAnnotations() {
		val code = getFileText(TO_GEN_SRC + "/org/sculptor/example/helloworld/milkyway/domain/PlanetBase.java");
		assertContainsConsecutiveFragments(code, #['@NotNull', 'private String message;']);
		assertContainsConsecutiveFragments(code, #['@Min(1)', 'private Integer diameter;']);
		assertContainsConsecutiveFragments(code, #['@Min(0)', 'private Integer population;']);
	}

	@Test
	def void assertJpaAnnotations() {
		val code = getFileText(TO_GEN_SRC + "/org/sculptor/example/helloworld/milkyway/domain/PlanetBase.java");
		assertContainsConsecutiveFragments(code,
			#['@Id', '@GeneratedValue(strategy = GenerationType.AUTO)', '@Column(name = "ID")', 'private Long id;']);
		assertContainsConsecutiveFragments(code,
			#['@Version', '@Column(name = "VERSION", nullable = false)', 'private Long version;']);
		assertContainsConsecutiveFragments(code,
			#['@Column(name = "NAME", nullable = false, length = 100, unique = true)', '@NotNull',
				'private String name;']);
	}

}
