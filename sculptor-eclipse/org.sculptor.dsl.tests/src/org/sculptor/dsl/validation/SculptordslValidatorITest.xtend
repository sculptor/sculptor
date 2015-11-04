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
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslAttribute
import org.sculptor.dsl.sculptordsl.DslDataTransferObject
import org.sculptor.dsl.sculptordsl.DslEntity
import org.sculptor.dsl.sculptordsl.DslModule
import org.sculptor.dsl.sculptordsl.DslParameter
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslServiceOperation
import org.sculptor.dsl.sculptordsl.DslValueObject

import static org.junit.Assert.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class SculptordslValidatorITest extends XtextTest {

	new() {
		super("SculptordslValidatorITest")
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

	@Test
	def void testCheckRepositoryDuplicateName() {
		val issues = testFile("repository_duplicate_name.btdesign")
		assertEquals(2, issues.errorsOnly.size)
		assertConstraints(issues.errorsOnly().inLine(5).under(typeof(DslRepository), "TestRepository").named("TestRepository").oneOfThemContains("Duplicate name"))
		assertConstraints(issues.errorsOnly().inLine(8).under(typeof(DslRepository), "TestRepository").named("TestRepository").oneOfThemContains("Duplicate name"))
	}

	@Test
	def void testCheckModuleDuplicateName() {
		val issues = testFile("module_duplicate_name.btdesign")
		assertEquals(2, issues.errorsOnly.size)
		assertConstraints(issues.errorsOnly().inLine(3).under(typeof(DslModule), "test").named("test").oneOfThemContains("Duplicate name"))
		assertConstraints(issues.errorsOnly().inLine(6).under(typeof(DslModule), "test").named("test").oneOfThemContains("Duplicate name"))
	}

//	@Test Disabled for now.  The testFile() method is only validating resources in main file, so can't get duplicate Application/ApplicationPart objects
	def void testCheckAppDuplicateName() {
		val issues = testFile("app_duplicate_name.btdesign", "app_duplicate_name_part.btdesign")
		assertEquals(4, issues.errorsOnly.size)
		assertConstraints(issues.errorsOnly().inLine(1).under(typeof(DslApplication), "Test").named("Test").oneOfThemContains("Duplicate name"))
		assertConstraints(issues.errorsOnly().inLine(7).under(typeof(DslApplication), "Test").named("Test").oneOfThemContains("Duplicate name"))
	}

	@Test
	def void testBadReferenceMissingDash() {
		val issues = testFile("attributes.btdesign")
		assertEquals(2, issues.warningsOnly.size)
		assertConstraints(issues.warningsOnly().inLine(6).under(typeof(DslAttribute), "badReference").named("badReference").oneOfThemContains("Use - Another"))
		assertConstraints(issues.warningsOnly().inLine(7).under(typeof(DslAttribute), "badReference2").named("badReference2").oneOfThemContains("Use - List<Another>"))
	}

	@Test
	def void testBadServiceAndRepositoryOperationReturnTypeOfDomainObject() {
		val issues = testFile("operation_return_type_bad.btdesign")
		assertEquals(2, issues.warningsOnly.size)
		assertConstraints(issues.warningsOnly().inLine(5).under(typeof(DslServiceOperation), "anOperation").named("anOperation").oneOfThemContains("Use @SomeType"))
		assertConstraints(issues.warningsOnly().inLine(9).under(typeof(DslRepositoryOperation), "findIt").named("findIt").oneOfThemContains("Use @SomeType"))
	}

	@Test
	def void testBadParameterTypeOfDomainObject() {
		val issues = testFile("operation_parameter_type_bad.btdesign")
		assertEquals(1, issues.warningsOnly.size)
		assertConstraints(issues.warningsOnly().inLine(6).under(typeof(DslParameter), "toMatch").named("toMatch").oneOfThemContains("Use @SomeType"))
	}

	@Test
	def void testUnresolvedExtendsNames() {
		val issues = testFile("unresolved_extends_names.btdesign")
		assertEquals(3, issues.size)
		assertConstraints(issues.errorsOnly().inLine(4).under(typeof(DslEntity), "TestEntity").named("TestEntity").oneOfThemContains("resolve reference to 'NonExistentEntity'"))
		assertConstraints(issues.errorsOnly().inLine(5).under(typeof(DslValueObject), "TestVO").named("TestVO").oneOfThemContains("resolve reference to 'NonExistentVO'"))
		assertConstraints(issues.errorsOnly().inLine(6).under(typeof(DslDataTransferObject), "TestDTO").named("TestDTO").oneOfThemContains("resolve reference to 'NonExistentDTO'"))
	}

}
