/*
 * Copyright 2019 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.template.domain

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.XtextRunner
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.After
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.tests.SculptordslInjectorProvider
import org.sculptor.generator.configuration.Configuration
import org.sculptor.generator.configuration.ConfigurationProviderModule
import org.sculptor.generator.test.GeneratorModelTestFixtures

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner))
@InjectWith(typeof(SculptordslInjectorProvider))
class DomainObjectReferenceAnnotationTmplDDDSampleTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures

	var DomainObjectReferenceAnnotationTmpl domainObjectReferenceAnnotationTmpl

	@Before
	def void setup() {
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			"generator-tests/dddsample/sculptor-generator.properties")
		generatorModelTestFixtures.setupInjector(typeof(DomainObjectReferenceAnnotationTmpl))
		generatorModelTestFixtures.setupModel("generator-tests/dddsample/model.btdesign")

		domainObjectReferenceAnnotationTmpl = generatorModelTestFixtures.getProvidedObject(
			typeof(DomainObjectReferenceAnnotationTmpl))
	}

	@After
	def void clearSystemProperties() {
		System.clearProperty(ConfigurationProviderModule.PROPERTIES_LOCATION_PROPERTY);
	}

	@Test
	def void testAppTransformation() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		assertEquals(4, app.modules.size)
	}

	@Test
	def void assertOneToManyInIntineraryBaseForReferenceLeg() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("cargo")
		assertNotNull(module)

		val itinerary = module.domainObjects.namedElement("Itinerary")
		val legs = itinerary.references.namedElement("legs")
		assertNotNull(legs)

		val code = domainObjectReferenceAnnotationTmpl.oneToManyJpaAnnotation(legs)
		assertNotNull(code)
		assertContains(code, '@javax.persistence.OneToMany')
		assertContains(code, 'cascade=javax.persistence.CascadeType.ALL')
		assertContains(code, 'orphanRemoval=true')
		assertContains(code, 'fetch=javax.persistence.FetchType.EAGER')
		assertContains(code, '@javax.persistence.JoinColumn')
		assertContains(code, 'name="ITINERARY"')
		assertContains(code, 'foreignKey=@javax.persistence.ForeignKey')
		assertContains(code, 'name="FK_ITINERARY_LEG"')
	}

	@Test
	def void assertManyToOneInLegBaseForReferenceCarrierMovement() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("cargo")
		assertNotNull(module)

		val leg = module.domainObjects.namedElement("Leg")
		val carrierMovement = leg.references.namedElement("carrierMovement")
		assertNotNull(carrierMovement)

		val code = domainObjectReferenceAnnotationTmpl.manyToOneJpaAnnotation(carrierMovement)
		assertNotNull(code)
		assertContains(code, '@javax.persistence.ManyToOne')
		assertContains(code, 'optional=false')
		assertContains(code, 'fetch=javax.persistence.FetchType.EAGER')
		assertContains(code, '@javax.persistence.JoinColumn')
		assertContains(code, 'name="CARRIERMOVEMENT"')
		assertContains(code, 'foreignKey=@javax.persistence.ForeignKey')
		assertContains(code, 'name="FK_LEG_CARRIERMOVEMENT"')
	}

}
