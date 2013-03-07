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
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Trait

import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.domain.DomainObjectTraitTmpl.*
import static org.sculptor.generator.util.PropertiesBase.*

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*

class DomainObjectTraitTmpl {

def static String domainObjectSubclass(Trait it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name + "Trait"), 'TO_SRC', '''
		«javaHeader()»
		package «getDomainPackage()»;

		«IF it.formatJavaDoc() == "" »
			/**
			 * «name» trait
			 * @param S self type
			 */
		«ELSE »
			«it.formatJavaDoc()»
		«ENDIF »
		«DomainObjectAnnotationTmpl::domainObjectSubclassAnnotations(it)»
		public «it.getAbstractLitteral()»class «name»Trait<S ^extends  «getDomainPackage()».«name»> extends «name»TraitBase<S> {
		«DomainObjectTmpl::serialVersionUID(it)»
			«it.operations.filter(e | !e.^abstract).map[traitImplMethod(it)]»
		}
	''')
}

def static String domainObjectBase(Trait it) {
	traitInterface(it)
	fileOutput(javaFileName(getDomainPackage() + "." + name + "TraitBase"), '''
		«javaHeader()»
		package «getDomainPackage()»;

		/**
		 * @param S self type
		 */
		public abstract class «name»TraitBase<S ^extends  «getDomainPackage()».«name»> «it.getExtendsAndImplementsLitteral()» {
			«DomainObjectTmpl::serialVersionUID(it)»
		
			«traitBaseSelfMethod(it)»
			«operations.filter(op | !op.isPublicVisibility()).map[o | traitBaseMethod(o)]»
			«operations.filter(e | e.^abstract && e.isPublicVisibility()).map[o | traitBaseDelegateToSelfMethod(o)]»
			«traitBaseHook(it)»
		}
	''')
}

def static String traitInterface(Trait it) {
	fileOutput(javaFileName(getDomainPackage() + "." + name), '''
		«javaHeader()»
		package «getDomainPackage()»;

		public interface «name» {
			«operations.filter(op | op.isPublicVisibility()).map[o | traitInterfaceMethod(o)]»
			«traitInterfaceHook(it)»
		}
	''')
}

def static String traitImplMethod(DomainObjectOperation it) {
	'''
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[p | DomainObjectTmpl::methodParameterTypeAndName(p)].join(",")») «ExceptionTmpl::throwsDecl(it)» {
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
			}
	'''
}

def static String traitInterfaceMethod(DomainObjectOperation it) {
	'''
		«it.formatJavaDoc()»
		«it.getTypeName()» «name»(«it.parameters.map[p | DomainObjectTmpl::methodParameterTypeAndName(p)].join(",")») «ExceptionTmpl::throwsDecl(it)»;
	'''
}

def static String delegateToTraitMethod(DomainObjectOperation it) {
	'''
		«it.formatJavaDoc()»
		«IF it.isPublicVisibility()»@Override«ENDIF»
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[p | DomainObjectTmpl::methodParameterTypeAndName(p)].join(", ")») «ExceptionTmpl::throwsDecl(it)» {
				«IF it.getTypeName() != "void"»return «ENDIF»«it.getHint("trait").toFirstLower()»Trait.«name»(«FOR p : parameters SEPARATOR ", "»«p.name»«ENDFOR»);
		}
	'''
}

def static String traitInstance(Trait it, DomainObject inDomainObject) {
	'''
		«IF isJpaAnnotationToBeGenerated() && isJpaAnnotationOnFieldToBeGenerated()»
			@javax.persistence.Transient
		«ENDIF»
		private «getDomainPackage()».«name»Trait<«inDomainObject.getDomainPackage()».«inDomainObject.name»> «name.toFirstLower()»Trait = new «getDomainPackage()».«name»Trait<«inDomainObject.getDomainPackage()».«inDomainObject.name»>() {
			«DomainObjectTmpl::serialVersionUID(it)»
			«traitInstanceSelfMethod(it, inDomainObject)»
			«it.operations.filter(e | e.^abstract && !e.isPublicVisibility()).map[e | traitInstanceMethod(e, inDomainObject)]»
		}; 
	'''
}

def static String traitInstanceSelfMethod(Trait it, DomainObject inDomainObject) {
	'''
		@Override
		protected «inDomainObject.getDomainPackage()».«inDomainObject.name» self() {
			return «IF inDomainObject.gapClass»(«inDomainObject.getDomainPackage()».«inDomainObject.name»)«ENDIF» «inDomainObject.getDomainPackage()».«inDomainObject.name»«IF inDomainObject.gapClass»Base«ENDIF».this;
		}
	'''
}

def static String traitInstanceMethod(DomainObjectOperation it, DomainObject inDomainObject) {
	'''
		@Override
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[e | DomainObjectTmpl::methodParameterTypeAndName(e)].join(", ")») «ExceptionTmpl::throwsDecl(it)» {
			«IF it.getTypeName() != "void"»return «ENDIF»«inDomainObject.getDomainPackage()».«inDomainObject.name»«IF inDomainObject.gapClass»Base«ENDIF».this.«name»(
			«FOR p : parameters SEPARATOR ", "»«p.name»«ENDFOR»);
		}
	'''
}

def static String traitBaseSelfMethod(Trait it) {
	'''
		/**
			* The instance that contains the trait
			*/
		protected abstract S self();
	'''
}

def static String traitBaseMethod(DomainObjectOperation it) {
	'''
		«it.formatJavaDoc()»
		«it.getVisibilityLitteral()» abstract «it.getTypeName()» «name»(«it.parameters.map[e | DomainObjectTmpl::methodParameterTypeAndName(e)].join(",")») «ExceptionTmpl::throwsDecl(it)»;
	'''
}

def static String traitBaseDelegateToSelfMethod(DomainObjectOperation it) {
	'''
		@Override
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[e | DomainObjectTmpl::methodParameterTypeAndName(e)].join(", ")») «ExceptionTmpl::throwsDecl(it)» {
			«IF it.getTypeName() != "void"»return «ENDIF»self().«name»(
				«FOR p : parameters SEPARATOR ", "»«p.name»«ENDFOR»);
		}
	'''
}

/*Extension point to generate more stuff in trait interface.
	User AROUND DomainObjectTraitTmplTmpl::traitInterfaceHook FOR Trait
	in SpecialCases.xpt */
def static String traitInterfaceHook(Trait it) {
	'''
	'''
}

/*Extension point to generate more stuff in trait abstract base class.
	User AROUND DomainObjectTraitTmplTmpl::traitBaseHook FOR Trait
	in SpecialCases.xpt */
def static String traitBaseHook(Trait it) {
	'''
	'''
}
}
