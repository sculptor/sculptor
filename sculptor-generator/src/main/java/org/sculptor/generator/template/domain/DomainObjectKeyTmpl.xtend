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

class DomainObjectKeyTmpl {

def static String keyGetter(DomainObject it) {
	'''
		«IF attributes.exists(a | a.isUuid()) »
			/**
				* This method is used by equals and hashCode.
				* @return {{@link #getUuid}
				*/
		«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
			public Object getKey() {
				return getUuid();
			}
		«ELSEIF getNaturalKeyAttributes().isEmpty && getNaturalKeyReferences().isEmpty »
			/*No keys in this class, key implemented by extended class */
		«ELSEIF getNaturalKeyReferences().size == 1 && getAllNaturalKeyReferences().size == 1 && getAllNaturalKeyAttributes().isEmpty »
			/**
				* This method is used by equals and hashCode.
				* @return {@link #get«getNaturalKeyReferences().first().name.toFirstUpper()»}
				*/
		«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
			public Object getKey() {
				return get«getNaturalKeyReferences().first().name.toFirstUpper()»();
			}
		«ELSEIF getNaturalKeyAttributes().size == 1 && getAllNaturalKeyAttributes().size == 1 && getAllNaturalKeyReferences().isEmpty »
			/**
				* This method is used by equals and hashCode.
				* @return {@link #«getGetAccessor(attributes.filter(a | a.naturalKey).get(0))»}
				*/
		«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
			public Object getKey() {
				return «getGetAccessor(attributes.filter(a | a.naturalKey).get(0))»();
			}
		«ELSEIF isDomainObjectCompositeKeyClassToBeGenerated() »
			«compositeKeyGetter(it)»
		«ELSE»
			«compositeKeyEquals(it)»
			«compositeKeyHashCode(it)»
		«ENDIF»
	'''
}

def static String compositeKeyGetter(DomainObject it) {
	'''
			/**
				* This method is used by equals and hashCode.
				* @return {@link #get«name»Key}
				*/
		«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
			public Object getKey() {
				return get«name»Key();
			}
			
			«IF isJpaAnnotationToBeGenerated() && isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
			private transient «name»Key cached«name»Key;

			/**
				* The natural key for the domain object is
				* a composite key consisting of several attributes.
				*/
		«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
			public «name»Key get«name»Key() {
				if (cached«name»Key == null) {
				    cached«name»Key = new «name»Key(«FOR a SEPARATOR "," : getAllNaturalKeys()»«a.getGetAccessor()»()«ENDFOR»);
				}
				return cached«name»Key;
			}
			«compositeKey(it) »
	'''
}

def static String compositeKey(DomainObject it) {
	'''
	«val allKeys = it.getAllNaturalKeys()»

		/**
			* This is the natural key for the domain object.
			* It is a composite key consisting of several
			* attributes.
			*/
		public static class «name»Key {

			«FOR a : getAllNaturalKeyAttributes()»
			«DomainObjectAttributeTmpl::attribute(it)(false) FOR a »
			«ENDFOR»

			«FOR ref : getAllNaturalKeyReferences()»
			«DomainObjectReferenceTmpl::oneReferenceAttribute(it)(false) FOR ref »
			«ENDFOR»

			public «name»Key(«it.allKeys SEPARATOR ",".forEach[DomainObjectConstructorTmpl::parameterTypeAndName(it)]») {
				«FOR a  : allKeys»
				this.«a.name» = «a.name»;
				«ENDFOR»
			}

		/*no annotations for composite key classes */
			«it.getAllNaturalKeyAttributes().forEach[DomainObjectAttributeTmpl::propertyGetter(it)(false)]»
			«it.getAllNaturalKeyReferences().forEach[DomainObjectReferenceTmpl::oneReferenceGetter(it)(false)]»

		«compositeKeyEquals(it)»
			«compositeKeyHashCode(it)»

		}
	'''
}

def static String compositeKeyEquals(DomainObject it) {
	'''
	«val allKeys = it.getAllNaturalKeys()»
	«val className = it.isDomainObjectCompositeKeyClassToBeGenerated() ? name + "Key" : name»
			@Override
			public boolean equals(Object obj) {
				if (this == obj) return true;
				if (!(obj instanceof «className»)) return false;

				«className» other = («className») obj;

				«FOR a  : getAllNaturalKeyAttributes()»
					«IF a.isPrimitive() »
				if («getGetAccessor(a)»() != other.«getGetAccessor(a)»()) return false;
					«ELSE »
				if (!«fw("util.EqualsHelper")».equals(«getGetAccessor(a)»(), other.«getGetAccessor(a)»())) return false;
					«ENDIF »
				«ENDFOR»
				«FOR r  : getAllNaturalKeyReferences()»
				if (!«fw("util.EqualsHelper")».equals(«getGetAccessor(r)»(), other.«getGetAccessor(r)»())) return false;
				«ENDFOR»
				return true;
			}
	'''
}

def static String compositeKeyHashCode(DomainObject it) {
	'''
	«val allKeys = it.getAllNaturalKeys()»
			@Override
			public int hashCode() {
				int result = 17;
				«FOR a  : allKeys»
				result = 37 * result + «fw("util.EqualsHelper")».computeHashCode(«getGetAccessor(a)»());
				«ENDFOR»
				return result;
			}
	'''
}




}
