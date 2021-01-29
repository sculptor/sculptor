/*
 * Copyright 2015 The Sculptor Project Team, including the original 
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

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class OracleDDLTest extends GeneratorTestBase {

	static val TEST_NAME = "ddl"

	new() {
		super(TEST_NAME)
	}

	@BeforeAll
	def static void setup() {
		System.setProperty("db.product", "oracle")
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertDdl() {

		val ddl = getFileText(TO_GEN_RESOURCES + "/dbschema/Library_ddl.sql");

		// Drop sequence
		assertContains(ddl, "DROP SEQUENCE hibernate_sequence;")

		// Create sequence
		assertContains(ddl, "CREATE SEQUENCE hibernate_sequence;")

		// Drop table
		assertContains(ddl, "DROP TABLE PERSON CASCADE CONSTRAINTS PURGE;")

		// Create table with ID
		assertContainsConsecutiveFragments(ddl, #[
			"CREATE TABLE PERSON (",
			"ID NUMBER(19) NOT NULL,",
			"BIRTHDATE DATE NOT NULL,",
			"SSN_NUMBER VARCHAR2(20) NOT NULL,",
			"SSN_COUNTRY VARCHAR2(7) NOT NULL,",
			"NAME_FIRST VARCHAR2(100) NOT NULL,",
			"NAME_LAST VARCHAR2(100) NOT NULL,",
			"SEX VARCHAR2(1) NOT NULL,",
			"CREATEDDATE DATE,",
			"CREATEDBY VARCHAR2(50),",
			"LASTUPDATED DATE,",
			"LASTUPDATEDBY VARCHAR2(50),",
			"VERSION NUMBER(19) NOT NULL",
			");"
		])

		// Create unique key constraint
		assertContainsConsecutiveFragments(ddl, #[
			"ALTER TABLE PERSON",
			"	ADD CONSTRAINT UQ_PERSON UNIQUE (SSN_NUMBER, SSN_COUNTRY);"
		])

	}

}
