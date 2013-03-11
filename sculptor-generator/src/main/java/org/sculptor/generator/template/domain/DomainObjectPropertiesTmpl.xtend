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

import sculptormetamodel.BasicType
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.Trait

import static org.sculptor.generator.ext.DbHelper.*
import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.domain.DomainObjectPropertiesTmpl.*
import static org.sculptor.generator.util.PropertiesBase.*

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*

class DomainObjectPropertiesTmpl {


def static String domainObjectProperties(Trait it) {
	'''
	'''
}

def static String domainObjectProperties(DomainObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + "Properties"), 'TO_GEN_SRC', '''
	«javaHeader()»
	package «getDomainPackage()»;

	/**
	 * This generated interface defines property names for all
	 * attributes and associatations in
	 * {@link «getDomainPackage()».«name»}.
	 * <p>
	 * These properties are useful when building
	 * criteria with {@link «fw("accessapi.ConditionalCriteriaBuilder")»},
	 * which can be used with findByCondition Repository operation.
	 */
	public class «name»Properties {

		private «name»Properties() {
		}

		/* note that static methods are not generated in BasicType, since they can't be root of the criteria */
		«IF !(it instanceof BasicType)»
			«sharedInstance(it)»
			«it.getAllAttributes().forEach[a | staticLeafProperty(a, it)]»
			«it.getAllReferences().filter(e|e.isEnumReference() || (nosql() && e.isUnownedReference())).forEach[r | staticLeafProperty(r, it)]»
			«it.getAllReferences().filter[e | !(e.isEnumReference() || (nosql() && e.isUnownedReference()))].forEach[r | staticReferenceProperty(r, it)]»
		«ENDIF»
	
		«domainObjectProperty(it)»
		«domainObjectPropertiesImpl(it)»
	}
	'''
	)
	'''
	'''
}

def static String sharedInstance(DomainObject it) {
	'''
		private static final «name»PropertiesImpl<«getDomainPackage()».«name»> sharedInstance = new «name»PropertiesImpl<«getDomainPackage()».«name»>(«getDomainPackage()».«name».class);
	'''
}

def static String staticLeafProperty(NamedElement it, DomainObject rootType) {
	'''
		public static «fw("domain.Property")»<«rootType.getDomainPackage()».«rootType.name»> «name»() {
			return sharedInstance.«name»();
		}
	'''
}

def static String staticReferenceProperty(Reference it, DomainObject rootType) {
	'''
		public static «to.getDomainPackage()».«to.name»Properties.«to.name»Property<«rootType.getDomainPackage()».«rootType.name»> «name»() {
			return sharedInstance.«name»();
		}
	'''
}

def static String domainObjectProperty(DomainObject it) {
	'''

		/**
		 * This class is used for references to {@link «getDomainPackage()».«name»},
		 * i.e. nested property.
		 */
		public static class «name»Property<T> extends «name»PropertiesImpl<T> implements «fw("domain.Property")»<T> {
			«serialVersionUID(it)»
			public «name»Property(String parentPath, String additionalPath, Class<T> owningClass) {
				super(parentPath, additionalPath, owningClass);
			}
		} 
	'''
}

def static String domainObjectPropertiesImpl(DomainObject it) {
	'''

		protected static class «name»PropertiesImpl<T> extends «fw("domain.PropertiesCollection")» {
			«serialVersionUID(it)»
			Class<T> owningClass;

			«name»PropertiesImpl(Class<T> owningClass) {
				super(null);
				this.owningClass=owningClass;
			}

			«name»PropertiesImpl(String parentPath, String additionalPath, Class<T> owningClass) {
				super(parentPath, additionalPath);
				this.owningClass=owningClass;
			}

			«it.getAllAttributes().forEach[a | leafProperty(a, isEmbeddable(it))]»
			«it.getAllReferences().filter[e|e.isEnumReference() || (nosql() && e.isUnownedReference())].forEach[a | leafProperty(a, isEmbeddable(it))]»
			«it.getAllReferences().filter[e| ! (e.isEnumReference() || (nosql() && e.isUnownedReference()))].forEach[referenceProperty(it)]»
		} 
	'''
}

def static String leafProperty(NamedElement it, boolean isEmbeddable) {
	'''
		public «fw("domain.Property")»<T> «name»() {
			return new «fw("domain.LeafProperty")»<T>(getParentPath(), "«IF nosql()»«getDatabaseName(it)»«ELSE»«name»«ENDIF»", «isEmbeddable», owningClass);
		}
	'''
}

def static String referenceProperty(Reference it) {
	'''
		public «to.getDomainPackage()».«to.name»Properties.«to.name»Property<T> «name»() {
			return new «to.getDomainPackage()».«to.name»Properties.«to.name»Property<T>(getParentPath(), "«IF nosql()»«getDatabaseName(it)»«ELSE»«name»«ENDIF»", owningClass);
		}
	'''
}

def static String serialVersionUID(Object it) {
	'''
		private static final long serialVersionUID = 1L;
	'''
}
}
