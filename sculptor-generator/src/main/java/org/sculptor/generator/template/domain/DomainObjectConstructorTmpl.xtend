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
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Attribute
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainObject
import sculptormetamodel.Event
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.TypedElement

class DomainObjectConstructorTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def dispatch String parameterTypeAndNameIdReference(NamedElement it) {
	'''«parameterTypeAndName(it)»'''
}

def dispatch String parameterTypeAndNameIdReference(Reference it) {
	'''
		«IF !it.isUnownedReference()»
			«parameterTypeAndName(it)»
		«ELSE»
			«IF many»
				«IF isGenerateParameterName()» @«fw("annotation.Name")»("«name»")«ENDIF» «it.getCollectionInterfaceType()»<«getJavaType("IDTYPE")»> «name»«it.unownedReferenceSuffix()»
			«ELSE»
				«IF isGenerateParameterName()» @«fw("annotation.Name")»("«name»")«ENDIF» «getJavaType("IDTYPE")» «name»«it.unownedReferenceSuffix()»
			«ENDIF»
		«ENDIF»
	'''
}

def dispatch String parameterTypeAndName(NamedElement it) {
	error("DomainObjectConstructorTmpl.parameterTypeAndName wrong element type " + it.^class)
	'''
	'''
}

def dispatch String parameterTypeAndName(TypedElement it) {
	'''«parameterAnnotations(it)» «it.getTypeName()» «name»'''
}

def dispatch String parameterTypeAndName(Reference it) {
	'''«IF many»«
			parameterAnnotations(it)» «it.getCollectionInterfaceType()»<«it.getTypeName()»> «name»«
		ELSE»«
			parameterAnnotations(it)» «it.getTypeName()» «name»«
		ENDIF»'''
}

def String parameterAnnotations(NamedElement it) {
	'''«IF isGenerateParameterName()»@«fw("annotation.Name")»("«name»")«ENDIF»'''
}


def String propertyConstructorBase(DomainObject it) {
	'''
		«IF !getConstructorParameters(it).isEmpty »
			public «name»«IF gapClass»Base«ENDIF»(«it.getConstructorParameters().map[parameterTypeAndName(it)].join(",")») {
				«IF !getConstructorParameters(it).isEmpty »
					super(«getSuperConstructorParameters(it).map[name].join(",")»);
				«ENDIF»
				«val par = it.getConstructorParameters()»
				«par.removeAll(it.getSuperConstructorParameters())»
				«FOR a : par»
					«IF a.validateNotNullInConstructor() »
						«validateNotNull(it, a.name) »
					«ENDIF»
					«IF a instanceof Reference && (a as Reference).many »
						this.«a.name».addAll(«a.name»);
					«ELSEIF a.isUnownedReference() && mongoDb() »
						this.«a.name»«a.unownedReferenceSuffix()» = («a.name» == null ? null : «a.name».getId());
						this.«a.name» = «a.name»;
						this.«a.name»IsLoaded = true;
					«ELSE»
						this.«a.name» = «a.name»;
					«ENDIF»
				«ENDFOR»
			}
		«ENDIF»
	'''
}

def String propertyConstructorBaseIdReferences(DomainObject it) {
	'''
		«IF !it.getConstructorParameters().isEmpty && it.getConstructorParameters().exists(e|e.isUnownedReference()) »
			public «name»«IF gapClass»Base«ENDIF»(«it.getConstructorParameters().map[parameterTypeAndNameIdReference(it)].join(",")») {
				«IF !it.getConstructorParameters().isEmpty »
					super(«FOR a : it.getSuperConstructorParameters() SEPARATOR ","»«a.name»«a.unownedReferenceSuffix()»«ENDFOR»);
				«ENDIF»
				«val par = it.getConstructorParameters()»
				«par.removeAll(it.getSuperConstructorParameters())»
				«FOR a : par»
					«IF a instanceof Reference && (a as Reference).many »
						«IF a.validateNotNullInConstructor() »
							«validateNotNull(it, a.name + a.unownedReferenceSuffix()) »
						«ENDIF»
						this.«a.name»«a.unownedReferenceSuffix()».addAll(«a.name»«a.unownedReferenceSuffix()»);
					«ELSEIF a.isUnownedReference() »
						«IF a.validateNotNullInConstructor() »
							«validateNotNull(it, a.name + a.unownedReferenceSuffix()) »
						«ENDIF»
						this.«a.name»«a.unownedReferenceSuffix()» = «a.name»«a.unownedReferenceSuffix()»;
					«ELSE»
						«IF a.validateNotNullInConstructor() »
							«validateNotNull(it, a.name) »
						«ENDIF»
						this.«a.name» = «a.name»;
					«ENDIF»
				«ENDFOR»
			}
		«ENDIF»
	'''
}

