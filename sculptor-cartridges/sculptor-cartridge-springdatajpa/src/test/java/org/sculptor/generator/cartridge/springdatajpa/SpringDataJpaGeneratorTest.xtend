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
package org.sculptor.generator.cartridge.springdatajpa

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

/**
 * Tests that verify overall generator workflow for projects that have Spring Data JPA cartridge enabled
 */
class SpringDataJpaGeneratorTest extends GeneratorTestBase {

	static val TEST_NAME = "springdatajpa"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertMediaRepositoryCustomInterface() {
		val code = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/media/domain/MediaRepositoryCustom.java");
		assertContainsConsecutiveFragments(code,
			#[
				"public interface MediaRepositoryCustom {",
				"public List<Media> findMediaByCharacter(Long libraryId, String characterName);",
				"public List<Media> findMediaByName(Long libraryId, String name);",
				"public Map<String, Movie> findMovieByUrlIMDB(Set<String> keys);",
				"}"
			])
	}

	@Test
	def void assertMediaRepositoryCustomClass() {
		val code = getFileText(
			TO_SRC + "/org/sculptor/example/library/media/repositoryimpl/MediaRepositoryCustomImpl.java");
		assertContainsConsecutiveFragments(code,
			#[
				"public class MediaRepositoryCustomImpl implements MediaRepositoryCustom {",
				"public MediaRepositoryCustomImpl() {",
				"}",
				"public List<Media> findMediaByCharacter(Long libraryId, String characterName) {",
				"// TODO Auto-generated method stub",
				"throw new UnsupportedOperationException(\"findMediaByCharacter not implemented\");",
				"}"
			])
	}

}
