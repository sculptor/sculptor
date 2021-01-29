/*
 * Copyright 2014 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License")
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
import org.eclipse.emf.common.util.EList
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.^extension.ExtendWith;
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.dsl.tests.SculptordslInjectorProvider
import org.sculptor.generator.chain.ChainOverrideAwareInjector
import org.sculptor.generator.configuration.Configuration
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.Module

import static org.junit.jupiter.api.Assertions.*;

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@ExtendWith(typeof(InjectionExtension))
@InjectWith(typeof(SculptordslInjectorProvider))
class NestedTransformationTest extends XtextTest {

	static val BASE_PACKAGE = "org.sculptor.test"

	extension HelperBase helperBase

	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app

	@BeforeEach
	def void setupDslModel() {

		// Activate cartridge 'test' with transformation extensions 
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			"generator-tests/transformation/sculptor-generator.properties")

		// Disable generation of module nested3 and nested4 (to keep their objects as external ones) 
		System.setProperty("generate.module.nested3", "false")
		System.setProperty("generate.module.nested4", "false")

		val injector = ChainOverrideAwareInjector.createInjector(#[typeof(DslTransformation), typeof(Transformation)])
		helperBase = injector.getInstance(typeof(HelperBase))
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app

		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)

		val transformation = transformationProvider.get
		app = transformation.modify(app)
	}

	def getDomainModel() {
		testFileNoSerializer("generator-tests/nested/nested1.btdesign")
		modelRoot as DslModel
	}

	@Test
	def void assertApplication() {
		assertEquals("Nested", app.name)
		val modules = app.modules
		assertNotNull(modules)
		assertEquals(4, modules.size())
		assertModules(modules)
	}

	private def void assertModules(EList<Module> modules) {
		assertOneAndOnlyOne(modules, "nested1", "nested2", "nested3", "nested4")
		modules.forEach [
			switch name {
				case "nested1":
					assertNested1Module(it)
				case "nested2":
					assertNested2Module(it)
				case "nested3":
					assertNested3Module(it)
				case "nested4":
					assertNested4Module(it)
				default:
					fail("unexpected module: " + name)
			}
		]
	}

	private def void assertNested1Module(Module module) {
		assertFalse(module.external)
		assertOneAndOnlyOne(module.domainObjects, "A")

	}

	private def void assertNested2Module(Module module) {
		assertFalse(module.external)
		assertEquals(BASE_PACKAGE + ".nested.nested2.domain", helperBase.getDomainPackage(module))
		assertOneAndOnlyOne(module.domainObjects, "B")
		val bObj = module.domainObjects.namedElement("B")
		assertEquals("B", bObj.name)
		assertEquals(BASE_PACKAGE + ".nested.nested2.domain", helperBase.getDomainPackage(bObj))
		assertOneAndOnlyOne(bObj.attributes, "b")
		assertOneAndOnlyOne(bObj.references, "c", "d")
		val cRef = bObj.references.namedElement("c")
		assertTrue(cRef.to.module.external)
		val dRef = bObj.references.namedElement("d")
		assertTrue(dRef.to.module.external)
	}

	private def void assertNested3Module(Module module) {
		assertTrue(module.external)
		assertEquals(BASE_PACKAGE + ".common.nested3.domain", helperBase.getDomainPackage(module))
		assertOneAndOnlyOne(module.domainObjects, "C")
	}

	private def void assertNested4Module(Module module) {
		assertTrue(module.external)
		assertOneAndOnlyOne(module.domainObjects, "D")
	}

}
