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

import org.sculptor.generator.template.common.ExceptionTmpl
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Enum
import sculptormetamodel.EnumValue
import sculptormetamodel.Parameter
import sculptormetamodel.Trait

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.HelperBase.*

import static org.sculptor.generator.template.domain.DomainObjectTmpl.*
import static org.sculptor.generator.util.PropertiesBase.*

class DomainObjectTmpl {

def static String domainObject(DomainObject it) {
	'''
	«IF gapClass»
 	   «domainObjectSubclass(it)»
		«ENDIF»
		«domainObjectBase(it)»
		«IF getBooleanProperty("generate.domainObject.conditionalCriteriaProperties")»
			«DomainObjectPropertiesTmpl::domainObjectProperties(it)»
		«ENDIF»
		«IF getBooleanProperty("generate.domainObject.nameConstants")»
			«DomainObjectNamesTmpl::propertyNamesInterface(it)»
		«ENDIF»
	'''
}

def static String domainObjectSubclass(DataTransferObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), 'TO_SRC', '''
	«javaHeader()»
	package «getDomainPackage()»;

	«IF formatJavaDoc(it) == "" »
	/**
	 * Data transfer object for «name». Properties and associations are
	 * implemented in the generated base class {@link «getDomainPackage()».«name»Base}.
	 */
	«ELSE »
	«formatJavaDoc(it)»
	«ENDIF »
	«DomainObjectAnnotationTmpl::domainObjectSubclassAnnotations(it)»
	public «getAbstractLitteral(it)»class «name» ^extends «name»Base {
		«serialVersionUID(it)»
		«IF isJpaProviderDataNucleus() || getLimitedConstructorParameters(it).isEmpty || getMinimumConstructorParameters(it).isEmpty»public«ELSE»protected«ENDIF» «name»() {
		}

		«DomainObjectConstructorTmpl::propertyConstructorSubclass(it)»
		«DomainObjectConstructorTmpl::limitedConstructor(it)»
		«DomainObjectConstructorTmpl::minimumConstructor(it)»

	}
	'''
	)
}



def static String domainObjectSubclass(DomainObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), 'TO_SRC', '''
	«javaHeader()»
	package «getDomainPackage()»;

	«domainObjectSubclassJavaDoc(it)»
	«IF isJpaAnnotationToBeGenerated()»
	«DomainObjectAnnotationTmpl::domainObjectAnnotations(it)»
	«ENDIF»
	«DomainObjectAnnotationTmpl::domainObjectSubclassAnnotations(it)»
	public «getAbstractLitteral(it)»class «name» ^extends «name»Base {
	«serialVersionUID(it)»
		«IF isJpaProviderDataNucleus() || getLimitedConstructorParameters(it).isEmpty»public«ELSE»protected«ENDIF» «name»() {
		}

		«DomainObjectConstructorTmpl::propertyConstructorSubclass(it)»
		«DomainObjectConstructorTmpl::limitedConstructor(it)»
		«IF it.isPersistent() && (isJpaProviderAppEngine() || nosql())»
			«DomainObjectConstructorTmpl::propertyConstructorBaseIdReferencesSubclass(it)»
		«ENDIF»

		«it.operations.filter(e | e.isImplementedInGapClass()).map[o | domainObjectSubclassImplMethod(o)]»
	}

	'''
	)
}

def static String domainObjectSubclass(Trait it) {
	'''
	«DomainObjectTraitTmpl::domainObjectSubclass(it)»
	'''
}

def static String domainObjectSubclassJavaDoc(DomainObject it) {
	'''
	«IF formatJavaDoc(it) == "" »
	/**
	 * «docMetaTypeName(it)» representing «name».
	 * <p>
	 * This class is responsible for the domain object related
	 * business logic for «name». Properties and associations are
	 * implemented in the generated base class {@link «getDomainPackage()».«name»Base}.
	 */
	«ELSE »
	«formatJavaDoc(it)»
	«ENDIF »
	'''
}

