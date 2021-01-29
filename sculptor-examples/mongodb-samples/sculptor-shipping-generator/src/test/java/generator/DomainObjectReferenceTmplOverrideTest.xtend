package generator

import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;
import org.sculptor.generator.test.GeneratorTestBase

import static org.sculptor.generator.test.GeneratorTestExtensions.*

class DomainObjectReferenceTmplOverrideTest extends GeneratorTestBase {

	static val TEST_NAME = "library"

	new() {
		super(TEST_NAME)
	}

	@BeforeAll
	def static void setup() {
		runGenerator(TEST_NAME)
	}

	@Test
	def void assertOverridenTemplateInMediaBase() {
		val mediaCode = getFileText(TO_GEN_SRC + "/org/sculptor/example/library/media/domain/MediaBase.java");
		assertContains(mediaCode, 'public void addToEngagements(Engagement engagementElement) {');
	}

}
