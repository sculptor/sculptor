package org.sculptor.generator

import org.eclipse.xtext.junit4.InjectWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.junit.runner.RunWith
import org.sculptor.dsl.sculptordsl.DslModel
import org.junit.Test
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.sculptor.dsl.sculptordsl.DslApplication
import com.google.inject.Provider
import org.sculptor.generator.transform.DslTransformation
import com.google.inject.Injector
import com.google.inject.Guice
import org.sculptor.generator.transform.DslTransformationModule
import org.sculptor.generator.ext.Helper
import org.eclipse.emf.common.util.URI
import sculptormetamodel.Module
import sculptormetamodel.Application
import org.eclipse.emf.common.util.EList
import sculptormetamodel.NamedElement
import java.util.ArrayList
import org.junit.Ignore
import sculptormetamodel.Entity
import sculptormetamodel.Reference
import sculptormetamodel.Attribute
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.util.DbHelperBase

import static org.junit.Assert.*
import org.sculptor.generator.transform.Transformation
import org.sculptor.generator.ext.Properties

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class LibraryTransformationTest extends XtextTest{
	
	extension Properties properties

	extension Helper helper

	extension DbHelper dbHelper
	
	extension DbHelperBase dbHelperBase
	
	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app
	
	protected static val SYSTEM_ATTRIBUTES = newImmutableSet("id", "uuid", "version",
		"createdBy", "createdDate", "updatedBy", "updatedDate", "lastUpdated", "lastUpdatedBy");
	
	
	@Before
	def void setupDslModel() {
		val Injector injector = Guice::createInjector(new DslTransformationModule)
		properties = injector.getInstance(typeof(Properties))
		helper = injector.getInstance(typeof(Helper))
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

	def  getDomainModel() {
		
		testFileNoSerializer("library.btdesign", "library-person.btdesign")
		val dslModel = modelRoot as DslModel
		
		dslModel
		
        //val URI uri = URI::createURI(resourceRoot + "/" + "library.btdesign");
        //loadModel(resourceSet, uri, getRootObjectType(uri)) as DslModel;
	}
	
	
	def Module personModule() {		
		app.modules.namedElement('person')
    }

	// TODO: Move into helpers?
	def <T extends NamedElement> namedElement(EList<T> list, String toFindName) {
		list.findFirst[name == toFindName]
	}
	
	def Module mediaModule() {		
		app.modules.namedElement('media')
    }
    
    
    @Test
    def void assertApplication() {
        assertEquals("Library", app.getName());
    }



	def <NE extends NamedElement> void assertOneAndOnlyOne(EList<NE> listOfNamedElements, String... expectedNames) {
		val expectedNamesList = expectedNames.toList

		val actualNames = listOfNamedElements.map[ne|ne.name].filter[name | !SYSTEM_ATTRIBUTES.contains(name)].toList
				
		assertTrue("Expected: " + expectedNamesList + ", Actual: " + actualNames, actualNames.containsAll(expectedNamesList))
		assertTrue("Expected: " + expectedNamesList + ", Actual: " + actualNames, expectedNamesList.containsAll(actualNames))
		
	}

	@Test
    def void assertModules() {
        val modules = app.getModules();
        assertNotNull(modules);
        assertOneAndOnlyOne(modules, "media", "person");
    }

    @Test
    def void assertMediaModule() {
        val module = mediaModule;
        assertOneAndOnlyOne(module.domainObjects, "Library", "PhysicalMedia", "Media", "Book", "Movie",
                "Engagement", "MediaCharacter", "Genre", "Review", "Comment");
    }
    
    @Test
    def void assertPersonModule() {
        val module = personModule();
        assertOneAndOnlyOne(module.domainObjects, "Person", "Ssn", "Country", "Gender", "PersonName");
    }

    @Test
    def void assertPerson() {
        val person = personModule.domainObjects.namedElement("Person")
        assertOneAndOnlyOne(person.getAttributes(), "birthDate")
        assertOneAndOnlyOne(person.getReferences(), "ssn", "name", "sex")
        val ssn =  person.references.namedElement("ssn")
        assertTrue(ssn.isNaturalKey())
        val ssnNumber = ssn.to.attributes.namedElement("number")
        assertTrue(ssnNumber.isNaturalKey())
        val ssnCountry = ssn.to.references.namedElement("country")
        assertTrue(ssnCountry.isNaturalKey())
        assertTrue(person.isGapClass())
        assertFalse(ssn.getTo().isGapClass())
    }
    
    /**
     * Bidirectional one-to-many
     */
    @Test
    def void assertReferenceToPhysicalMediaFromLibrary() {
        val library = mediaModule.domainObjects.namedElement("Library")
        val mediaRef = library.references.namedElement("media")
        assertFalse(dbHelperBase.isInverse(mediaRef))
        assertEquals("LIB_REF", mediaRef.oppositeForeignKeyName);
    }


    /**
     * Bidirectional many-to-one
     */
    @Test
    def void assertReferenceToLibraryFromPhysicalMedia() {
        val physicalMedia = mediaModule.domainObjects.namedElement("PhysicalMedia");
        val libraryRef = physicalMedia.references.namedElement("library");
        assertTrue(dbHelperBase.isInverse(libraryRef));
        
        assertEquals("LIB_REF", libraryRef.databaseColumn);
        assertEquals("LIB_REF", libraryRef.foreignKeyName);
        assertEquals("MEDIA", libraryRef.oppositeForeignKeyName);
    }



}