def static String domainObjectBase(DomainObject it) {
	val hasUuidAttribute  = it.attributes.exists(a | a.isUuid())

	fileOutput(javaFileName(getDomainPackage() + "." + name + (if (gapClass) "Base" else "")), 'TO_GEN_SRC', '''
	«javaHeader()»
	package «getDomainPackage()»;

	«domainObjectBaseJavaDoc(it)»
	«IF !gapClass && isJpaAnnotationToBeGenerated()»
		«DomainObjectAnnotationTmpl::domainObjectAnnotations(it) »
	«ENDIF»
	«DomainObjectAnnotationTmpl::domainObjectBaseAnnotations(it)»
	public «IF gapClass || ^abstract»abstract «ENDIF»class «name»«IF gapClass»Base«ENDIF» «getExtendsAndImplementsLitteral(it)» {
	«serialVersionUID(it)»
		«it.attributes.forEach[DomainObjectAttributeTmpl::attribute(it)]»

		«it.references.filter(r | !r.many).forEach[DomainObjectReferenceTmpl::oneReferenceAttribute(it)]»
		«it.references.filter(r | r.many).forEach[DomainObjectReferenceTmpl::manyReferenceAttribute(it)]»

		«IF getLimitedConstructorParameters(it).isEmpty»public«ELSE»«it.getDefaultConstructorVisibility()»«ENDIF» «name»«IF gapClass»Base«ENDIF»() {
		}

		«DomainObjectConstructorTmpl::propertyConstructorBase(it)»
		«IF isPersistent(it) && (isJpaProviderAppEngine() || nosql())»
			«DomainObjectConstructorTmpl::propertyConstructorBaseIdReferences(it)»
		«ENDIF»
		«IF !gapClass»
			«DomainObjectConstructorTmpl::limitedConstructor(it)»
		«ENDIF»
		«IF isImmutable(it) && !^abstract»
			«DomainObjectConstructorTmpl::factoryMethod(it)»
		«ENDIF»

		«it.attributes.filter(a | !a.isUuid()) .forEach[DomainObjectAttributeTmpl::propertyAccessors(it)]»
		«IF hasUuidAttribute »
	    «DomainObjectAttributeTmpl::uuidAccessor(it)»
		«ENDIF»

		«it.references.filter(r | !r.many).forEach[DomainObjectReferenceTmpl::oneReferenceAccessors(it)]»
		«it.references.filter(r | r.many).forEach[DomainObjectReferenceTmpl::manyReferenceAccessors(it)]»

		«IF isImmutable(it) && ^abstract»
			«it.attributes.filter[a | !(a.isSystemAttribute())].forEach[DomainObjectConstructorTmpl::abstractCopyModifier(it)]»
			«it.references.filter[r | !(r.many || r.isUnownedReference())].forEach[DomainObjectConstructorTmpl::abstractCopyModifier(it)]»
		«ENDIF»
		«IF isImmutable(it) && !^abstract»
			«it.getAllAttributes().filter[a | !a.isSystemAttribute()].forEach[a | DomainObjectConstructorTmpl::copyModifier(a, it)]»
			«it.getAllReferences().filter[r | !(r.many || r.isUnownedReference())].forEach[a | DomainObjectConstructorTmpl::copyModifier(a, it)]»
		«ENDIF»

		«IF isFullyAuditable() »
			«generateFullAudit(it)»
		«ENDIF»

		«IF isJpaAnnotationToBeGenerated()»
			«prePersist(it)»
		«ENDIF»

		«toStringStyle(it)»
		«acceptToString(it)»
		«DomainObjectKeyTmpl::keyGetter(it)»

		«it.traits.filter(e | !e.operations.isEmpty).forEach[e | DomainObjectTraitTmpl::traitInstance(e, it)]»
		«it.operations.filter(e | !e.^abstract && e.hasHint("trait")).forEach[DomainObjectTraitTmpl::delegateToTraitMethod(it)]»
		«it.operations.filter[e | e.^abstract || !e.hasHint("trait")].forEach[abstractMethod(it)]»

		«domainObjectHook(it)»
	}
	'''
	)
}

def static String domainObjectBase(Trait it) {
	'''
		«DomainObjectTraitTmpl::domainObjectBase(it)»
	'''
}

def static String domainObjectBaseJavaDoc(DomainObject it) {
	'''
	«IF gapClass»
		/**
		 * Generated base class, which implements properties and
		 * associations for the domain object.
		«IF isJpaAnnotationToBeGenerated() »
			 * <p>Make sure that subclass defines the following annotations:
			 * <pre>
			 «DomainObjectAnnotationTmpl::domainObjectAnnotations(it) »
			 * </pre>
		«ENDIF»
		 */
		«IF isJpaAnnotationToBeGenerated() && isPersistent(it)»
		@javax.persistence.MappedSuperclass
		«ENDIF»
		«ELSEIF formatJavaDoc(it) == "" »
		 /**
		 * «docMetaTypeName(it)» representing «name».
		 */
	«ELSE»
		«formatJavaDoc(it)»
	«ENDIF»
	'''
}

