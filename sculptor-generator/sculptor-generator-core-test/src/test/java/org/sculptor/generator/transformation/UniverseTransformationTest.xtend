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
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.Consumer
import sculptormetamodel.Entity
import sculptormetamodel.Module
import sculptormetamodel.Repository
import sculptormetamodel.Service
import sculptormetamodel.ValueObject

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class UniverseTransformationTest extends XtextTest {

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
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app

		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)

		val transformation = transformationProvider.get
		app = transformation.modify(app)
	}

	def getDomainModel() {
		testFileNoSerializer("generator-tests/universe/model.btdesign")
		modelRoot as DslModel
	}

	def Module module() {
		app.modules.namedElement("milkyway")
	}

	@Test
	def void assertApplication() {
		assertEquals("Universe", app.name)
	}

	@Test
	def void assertModules() {
		val modules = app.modules
		assertNotNull(modules)
		assertOneAndOnlyOne(modules, "milkyway")
		assertMilkyWayModule(modules.get(0))
	}

	private def void assertMilkyWayModule(Module module) {

		// domain objects
		assertOneAndOnlyOne(module.domainObjects, "Planet", "Moon", "MoonMessage", "PlanetMessage", "XmlMoon")
		assertPlanet(module.domainObjects.namedElement("Planet") as Entity)
		assertMoon(module.domainObjects.namedElement("Moon") as Entity)
		assertMoonMessage(module.domainObjects.namedElement("MoonMessage") as ValueObject)
		assertPlanetMessage(module.domainObjects.namedElement("PlanetMessage") as ValueObject)
		assertXmlMoon(module.domainObjects.namedElement("XmlMoon") as ValueObject)

		// services
		assertOneAndOnlyOne(module.services, "PlanetService")
		assertPlanetService(module.services.get(0))

		// consumers
		assertOneAndOnlyOne(module.consumers, "PlanetConsumer", "MoonConsumer")
		assertPlanetConsumer(module.consumers.namedElement("PlanetConsumer"))
		assertMoonConsumer(module.consumers.namedElement("MoonConsumer"))
	}

	private def void assertMoonConsumer(Consumer moonConsumer) {
		assertEquals("MoonConsumer", moonConsumer.name)
		assertEquals("MoonMessage", moonConsumer.getMessageRoot().name)
		assertEquals("milkyway", moonConsumer.module.name)
		assertEquals(0, moonConsumer.getOtherDependencies().size)
		assertEquals(1, moonConsumer.repositoryDependencies.size)
		assertEquals("PlanetRepository", moonConsumer.repositoryDependencies.get(0).name)
		assertNull(moonConsumer.channel)
		assertEquals(0, moonConsumer.getServiceDependencies().size)
	}

	private def void assertPlanetConsumer(Consumer planetConsumer) {
		assertEquals("PlanetConsumer", planetConsumer.name)
		assertEquals("PlanetMessage", planetConsumer.getMessageRoot().name)
		assertEquals("milkyway", planetConsumer.module.name)
		assertEquals(0, planetConsumer.getOtherDependencies().size)
		assertEquals(1, planetConsumer.repositoryDependencies.size)
		assertEquals("PlanetRepository", planetConsumer.repositoryDependencies.get(0).name)
		assertNull(planetConsumer.channel)
		assertEquals(0, planetConsumer.getServiceDependencies().size)
	}

	private def void assertPlanetService(Service service) {
		assertEquals("PlanetService", service.name)
		assertEquals("milkyway", service.module.name)
		assertOneAndOnlyOne(service.getOperations(), "sayHello", "findByExample", "getPlanet", "findById", "findAll",
			"save", "delete")
		assertEquals(0, service.getOtherDependencies().size)
		assertEquals(0, service.repositoryDependencies.size)
	}

	private def void assertPlanet(Entity planet) {
		assertEquals("Planet", planet.name)
		assertFalse(planet.isAbstract())
		assertTrue(planet.isAggregateRoot())
		assertEquals(planet, planet.getBelongsToAggregate())
		assertTrue(planet.isAuditable())
		assertFalse(planet.isCache())
		assertTrue(planet.isOptimisticLocking())
		assertEquals("PLANET", planet.getDatabaseTable())
		assertEquals("milkyway", planet.module.name)
		assertNull(planet.getExtends())

		assertOneAndOnlyOne(planet.attributes, "name", "message", "diameter", "population")
		assertOneAndOnlyOne(planet.references, "moons")
		assertPlanetRepository(planet.repository)
		assertAttribute(planet.attributes.namedElement("name"), "String", false, false, false, true)
		assertAttribute(planet.attributes.namedElement("message"), "String", true, false, false, false)
		assertAttribute(planet.attributes.namedElement("diameter"), "Integer", true, true, false, false)
		assertAttribute(planet.attributes.namedElement("population"), "Integer", true, true, false, false)
	}

	private def void assertMoon(Entity moon) {
		assertEquals("Moon", moon.name)
		assertFalse(moon.isAbstract())
		assertFalse(moon.isAggregateRoot())
		val planet = moon.module.domainObjects.namedElement("Planet")
		assertEquals(planet, moon.getBelongsToAggregate())
		assertTrue(moon.isAuditable())
		assertFalse(moon.isCache())
		assertTrue(moon.isOptimisticLocking())
		assertEquals("MOON", moon.getDatabaseTable())
		assertEquals("milkyway", moon.module.name)
		assertNull(moon.getExtends())

		assertOneAndOnlyOne(moon.attributes, "name", "diameter")
		assertOneAndOnlyOne(moon.references, "planet")
		assertAttribute(moon.attributes.namedElement("name"), "String", false, false, false, true)
		assertAttribute(moon.attributes.namedElement("diameter"), "Integer", true, true, false, false)
	}

	private def void assertPlanetMessage(ValueObject planetMessage) {
		assertFalse(planetMessage.isAbstract())
		assertFalse(planetMessage.isCache())
		assertTrue(planetMessage.isImmutable())
		assertTrue(planetMessage.isOptimisticLocking())
		assertFalse(planetMessage.isPersistent())
		assertNull(planetMessage.repository)
		assertOneAndOnlyOne(planetMessage.references, "planets")
	}

	private def void assertMoonMessage(ValueObject moonMessage) {
		assertFalse(moonMessage.isAbstract())
		assertFalse(moonMessage.isCache())
		assertTrue(moonMessage.isImmutable())
		assertTrue(moonMessage.isOptimisticLocking())
		assertFalse(moonMessage.isPersistent())
		assertNull(moonMessage.repository)
		assertOneAndOnlyOne(moonMessage.references, "moons")
	}

	private def void assertXmlMoon(ValueObject xmlMoon) {
		assertOneAndOnlyOne(xmlMoon.attributes, "name", "planetName")
		assertFalse(xmlMoon.isAbstract())
		assertFalse(xmlMoon.isCache())
		assertFalse(xmlMoon.isImmutable())
		assertTrue(xmlMoon.isOptimisticLocking())
		assertFalse(xmlMoon.isPersistent())
		assertEquals(0, xmlMoon.references.size)
		assertNull(xmlMoon.repository)
	}

	private def void assertPlanetRepository(Repository repository) {
		assertOneAndOnlyOne(repository.getOperations(), "findById", "findAll", "delete", "findByExample", "findByKeys",
			"save")
		assertEquals("Planet", repository.getAggregateRoot().name)
		assertEquals("PlanetRepository", repository.name)
		assertEquals(0, repository.getOtherDependencies().size)
		assertEquals(0, repository.repositoryDependencies.size)
	}

	private def void assertAttribute(Attribute attribute, String type, boolean changeable, boolean nullable,
		boolean required, boolean key) {
		assertEquals(type, attribute.getType())
		assertEquals(changeable, attribute.isChangeable())
		assertEquals(nullable, attribute.isNullable())
		assertEquals(required, attribute.isRequired())
		assertEquals(key, attribute.isNaturalKey())
	}

}
