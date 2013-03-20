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

import javax.inject.Inject
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.BasicType
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.Trait

class DomainObjectPropertiesTmpl {

	@Inject extension DbHelper dbHelper
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

def String domainObjectProperties(Trait it) {
	'''
	'''
}

def String domainObjectProperties(DomainObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + "Properties"), OutputSlot::TO_GEN_SRC, '''
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
			«it.getAllAttributes().map[a | staticLeafProperty(a, it)].join()»
			«it.getAllReferences().filter(e|e.isEnumReference() || (nosql() && e.isUnownedReference())).map[r | staticLeafProperty(r, it)].join()»
			«it.getAllReferences().filter[e | !(e.isEnumReference() || (nosql() && e.isUnownedReference()))].map[r | staticReferenceProperty(r, it)].join()»
		«ENDIF»
	
		«domainObjectProperty(it)»
		«domainObjectPropertiesImpl(it)»
	}
	'''
	)
	'''
	'''
}

def String sharedInstance(DomainObject it) {
	'''
		private static final «name»PropertiesImpl<«getDomainPackage()».«name»> sharedInstance = new «name»PropertiesImpl<«getDomainPackage()».«name»>(«getDomainPackage()».«name».class);
	'''
}

def String staticLeafProperty(NamedElement it, DomainObject rootType) {
	'''
		public static «fw("domain.Property")»<«rootType.getDomainPackage()».«rootType.name»> «name»() {
			return sharedInstance.«name»();
		}
	'''
}

def String staticReferenceProperty(Reference it, DomainObject rootType) {
	'''
		public static «to.getDomainPackage()».«to.name»Properties.«to.name»Property<«rootType.getDomainPackage()».«rootType.name»> «name»() {
			return sharedInstance.«name»();
		}
	'''
}

def String domainObjectProperty(DomainObject it) {
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

def String domainObjectPropertiesImpl(DomainObject it) {
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

			«it.getAllAttributes().map[a | leafProperty(a, isEmbeddable(it))].join()»
			«it.getAllReferences().filter[e|e.isEnumReference() || (nosql() && e.isUnownedReference())].map[a | leafProperty(a, isEmbeddable(it))].join()»
			«it.getAllReferences().filter[e| ! (e.isEnumReference() || (nosql() && e.isUnownedReference()))].map[referenceProperty(it)].join()»
		} 
	'''
}

def String leafProperty(NamedElement it, boolean isEmbeddable) {
	'''
		public «fw("domain.Property")»<T> «name»() {
			return new «fw("domain.LeafProperty")»<T>(getParentPath(), "«IF nosql()»«getDatabaseName(it)»«ELSE»«name»«ENDIF»", «isEmbeddable», owningClass);
		}
	'''
}

def String referenceProperty(Reference it) {
	'''
		public «to.getDomainPackage()».«to.name»Properties.«to.name»Property<T> «name»() {
			return new «to.getDomainPackage()».«to.name»Properties.«to.name»Property<T>(getParentPath(), "«IF nosql()»«getDatabaseName(it)»«ELSE»«name»«ENDIF»", owningClass);
		}
	'''
}

def String serialVersionUID(Object it) {
	'''
		private static final long serialVersionUID = 1L;
	'''
}
}