def static String domainObjectBase(DataTransferObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + (if (gapClass) "Base" else "")), 'TO_GEN_SRC', '''
	«javaHeader()»
	package «getDomainPackage()»;

	«IF gapClass»
	/**
	 * Generated base class, which implements properties and
	 * associations for the data transfer object.
	 */
	«ELSEIF formatJavaDoc(it) == "" »
	 /**
	 * Data transfer object for «name».
	 */
	«ELSE »
	«formatJavaDoc(it)»
	«ENDIF »
	«DomainObjectAnnotationTmpl::domainObjectBaseAnnotations(it)»
	public «IF gapClass || ^abstract»abstract «ENDIF»class «name»«IF gapClass»Base«ENDIF» «it.getExtendsAndImplementsLitteral()» {
	«serialVersionUID(it)»

			«it.attributes.forEach[DomainObjectAttributeTmpl::attribute(it)]»

		«it.references.filter(r | !r.many).forEach[DomainObjectReferenceTmpl::oneReferenceAttribute(it)]»
		«it.references.filter(r | r.many).forEach[DomainObjectReferenceTmpl::manyReferenceAttribute(it)]»

		«IF getLimitedConstructorParameters(it).isEmpty || getMinimumConstructorParameters(it).isEmpty»public«ELSE»protected«ENDIF» «name»«IF gapClass»Base«ENDIF»() {
		}

		«DomainObjectConstructorTmpl::propertyConstructorBase(it)»
		«IF !gapClass»
			«DomainObjectConstructorTmpl::limitedConstructor(it)»
			«DomainObjectConstructorTmpl::minimumConstructor(it)»
		«ENDIF»
		«IF isImmutable() && !^abstract»
			«DomainObjectConstructorTmpl::factoryMethod(it)»
		«ENDIF»

		«it.attributes .forEach[DomainObjectAttributeTmpl::propertyAccessors(it)]»

		«it.references.filter(r | !r.many).forEach[DomainObjectReferenceTmpl::oneReferenceAccessors(it)]»
		«it.references.filter(r | r.many).forEach[DomainObjectReferenceTmpl::manyReferenceAccessors(it)]»

	«IF ^extends == null»
		«clone(it)»
	«ENDIF»

	«dataTransferObjectHook(it)»
	}
	'''
	)
}

def static String serialVersionUID(DomainObject it) {
	'''
		private static final long serialVersionUID = 1L;
	'''
}

def static String prePersist(DomainObject it) {
	val hasUuidAttribute  = it.attributes.exists(a | a.isUuid())
	'''
		«IF hasUuidAttribute && isJpaAnnotationOnFieldToBeGenerated()»
		@javax.persistence.PrePersist
		protected void prePersist() {
			getUuid();
		}
		«ENDIF»
	'''
}

def static String generateFullAudit(DomainObject it) {
	'''
		@javax.persistence.Transient
		«fw("domain.AuditHandlerImpl")»<«name»> auditHandler = new «fw("domain.AuditHandlerImpl")»<«name»>();

		public «fw("domain.AuditHandler")»<? ^extends «name»> receiveAuditHandler() {
			return auditHandler;
		}

		protected «fw("domain.AuditHandlerImpl")»<? ^extends «name»> receiveInternalAuditHandler() {
			return auditHandler;
		}

		@javax.persistence.PostLoad
		protected void startAuditing() {
			auditHandler.startAuditing();
		}
	'''
}

def static String acceptToString(DomainObject it) {
	'''
		«IF !getBasicTypeReferences(it).isEmpty || !getEnumReferences(it).isEmpty »
			/**
				* This method is used by toString. It specifies what to
				* include in the toString result.
				* @return true if the field is to be included in toString
				*/
			protected boolean acceptToString(java.lang.reflect.Field field) {
				if (super.acceptToString(field)) {
				    return true;
				} else {
				    «FOR r : getBasicTypeReferences(it)»
				    if (field.getName().equals("«r.name»")) {
				        return true;
				    }
				    «ENDFOR»
				    «FOR r : getEnumReferences(it)»
				    if (field.getName().equals("«r.name»")) {
				        return true;
				    }
				    «ENDFOR»
				    return false;
				}
			}
		«ENDIF»
	'''
}

def static String toStringStyle(DomainObject it) {
	'''
	«IF toStringStyle(it) != null»
		protected org.apache.commons.lang.builder.ToStringStyle toStringStyle() {
			return org.apache.commons.lang.builder.ToStringStyle.«it.toStringStyle()»;
		}
	«ENDIF»
	'''
}

