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

import org.sculptor.generator.ext.GeneratorFactory
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Attribute
import sculptormetamodel.DomainObject

import static org.sculptor.generator.template.domain.DomainObjectAttributeTmpl.*

class DomainObjectAttributeTmpl {

	extension HelperBase helperBase = GeneratorFactory::helperBase
	extension Helper helper = GeneratorFactory::helper
	extension Properties properties = GeneratorFactory::properties
	private static val DomainObjectAttributeAnnotationTmpl domainObjectAttributeAnnotationTmpl = GeneratorFactory::domainObjectAttributeAnnotationTmpl

def String attribute(Attribute it) {
	'''
		«attribute(it, true)»
	'''
}

def String attribute(Attribute it, boolean annotations) {
	'''
		«IF annotations»
			«domainObjectAttributeAnnotationTmpl.attributeAnnotations(it)»
		«ENDIF»
		private «IF transient»transient «ENDIF»«it.getTypeName()» «name»«IF collectionType != null» = new «it.getImplTypeName()»()«ENDIF»«attributeDefaultValue(it)»;
	'''
}

/*Possibility to overwrite and set custom default initialization for some attributes,
	e.g. using hint. Note that you must include =.
 */
def String attributeDefaultValue(Attribute it) {
	'''
	'''
}

def String propertyAccessors(Attribute it) {
	'''
		«propertyGetter(it)»
		«IF name == "id" && it.getDomainObject().isPersistent()»
			«idPropertySetter(it)»
		«ELSEIF !changeable && it.getTypeName().isPrimitiveType()»
			«notChangeablePrimitivePropertySetter(it)»
		«ELSEIF !changeable»
			«notChangeablePropertySetter(it)»
		«ELSE»
			«propertySetter(it)»
		«ENDIF»
	'''
}

def String propertyGetter(Attribute it) {
	'''
		«propertyGetter(it, true)»
	'''
}

def String propertyGetter(Attribute it, boolean annotations) {
	'''
		«it.formatJavaDoc()»
		«IF annotations»
			«domainObjectAttributeAnnotationTmpl.propertyGetterAnnotations(it)»
		«ENDIF»
		«it.getVisibilityLitteralGetter()»«it.getTypeName()» «it.getGetAccessor()»() {
			«IF isJpaProviderAppEngine() && collectionType != null && it.getDomainObject().isPersistent() »
				// appengine sometimes stores the collection as null
				if («name» == null) {
				    «name» = new «it.getImplTypeName()»();
				}
			«ENDIF »
			return «name»;
		};
	'''
}

def String propertySetter(Attribute it) {
	'''
		«IF it.isSetterNeeded()»
			«it.formatJavaDoc()»
			«domainObjectAttributeAnnotationTmpl.propertySetterAnnotations(it)»
			«it.getVisibilityLitteralSetter()»void set«name.toFirstUpper()»(«it.getTypeName()» «name») {
				«IF isFullyAuditable() && !transient»
				receiveInternalAuditHandler().recordChange(«it.getDomainObject().name»Properties.«name»(), this.«name», «name»);
				«ENDIF»
				this.«name» = «name»;
			};
		«ENDIF»
	'''
}

def String notChangeablePropertySetter(Attribute it) {
	'''
		«IF it.isSetterNeeded()»
		«IF notChangeablePropertySetterVisibility() == "private"»
		@SuppressWarnings("unused")
		«ELSE»
		«notChangeablePropertySetterJavaDoc(it) »
		«ENDIF »
		«domainObjectAttributeAnnotationTmpl.propertySetterAnnotations(it)»
		«notChangeablePropertySetterVisibility()» void set«name.toFirstUpper()»(«it.getTypeName()» «name») {
			if ((this.«name» != null) && !this.«name».equals(«name»)) {
				throw new IllegalArgumentException("Not allowed to change the «name» property.");
			}
			this.«name» = «name»;
		};
		«ENDIF»
	'''
}

def String notChangeablePrimitivePropertySetter(Attribute it) {
	'''
		«IF it.isSetterNeeded()»
			«IF isJpaAnnotationToBeGenerated() && isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
			«ENDIF»
			private boolean «name»IsSet = false;
			«IF notChangeablePropertySetterVisibility() == "private"»
				@SuppressWarnings("unused")
			«ELSE»
				«notChangeablePropertySetterJavaDoc(it) »
			«ENDIF »
			«domainObjectAttributeAnnotationTmpl.propertySetterAnnotations(it)»
			«notChangeablePropertySetterVisibility()» void set«name.toFirstUpper()»(«it.getTypeName()» «name») {
				if (this.«name»IsSet && (this.«name» != «name»)) {
					throw new IllegalArgumentException("Not allowed to change the «name» property.");
				}
				this.«name» = «name»;
				this.«name»IsSet = true;
			};
		«ENDIF»
	'''
}

def String notChangeablePropertySetterJavaDoc(Attribute it) {
	'''
		/**
			* This property can't be changed. Use constructor to assign value.
			* However, some tools need setter methods and therefore this method
			* is visible, but the value can't be changed once it is assigned..
			*/
	'''
}

def String idPropertySetter(Attribute it) {
	'''
		/**
			* The id is not intended to be changed or assigned manually, but
			* for test purpose it is allowed to assign the id.
			*/
		«domainObjectAttributeAnnotationTmpl.propertySetterAnnotations(it)»
		protected void set«name.toFirstUpper()»(«it.getTypeName()» «name») {
			if ((this.«name» != null) && !this.«name».equals(«name»)) {
				throw new IllegalArgumentException("Not allowed to change the id property.");
			}
			this.«name» = «name»;
		};
	'''
}

def String uuidAccessor(DomainObject it) {
	'''
		/**
		 * This domain object doesn't have a natural key
		 * and this random generated identifier is the
		 * unique identifier for this domain object.
		 */
		«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
			«domainObjectAttributeAnnotationTmpl.jpaAnnotations(attributes.findFirst(e|e.isUuid()))»
		«ENDIF»
		public String getUuid() {
			// lazy init of UUID
			if (uuid == null) {
				uuid = java.util.UUID.randomUUID().toString();
			}
			return uuid;
		}

		«IF !isJpaAnnotationToBeGenerated()»
			@SuppressWarnings("unused")
			private void setUuid(String uuid) {
				this.uuid = uuid;
			}
		«ENDIF»

	'''
}


}
