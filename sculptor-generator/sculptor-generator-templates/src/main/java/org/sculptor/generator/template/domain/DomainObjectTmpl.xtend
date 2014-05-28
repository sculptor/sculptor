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

package org.sculptor.generator.template.domain

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Enum
import sculptormetamodel.EnumValue
import sculptormetamodel.Parameter
import sculptormetamodel.Trait
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class DomainObjectTmpl {

	@Inject private var ExceptionTmpl exceptionTmpl
	@Inject private var DomainObjectPropertiesTmpl domainObjectPropertiesTmpl
	@Inject private var DomainObjectNamesTmpl domainObjectNamesTmpl
	@Inject private var DomainObjectConstructorTmpl domainObjectConstructorTmpl
	@Inject private var DomainObjectAnnotationTmpl domainObjectAnnotationTmpl
	@Inject private var DomainObjectTraitTmpl domainObjectTraitTmpl
	@Inject private var DomainObjectAttributeTmpl domainObjectAttributeTmpl
	@Inject private var DomainObjectReferenceTmpl domainObjectReferenceTmpl
	@Inject private var DomainObjectKeyTmpl domainObjectKeyTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def dispatch String domainObject(DomainObject it) {
	'''
	«IF gapClass»
		«domainObjectSubclass(it)»
	«ENDIF»
	«domainObjectBase(it)»
	«IF getBooleanProperty("generate.domainObject.conditionalCriteriaProperties")»
		«domainObjectPropertiesTmpl.domainObjectProperties(it)»
	«ENDIF»
	«IF getBooleanProperty("generate.domainObject.nameConstants")»
		«domainObjectNamesTmpl.propertyNamesInterface(it)»
	«ENDIF»
	'''
}

def dispatch String domainObjectSubclass(DataTransferObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), OutputSlot::TO_SRC, '''
	«javaHeader()»
	package «getDomainPackage()»;

/// Sculptor code formatter imports ///

	«IF formatJavaDoc(it) == "" »
		/**
		 * Data transfer object for «name». Properties and associations are
		 * implemented in the generated base class {@link «getDomainPackage()».«name»Base}.
		 */
	«ELSE »
		«formatJavaDoc(it)»
	«ENDIF »

	«domainObjectAnnotationTmpl.domainObjectSubclassAnnotations(it)»
	public «getAbstractLitteral(it)»class «name» extends «name»Base {

		«serialVersionUID(it)»

		«IF isJpaProviderDataNucleus() || getLimitedConstructorParameters(it).isEmpty || getMinimumConstructorParameters(it).isEmpty»public«ELSE»protected«ENDIF» «name»() {
		}

		«domainObjectConstructorTmpl.propertyConstructorSubclass(it)»
		«domainObjectConstructorTmpl.limitedConstructor(it)»
		«domainObjectConstructorTmpl.minimumConstructor(it)»
	}
	'''
	)
}



def dispatch String domainObjectSubclass(DomainObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), OutputSlot::TO_SRC, '''
	«javaHeader()»
	package «getDomainPackage()»;

/// Sculptor code formatter imports ///

	«domainObjectSubclassJavaDoc(it)»

	«IF isJpaAnnotationToBeGenerated()»
		«domainObjectAnnotationTmpl.domainObjectAnnotations(it)»
	«ENDIF»
	«domainObjectAnnotationTmpl.domainObjectSubclassAnnotations(it)»
	public «getAbstractLitteral(it)»class «name» extends «name»Base {

		«serialVersionUID(it)»

		«IF isJpaProviderDataNucleus() || getLimitedConstructorParameters(it).isEmpty»public«ELSE»protected«ENDIF» «name»() {
		}

		«domainObjectConstructorTmpl.propertyConstructorSubclass(it)»
		«domainObjectConstructorTmpl.limitedConstructor(it)»
		«IF it.isPersistent() && (isJpaProviderAppEngine() || nosql())»
			«domainObjectConstructorTmpl.propertyConstructorBaseIdReferencesSubclass(it)»
		«ENDIF»

		«it.operations.filter(e | e.isImplementedInGapClass()).map[o | domainObjectSubclassImplMethod(o)].join()»
	}
	'''
	)
}

def dispatch String domainObjectSubclass(Trait it) {
	'''
	«domainObjectTraitTmpl.domainObjectSubclass(it)»
	'''
}

