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
	var GeneratorModelTestFixtures generatorModelTestFixtures;

	var DomainObjectReferenceAnnotationTmpl domainObjectReferenceAnnotationTmpl;
	var DomainObjectReferenceTmpl domainObjectReferenceTmpl;

	@Before
	def void setup() {
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			"generator-tests/dddsample/sculptor-generator.properties")
		generatorModelTestFixtures.setupInjector(typeof(DomainObjectReferenceAnnotationTmpl))
		generatorModelTestFixtures.setupInjector(typeof(DomainObjectReferenceTmpl))
		generatorModelTestFixtures.setupModel("generator-tests/dddsample/model.btdesign")

		domainObjectReferenceAnnotationTmpl = generatorModelTestFixtures.getProvidedObject(
			typeof(DomainObjectReferenceAnnotationTmpl));
		domainObjectReferenceTmpl = generatorModelTestFixtures.getProvidedObject(
			typeof(DomainObjectReferenceTmpl));
	}

	@After
	def void clearSystemProperties() {
		System.clearProperty(ConfigurationProviderModule.PROPERTIES_LOCATION_PROPERTY);
	}

	@Test
	def void testAppTransformation() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		assertEquals(5, app.modules.size)
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

	@Test
	def void assertAllPersonReferences() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val routingModule = app.modules.namedElement("relation")
		assertNotNull(routingModule)
		val person = routingModule.domainObjects.namedElement("Person")
		assertNotNull(person)
