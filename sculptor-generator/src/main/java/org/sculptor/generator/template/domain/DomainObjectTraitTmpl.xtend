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

class DomainObjectTraitTmpl {

def static String domainObjectSubclass(Trait it) {
	'''
	'''
	fileOutput(javaFileName(getDomainPackage() + "." + name + "Trait"), 'TO_SRC', '''
	«javaHeader()»
	package «getDomainPackage()»;

	«IF formatJavaDoc() == "" »
/**
 * «name» trait
 * @param S self type
 */
	«ELSE »
	«formatJavaDoc()»
	«ENDIF »
	«DomainObjectAnnotationTmpl::domainObjectSubclassAnnotations(it)»
	public «getAbstractLitteral()»class «name»Trait<S ^extends  «getDomainPackage()».«name»> ^extends «name»TraitBase<S> {
	«DomainObjectTmpl::serialVersionUID(it)»
		«it.operations.reject(e | e.^abstract).forEach[traitImplMethod(it)]»
	}
	'''
	)
	'''
	'''
}

def static String domainObjectBase(Trait it) {
	'''
	«traitInterface(it)»
	'''
	fileOutput(javaFileName(getDomainPackage() + "." + name + "TraitBase"), '''
	«javaHeader()»
	package «getDomainPackage()»;

/**
 * @param S self type
 */
	public abstract class «name»TraitBase<S ^extends  «getDomainPackage()».«name»> «getExtendsAndImplementsLitteral()» {
	«DomainObjectTmpl::serialVersionUID(it)»

	«traitBaseSelfMethod(it)»
	«it.operations.reject(op | op.isPublicVisibility()).forEach[traitBaseMethod(it)]»
	«it.operations.filter(e | e.^abstract && e.isPublicVisibility()).forEach[traitBaseDelegateToSelfMethod(it)]»
	«traitBaseHook(it)»
	}
	'''
	)
	'''
	'''
}

def static String traitInterface(Trait it) {
	'''
	'''
	fileOutput(javaFileName(getDomainPackage() + "." + name), '''
	«javaHeader()»
	package «getDomainPackage()»;

	public interface «name» {
	«it.operations.filter(op | op.isPublicVisibility()).forEach[traitInterfaceMethod(it)]»
	«traitInterfaceHook(it)»
	}
	'''
	)
	'''
	'''
}

def static String traitImplMethod(DomainObjectOperation it) {
	'''
	«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[DomainObjectTmpl::methodParameterTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
			}
	'''
}

def static String traitInterfaceMethod(DomainObjectOperation it) {
	'''
		«formatJavaDoc()»
		«getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[DomainObjectTmpl::methodParameterTypeAndName(it)]») « EXPAND ExceptionTmpl::throws»;
	'''
}

def static String delegateToTraitMethod(DomainObjectOperation it) {
	'''
	«formatJavaDoc()»
		«IF isPublicVisibility()»@Override«ENDIF»
	«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ", ".forEach[DomainObjectTmpl::methodParameterTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
			«IF getTypeName() != "void"»return «ENDIF»«getHint("trait").toFirstLower()»Trait.«name»(«FOR p SEPARATOR ", " : parameters»«p.name»«ENDFOR»);
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
			«traitInstanceSelfMethod(it)(inDomainObject)»
			«it.operations.filter(e | e.^abstract && !e.isPublicVisibility()).forEach[traitInstanceMethod(it)(inDomainObject)]»
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
	«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ", ".forEach[DomainObjectTmpl::methodParameterTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
			«IF getTypeName() != "void"»return «ENDIF»«inDomainObject.getDomainPackage()».«inDomainObject.name»«IF inDomainObject.gapClass»Base«ENDIF».this.«name»(
				«FOR p SEPARATOR ", " : parameters»«p.name»«ENDFOR»);
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
		«formatJavaDoc()»
		«getVisibilityLitteral()» abstract «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[DomainObjectTmpl::methodParameterTypeAndName(it)]») « EXPAND ExceptionTmpl::throws»;
	'''
}

def static String traitBaseDelegateToSelfMethod(DomainObjectOperation it) {
	'''
		@Override
	«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ", ".forEach[DomainObjectTmpl::methodParameterTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
			«IF getTypeName() != "void"»return «ENDIF»self().«name»(
				«FOR p SEPARATOR ", " : parameters»«p.name»«ENDFOR»);
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
