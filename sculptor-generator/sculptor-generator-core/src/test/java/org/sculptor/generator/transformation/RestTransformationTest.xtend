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

import com.google.inject.Guice
import com.google.inject.Injector
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
import org.sculptor.generator.chain.ChainOverrideAwareModule
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import sculptormetamodel.Application
import sculptormetamodel.HttpMethod
import sculptormetamodel.Module
import sculptormetamodel.Resource

import static org.junit.Assert.*

import static extension org.sculptor.generator.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class RestTransformationTest extends XtextTest {
	
	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app

	@Before
	def void setupDslModel() {
		val uniLoadModule = new ChainOverrideAwareModule(#[typeof(DslTransformation), typeof(Transformation)])
		val Injector injector = Guice::createInjector(uniLoadModule)
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app
		
		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)
		
		val transformation = transformationProvider.get
		app = transformation.modify(app)
	}

	def getDomainModel() {
		testFileNoSerializer("generator-tests/rest/model.btdesign")
		val dslModel = modelRoot as DslModel
		
		dslModel
	}

    private def Module module() {
        return app.modules.namedElement("module1")
    }

    private def Resource personResource() {
        val person = module().resources.namedElement("PersonResource")
        assertNotNull(person)
        person
    }

    private def Resource customerResource() {
        val customer = module().resources.namedElement("CustomerResource")
        assertNotNull(customer)
        customer
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
    }

    @Test
    def void assertPersonFindById() {
        val person = personResource()

        val findById = person.getOperations().namedElement("findById")
        assertEquals(HttpMethod.GET, findById.getHttpMethod())
        assertEquals("/person/{id}", findById.getPath())
        assertEquals("person/show", findById.getReturnString())
        assertOneAndOnlyOne(findById.getParameters(), "modelMap")
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
    }

    @Test
    def void assertFooBarResource() {
        val foobar = module().resources.namedElement("FooBarResource")
        assertNotNull(foobar)

        val foo = foobar.operations.namedElement("foo")
        assertEquals(HttpMethod.GET, foo.getHttpMethod())
        assertEquals("/fooBar", foo.getPath())

        val bar = foobar.operations.namedElement("bar")
        assertEquals(HttpMethod.POST, bar.getHttpMethod())
        assertEquals("/fooBar/baz", bar.getPath())

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
        val foobar = module().resources.namedElement("FooBarResource")
        val something = foobar.operations.namedElement("something")
        val p = something.parameters.get(0)
        val someDto = p.getDomainObjectType()
        assertEquals("xmlRoot=true", someDto.getHint())
    }

}