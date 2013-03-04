/*
 * Copyright 2011 The Fornax Project Team, including the original
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

class BuilderTmpl {

def static String builder(DomainObject it) {
	'''
	'''
	fileOutput(javaFileName(getBuilderFqn()), '''
	«javaHeader()»
	package «getBuilderPackage()»;
	«builderBody(it) FOR this»
	'''
	)
	'''
	'''
}

def static String builderBody(DomainObject it) {
	'''

	/**
	  * Builder for «name» class.
	  */
	public class «getBuilderClassName()»  {
	
		«it.getBuilderAttributes().forEach[DomainObjectAttributeTmpl::attribute(it)(false)]»
		
	    «it.this.getBuilderReferences().filter(r| !r.many).forEach[DomainObjectReferenceTmpl::oneReferenceAttribute(it)(false)]»
	    «it.this.getBuilderReferences().filter(r| r.many).forEach[DomainObjectReferenceTmpl::manyReferenceAttribute(it)(false)]»

		/**
		 * Static factory method for «getBuilderClassName()»
		 */
		public static «name»Builder «name.toFirstLower()»() {
			return new «name»Builder();
		}
		 
		public «name»Builder() {
		}
		
		«IF !getBuilderConstructorParameters().isEmpty »
		public «name»Builder(«it.getBuilderConstructorParameters() SEPARATOR ",".forEach[DomainObjectConstructorTmpl::parameterTypeAndName(it)]») {
		
			«FOR p : getBuilderConstructorParameters()»
				«assignAttributeInConstructor(it) FOR p»
			«ENDFOR»
		}
		«ENDIF»
		
		«it.getBuilderAttributes() .forEach[builderAttributeSetter(it)(this)]»
		
		«it.getBuilderReferences().filter(r | !r.many) .forEach[builderSingleReferenceSetter(it)(this)]»
		
		
		«it.getBuilderReferences().filter(r| r.many).forEach[multiReferenceAdd(it)(this)]»
		
		«it.getBuilderAttributes() .forEach[DomainObjectAttributeTmpl::propertyGetter(it)]»

		«it.getBuilderReferences().filter(r| !r.many).forEach[DomainObjectReferenceTmpl::oneReferenceGetter(it)(false)]»
		«it.getBuilderReferences().filter(r| r.many).forEach[DomainObjectReferenceTmpl::manyReferenceGetter(it)(false)]»
		
		/**
		 * @return new «name» instance constructed based on the values that have been set into this builder
		 */
		public «getDomainPackage() + "." + name» build() {
			«getDomainPackage() + "." + name» obj = new «name»(«FOR attr SEPARATOR ", " : getBuilderConstructorParameters()»«attr.getGetAccessor()»()«ENDFOR»);
			«FOR prop : getBuilderAttributes() .addAll(getBuilderReferences().filter(r | !r.many)).removeAll(getBuilderConstructorParameters())»
				obj.set«prop.name.toFirstUpper()»(«prop.name»);
			«ENDFOR»
			
			«FOR prop : this.getBuilderReferences().filter(r | r.many).removeAll(getBuilderConstructorParameters())»
				obj.get«prop.name.toFirstUpper()»().addAll(«prop.name»);
			«ENDFOR»

			return obj;
		}		
	}

	'''
}

def static String assignAttributeInConstructor(NamedElement it) {
	'''
	        «IF metaType == Reference && ((Reference) this).many »
	        	this.«name».addAll(«name»);
	        «ELSE»
	        	this.«name» = «name»;
	        «ENDIF»

	'''
}

def static String multiReferenceAdd(Reference it, DomainObject obj) {
	'''
		/**
			* Adds an object to the to-many
			* association.
			* It is added the collection {@link #get«name.toFirstUpper()»}.
			*/
		public «obj.name»Builder add«name.toFirstUpper().singular()»(«getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
			return this;
		};
	'''
}


def static String builderAttribute(Attribute it) {
	'''
	protected «getImplTypeName()» «name»;
	'''
}

def static String builderAttributeSetter(Attribute it, DomainObject obj) {
	'''
		«formatJavaDoc()»
	public «obj.name»Builder «name»(«getTypeName()» val) {
		this.«name» = val;
		return this;
	}
	'''
}

def static String builderSingleReferenceSetter(Reference it, DomainObject obj) {
	'''
		«formatJavaDoc()»
		public «obj.name»Builder «name»(«getTypeName()» «name») {
			this.«name» = «name»;
			return this;
		};
	'''
}


}