def static String domainObject(Enum it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), 'TO_GEN_SRC', '''
		«javaHeader()»
		package «getDomainPackage()»;

		«IF it.formatJavaDoc() == "" »
			 /**
			 * Enum for «name»
			 */
		«ELSE »
			«it.formatJavaDoc()»
		«ENDIF »
		public enum «name» implements java.io.Serializable {
			«it.values.map[v | enumValue(v)].join(",")»;

			«enumIdentifierMap(it)»

			«it.attributes.forEach[DomainObjectAttributeTmpl::attribute(it)]»
			«enumConstructor(it)»
			«enumFromIdentifierMethod(it)»
			«it.attributes.forEach[DomainObjectAttributeTmpl::propertyGetter(it)]»
			«enumNamePropertyGetter(it)»
		}
	'''
	)
}

def static String enumValue(EnumValue it) {
	'''
		«it.formatJavaDoc()»
		«name»«IF !parameters.isEmpty »(«FOR param : parameters SEPARATOR ","»«param.value»«ENDFOR»)«ENDIF»
	'''
}

def static String enumIdentifierMap(Enum it) {
	val identifierAttribute  = it.getIdentifierAttribute()
	'''
		«IF identifierAttribute != null »
			/**
			 */
			private static java.util.Map<«identifierAttribute.getTypeName().getObjectTypeName()», «name»> identifierMap = new java.util.HashMap<«identifierAttribute.getTypeName().getObjectTypeName()», «name»>();
			static {
				for («name» value : «name».values()) {
					identifierMap.put(value.«identifierAttribute.getGetAccessor()»(), value);
				}
			}
		«ENDIF»
	'''
}

def static String enumFromIdentifierMethod(Enum it) {
	val identifierAttribute  = it.getIdentifierAttribute()
	'''
		«IF identifierAttribute != null »
			public static «name» from«identifierAttribute.name.toFirstUpper()»(«identifierAttribute.getTypeName()» «identifierAttribute.name») {
				«name» result = identifierMap.get(«identifierAttribute.name»);
				if (result == null) {
					throw new IllegalArgumentException("No «name» for «identifierAttribute.name»: " + «identifierAttribute.name»);
				}
				return result;
			}

			/* new enum handling */
			public static «name» toEnum(java.lang.Object key) {
				if (!(key instanceof «identifierAttribute.getTypeName().getObjectTypeName()»)) {
					throw new IllegalArgumentException("key is not of type «identifierAttribute.getTypeName().getObjectTypeName()»");
				}
				return from«identifierAttribute.name.toFirstUpper()»((«identifierAttribute.getTypeName().getObjectTypeName()») key);
			}

			public Object toData() {
				return get«identifierAttribute.name.toFirstUpper()»();
			}
		«ENDIF»
	'''
}


def static String enumConstructor(Enum it) {
	'''
		/**
		 */
		private «name»(«it.attributes.map[a | DomainObjectConstructorTmpl::parameterTypeAndName(a)].join(",")») {
			«FOR a : attributes»
				this.«a.name» = «a.name»;
			«ENDFOR»
		}
	'''
}

def static String enumNamePropertyGetter(Enum it) {
	'''
	public String getName() {
		return name();
		}
	'''
}

def static String clone(DomainObject it) {
	'''
		@Override
		public Object clone() {
			try {
				return super.clone();
			} catch (CloneNotSupportedException e) {
				// this shouldn't happen, since we are Cloneable
				throw new InternalError();
			}
		}
	'''
}

def static String domainObjectSubclassImplMethod(DomainObjectOperation it) {
	'''
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[p | methodParameterTypeAndName(p)].join(",")») «ExceptionTmpl::throwsDecl(it)» {
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
			}
	'''
}

def static String abstractMethod(DomainObjectOperation it) {
	'''
		«it.formatJavaDoc()»
		abstract «it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[methodParameterTypeAndName(it)].join(", ")») «ExceptionTmpl::throwsDecl(it)»;
	'''
}

def static String methodParameterTypeAndName(Parameter it) {
	'''
		«it.getTypeName()» «name»
	'''
}

/*Extension point to generate more stuff in DomainObjects.
	Use AROUND DomainObjectTmplTmpl::domainObjectHook FOR DomainObject
	in SpecialCases.xpt */
def static String domainObjectHook(DomainObject it) {
	'''
	'''
}

/*Extension point to generate more stuff in DataTransferObjects
	Use AROUND DomainObjectTmplTmpl::dataTransferObjectHook FOR DataTransferObject
	in SpecialCases.xpt */
def static String dataTransferObjectHook(DataTransferObject it) {
	'''
	'''
}

}
