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
package org.sculptor.generator.transformation

import com.google.inject.Provider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.generator.chain.ChainOverrideAwareInjector
import org.sculptor.generator.configuration.Configuration
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.Enum

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class EnumTransformationTest extends XtextTest {

	extension Properties properties

	extension Helper helper

	extension HelperBase helperBase

	extension DbHelper dbHelper

	extension DbHelperBase dbHelperBase

	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app

	@Before
	def void setupDslModel() {

		// Activate cartridge 'test' with transformation extensions 
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			"generator-tests/transformation/sculptor-generator.properties")

		val injector = ChainOverrideAwareInjector.createInjector(#[typeof(DslTransformation), typeof(Transformation)])
		properties = injector.getInstance(typeof(Properties))
		helper = injector.getInstance(typeof(Helper))
		helperBase = injector.getInstance(typeof(HelperBase))
		dbHelper = injector.getInstance(typeof(DbHelper))
		dbHelperBase = injector.getInstance(typeof(DbHelperBase))
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app

		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)

		val transformation = transformationProvider.get
		app = transformation.modify(app)
	}

	def getDomainModel() {
		testFileNoSerializer("generator-tests/enum/model.btdesign")
		modelRoot as DslModel
	}

	def enumByName(String name) {
		app.modules.namedElement("module").domainObjects.namedElement(name) as Enum
	}

	def referenceByName(String name) {
		app.modules.namedElement("module").domainObjects.namedElement("EnumTest").references.namedElement(name)
	}

	@Test
	def void assertApplication() {
		assertEquals("app", app.name)
		assertOneAndOnlyOne(app.modules, "module")
	}

	@Test
	def void assertSimpleEnum() {
		val testEnum = enumByName("SimpleEnum")
		assertFalse(testEnum.ordinal)
		assertEquals(0, testEnum.attributes.size)
		assertEquals(3, testEnum.values.size)
	}

	@Test
	def void assertSimpleEnumDatabaseType() {
		val testEnum = enumByName("SimpleEnum")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("VARCHAR(5)", databaseType)
	}

	@Test
	def void assertSimpleEnumType() {
		val testEnum = enumByName("SimpleEnum")
		val databaseType = testEnum.enumType
		assertEquals("String", databaseType)
	}

	@Test
	def void assertSimpleEnumDatabaseLength() {
		val testEnum = enumByName("SimpleEnum")
		val databaseLength = testEnum.enumDatabaseLength
		assertEquals("5", databaseLength)
	}

	@Test
	def void assertSimpleEnumIsOfTypeString() {
		val testEnum = enumByName("SimpleEnum")
		val isString = testEnum.isOfTypeString
		assertTrue(isString)
	}

	@Test
	def void assertSimpleOrdinalEnumType() {
		val testEnum = enumByName("SimpleOrdinalEnum")
		val type = testEnum.enumType
		assertEquals("int", type)
	}

	@Test
	def void assertSimpleOrdinalEnum() {
		val testEnum = enumByName("SimpleOrdinalEnum")
		assertTrue(testEnum.ordinal)
		assertEquals(0, testEnum.attributes.size)
		assertEquals(2, testEnum.values.size)
	}

	@Test
	def void assertSimpleOrdinalEnumDatabaseType() {
		val testEnum = enumByName("SimpleOrdinalEnum")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("INTEGER", databaseType)
	}

	@Test
	def void assertSimpleOrdinalEnumIsOfTypeString() {
		val testEnum = enumByName("SimpleOrdinalEnum")
		val isString = testEnum.isOfTypeString
		assertFalse(isString)
	}

	@Test
	def void assertEnumWithDefaultParameter() {
		val testEnum = enumByName("EnumWithDefaultParameter")
		assertFalse(testEnum.ordinal)
		assertEquals(1, testEnum.attributes.size)
		assertEquals(3, testEnum.values.size)
	}

	@Test
	def void assertEnumWithDefaultParameterDatabaseType() {
		val testEnum = enumByName("EnumWithDefaultParameter")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("INTEGER(1)", databaseType)
	}

	@Test
	def void assertEnumWithHintDatabaseLengthDatabaseType() {
		val testEnum = enumByName("EnumWithHintDatabaseLength")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("VARCHAR(10)", databaseType)
	}

	@Test
	def void assertEnumWithDefaultStringParameter() {
		val testEnum = enumByName("EnumWithDefaultStringParameter")
		assertFalse(testEnum.ordinal)
		assertEquals(1, testEnum.attributes.size)
		assertEquals(3, testEnum.values.size)
	}

	@Test
	def void assertEnumWithDefaultStringParameterDatabaseType() {
		val testEnum = enumByName("EnumWithDefaultStringParameter")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("VARCHAR(2)", databaseType)
	}

	@Test
	def void assertEnumWithParametersWithoutKeyAttributeDatabaseType() {
		val testEnum = enumByName("EnumWithParametersWithoutKeyAttribute")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("VARCHAR(5)", databaseType)
	}

	@Test
	def void assertOrdinalEnumWithParametersWithoutKeyAttributeDatabaseType() {
		val testEnum = enumByName("OrdinalEnumWithParametersWithoutKeyAttribute")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("INTEGER", databaseType)
	}

	@Test
	def void assertEnumWithParametersWithDoubleKeyAttributeDatabaseType() {
		val testEnum = enumByName("EnumWithParametersWithDoubleKeyAttribute")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("DOUBLE(3)", databaseType)
	}

	@Test
	def void assertEnumWithParametersWithIntKeyAttributeDatabaseType() {
		val testEnum = enumByName("EnumWithParametersWithIntKeyAttribute")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("INTEGER(1)", databaseType)
	}

	@Test
	def void assertEnumWithParametersWithStringKeyAttributeDatabaseType() {
		val testEnum = enumByName("EnumWithParametersWithStringKeyAttribute")
		val databaseType = testEnum.enumDatabaseType
		assertEquals("VARCHAR(2)", databaseType)
	}

	@Test
	def void assertSimpleEnumReferenceDatabaseType() {
		val reference = referenceByName("simpleEnum")
		val databaseType = reference.enumDatabaseType
		assertEquals("VARCHAR(5)", databaseType)
	}

	@Test
	def void assertSimpleEnumReferenceWithHintDatabaseLengthDatabaseType() {
		val reference = referenceByName("simpleEnumWithHintDatabaseLength")
		val databaseType = reference.enumDatabaseType
		assertEquals("VARCHAR(20)", databaseType)
	}

	@Test
	def void assertSimpleOrdinalEnumReferenceDatabaseType() {
		val reference = referenceByName("simpleOrdinalEnum")
		val databaseType = reference.enumDatabaseType
		assertEquals("INTEGER", databaseType)
	}

}
