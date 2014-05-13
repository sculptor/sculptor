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
package org.sculptor.generator.cartridge.builder

import com.google.inject.Inject
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.generator.test.GeneratorModelTestFixtures

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class BuilderTemplateTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures

	var BuilderTmpl builderTmpl

	@Before
	def void setupExtensions() {
		generatorModelTestFixtures.setupInjector(typeof(BuilderTmpl))
		generatorModelTestFixtures.setupModel("generator-tests/builder/model.btdesign")

		builderTmpl = generatorModelTestFixtures.getProvidedObject(typeof(BuilderTmpl))
	}

	@Test
	def void testAppTransformation() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		assertEquals(1, app.modules.size)
	}

	@Test
	def void testBuilderBody() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("foobar")
		assertNotNull(module)

		val obj = module.domainObjects.namedElement("Foo")
		assertNotNull(obj)

		val code = builderTmpl.builderBody(obj)
		assertNotNull(code)

		// class and attributes
		code.assertContainsConsecutiveFragments(
			#[
				"public class FooBuilder {",
				"private String name;",
				"private java.util.Date timestamp;"
			])

		// factory method
		code.assertContainsConsecutiveFragments(
			#[
				"public static FooBuilder foo() {",
				"return new FooBuilder();",
				"}",
				"public FooBuilder() {",
				"}"
			])

		// default constructor
		code.assertContainsConsecutiveFragments(
			#[
				"public FooBuilder() {",
				"}"
			])

		// constructor
		code.assertContainsConsecutiveFragments(
			#[
				"public FooBuilder( String name, java.util.Date timestamp) {",
				"this.name = name;",
				"this.timestamp = timestamp;",
				"}"
			])

		// modifiers
		code.assertContainsConsecutiveFragments(
			#[
				"public FooBuilder name(String val) {",
				"this.name = val;",
				"return this;",
				"}",
				"public FooBuilder timestamp(java.util.Date val) {",
				"this.timestamp = val;",
				"return this;",
				"}"
			])

		// getters
		code.assertContainsConsecutiveFragments(
			#[
				"public String getName() {",
				"return name;",
				"}",
				"public java.util.Date getTimestamp() {",
				"return timestamp;",
				"}"
			])

		// build
		code.assertContainsConsecutiveFragments(
			#[
				"public org.sculptor.example.builder.foobar.domain.Foo build() {",
				"org.sculptor.example.builder.foobar.domain.Foo obj = new Foo(getName(), getTimestamp());",
				"return obj;",
				"}"
			])
	}

}
