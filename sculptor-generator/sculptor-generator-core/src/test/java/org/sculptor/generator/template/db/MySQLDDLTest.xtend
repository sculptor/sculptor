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
package org.sculptor.generator.template.db

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.GeneratorTestBase

import static org.sculptor.generator.GeneratorTestExtensions.*

class MySQLDDLTest extends GeneratorTestBase {

	static val TEST_NAME = "ddl"

	new() {
		super(TEST_NAME)
	}

	@BeforeClass
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertDdl() {

		val ddl = getFileText(TO_GEN_RESOURCES + "/dbschema/Library_ddl.sql");

		// Drop table
		assertContains(ddl, "DROP TABLE IF EXISTS MEDIA;")

		// Create table with ID
		assertContainsConsecutiveFragments(ddl,
			#[
				"CREATE TABLE MEDIA (",
				"ID BIGINT NOT NULL AUTO_INCREMENT PRIMARY KEY",
				",",
				"TITLE VARCHAR(100) NOT NULL",
				",",
				"CREATEDDATE TIMESTAMP",
				",",
				"CREATEDBY VARCHAR(50)",
				",",
				"LASTUPDATED TIMESTAMP",
				",",
				"LASTUPDATEDBY VARCHAR(50)",
				",",
				"VERSION BIGINT NOT NULL",
				");"
			])

		// Create table with extension
		assertContainsConsecutiveFragments(ddl,
			#[
				"CREATE TABLE MOVIE (",
				"URLIMDB VARCHAR(100) NOT NULL",
				",",
				"PLAYLENGTH INTEGER NOT NULL",
				",",
				"CATEGORY VARCHAR(6)",
				",",
				"MEDIA BIGINT NOT NULL",
				",",
				"CONSTRAINT UNIQUE (URLIMDB)",
				");"
			])

		// References
		assertContainsConsecutiveFragments(ddl,
			#[
				"-- Reference from Engagement.PERSON to Person",
				"ALTER TABLE ENGAGEMENT ADD CONSTRAINT FK_ENGAGEMENT_PERSON",
				"	FOREIGN KEY (PERSON) REFERENCES PERSON(ID);"
			])

		// Many to many relations
		assertContainsConsecutiveFragments(ddl,
			#[
				"CREATE TABLE EXISTSINMEDIA_MEDIACHARACTER (",
				"MEDIACHARACTER BIGINT NOT NULL,",
				"FOREIGN KEY (MEDIACHARACTER) REFERENCES MEDIA_CHR(ID)",
				",",
				"EXISTSINMEDIA BIGINT NOT NULL,",
				"FOREIGN KEY (EXISTSINMEDIA) REFERENCES MEDIA(ID)",
				");"
			])
	}

}