def String propertyConstructorBaseIdReferencesSubclass(DomainObject it) {
	'''
		«IF !it.getConstructorParameters().isEmpty && it.getConstructorParameters().exists(e|e.isUnownedReference()) »
			public «name»(«it.getConstructorParameters().map[parameterTypeAndNameIdReference(it)].join(",")») {
				super(«FOR a : it.getConstructorParameters() SEPARATOR ","»«a.name»«a.unownedReferenceSuffix()»«ENDFOR»);
			}
		«ENDIF»
	'''
}

def dispatch String validateNotNull(DomainObject it, String field) {
	'''
		org.apache.commons.lang.Validate.notNull(«field», "«name».«field» must not be null");
	'''
}

def dispatch String validateNotNull(DataTransferObject it, String field) {
	'''
		if («field» == null) {
			throw new IllegalArgumentException("«name».«field» must not be null");
		}
	'''
}

def String propertyConstructorSubclass(DomainObject it) {
	'''
		«IF !it.getConstructorParameters().isEmpty »
		public «name»(«it.getConstructorParameters().map[parameterTypeAndName(it)].join(",")») {
			super(«FOR a : it.getConstructorParameters() SEPARATOR ","»«a.name»«ENDFOR»);
		}
		«ENDIF»
	'''
}

def dispatch String limitedConstructor(DomainObject it) {
	'''
		«val allParameters = it.getConstructorParameters()»
		«val parameters = it.getLimitedConstructorParameters()»
		«IF !parameters.isEmpty && allParameters.size != parameters.size »
			public «name»(«parameters.map[parameterTypeAndName(it)].join(",")») {
				this(«FOR a : allParameters SEPARATOR ","»«IF parameters.contains(a)»«a.name»«ELSE»null«ENDIF»«ENDFOR»);
			}
		«ENDIF»
	'''
}

def dispatch String limitedConstructor(Event it) {
	'''
	«limitedEventConstructor(it)»
	'''
}

def String limitedEventConstructor(DomainObject it) {
	'''
		«val allParameters = it.getConstructorParameters()»
		«val parameters = it.getLimitedConstructorParameters()»
		«IF !parameters.isEmpty && allParameters.size != parameters.size »
			public «name»(«parameters.map[parameterTypeAndName(it)].join(",")») {
				this(«FOR a : allParameters SEPARATOR ","»«IF parameters.contains(a)»«a.name»«ELSE»null«ENDIF»«ENDFOR»);
			}
		«ENDIF»

		«val parameters2 = it.getLimitedConstructorParameters().filter(e | e.name!="recorded").toList»
		«IF !parameters2.isEmpty && allParameters.size != parameters2.size »
			/**
			 * Current time is used for recorded timestamp
			 */ 
			public «name»(«parameters2.map[parameterTypeAndName(it)].join(",")») {
				this(«FOR a : allParameters SEPARATOR ","»«IF a.name=="recorded"»new <TODO CONV: a.getTypeName()>()«
					ELSEIF parameters2.contains(a)»«a.name»« ELSE»null«ENDIF»«ENDFOR»);
			}
		«ENDIF»
		
	'''
}

