package org.sculptor.generator

import java.io.BufferedReader
import java.io.File
import java.io.FileReader
import java.io.IOException
import java.util.regex.Pattern
import junit.framework.Assert
import org.eclipse.emf.common.util.EList
import sculptormetamodel.NamedElement

/**
 * Extensions used in generator tests
 */
class GeneratorTestExtensions {

	// TODO: Move into helpers?
	def static <T extends NamedElement> namedElement(EList<T> list, String toFindName) {
		list.findFirst[name == toFindName]
	}

	def static void assertContains(String text, String subString) {
		Assert::assertTrue("text does not contain expected substring: " + subString, text.contains(subString));
	}

	/**
      * Assert that the given text contains the regular expression, using multiline matching
      */
	def static void assertMatchesRegexp(String text, String regexp) {
		val p = Pattern::compile(regexp, Pattern::MULTILINE);
		Assert::assertTrue("Text did not contain pattern \"" + regexp + "\"", p.matcher(text).find());
	}

	/**
      * Assert that the given text contains the given text fragments, separated by whitespace (including newline).
      */
	def static void assertContainsConsecutiveFragments(String text, String[] fragments) {
		val sb = new StringBuilder();

		for (String fragment : fragments) {
			sb.append("\\Q" + fragment + "\\E\\s*");
		}
		assertMatchesRegexp(text, sb.toString());
	}

	def static void assertNotContains(String text, String subStr) {
		Assert::assertFalse("Text contained substring \"" + subStr + "\"", text.contains(subStr));
	}

	/**
	 * @return contents of file as a String
	 */
	def static String getText(File textFile) throws IOException {
		val sb = new StringBuffer();
		val in = new BufferedReader(new FileReader(textFile));
		var String str;
		while ((str = in.readLine()) != null) {
			sb.append(str);
		}
		in.close();
		return sb.toString();
	}

}
