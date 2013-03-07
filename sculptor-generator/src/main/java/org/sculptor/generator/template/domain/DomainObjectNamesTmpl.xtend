/*
 * Copyright 2007 The Fornax Project Team, including the original
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

import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Trait

import static org.sculptor.generator.ext.Helper.*
import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.domain.DomainObjectNamesTmpl.*
import static org.sculptor.generator.util.PropertiesBase.*

class DomainObjectNamesTmpl {


def static String propertyNamesInterface(DataTransferObject it) {
	'''
	'''
}
def static String propertyNamesInterface(Trait it) {
	'''
	'''
}

def static String propertyNamesInterface(DomainObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + "Names"), '''
		«javaHeader()»
		package «getDomainPackage()»;

		/**
		 * This generated interface defines constants for all
		 * attributes and associatations in
		 * {@link «getDomainPackage()».«name»}.
		 * <p>
		 * These constants are useful for example when building
		 * criterias.
		 */
		public interface «name»Names {
			«it.attributes.forEach[propertyNameConstant(it)]»
			«it.references.forEach[propertyNameConstant(it)]»
		}
	'''
	)
}

def static String propertyNameConstant(NamedElement it) {
	'''
		public static final String «name.toUpperCase()» = "«name»";
	'''
}

}
