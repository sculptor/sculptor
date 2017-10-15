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
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Trait

@ChainOverridable
class DomainObjectTraitTmpl {

	@Inject private var DomainObjectAnnotationTmpl domainObjectAnnotationTmpl
	@Inject private var DomainObjectTmpl domainObjectTmpl
	@Inject private var ExceptionTmpl exceptionTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String domainObjectSubclass(Trait it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + "Trait"), OutputSlot.TO_SRC, '''
		«javaHeader()»
		package «getDomainPackage()»;

/// Sculptor code formatter imports ///

		«IF it.formatJavaDoc() == "" »
			/**
			 * «name» trait
			 * @param S self type
			 */
		«ELSE »
			«it.formatJavaDoc()»
		«ENDIF »
		«domainObjectAnnotationTmpl.domainObjectSubclassAnnotations(it)»
		public «it.getAbstractLitteral()»class «name»Trait<S extends  «getDomainPackage()».«name»> extends «name»TraitBase<S> {
		«domainObjectTmpl.serialVersionUID(it)»
			«it.operations.filter(e | !e.^abstract).map[traitImplMethod(it)].join»
		}
	''')
}

def String domainObjectBase(Trait it) {
	traitInterface(it)
	fileOutput(javaFileName(getDomainPackage() + "." + name + "TraitBase"), OutputSlot.TO_GEN_SRC, '''
		«javaHeader()»
		package «getDomainPackage()»;

/// Sculptor code formatter imports ///

		/**
		 * @param S self type
		 */
		public abstract class «name»TraitBase<S extends  «getDomainPackage()».«name»> «it.getExtendsAndImplementsLitteral()» {
			«domainObjectTmpl.serialVersionUID(it)»
		
			«traitBaseSelfMethod(it)»
			«operations.filter(op | !op.isPublicVisibility()).map[o | traitBaseMethod(o)].join»
			«operations.filter(e | e.^abstract && e.isPublicVisibility()).map[o | traitBaseDelegateToSelfMethod(o)].join»
			«traitBaseHook(it)»
		}
	''')
}

def String traitInterface(Trait it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), OutputSlot.TO_GEN_SRC, '''
		«javaHeader()»
		package «getDomainPackage()»;

/// Sculptor code formatter imports ///

		public interface «name» {
			«operations.filter(op | op.isPublicVisibility()).map[o | traitInterfaceMethod(o)].join»
			«traitInterfaceHook(it)»
		}
	''')
}

def String traitImplMethod(DomainObjectOperation it) {
	'''
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[p | domainObjectTmpl.methodParameterTypeAndName(p)].join(",")») «exceptionTmpl.throwsDecl(it)» {
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
			}
	'''
}

def String traitInterfaceMethod(DomainObjectOperation it) {
	'''
		«it.formatJavaDoc()»
		«it.getTypeName()» «name»(«it.parameters.map[p | domainObjectTmpl.methodParameterTypeAndName(p)].join(",")») «exceptionTmpl.throwsDecl(it)»;
	'''
}

def String delegateToTraitMethod(DomainObjectOperation it) {
	'''
		«it.formatJavaDoc()»
		«IF it.isPublicVisibility()»@Override«ENDIF»
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[p | domainObjectTmpl.methodParameterTypeAndName(p)].join(", ")») «exceptionTmpl.throwsDecl(it)» {
				«IF it.getTypeName() != "void"»return «ENDIF»«it.getHint("trait").toFirstLower()»Trait.«name»(«FOR p : parameters SEPARATOR ", "»«p.name»«ENDFOR»);
		}
	'''
}

def String traitInstance(Trait it, DomainObject inDomainObject) {
	'''
		«IF isJpaAnnotationToBeGenerated() && isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
		private «getDomainPackage()».«name»Trait<«inDomainObject.getDomainPackage()».«inDomainObject.name»> «name.toFirstLower()»Trait = new «getDomainPackage()».«name»Trait<«inDomainObject.getDomainPackage()».«inDomainObject.name»>() {
			«domainObjectTmpl.serialVersionUID(it)»
			«traitInstanceSelfMethod(it, inDomainObject)»
			«it.operations.filter(e | e.^abstract && !e.isPublicVisibility()).map[e | traitInstanceMethod(e, inDomainObject)].join»
		}; 
	'''
}

def String traitInstanceSelfMethod(Trait it, DomainObject inDomainObject) {
	'''
		@Override
		protected «inDomainObject.getDomainPackage()».«inDomainObject.name» self() {
			return «IF inDomainObject.gapClass»(«inDomainObject.getDomainPackage()».«inDomainObject.name»)«ENDIF» «inDomainObject.getDomainPackage()».«inDomainObject.name»«IF inDomainObject.gapClass»Base«ENDIF».this;
		}
	'''
}

def String traitInstanceMethod(DomainObjectOperation it, DomainObject inDomainObject) {
	'''
		@Override
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[e | domainObjectTmpl.methodParameterTypeAndName(e)].join(", ")») «exceptionTmpl.throwsDecl(it)» {
			«IF it.getTypeName() != "void"»return «ENDIF»«inDomainObject.getDomainPackage()».«inDomainObject.name»«IF inDomainObject.gapClass»Base«ENDIF».this.«name»(
			«FOR p : parameters SEPARATOR ", "»«p.name»«ENDFOR»);
		}
	'''
}

def String traitBaseSelfMethod(Trait it) {
	'''
		/**
			* The instance that contains the trait
			*/
		protected abstract S self();
	'''
}

def String traitBaseMethod(DomainObjectOperation it) {
	'''
		«it.formatJavaDoc()»
		«it.getVisibilityLitteral()» abstract «it.getTypeName()» «name»(«it.parameters.map[e | domainObjectTmpl.methodParameterTypeAndName(e)].join(",")») «exceptionTmpl.throwsDecl(it)»;
	'''
}

def String traitBaseDelegateToSelfMethod(DomainObjectOperation it) {
	'''
		@Override
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[e | domainObjectTmpl.methodParameterTypeAndName(e)].join(", ")») «exceptionTmpl.throwsDecl(it)» {
			«IF it.getTypeName() != "void"»return «ENDIF»self().«name»(
				«FOR p : parameters SEPARATOR ", "»«p.name»«ENDFOR»);
		}
	'''
}

/*Extension point to generate more stuff in trait interface.
	User AROUND domainObjectTraitTmplTmpl.traitInterfaceHook FOR Trait
	in SpecialCases.xpt */
def String traitInterfaceHook(Trait it) {
	'''
	'''
}

/*Extension point to generate more stuff in trait abstract base class.
	User AROUND domainObjectTraitTmplTmpl.traitBaseHook FOR Trait
	in SpecialCases.xpt */
def String traitBaseHook(Trait it) {
	'''
	'''
}
}
