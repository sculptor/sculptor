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

import static org.sculptor.generator.GeneratorTestExtensions.*
import org.sculptor.generator.GeneratorTestBase

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
    	
    	val libraryBuilderCode = getFileText("src/generated/java/org/sculptor/example/library/media/mapper/BookMapper.java");
    	
    	assertContains(libraryBuilderCode, "package org.sculptor.example.library.media.mapper;");
    	
    	assertContains(libraryBuilderCode, "List<DBObject> engagementsData = new ArrayList<DBObject>();");
    }

}
