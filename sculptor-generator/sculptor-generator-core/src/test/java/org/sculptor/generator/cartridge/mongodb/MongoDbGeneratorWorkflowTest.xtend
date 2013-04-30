package org.sculptor.generator.cartridge.mongodb

import org.junit.BeforeClass
import org.junit.Test
import org.sculptor.generator.GeneratorWorkflowTestBase
import org.sculptor.generator.SculptorRunner

import static org.sculptor.generator.GeneratorTestExtensions.*

/**
 * Tests that verify overall generator workflow for projects that have MongoDB cartridge enabled
 */
class MongoDbGeneratorWorkflowTest extends GeneratorWorkflowTestBase {

	new() {
		super("target/xtend-templates/library-mongodb/sculptor")
	}	
	
	@BeforeClass
	def static void setup() {
		runSculptorWorkflow("org/sculptor/generator/cartridge/mongodb/mongodb-generator.properties", "src/test/resources/library-mongodb.btdesign")
	}
	
	
    @Test
    def void assertBookMapper() {
    	
    	val libraryBuilderCode = getFileText("src/generated/java/org/fornax/cartridges/sculptor/examples/library/media/mapper/BookMapper.java");
    	
    	assertContains(libraryBuilderCode, "package org.fornax.cartridges.sculptor.examples.library.media.mapper;");
    	
    	assertContains(libraryBuilderCode, "List<DBObject> engagementsData = new ArrayList<DBObject>();");
    }
}