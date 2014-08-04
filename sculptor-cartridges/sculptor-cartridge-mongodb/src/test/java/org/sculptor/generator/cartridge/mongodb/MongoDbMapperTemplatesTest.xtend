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
package org.sculptor.generator.cartridge.mongodb

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
class MongoDbMapperTemplatesTest extends XtextTest {

	@Inject
	var GeneratorModelTestFixtures generatorModelTestFixtures

	var MongoDbMapperTmpl mongoDbMapperTmpl

	@Before
	def void setupExtensions() {
		generatorModelTestFixtures.setupInjector(typeof(MongoDbMapperTmpl))
		generatorModelTestFixtures.setupModel("generator-tests/mongodb/model.btdesign", "generator-tests/mongodb/model-person.btdesign")
		
		mongoDbMapperTmpl = generatorModelTestFixtures.getProvidedObject(typeof(MongoDbMapperTmpl))
	}

	@Test
	def void testAppTransformation() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		assertEquals(2, app.modules.size)
	}

	@Test
	def void testToDataInheritedOneManyAssoc() {
		val app = generatorModelTestFixtures.app
		assertNotNull(app)

		val mediaModule = app.modules.namedElement("media")
		assertNotNull(mediaModule)

		val book = mediaModule.domainObjects.namedElement("Book")
		
		val code = mongoDbMapperTmpl.toData(book)
		assertNotNull(code)
		
        code.assertContainsConsecutiveFragments(#[
            "java.util.List<com.mongodb.DBObject> engagementsData = new java.util.ArrayList<com.mongodb.DBObject>();",
            "for (org.sculptor.example.library.media.domain.Engagement each : from.getEngagements()) {",
            "engagementsData.add(org.sculptor.example.library.media.mapper.EngagementMapper.getInstance().toData(each));"
        ])
	}

}