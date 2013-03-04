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

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class DomainObjectAttributeTmpl {

def static String attribute(Attribute it) {
	'''
		«attribute(it)(true)»
	'''
}

def static String attribute(Attribute it, boolean annotations) {
	'''
	«IF annotations»
		«DomainObjectAttributeAnnotationTmpl::attributeAnnotations(it)»
	«ENDIF»
		private «IF transient»transient «ENDIF»«getTypeName()» «name»«IF collectionType != null» = new «getImplTypeName()»()«ENDIF»«attributeDefaultValue(it)»;
	'''
}

/*Possibility to overwrite and set custom default initialization for some attributes,
	e.g. using hint. Note that you must include =.
 */
def static String attributeDefaultValue(Attribute it) {
	'''
	'''
}

def static String propertyAccessors(Attribute it) {
	'''
		«propertyGetter(it)»
		«IF name == "id" && getDomainObject().isPersistent()»
			«idPropertySetter(it)»
		«ELSEIF !changeable && getTypeName().isPrimitiveType()»
			«notChangeablePrimitivePropertySetter(it)»
		«ELSEIF !changeable»
			«notChangeablePropertySetter(it)»
		«ELSE»
			«propertySetter(it)»
		«ENDIF»
	'''
}

def static String propertyGetter(Attribute it) {
	'''
	«propertyGetter(it)(true)»
	'''
}

def static String propertyGetter(Attribute it, boolean annotations) {
	'''
		«formatJavaDoc()»
		«IF annotations»
			«DomainObjectAttributeAnnotationTmpl::propertyGetterAnnotations(it)»
		«ENDIF»
		«getVisibilityLitteralGetter()»«getTypeName()» «getGetAccessor()»() {
			«IF isJpaProviderAppEngine() && collectionType != null && getDomainObject().isPersistent() »
			// appengine sometimes stores the collection as null
			if («name» == null) {
			    «name» = new «getImplTypeName()»();
			}
			«ENDIF »
			return «name»;
		};
	'''
}

def static String propertySetter(Attribute it) {
	'''
	«IF isSetterNeeded()»
		«formatJavaDoc()»
		«DomainObjectAttributeAnnotationTmpl::propertySetterAnnotations(it)»
		«getVisibilityLitteralSetter()»void set«name.toFirstUpper()»(«getTypeName()» «name») {
			«IF isFullyAuditable() && !transient»
			receiveInternalAuditHandler().recordChange(«getDomainObject().name»Properties.«name»(), this.«name», «name»);
			«ENDIF»
			this.«name» = «name»;
		};
	«ENDIF»
	'''
}

def static String notChangeablePropertySetter(Attribute it) {
	'''
		«IF isSetterNeeded()»
		«IF notChangeablePropertySetterVisibility() == "private"»
		@SuppressWarnings("unused")
		«ELSE»
		«notChangeablePropertySetterJavaDoc(it) »
		«ENDIF »
		«DomainObjectAttributeAnnotationTmpl::propertySetterAnnotations(it)»
		«notChangeablePropertySetterVisibility()» void set«name.toFirstUpper()»(«getTypeName()» «name») {
			if ((this.«name» != null) && !this.«name».equals(«name»)) {
				throw new IllegalArgumentException("Not allowed to change the «name» property.");
			}
			this.«name» = «name»;
		};
		«ENDIF»
	'''
}

def static String notChangeablePrimitivePropertySetter(Attribute it) {
	'''
	«IF isSetterNeeded()»
		«IF isJpaAnnotationToBeGenerated() && isJpaAnnotationOnFieldToBeGenerated()»
		@javax.persistence.Transient
		«ENDIF»
		private boolean «name»IsSet = false;
	    «IF notChangeablePropertySetterVisibility() == "private"»
	    @SuppressWarnings("unused")
	    «ELSE»
	    «notChangeablePropertySetterJavaDoc(it) »
	    «ENDIF »
	    «DomainObjectAttributeAnnotationTmpl::propertySetterAnnotations(it)»
	    «notChangeablePropertySetterVisibility()» void set«name.toFirstUpper()»(«getTypeName()» «name») {
	        if (this.«name»IsSet && (this.«name» != «name»)) {
	            throw new IllegalArgumentException("Not allowed to change the «name» property.");
	        }
	        this.«name» = «name»;
	        this.«name»IsSet = true;
	    };
		«ENDIF»
	'''
}

def static String notChangeablePropertySetterJavaDoc(Attribute it) {
	'''
		/**
			* This property can't be changed. Use constructor to assign value.
			* However, some tools need setter methods and therefore this method
			* is visible, but the value can't be changed once it is assigned..
			*/
	'''
}

def static String idPropertySetter(Attribute it) {
	'''
		/**
			* The id is not intended to be changed or assigned manually, but
			* for test purpose it is allowed to assign the id.
			*/
		«DomainObjectAttributeAnnotationTmpl::propertySetterAnnotations(it)»
		protected void set«name.toFirstUpper()»(«getTypeName()» «name») {
			if ((this.«name» != null) && !this.«name».equals(«name»)) {
				throw new IllegalArgumentException("Not allowed to change the id property.");
			}
			this.«name» = «name»;
		};
	'''
}

def static String uuidAccessor(DomainObject it) {
	'''
		/**
			* This domain object doesn't have a natural key
			* and this random generated identifier is the
			* unique identifier for this domain object.
			*/
		«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
		«DomainObjectAttributeAnnotationTmpl::jpaAnnotations(it) FOR attributes.selectFirst(e|e.isUuid())»
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
