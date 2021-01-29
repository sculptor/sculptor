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
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.^extension.ExtendWith;
import org.sculptor.dsl.tests.SculptordslInjectorProvider
import org.sculptor.generator.configuration.Configuration
import org.sculptor.generator.configuration.ConfigurationProviderModule
import org.sculptor.generator.test.GeneratorModelTestFixtures

import static org.junit.jupiter.api.Assertions.*;

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@ExtendWith(typeof(InjectionExtension))
@InjectWith(typeof(SculptordslInjectorProvider))
class DomainObjectReferenceAnnotationTmplDDDSampleTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures;

	var DomainObjectReferenceAnnotationTmpl domainObjectReferenceAnnotationTmpl;
	var DomainObjectReferenceTmpl domainObjectReferenceTmpl;

	@BeforeEach
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

	@AfterEach
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

		// - List<@House> owningUni inverse;
		val owningUni = person.references.namedElement("owningUni");
		val owningUniCode = domainObjectReferenceTmpl.manyReferenceAttribute(owningUni, true);
		assertContains(owningUniCode, '@javax.persistence.OneToMany');
		assertContains(owningUniCode, '@javax.persistence.JoinColumn');
		assertContains(owningUniCode, 'name="PERSON"');
		assertContains(owningUniCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(owningUniCode, 'name="FK_PERSON_HOUSE"');
		assertContains(owningUniCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(owningUniCode, 'owningUni = new');

		// - Set<@House> relatedUni inverse;
		val relatedUni = person.references.namedElement("relatedUni");
		val relUniCode = domainObjectReferenceTmpl.manyReferenceAttribute(relatedUni, true);
		assertContains(relUniCode, '@javax.persistence.OneToMany');
		assertContains(relUniCode, '@javax.persistence.JoinColumn');
		assertContains(relUniCode, 'name="PERSON"');
		assertContains(relUniCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(relUniCode, 'name="FK_PERSON_HOUSE"');
		assertContains(relUniCode, 'java.util.Set<org.sculptor.dddsample.relation.domain.House>');
		assertContains(relUniCode, 'relatedUni = new');

		// - Bag<@House> otherUni inverse;
		val otherUni = person.references.namedElement("otherUni");
		val otherUniCode = domainObjectReferenceTmpl.manyReferenceAttribute(otherUni, true)
		assertContains(otherUniCode, '@javax.persistence.OneToMany');
		assertContains(otherUniCode, '@javax.persistence.JoinColumn');
		assertContains(otherUniCode, 'name="PERSON"');
		assertContains(otherUniCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(otherUniCode, 'name="FK_PERSON_HOUSE"');
		assertContains(otherUniCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(otherUniCode, 'otherUni = new');

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

		// - List<@House> owningUniN;
		val owningUniN = person.references.namedElement("owningUniN");
		val owningUniNCode = domainObjectReferenceTmpl.manyReferenceAttribute(owningUniN, true);
		assertContains(owningUniNCode, '@javax.persistence.ManyToMany');
		assertContains(owningUniNCode, '@javax.persistence.JoinTable');
		assertContains(owningUniNCode, 'name="OWNINGUNIN_PERSON"');
		assertContains(owningUniNCode, 'joinColumns=@javax.persistence.JoinColumn');
		assertContains(owningUniNCode, 'name="PERSON"');
		assertContains(owningUniNCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(owningUniNCode, 'name="FK_OWNINGUNIN_PERSON_PERSON"');
		assertContains(owningUniNCode, 'inverseJoinColumns=@javax.persistence.JoinColumn');
		assertContains(owningUniNCode, 'name="OWNINGUNIN"');
		assertContains(owningUniNCode, 'name="FK_OWNINGUNIN_PERSON_OWNINGUNIN"');
		assertContains(owningUniNCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(owningUniNCode, 'owningUniN = new');

		// - Set<@House> relatedUniN;
		val relatedUniN = person.references.namedElement("relatedUniN");
		val relatedUniNCode = domainObjectReferenceTmpl.manyReferenceAttribute(relatedUniN, true);
		assertContains(relatedUniNCode, '@javax.persistence.ManyToMany');
		assertContains(relatedUniNCode, '@javax.persistence.JoinTable');
		assertContains(relatedUniNCode, 'name="PERSON_RELATEDUNIN"');
		assertContains(relatedUniNCode, 'joinColumns=@javax.persistence.JoinColumn');
		assertContains(relatedUniNCode, 'name="PERSON"');
		assertContains(relatedUniNCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(relatedUniNCode, 'name="FK_PERSON_RELATEDUNIN_PERSON"');
		assertContains(relatedUniNCode, 'inverseJoinColumns=@javax.persistence.JoinColumn');
		assertContains(relatedUniNCode, 'name="RELATEDUNIN"');
		assertContains(relatedUniNCode, 'name="FK_PERSON_RELATEDUNIN_RELATEDUNIN"');
		assertContains(relatedUniNCode, 'java.util.Set<org.sculptor.dddsample.relation.domain.House>');
		assertContains(relatedUniNCode, 'relatedUniN = new');

		// - Bag<@House> otherUniN;
		val otherUniN = person.references.namedElement("otherUniN");
		val otherUniNCode = domainObjectReferenceTmpl.manyReferenceAttribute(otherUniN, true);
		assertContains(otherUniNCode, '@javax.persistence.ManyToMany');
		assertContains(otherUniNCode, '@javax.persistence.JoinTable');
		assertContains(otherUniNCode, 'name="OTHERUNIN_PERSON"');
		assertContains(otherUniNCode, 'joinColumns=@javax.persistence.JoinColumn');
		assertContains(otherUniNCode, 'name="PERSON"');
		assertContains(otherUniNCode, 'foreignKey=@javax.persistence.ForeignKey');
		assertContains(otherUniNCode, 'name="FK_OTHERUNIN_PERSON_PERSON"');
		assertContains(otherUniNCode, 'inverseJoinColumns=@javax.persistence.JoinColumn');
		assertContains(otherUniNCode, 'name="OTHERUNIN",');
		assertContains(otherUniNCode, 'name="FK_OTHERUNIN_PERSON_OTHERUNIN"');
		assertContains(otherUniNCode, 'java.util.List<org.sculptor.dddsample.relation.domain.House>');
		assertContains(otherUniNCode, 'otherUniN = new');
	}
}
