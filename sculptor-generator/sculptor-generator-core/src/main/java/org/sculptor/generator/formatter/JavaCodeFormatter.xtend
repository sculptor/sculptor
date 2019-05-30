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
package org.sculptor.generator.formatter

import com.google.inject.Inject
import java.util.Properties
import java.util.regex.Pattern
import org.eclipse.jdt.core.ToolFactory
import org.eclipse.jdt.core.formatter.CodeFormatter
import org.eclipse.jface.text.Document
import org.sculptor.generator.configuration.ConfigurationProvider
import org.slf4j.LoggerFactory

/**
 * Uses the JDT {@org.eclipse.jdt.core.formatter.CodeFormatter} to format the generated Java source code.
 * <p>
 * All full qualified Java are replaced (as long as there is
 * no conflict) by their short name and the corresponding import statement is added. 
 * 
 * @see JavaCodeAutoImporter
 */
class JavaCodeFormatter {

	static val LOG = LoggerFactory.getLogger(typeof(JavaCodeFormatter))

	public static val IMPORT_MARKER_PATTERN = "/// Sculptor code formatter imports ///"

	@Inject var ConfigurationProvider configuration
	@Inject var JavaCodeAutoImporter javaCodeAutoImporter

	def format(String path, String code, boolean abortOnError) {

		// As fall-back return the original code
		var formattedCode = code

		// Auto-importing full qualified Java types
		val autoImportedCode = javaCodeAutoImporter.replaceQualifiedTypes(code, Pattern.quote(IMPORT_MARKER_PATTERN))

		// Use Eclipse JDTs code formatter
		val textEdit = getCodeFormatter().format(
			CodeFormatter.K_COMPILATION_UNIT.bitwiseOr(CodeFormatter.F_INCLUDE_COMMENTS), autoImportedCode, 0,
			autoImportedCode.length(), 0, null)
		if (textEdit !== null) {
			val doc = new Document(autoImportedCode)
			try {
				textEdit.apply(doc)
				formattedCode = doc.get()
			} catch (Exception e) {
				LOG.error("Error formating code for '{}'. Using original code from generator", path)
				if (abortOnError) {
					throw new RuntimeException("Invalid generated Java code in '" + path + "'")
				}
			}
		} else {
			LOG.error("Error formating code for '{}'. Using original code from generator", path)
			if (abortOnError) {
				throw new RuntimeException("Invalid generated Java code in '" + path + "'")
			}
		}
		formattedCode
	}

	var CodeFormatter codeFormatter

	private def getCodeFormatter() {
		if (codeFormatter === null) {
			val classLoader = Thread.currentThread().getContextClassLoader() ?: this.^class.getClassLoader()

			// Read default properties
			val props = new Properties()
			LOG.debug("Loading default properties for Java code formatter from file 'default-java-code-formatter.properties'")
			props.load(classLoader.getResourceAsStream("default-java-code-formatter.properties"))

			// Read additional properties
			if (configuration.has("java.code.formatter.props")) {
				val additionalProps = configuration.getString("java.code.formatter.props")
				if (!additionalProps.nullOrEmpty) {
					additionalProps.split("[,; ]").forEach [
						val stream = classLoader.getResourceAsStream(it)
						if (stream !== null) {
							LOG.debug("Loading additional properties for Java code formatter from file '{}'", it)
							props.load(classLoader.getResourceAsStream(it))
						} else {
							LOG.warn("File '{}' with additional properties for Java code formatter not found", it)
						}
					]
				}
			}
			codeFormatter = ToolFactory.createCodeFormatter(props)
		}
		codeFormatter
	}

}
