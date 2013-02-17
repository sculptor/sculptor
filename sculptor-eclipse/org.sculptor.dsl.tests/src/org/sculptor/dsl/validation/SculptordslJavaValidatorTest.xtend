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

import com.google.inject.Injector
import javax.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.validation.ValidatorTester
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.dsl.sculptordsl.SculptordslFactory

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(SculptordslInjectorProvider))
class SculptordslJavaValidatorTest {

	@Inject Injector injector
	@Inject SculptordslJavaValidator validator  
	ValidatorTester<SculptordslJavaValidator> tester;

	@Before
	def void prepareTester() {
		tester = new ValidatorTester<SculptordslJavaValidator>(validator, injector)
	}

	@Test
	def testCheckModuleNameStartsWithLowerCase() {
		val model = SculptordslFactory::eINSTANCE.createDslModule
		model.setName("UppercaseName")
		tester.validator().checkModuleNameStartsWithLowerCase(model)
		tester.diagnose().assertWarning(IssueCodes::UNCAPITALIZED_NAME)
	}

	@Test
	def testCheckServiceNameStartsWithUpperCase() {
		val service = SculptordslFactory::eINSTANCE.createDslService
		service.setName("lowercaseName")
		tester.validator().checkServiceNameStartsWithUpperCase(service)
		tester.diagnose().assertWarning(IssueCodes::CAPITALIZED_NAME)
	}

	@Test
	def testCheckRepositoryNameStartsWithUpperCase() {
		val repository = SculptordslFactory::eINSTANCE.createDslRepository
		repository.setName("lowercaseName")
		tester.validator().checkRepositoryNameStartsWithUpperCase(repository)
		tester.diagnose().assertWarning(IssueCodes::CAPITALIZED_NAME)
	}

	@Test
	def testCheckDomainObjectNameStartsWithUpperCase() {
		val object = SculptordslFactory::eINSTANCE.createDslSimpleDomainObject
		object.setName("lowercaseName")
		tester.validator().checkDomainObjectNameStartsWithUpperCase(object)
		tester.diagnose().assertWarning(IssueCodes::CAPITALIZED_NAME)
	}

	@Test
	def testCheckPropertyNameStartsWithLowerCase() {
		val prop = SculptordslFactory::eINSTANCE.createDslProperty
		prop.setName("UppercaseName")
		tester.validator().checkPropertyNameStartsWithLowerCase(prop)
		tester.diagnose().assertWarning(IssueCodes::UNCAPITALIZED_NAME)
	}

	@Test
	def testCheckParamterNameStartsWithLowerCase() {
		val param = SculptordslFactory::eINSTANCE.createDslParameter
		param.setName("UppercaseName")
		tester.validator().checkParamterNameStartsWithLowerCase(param)
		tester.diagnose().assertWarning(IssueCodes::UNCAPITALIZED_NAME)
	}

}