def String minimumConstructor(DomainObject it) {
	'''
	«val limitedParameters = it.getLimitedConstructorParameters()»
	«val parameters = it.getMinimumConstructorParameters()»
		«IF !parameters.isEmpty && limitedParameters.size != parameters.size »
		public «name»(«parameters.map[p | parameterTypeAndName(p)].join(",")») {
			this(«FOR a : limitedParameters SEPARATOR ","»«IF parameters.contains(a)»«a.name»«ELSE»null«ENDIF»«ENDFOR»);
		}
		«ENDIF»
	'''
}

def dispatch String factoryMethod(DomainObject it) {
	'''
		«val allParameters = it.getConstructorParameters()»
		«val parameters = it.getLimitedConstructorParameters()»
		«IF !parameters.isEmpty »
			/**
			 * Creates a new «name». Typically used with static import to
			 * achieve fluent interface.
			 */
			public static «name» «name.toFirstLower()»(«parameters.map[parameterTypeAndName(it)].join(",")») {
				return new «name»(«FOR a : allParameters SEPARATOR ","»«IF parameters.contains(a)»«a.name»«ELSE»null«ENDIF»«ENDFOR»);
			}
		«ENDIF»
	'''
}

def dispatch String factoryMethod(Event it) {
	'''
		«eventFactoryMethod(it)»
	'''
}

def String eventFactoryMethod(DomainObject it) {
	'''
		«val allParameters = it.getConstructorParameters()»
		«val parameters = it.getLimitedConstructorParameters().filter(e|e.name!="recorded").toList»
		«IF !parameters.isEmpty »
			/**
			 * Creates a new «name». Typically used with static import to
			 * achieve fluent interface.
			 * Current time is used for recorded timestamp.
			 */
			public static «name» «name.toFirstLower()»(«parameters.map[parameterTypeAndName(it)].join(",")») {
				return new «name»(«FOR a : allParameters SEPARATOR ","»«IF a.name == "recorded"»new <TODO CONV: a.getTypeName()>()«ELSEIF parameters.contains(a)»«a.name»«ELSE»null«ENDIF»«ENDFOR»);
			}
		«ENDIF»
	'''
}

def dispatch String copyModifier(Attribute it, DomainObject target) {
	'''
		/**
		 * Creates a copy of this instance, but with another «name».
		 */
		public «target.name» with«name.toFirstUpper()»(«it.getTypeName()» «name») {
			if («fw("util.EqualsHelper")».equals(«name», «it.getGetAccessor()»())) {
			    return «IF target.gapClass»(«target.name») «ENDIF»this;
			}
			return new «target.name»(«FOR a : target.getConstructorParameters() SEPARATOR ", "»«IF a == it»«it.name»«ELSE»«a.getGetAccessor()»()«ENDIF»«ENDFOR»);
		};
	'''
}

def dispatch String copyModifier(Reference it, DomainObject target) {
	'''
		/**
		 * Creates a copy of this instance, but with another «name».
		 */
		public «target.name» with«name.toFirstUpper()»(«it.getTypeName()» «name») {
			if («fw("util.EqualsHelper")».equals(«name», «it.getGetAccessor()»())) {
			    return «IF target.gapClass»(«target.name») «ENDIF»this;
			}
			return new «target.name»(«FOR a : target.getConstructorParameters() SEPARATOR ", "»«IF a == it»«it.name»«ELSE»«a.getGetAccessor()»()«ENDIF»«ENDFOR»);
		};
	'''
}

def dispatch String abstractCopyModifier(Attribute it) {
	'''
		/**
		 * Creates a copy of this instance, but with another «name».
		 */
		public abstract «it.getDomainObject().name» with«name.toFirstUpper()»(«it.getTypeName()» «name»);
	'''
}

def dispatch String abstractCopyModifier(Reference it) {
	'''
		/**
		 * Creates a copy of this instance, but with another «name».
		 */
		public abstract «from.name» with«name.toFirstUpper()»(«it.getTypeName()» «name»);
	'''
}
}
