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
import org.sculptor.generator.ext.GeneratorFactoryImpl

import sculptormetamodel.DomainObject

import org.sculptor.generator.ext.Properties


import org.sculptor.generator.ext.Helper
import org.sculptor.generator.util.HelperBase

class DomainObjectKeyTmpl {
	private static val GeneratorFactory GEN_FACTORY = GeneratorFactoryImpl::getInstance()


	extension HelperBase helperBase = GEN_FACTORY.helperBase
	extension Helper helper = GEN_FACTORY.helper
	extension Properties properties = GEN_FACTORY.properties
	private static val DomainObjectAttributeTmpl domainObjectAttributeTmpl = GEN_FACTORY.domainObjectAttributeTmpl
	private static val DomainObjectReferenceTmpl domainObjectReferenceTmpl = GEN_FACTORY.domainObjectReferenceTmpl
	private static val DomainObjectConstructorTmpl domainObjectConstructorTmpl = GEN_FACTORY.domainObjectConstructorTmpl

def String keyGetter(DomainObject it) {
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
		«ELSEIF it.getNaturalKeyAttributes().isEmpty && it.getNaturalKeyReferences().isEmpty »
			/* No keys in this class, key implemented by extended class */
		«ELSEIF it.getNaturalKeyReferences().size == 1 && it.getAllNaturalKeyReferences().size == 1 && it.getAllNaturalKeyAttributes().isEmpty »
			/**
				* This method is used by equals and hashCode.
				* @return {@link #get«it.getNaturalKeyReferences().head.name.toFirstUpper()»}
				*/
			«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
				@javax.persistence.Transient
			«ENDIF»
			public Object getKey() {
				return get«it.getNaturalKeyReferences().head.name.toFirstUpper()»();
			}
		«ELSEIF it.getNaturalKeyAttributes().size == 1 && it.getAllNaturalKeyAttributes().size == 1 && it.getAllNaturalKeyReferences().isEmpty »
			/**
				* This method is used by equals and hashCode.
				* @return {@link #«getGetAccessor(attributes.filter(a | a.naturalKey).head)»}
				*/
			«IF isJpaAnnotationToBeGenerated() && !isJpaAnnotationOnFieldToBeGenerated()»
				@javax.persistence.Transient
			«ENDIF»
			public Object getKey() {
				return «getGetAccessor(attributes.filter(a | a.naturalKey).head)»();
			}
		«ELSEIF isDomainObjectCompositeKeyClassToBeGenerated() »
			«compositeKeyGetter(it)»
		«ELSE»
			«compositeKeyEquals(it)»
			«compositeKeyHashCode(it)»
		«ENDIF»
	'''
}

def String compositeKeyGetter(DomainObject it) {
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
			    cached«name»Key = new «name»Key(«FOR a : it.getAllNaturalKeys() SEPARATOR ","»«a.getGetAccessor()»()«ENDFOR»);
			}
			return cached«name»Key;
		}
		«compositeKey(it) »
	'''
}

def String compositeKey(DomainObject it) {
	val allKeys = it.getAllNaturalKeys()
	'''
		/**
		 * This is the natural key for the domain object.
		 * It is a composite key consisting of several
		 * attributes.
		 */
		public static class «name»Key {

			«FOR a : it.getAllNaturalKeyAttributes()»
				«domainObjectAttributeTmpl.attribute(a, false)»
			«ENDFOR»

			«FOR ref : it.getAllNaturalKeyReferences()»
				«domainObjectReferenceTmpl.oneReferenceAttribute(ref, false)»
			«ENDFOR»

			public «name»Key(«allKeys.map[domainObjectConstructorTmpl.parameterTypeAndName(it)].join(",")») {
				«FOR a  : allKeys»
					this.«a.name» = «a.name»;
				«ENDFOR»
			}

			/* no annotations for composite key classes */
			«it.getAllNaturalKeyAttributes().map[k | domainObjectAttributeTmpl.propertyGetter(k, false)]»
			«it.getAllNaturalKeyReferences().map[k | domainObjectReferenceTmpl.oneReferenceGetter(k, false)]»

			«compositeKeyEquals(it)»
			«compositeKeyHashCode(it)»
		}
	'''
}

def String compositeKeyEquals(DomainObject it) {
	// val allKeys = it.getAllNaturalKeys()
	val className = if (isDomainObjectCompositeKeyClassToBeGenerated()) name + "Key" else name
	'''
		@Override
		public boolean equals(Object obj) {
			if (this == obj) return true;
			if (!(obj instanceof «className»)) return false;

			«className» other = («className») obj;

			«FOR a  : it.getAllNaturalKeyAttributes()»
				«IF a.isPrimitive() »
					if («getGetAccessor(a)»() != other.«getGetAccessor(a)»()) return false;
				«ELSE »
					if (!«fw("util.EqualsHelper")».equals(«getGetAccessor(a)»(), other.«getGetAccessor(a)»())) return false;
				«ENDIF »
			«ENDFOR»
			«FOR r  : it.getAllNaturalKeyReferences()»
				if (!«fw("util.EqualsHelper")».equals(«getGetAccessor(r)»(), other.«getGetAccessor(r)»())) return false;
			«ENDFOR»
			return true;
		}
	'''
}

def String compositeKeyHashCode(DomainObject it) {
	val allKeys = it.getAllNaturalKeys()
	'''
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
