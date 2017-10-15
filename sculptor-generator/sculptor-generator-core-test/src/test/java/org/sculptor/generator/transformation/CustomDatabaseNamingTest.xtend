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
import org.eclipse.xtext.testing.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.dsl.tests.SculptordslInjectorProvider
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
import sculptormetamodel.Module

import static org.junit.Assert.*

import static extension org.sculptor.generator.test.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class CustomDatabaseNamingTest extends XtextTest {

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

		// Need to add rcp nature to add populate method to scaffold operations
		System.setProperty("project.nature", "business-tier, rcp")
		System.setProperty("db.useUnderscoreNaming", "true")
		System.setProperty("db.useIdSuffixInForeigKey", "true")
		System.setProperty("db.useTablePrefixedIdColumn", "true")

		val injector = ChainOverrideAwareInjector.createInjector(
			#[typeof(DslTransformation), typeof(Transformation)])
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
		testFileNoSerializer("generator-tests/library/model.btdesign")
		modelRoot as DslModel
	}

	def Module mediaModule() {
		return app.modules.namedElement("media")
	}

	/**
     * Bidirectional one-to-many
     */
	@Test
	public def void assertReferenceToPhysicalMediaFromLibrary() {
		val library = mediaModule.domainObjects.namedElement("Library")
		val mediaRef = library.references.namedElement("media")
		assertFalse(mediaRef.isInverse)
		assertEquals("LIB_REF", mediaRef.oppositeForeignKeyName)
	}

	/**
     * Bidirectional many-to-one
     */
	@Test
	public def void assertReferenceToLibraryFromPhysicalMedia() {
		val physicalMedia = mediaModule.domainObjects.namedElement("PhysicalMedia")

		val libraryRef = physicalMedia.references.namedElement("library")
		assertFalse(libraryRef.inverse)
		assertEquals("LIB_REF", libraryRef.databaseColumn)
		assertEquals("LIB_REF", libraryRef.foreignKeyName)
		assertEquals("MEDIA_PHYSICAL_MEDIA_ID", libraryRef.oppositeForeignKeyName)
	}

	/**
     * Bidirectional many-to-many
     */
	@Test
	public def void assertReferenceToMediaFromPhysicalMedia() {
		val physicalMedia = mediaModule.domainObjects.namedElement("PhysicalMedia")
		val mediaRef = physicalMedia.references.namedElement("media")
		assertFalse(mediaRef.inverse)
		assertEquals("PHMED_MED", mediaRef.manyToManyJoinTableName)
		assertEquals("MEDIA_REF", mediaRef.databaseColumn)
		assertEquals("MEDIA_REF", mediaRef.foreignKeyName)
		assertEquals("PHYSICAL_MEDIA_ID", mediaRef.oppositeForeignKeyName)

		val manyToManyObject = mediaRef.createFictiveManyToManyObject
		assertEquals("PHMED_MED", manyToManyObject.databaseTable)
		assertOneAndOnlyOne(manyToManyObject.references, "media", "physicalMedia");
		val manyToManyObjectMediaRef = manyToManyObject.references.namedElement("media")
		assertEquals("MEDIA_REF", manyToManyObjectMediaRef.databaseColumn)
		val manyToManyObjectPhysicalMediaRef = manyToManyObject.references.namedElement("physicalMedia")
		assertEquals("PHYSICAL_MEDIA_ID", manyToManyObjectPhysicalMediaRef.databaseColumn)
	}

	/**
     * Bidirectional many-to-many
     */
	@Test
	public def void assertReferenceToPhysicalMediaFromMedia() {
		val media = mediaModule.domainObjects.namedElement("Media")
		val physicalMediaRef = media.references.namedElement("physicalMedia")
		assertTrue(physicalMediaRef.inverse)
		assertEquals("PHMED_MED", physicalMediaRef.manyToManyJoinTableName)
		assertEquals("PHYSICAL_MEDIA_ID", physicalMediaRef.databaseColumn)
		assertEquals("PHYSICAL_MEDIA_ID", physicalMediaRef.foreignKeyName)
		assertEquals("MEDIA_REF", physicalMediaRef.oppositeForeignKeyName)

		val manyToManyObject = physicalMediaRef.createFictiveManyToManyObject
		assertEquals("PHMED_MED", manyToManyObject.databaseTable)
		assertOneAndOnlyOne(manyToManyObject.references, "media", "physicalMedia");
		val manyToManyObjectMediaRef = manyToManyObject.references.namedElement("media")
		assertEquals("MEDIA_REF", manyToManyObjectMediaRef.databaseColumn)
		val manyToManyObjectPhysicalMediaRef = manyToManyObject.references.namedElement("physicalMedia")
		assertEquals("PHYSICAL_MEDIA_ID", manyToManyObjectPhysicalMediaRef.databaseColumn)
	}

	/**
     * Unidirectional to-many with join table From obj has customer
     * databaseTable="MEDIA_CHR"
     */
	@Test
	public def void assertReferencePlayedByFromMediaCharacter() {
		val mediaCharacter = mediaModule.domainObjects.namedElement("MediaCharacter")
		val playedByRef = mediaCharacter.references.namedElement("playedBy")
		assertFalse(playedByRef.inverse)
		assertEquals("MEDIA_CHR_PLAYED_BY", playedByRef.manyToManyJoinTableName)
		assertEquals("PLAYED_BY_PERSON_ID", playedByRef.databaseColumn)
		assertEquals("PLAYED_BY_PERSON_ID", playedByRef.foreignKeyName)
		assertEquals("MEDIA_CHR_ID", playedByRef.oppositeForeignKeyName)

		val manyToManyObject = playedByRef.createFictiveManyToManyObject
		assertEquals("MEDIA_CHR_PLAYED_BY", manyToManyObject.databaseTable)
		assertOneAndOnlyOne(manyToManyObject.references, "playedBy", "mediaCharacter")
		val manyToManyObjectPlayedByRef = manyToManyObject.references.namedElement("playedBy")
		assertEquals("PLAYED_BY_PERSON_ID", manyToManyObjectPlayedByRef.databaseColumn)
		val manyToManyObjectMediaCharacterRef = manyToManyObject.references.namedElement("mediaCharacter")
		assertEquals("MEDIA_CHR_ID", manyToManyObjectMediaCharacterRef.databaseColumn)
	}

	@Test
	public def void assertReferenceToPersonFromMediaCharacter() {
		val mediaCharacter = mediaModule.domainObjects.namedElement("MediaCharacter")
		val personsRef = mediaCharacter.references.namedElement("persons")
		assertFalse(personsRef.inverse)
		assertEquals("MEDIA_CHR_PERSON", personsRef.manyToManyJoinTableName)
		assertEquals("PERSON_ID", personsRef.databaseColumn)
		assertEquals("PERSON_ID", personsRef.foreignKeyName)
		assertEquals("MEDIA_CHR_ID", personsRef.oppositeForeignKeyName)

		val manyToManyObject = personsRef.createFictiveManyToManyObject
		assertEquals("MEDIA_CHR_PERSON", manyToManyObject.databaseTable)
		assertOneAndOnlyOne(manyToManyObject.references, "person", "mediaCharacter")
		val manyToManyObjectPersonRef = manyToManyObject.references.namedElement("person")
		assertEquals("PERSON_ID", manyToManyObjectPersonRef.databaseColumn)
		val manyToManyObjectMediaCharacterRef = manyToManyObject.references.namedElement("mediaCharacter")
		assertEquals("MEDIA_CHR_ID", manyToManyObjectMediaCharacterRef.databaseColumn)
	}

	/**
     * Unidirectional to-many without join table
     */
	@Test
	public def void assertReferenceToReviewFromMediaCharacter() {
		val mediaCharacter = mediaModule.domainObjects.namedElement("MediaCharacter")
		val reviewsRef = mediaCharacter.references.namedElement("reviews")
		assertTrue(reviewsRef.inverse)
		assertEquals("MEDIA_CHR_ID", reviewsRef.databaseColumn)
		assertEquals("MEDIA_CHR_ID", reviewsRef.oppositeForeignKeyName)
	}

	/**
     * Unidirectional to-many without join table, custom databaseColumn name.
     * List collection.
     */
	@Test
	public def void assertReferenceToCommentFromMediaCharacter() {
		val mediaCharacter = mediaModule.domainObjects.namedElement("MediaCharacter")
		val commentsRef = mediaCharacter.references.namedElement("comments")
		assertTrue(commentsRef.inverse)
		assertEquals("COMMENT_OF_CHARACTER", commentsRef.databaseColumn)
		assertEquals("COMMENT_OF_CHARACTER", commentsRef.oppositeForeignKeyName)
		assertEquals("COMMENT_OF_CHARACTER", commentsRef.databaseName)
		assertEquals("COMMENTS_INDEX", commentsRef.listIndexColumnName)
	}

}
