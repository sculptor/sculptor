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
package org.sculptor.generator.transformation

import com.google.inject.Provider
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
import sculptormetamodel.Application
import sculptormetamodel.HttpMethod
import sculptormetamodel.Module
import sculptormetamodel.Resource

import static org.junit.jupiter.api.Assertions.*;

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@ExtendWith(typeof(InjectionExtension))
@InjectWith(typeof(SculptordslInjectorProvider))
class RestTransformationTest extends XtextTest {

	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app

	@BeforeEach
	def void setupDslModel() {

		// Activate cartridge 'test' with transformation extensions 
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			"generator-tests/transformation/sculptor-generator.properties")

		val injector = ChainOverrideAwareInjector.createInjector(#[typeof(DslTransformation), typeof(Transformation)])
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app

		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)

		val transformation = transformationProvider.get
		app = transformation.modify(app)
	}

	def getDomainModel() {
		testFileNoSerializer("generator-tests/rest/model.btdesign", "generator-tests/rest/model-person.btdesign")
		modelRoot as DslModel
	}

    private def Module restModule() {
        return app.modules.namedElement("rest")
    }

    private def Module personModule() {
        return app.modules.namedElement("person")
    }

    private def Resource personResource() {
        val person = restModule.resources.namedElement("PersonResource")
        assertNotNull(person)
        person
    }

    private def Resource customerResource() {
        val customer = restModule.resources.namedElement("CustomerResource")
        assertNotNull(customer)
        customer
    }

    @Test
	def void assertApplication() {
		assertEquals("ResourceTest", app.getName())
	}

	@Test
	def void assertModules() {
		val modules = app.getModules()
		assertNotNull(modules)
		assertOneAndOnlyOne(modules, "rest", "person")
	}

	@Test
	def void assertRestModule() {
		val module = restModule
		assertOneAndOnlyOne(module.domainObjects, "SomeDto", "Customer")
		assertOneAndOnlyOne(module.services, "CustomerService")
		assertOneAndOnlyOne(module.resources, "PersonResource", "FooBarResource", "CustomerResource")
	}

	@Test
	def void assertDomainModule() {
		val module = personModule
		assertOneAndOnlyOne(module.domainObjects, "Person")
		assertOneAndOnlyOne(module.services, "PersonService")
	}

    @Test
    def void assertPersonCreateForm() {
        val person = personResource()

        val createForm = person.getOperations().namedElement("createForm")
        assertEquals("String", createForm.getType())
        assertEquals(HttpMethod.GET, createForm.getHttpMethod())
        assertEquals("/person/form", createForm.getPath())
        assertEquals("person/create", createForm.getReturnString())
        assertOneAndOnlyOne(createForm.getParameters(), "modelMap")
    }

    @Test
    def void assertPersonUpdateForm() {
        val person = personResource()

        val updateForm = person.getOperations().namedElement("updateForm")
        assertEquals("String", updateForm.getType())
        assertEquals(HttpMethod.GET, updateForm.getHttpMethod())
        assertEquals("/person/{id}/form", updateForm.getPath())
        assertEquals("person/update", updateForm.getReturnString())
        assertOneAndOnlyOne(updateForm.getParameters(), "id", "modelMap")
        assertEquals("java.lang.Exception", updateForm.getThrows())
    }

    @Test
    def void assertPersonFindById() {
        val person = personResource()

        val findById = person.getOperations().namedElement("findById")
        assertEquals(HttpMethod.GET, findById.getHttpMethod())
        assertEquals("/person/{id}", findById.getPath())
        assertEquals("person/show", findById.getReturnString())
        assertOneAndOnlyOne(findById.getParameters(), "modelMap")
        assertEquals("org.sculptor.example.rest.person.exception.PersonNotFoundException", findById.getThrows())
    }

    @Test
    def void assertPersonFindAll() {
        val person = personResource()

        val findAll = person.getOperations().namedElement("findAll")
        // TODO
        // assertEquals("String", findAll.getType())
        assertEquals(HttpMethod.GET, findAll.getHttpMethod())
        assertEquals("/person", findAll.getPath())
        assertEquals("person/showlist", findAll.getReturnString())
        assertOneAndOnlyOne(findAll.getParameters(), "modelMap")
    }

    @Test
    def void assertPersonCreate() {
        val person = personResource()

        val create = person.getOperations().namedElement("create")
        assertEquals(HttpMethod.POST, create.getHttpMethod())
        assertEquals("/person", create.getPath())
        assertEquals("redirect:/rest/person/{id}", create.getReturnString())
        assertOneAndOnlyOne(create.getParameters(), "entity")
        assertOneAndOnlyOne(create.getDelegate().getParameters(), "ctx", "entity")

    }

    @Test
    def void assertPersonUpdate() {
        val person = personResource()

        val update = person.getOperations().namedElement("update")
        assertEquals(HttpMethod.PUT, update.getHttpMethod())
        assertEquals("/person", update.getPath())
        assertEquals("redirect:/rest/person/{id}", update.getReturnString())
    }

    @Test
    def void assertPersonDelete() {
        val person = personResource()

        val delete = person.getOperations().namedElement("delete")
        assertEquals(HttpMethod.DELETE, delete.getHttpMethod())
        assertEquals("/person/{id}", delete.getPath())
        assertEquals("redirect:/rest/person", delete.getReturnString())
        assertEquals("java.lang.Exception", delete.getThrows())
    }

    @Test
    def void assertFooBarResource() {
        val foobar = restModule.resources.namedElement("FooBarResource")
        assertNotNull(foobar)

        val foo = foobar.operations.namedElement("foo")
        assertEquals(HttpMethod.GET, foo.getHttpMethod())
        assertEquals("/fooBar", foo.getPath())

        val bar = foobar.operations.namedElement("bar")
        assertEquals(HttpMethod.POST, bar.getHttpMethod())
        assertEquals("/fooBar/baz", bar.getPath())

        val barPatch = foobar.operations.namedElement("barPatch")
        assertEquals(HttpMethod.PATCH, barPatch.getHttpMethod())
        assertEquals("/fooPatch/baz", barPatch.getPath())
    }

    @Test
    def void assertCustomerScaffold() {
        val customer = customerResource()

        assertOneAndOnlyOne(customer.operations, "createForm", "create", "show", "showAll", "delete")

        val delete = customer.operations.namedElement("delete")
        assertNotNull(delete.getDelegate())
        assertEquals("/customer/{id}", delete.getPath())
        assertEquals("redirect:/rest/customer", delete.getReturnString())

        val createForm = customer.operations.namedElement("createForm")
        assertNull(createForm.getDelegate())
        val save = customer.operations.namedElement("create")
        assertNotNull(save.getDelegate())

        assertTrue(customer.isGapClass())
    }

    @Test
    def void assertXmlRoot() {
        val foobar = restModule.resources.namedElement("FooBarResource")
        val something = foobar.operations.namedElement("something")
        val p = something.parameters.get(0)
        val someDto = p.getDomainObjectType()
        assertEquals("xmlRoot=true", someDto.getHint())
    }

}
