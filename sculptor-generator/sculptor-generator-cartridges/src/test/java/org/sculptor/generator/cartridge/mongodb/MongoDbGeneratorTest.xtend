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

package org.sculptor.generator.cartridge.mongodb

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

/**
 * Tests that verify overall generator workflow for projects that have MongoDB cartridge enabled
 */
class MongoDbGeneratorTest extends GeneratorTestBase {

	static val TEST_NAME = "mongodb" 

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		runGenerator(TEST_NAME)
	}

    @Test
    def void assertBookMapper() {
    	
    	val libraryBuilderCode = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/media/mapper/BookMapper.java");
    	
    	assertContains(libraryBuilderCode, "package org.sculptor.example.library.media.mapper;");
    	
    	assertContains(libraryBuilderCode, "List<DBObject> engagementsData = new ArrayList<DBObject>();");
    }
   
    @Test
    def void assertRepositoryBase() {
    	
    	val mediaRepositoryCode = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/media/repositoryimpl/MediaRepositoryBase.java");
    	
    	assertContainsConsecutiveFragments(mediaRepositoryCode,#[
    		"public List<Media> findByTitle(String title) {",
    		"List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Media.class)",
    		".withProperty(MediaProperties.title()).eq(title).build();",
    		"List<Media> result = findByCondition(condition);",
    		"return result;",
    		"}"])
    	
    	assertContainsConsecutiveFragments(mediaRepositoryCode,#[
    		"@Autowired",
			"private DbManager dbManager;",
			"protected DbManager getDbManager() {",
			"return dbManager;"
    	])
    	
    	
    	assertContainsConsecutiveFragments(mediaRepositoryCode,#[
			'private org.sculptor.framework.accessimpl.mongodb.DataMapper[] additionalDataMappers = new DataMapper[] {',
				'JodaLocalDateMapper.getInstance(), JodaDateTimeMapper.getInstance(), EnumMapper.getInstance(),',
				'IdMapper.getInstance(PhysicalMedia.class), IdMapper.getInstance(MediaCharacter.class),',
				'IdMapper.getInstance(Person.class) };'	
		])
		
    	assertContainsConsecutiveFragments(mediaRepositoryCode,#[
			'protected DataMapper<Object, DBObject>[] getAdditionalDataMappers() {',
				'return additionalDataMappers;',
			'}'
		])
    }
    

}
