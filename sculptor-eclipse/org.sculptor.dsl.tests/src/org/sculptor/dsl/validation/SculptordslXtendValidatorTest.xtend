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

package org.sculptor.dsl.validation

import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Test
import static org.junit.Assert.*
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.junit.Before
import org.sculptor.dsl.sculptordsl.DslEntity
import org.sculptor.dsl.sculptordsl.DslValueObject
import org.sculptor.dsl.sculptordsl.DslService

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class SculptordslXtendValidatorTest extends XtextTest {

	new() {
		super("SculptordslXtendValidatorTest")
	}

	@Before
	def setup() {
		ignoreFormattingDifferences()
	}

	@Test
	def void testCheckDomainObjectDuplicateName() {
		val issues = testFile("domain_object_duplicate_name.btdesign")
		assertEquals(2, issues.errorsOnly.size)
		assertConstraints(issues.errorsOnly().inLine(4).under(typeof(DslEntity), "Test").named("Test").oneOfThemContains("Duplicate name"))
		assertConstraints(issues.errorsOnly().inLine(5).under(typeof(DslValueObject), "Test").named("Test").oneOfThemContains("Duplicate name"))
	}

	@Test
	def void testCheckServiceDuplicateName() {
		val issues = testFile("service_duplicate_name.btdesign")
		assertEquals(2, issues.errorsOnly.size)
		assertConstraints(issues.errorsOnly().inLine(4).under(typeof(DslService), "Test").named("Test").oneOfThemContains("Duplicate name"))
		assertConstraints(issues.errorsOnly().inLine(5).under(typeof(DslService), "Test").named("Test").oneOfThemContains("Duplicate name"))
	}

}