def String domainObjectSubclassJavaDoc(DomainObject it) {
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

def dispatch String domainObjectBase(DomainObject it) {
	val hasUuidAttribute  = it.attributes.exists(a | a.isUuid())

	fileOutput(javaFileName(getDomainPackage() + "." + name + (if (gapClass) "Base" else "")), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «getDomainPackage()»;

/// Sculptor code formatter imports ///

	«domainObjectBaseJavaDoc(it)»

	«IF !gapClass && isJpaAnnotationToBeGenerated()»
		«domainObjectAnnotationTmpl.domainObjectAnnotations(it) »
	«ENDIF»
	«domainObjectAnnotationTmpl.domainObjectBaseAnnotations(it)»
	public «IF gapClass || ^abstract»abstract «ENDIF»class «name»«IF gapClass»Base«ENDIF» «getExtendsAndImplementsLitteral(it)» {

		«serialVersionUID(it)»

		«it.attributes.map[a | domainObjectAttributeTmpl.attribute(a)].join()»

		«it.references.filter(r | !r.many).map[r | domainObjectReferenceTmpl.oneReferenceAttribute(r)].join()»
		«it.references.filter(r | r.many).map[r | domainObjectReferenceTmpl.manyReferenceAttribute(r)].join()»

		«IF getLimitedConstructorParameters(it).isEmpty»public«ELSE»«it.getDefaultConstructorVisibility()»«ENDIF» «name»«IF gapClass»Base«ENDIF»() {
		}

		«domainObjectConstructorTmpl.propertyConstructorBase(it)»
		«IF isPersistent(it) && (isJpaProviderAppEngine() || nosql())»
			«domainObjectConstructorTmpl.propertyConstructorBaseIdReferences(it)»
		«ENDIF»
		«IF !gapClass»
			«domainObjectConstructorTmpl.limitedConstructor(it)»
		«ENDIF»
		«IF isImmutable(it) && !^abstract»
			«domainObjectConstructorTmpl.factoryMethod(it)»
		«ENDIF»

		«it.attributes.filter(a | !a.isUuid()).map[a | domainObjectAttributeTmpl.propertyAccessors(a)].join()»
		«IF hasUuidAttribute »
			«domainObjectAttributeTmpl.uuidAccessor(it)»
		«ENDIF»

		«it.references.filter(r | !r.many).map[r | domainObjectReferenceTmpl.oneReferenceAccessors(r)].join()»
		«it.references.filter(r | r.many).map[r | domainObjectReferenceTmpl.manyReferenceAccessors(r)].join()»

		«IF isImmutable(it) && ^abstract»
			«it.attributes.filter[a | !(a.isSystemAttribute())].map[r | domainObjectConstructorTmpl.abstractCopyModifier(r)].join()»
			«it.references.filter[r | !(r.many || r.isUnownedReference())].map[r | domainObjectConstructorTmpl.abstractCopyModifier(r)].join()»
		«ENDIF»
		«IF isImmutable(it) && !^abstract»
			«it.getAllAttributes().filter[a | !a.isSystemAttribute()].map[a | domainObjectConstructorTmpl.copyModifier(a, it)].join()»
			«it.getAllReferences().filter[r | !(r.many || r.isUnownedReference())].map[a | domainObjectConstructorTmpl.copyModifier(a, it)].join()»
		«ENDIF»

		«IF isFullyAuditable() »
			«generateFullAudit(it)»
		«ENDIF»

		«IF isJpaAnnotationToBeGenerated()»
			«prePersist(it)»
		«ENDIF»

		«toStringStyleMethod(it)»
		«acceptToString(it)»
		«domainObjectKeyTmpl.keyGetter(it)»

		«it.traits.filter(e | !e.operations.isEmpty).map[e | domainObjectTraitTmpl.traitInstance(e, it)].join()»
		«it.operations.filter(e | !e.^abstract && e.hasHint("trait")).map[domainObjectTraitTmpl.delegateToTraitMethod(it)].join()»
		«it.operations.filter[e | e.^abstract || !e.hasHint("trait")].map[abstractMethod(it)].join()»

		«domainObjectHook(it)»
	}
	'''
	)
}

def dispatch String domainObjectBase(Trait it) {
	'''
	«domainObjectTraitTmpl.domainObjectBase(it)»
	'''
}

def String domainObjectBaseJavaDoc(DomainObject it) {
	'''
	«IF gapClass»
		/**
		 * Generated base class, which implements properties and
		 * associations for the domain object.
		«IF isJpaAnnotationToBeGenerated() »
			 * <p>Make sure that subclass defines the following annotations:
			 * <pre>
			«domainObjectAnnotationTmpl.domainObjectAnnotations(it) »
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

def dispatch String domainObjectBase(DataTransferObject it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + (if (gapClass) "Base" else "")), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «getDomainPackage()»;

/// Sculptor code formatter imports ///

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

	«domainObjectAnnotationTmpl.domainObjectBaseAnnotations(it)»
	public «IF gapClass || ^abstract»abstract «ENDIF»class «name»«IF gapClass»Base«ENDIF» «it.getExtendsAndImplementsLitteral()» {
		«serialVersionUID(it)»

		«it.attributes.map[e | domainObjectAttributeTmpl.attribute(e)].join()»

		«it.references.filter(r | !r.many).map[r | domainObjectReferenceTmpl.oneReferenceAttribute(r)].join()»
		«it.references.filter(r | r.many).map[r | domainObjectReferenceTmpl.manyReferenceAttribute(r)].join()»

		«IF getLimitedConstructorParameters(it).isEmpty || getMinimumConstructorParameters(it).isEmpty»public«ELSE»protected«ENDIF» «name»«IF gapClass»Base«ENDIF»() {
		}

		«domainObjectConstructorTmpl.propertyConstructorBase(it)»
		«IF !gapClass»
			«domainObjectConstructorTmpl.limitedConstructor(it)»
			«domainObjectConstructorTmpl.minimumConstructor(it)»
		«ENDIF»
		«IF isImmutable() && !^abstract»
			«domainObjectConstructorTmpl.factoryMethod(it)»
		«ENDIF»

		«it.attributes.map[a | domainObjectAttributeTmpl.propertyAccessors(a)].join()»

		«it.references.filter(r | !r.many).map[r | domainObjectReferenceTmpl.oneReferenceAccessors(r)].join()»
		«it.references.filter(r | r.many).map[r | domainObjectReferenceTmpl.manyReferenceAccessors(r)].join()»

	«IF ^extends == null»
		«clone(it)»
	«ENDIF»

	«dataTransferObjectHook(it)»
	}
	'''
	)
}

def String serialVersionUID(DomainObject it) {
	'''private static final long serialVersionUID = 1L;'''
}

def String prePersist(DomainObject it) {
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

def String generateFullAudit(DomainObject it) {
	'''
	@javax.persistence.Transient
	«fw("domain.AuditHandlerImpl")»<«name»> auditHandler = new «fw("domain.AuditHandlerImpl")»<«name»>();

	public «fw("domain.AuditHandler")»<? extends «name»> receiveAuditHandler() {
		return auditHandler;
	}

	protected «fw("domain.AuditHandlerImpl")»<? extends «name»> receiveInternalAuditHandler() {
		return auditHandler;
	}

	@javax.persistence.PostLoad
	protected void startAuditing() {
		auditHandler.startAuditing();
	}
	'''
}

def String acceptToString(DomainObject it) {
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

def String toStringStyleMethod(DomainObject it) {
	'''
	«IF it.toStringStyle() != null»
		protected org.apache.commons.lang.builder.ToStringStyle toStringStyle() {
			return org.apache.commons.lang.builder.ToStringStyle.«it.toStringStyle()»;
		}
	«ENDIF»
	'''
}

def dispatch String domainObject(Enum it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «getDomainPackage()»;

/// Sculptor code formatter imports ///

	«IF it.formatJavaDoc() == "" »
		/**
		 * Enum for «name»
		 */
	«ELSE »
		«it.formatJavaDoc()»
	«ENDIF »
	public enum «name» implements «getImplementsLitteral» {
		«it.values.map[v | enumValue(v)].join(",")»;

		«enumIdentifierMap(it)»

		«it.attributes.map[domainObjectAttributeTmpl.attribute(it)].join()»
		«enumConstructor(it)»
		«enumFromIdentifierMethod(it)»
		«it.attributes.map[domainObjectAttributeTmpl.propertyGetter(it)].join()»
		«enumNamePropertyGetter(it)»
	}
	'''
	)
}

def String enumValue(EnumValue it) {
	'''
	«it.formatJavaDoc()»
	«name»«IF !parameters.isEmpty »(«FOR param : parameters SEPARATOR ","»«param.value»«ENDFOR»)«ENDIF»
	'''
}

def String enumIdentifierMap(Enum it) {
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

def String enumFromIdentifierMethod(Enum it) {
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

		«/* new enum handling */»
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


def String enumConstructor(Enum it) {
	'''
	/**
	 */
	private «name»(«it.attributes.map[a | domainObjectConstructorTmpl.parameterTypeAndName(a)].join(",")») {
		«FOR a : attributes»
			this.«a.name» = «a.name»;
		«ENDFOR»
	}
	'''
}

def String enumNamePropertyGetter(Enum it) {
	'''
	public String getName() {
		return name();
	}
	'''
}

def String clone(DomainObject it) {
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

def String domainObjectSubclassImplMethod(DomainObjectOperation it) {
	'''
	«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[p | methodParameterTypeAndName(p)].join(",")») «exceptionTmpl.throwsDecl(it)» {
		// TODO Auto-generated method stub
		throw new UnsupportedOperationException("«name» not implemented");
	}
	'''
}

def String abstractMethod(DomainObjectOperation it) {
	'''
	«it.formatJavaDoc()»
	abstract «it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[methodParameterTypeAndName(it)].join(", ")») «exceptionTmpl.throwsDecl(it)»;
	'''
}

def String methodParameterTypeAndName(Parameter it) {
	'''«it.getTypeName()» «name»'''
}

/* Extension point to generate more stuff in DomainObjects.
 * Use Sculptor extension mechanism to use hook.*/
def String domainObjectHook(DomainObject it) {
	''''''
}

/* Extension point to generate more stuff in DataTransferObjects.
 * Use Sculptor extension mechanism to use hook.
 */
def String dataTransferObjectHook(DataTransferObject it) {
	''''''
}

}