//		person.references.forEach[it |
//			System.out.println("-------------------------------------------------------\nPERSON REFS = " + it);
//			System.out.println("CODE:\n" + domainObjectReferenceTmpl.manyReferenceAttribute(it, true));
//		];
		
		// - List<@House> owning <-> owner inverse;
		val owning = person.references.namedElement("owning");
		val owningCode = domainObjectReferenceTmpl.manyReferenceAttribute(owning, true);
		assertContains(owningCode, '@javax.persistence.OneToMany');
		assertContains(owningCode, 'mappedBy="owner"');
		assertContains(owningCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(owningCode, 'owning = new');

		// - Set<@House> related <-> relation inverse;
		val related = person.references.namedElement("related");
		val relCode = domainObjectReferenceTmpl.manyReferenceAttribute(related, true);
		assertContains(relCode, '@javax.persistence.OneToMany');
		assertContains(relCode, 'mappedBy="relation"');
		assertContains(relCode, 'java.util.Set<org.sculptor.dddsample.relation.domain.House>');
		assertContains(relCode, 'related = new');

		// - Bag<@House> other <-> something inverse;
		val other = person.references.namedElement("other");
		val otherCode = domainObjectReferenceTmpl.manyReferenceAttribute(other, true)
		assertContains(otherCode, '@javax.persistence.OneToMany');
		assertContains(otherCode, 'mappedBy="something"')
		assertContains(otherCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(otherCode, 'other = new');

		// - List<@House> owningNoRel inverse;
		val owningNoRel = person.references.namedElement("owningNoRel");
		val owningNoRelCode = domainObjectReferenceTmpl.manyReferenceAttribute(owningNoRel, true);
		assertContains(owningNoRelCode, '@javax.persistence.OneToMany');
		assertContains(owningNoRelCode, '@javax.persistence.JoinColumn');
		assertContains(owningNoRelCode, 'name="PERSON"');
		assertContains(owningNoRelCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(owningNoRelCode, 'name="FK_PERSON_HOUSE"');
		assertContains(owningNoRelCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(owningNoRelCode, 'owningNoRel = new');

		// - Set<@House> relatedNoRel inverse;
		val relatedNoRel = person.references.namedElement("relatedNoRel");
		val relNoRelCode = domainObjectReferenceTmpl.manyReferenceAttribute(relatedNoRel, true);
		assertContains(relNoRelCode, '@javax.persistence.OneToMany');
		assertContains(relNoRelCode, '@javax.persistence.JoinColumn');
		assertContains(relNoRelCode, 'name="PERSON"');
		assertContains(relNoRelCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(relNoRelCode, 'name="FK_PERSON_HOUSE"');
		assertContains(relNoRelCode, 'java.util.Set<org.sculptor.dddsample.relation.domain.House>');
		assertContains(relNoRelCode, 'relatedNoRel = new');

		// - Bag<@House> otherNoRel inverse;
		val otherNoRel = person.references.namedElement("otherNoRel");
		val otherNoRelCode = domainObjectReferenceTmpl.manyReferenceAttribute(otherNoRel, true)
		assertContains(otherNoRelCode, '@javax.persistence.OneToMany');
		assertContains(otherNoRelCode, '@javax.persistence.JoinColumn');
		assertContains(otherNoRelCode, 'name="PERSON"');
		assertContains(otherNoRelCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(otherNoRelCode, 'name="FK_PERSON_HOUSE"');
		assertContains(otherNoRelCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(otherNoRelCode, 'otherNoRel = new');

		// - List<@House> owningN <-> ownerN;
		val owningN = person.references.namedElement("owningN");
		val owningNCode = domainObjectReferenceTmpl.manyReferenceAttribute(owningN, true)
		assertContains(owningNCode, '@javax.persistence.ManyToMany');
		assertContains(owningNCode, 'mappedBy="ownerN"')
		assertContains(owningNCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(owningNCode, 'owningN = new');

		// - Set<@House> relatedN <-> relationN;
		val relatedN = person.references.namedElement("relatedN");
		val relNCode = domainObjectReferenceTmpl.manyReferenceAttribute(relatedN, true)
		assertContains(relNCode, '@javax.persistence.ManyToMany');
		assertContains(relNCode, 'mappedBy="relationN"')
		assertContains(relNCode, 'java.util.Set<org.sculptor.dddsample.relation.domain.House>');
		assertContains(relNCode, 'relatedN = new');

		// - Bag<@House> otherN <-> somethingN;
		val otherN = person.references.namedElement("otherN");
		val otherNCode = domainObjectReferenceTmpl.manyReferenceAttribute(otherN, true)
		assertContains(otherNCode, '@javax.persistence.ManyToMany');
		assertContains(otherNCode, 'mappedBy="somethingN"')
		assertContains(otherNCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(otherNCode, 'otherN = new');

		// - List<@House> owningNoRelN;
		val owningNoRelN = person.references.namedElement("owningNoRelN");
		val owningNoRelNCode = domainObjectReferenceTmpl.manyReferenceAttribute(owningNoRelN, true);
		assertContains(owningNoRelNCode, '@javax.persistence.ManyToMany');
		assertContains(owningNoRelNCode, '@javax.persistence.JoinTable');
		assertContains(owningNoRelNCode, 'name="OWNINGNORELN_PERSON"');
		assertContains(owningNoRelNCode, 'joinColumns=@javax.persistence.JoinColumn');
		assertContains(owningNoRelNCode, 'name="PERSON"');
		assertContains(owningNoRelNCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(owningNoRelNCode, 'name="FK_OWNINGNORELN_PERSON_PERSON"');
		assertContains(owningNoRelNCode, 'inverseJoinColumns=@javax.persistence.JoinColumn');
		assertContains(owningNoRelNCode, 'name="OWNINGNORELN"');
		assertContains(owningNoRelNCode, 'name="FK_OWNINGNORELN_PERSON_OWNINGNORELN"');
		assertContains(owningNoRelNCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(owningNoRelNCode, 'owningNoRelN = new');

		// - Set<@House> relatedNoRelN;
		val relatedNoRelN = person.references.namedElement("relatedNoRelN");
		val relatedNoRelNCode = domainObjectReferenceTmpl.manyReferenceAttribute(relatedNoRelN, true);
		assertContains(relatedNoRelNCode, '@javax.persistence.ManyToMany');
		assertContains(relatedNoRelNCode, '@javax.persistence.JoinTable');
		assertContains(relatedNoRelNCode, 'name="PERSON_RELATEDNORELN"');
		assertContains(relatedNoRelNCode, 'joinColumns=@javax.persistence.JoinColumn');
		assertContains(relatedNoRelNCode, 'name="PERSON"');
		assertContains(relatedNoRelNCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(relatedNoRelNCode, 'name="FK_PERSON_RELATEDNORELN_PERSON"');
		assertContains(relatedNoRelNCode, 'inverseJoinColumns=@javax.persistence.JoinColumn');
		assertContains(relatedNoRelNCode, 'name="RELATEDNORELN"');
		assertContains(relatedNoRelNCode, 'name="FK_PERSON_RELATEDNORELN_RELATEDNORELN"');
		assertContains(relatedNoRelNCode, 'java.util.Set<org.sculptor.dddsample.relation.domain.House>');
		assertContains(relatedNoRelNCode, 'relatedNoRelN = new');

		// - Bag<@House> otherNoRelN;
		val otherNoRelN = person.references.namedElement("otherNoRelN");
		val otherNoRelNCode = domainObjectReferenceTmpl.manyReferenceAttribute(otherNoRelN, true);
		assertContains(otherNoRelNCode, '@javax.persistence.ManyToMany');
		assertContains(otherNoRelNCode, '@javax.persistence.JoinTable');
		assertContains(otherNoRelNCode, 'name="OTHERNORELN_PERSON"');
		assertContains(otherNoRelNCode, 'joinColumns=@javax.persistence.JoinColumn');
		assertContains(otherNoRelNCode, 'name="PERSON"');
		assertContains(otherNoRelNCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(otherNoRelNCode, 'name="FK_OTHERNORELN_PERSON_PERSON"');
		assertContains(otherNoRelNCode, 'inverseJoinColumns=@javax.persistence.JoinColumn');
		assertContains(otherNoRelNCode, 'name="OTHERNORELN",');
		assertContains(otherNoRelNCode, 'name="FK_OTHERNORELN_PERSON_OTHERNORELN"');
		assertContains(otherNoRelNCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(otherNoRelNCode, 'otherNoRelN = new');
	}
}
