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
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.^extension.ExtendWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.sculptor.dsl.tests.SculptordslInjectorProvider
import org.sculptor.generator.configuration.Configuration
import org.sculptor.generator.configuration.ConfigurationProviderModule
import org.sculptor.generator.test.GeneratorModelTestFixtures

import static org.junit.jupiter.api.Assertions.*;

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@ExtendWith(typeof(InjectionExtension))
@InjectWith(typeof(SculptordslInjectorProvider))
class DomainObjectReferenceAnnotationTmplLibraryTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures

	var DomainObjectReferenceAnnotationTmpl domainObjectReferenceAnnotationTmpl

	@BeforeEach
	def void setup() {
		System.setProperty(Configuration.PROPERTIES_LOCATION_PROPERTY,
			"generator-tests/library/sculptor-generator.properties")
		generatorModelTestFixtures.setupInjector(typeof(DomainObjectReferenceAnnotationTmpl))
		generatorModelTestFixtures.setupModel("generator-tests/library/model.btdesign")

		domainObjectReferenceAnnotationTmpl = generatorModelTestFixtures.getProvidedObject(
			typeof(DomainObjectReferenceAnnotationTmpl))
	}

	@AfterEach
	def void clearSystemProperties() {
		System.clearProperty(ConfigurationProviderModule.PROPERTIES_LOCATION_PROPERTY);
	}

	@Test
	def void testAppTransformation() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		assertEquals(2, app.modules.size)
	}

	@Test
	def void assertOneToManyWithCascadeTypeAllInLibraryBaseForReferenceMedia() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("media")
		assertNotNull(module)

		val library = module.domainObjects.namedElement("Library")
		val media = library.references.namedElement("media")
		assertNotNull(media)

		val code = domainObjectReferenceAnnotationTmpl.oneToManyJpaAnnotation(media)
		assertNotNull(code)
		assertContains(code, '@javax.persistence.OneToMany')
		assertContains(code, 'cascade=javax.persistence.CascadeType.ALL')
		assertContains(code, 'mappedBy="library"')
		assertNotContains(code, '@javax.persistence.JoinColumn')
		assertNotContains(code, '@javax.persistence.ForeignKey')
	}

	@Test
	def void assertManyToOneInEngamentForReferenceMedia() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("media")
		assertNotNull(module)

		val engagement = module.domainObjects.namedElement("Engagement")
		val media = engagement.references.namedElement("media")
		assertNotNull(media)

		val code = domainObjectReferenceAnnotationTmpl.manyToOneJpaAnnotation(media)
		assertNotNull(code)
		assertContains(code, '@javax.persistence.ManyToOne')
		assertContains(code, 'optional=false')
		assertContains(code, '@javax.persistence.JoinColumn')
		assertContains(code, 'name="MEDIA"')
		assertContains(code, 'foreignKey=@javax.persistence.ForeignKey(name="FK_ENGAGEMENT_MEDIA")')
	}

	@Test
	def void assertManyToManyInMediaForReferenceMediaCharacters() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val module = app.modules.namedElement("media")
		assertNotNull(module)

		val media = module.domainObjects.namedElement("Media")
		val mediaCharacters = media.references.namedElement("mediaCharacters")
		assertNotNull(media)

		val code = domainObjectReferenceAnnotationTmpl.manyToManyJpaAnnotation(mediaCharacters)
		assertNotNull(code)
		assertContains(code, '@javax.persistence.ManyToMany')
		assertContains(code, 'cascade=javax.persistence.CascadeType.ALL')
		assertContains(code, '@javax.persistence.JoinTable')
		assertContains(code, 'name="EXISTSINMEDIA_MEDIACHARACTER"')
		assertContains(code, '@javax.persistence.JoinColumn')
		assertContains(code, 'name="EXISTSINMEDIA"')
		assertContains(code, 'foreignKey=@javax.persistence.ForeignKey')
		assertContains(code, 'name="FK_EXISTSINMEDIA_MEDIACHARACTER_EXISTSINMEDIA"')
		assertContains(code, '@javax.persistence.JoinColumn')
		assertContains(code, 'name="MEDIACHARACTER"')
		assertContains(code, 'foreignKey=@javax.persistence.ForeignKey')
		assertContains(code, 'name="FK_EXISTSINMEDIA_MEDIACHARACTER_MEDIACHARACTER"')
	}

}
	