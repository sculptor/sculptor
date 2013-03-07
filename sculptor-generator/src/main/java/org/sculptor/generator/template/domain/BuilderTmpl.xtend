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

import java.util.List
import sculptormetamodel.Attribute
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference

import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.domain.BuilderTmpl.*
import static org.sculptor.generator.util.PropertiesBase.*

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*

class BuilderTmpl {

def static String builder(DomainObject it) {
	fileOutput(javaFileName(it.getBuilderFqn()), '''
	«javaHeader()»
	package «getBuilderPackage()»;
	«builderBody(it)»
	'''
	)
}

def static String builderBody(DomainObject it) {
	'''

	/**
	  * Builder for «name» class.
	  */
	public class «it.getBuilderClassName()»  {
	
		«it.getBuilderAttributes().forEach[a | DomainObjectAttributeTmpl::attribute(a, false)]»
		
	    «it.getBuilderReferences().filter(r| !r.many).map[DomainObjectReferenceTmpl::oneReferenceAttribute(it)(false)]»
	    «it.getBuilderReferences().filter(r| r.many).map[DomainObjectReferenceTmpl::manyReferenceAttribute(it)(false)]»

		/**
		 * Static factory method for «it.getBuilderClassName()»
		 */
		public static «name»Builder «name.toFirstLower()»() {
			return new «name»Builder();
		}
		 
		public «name»Builder() {
		}
		
		«IF !it.getBuilderConstructorParameters().isEmpty »
		public «name»Builder(«it.getBuilderConstructorParameters().map[p | DomainObjectConstructorTmpl::parameterTypeAndName(p)].join(",")») {
		
			«FOR p : it.getBuilderConstructorParameters()»
				«assignAttributeInConstructor(p)»
			«ENDFOR»
		}
		«ENDIF»
		
		«it.getBuilderAttributes() .map[a | builderAttributeSetter(a, it)]»
		
		«it.getBuilderReferences().filter(r | !r.many).map[r | builderSingleReferenceSetter(r, it)]»
		
		
		«it.getBuilderReferences().filter(r| r.many).map[r | multiReferenceAdd(r, it)]»
		
		«it.getBuilderAttributes() .map[DomainObjectAttributeTmpl::propertyGetter(it)]»

		«it.getBuilderReferences().filter(r| !r.many).map[r | DomainObjectReferenceTmpl::oneReferenceGetter(r, false)]»
		«it.getBuilderReferences().filter(r| r.many).map[r | DomainObjectReferenceTmpl::manyReferenceGetter(r, false)]»
		
		/**
		 * @return new «name» instance constructed based on the values that have been set into this builder
		 */
		public «getDomainPackage() + "." + name» build() {
			«getDomainPackage() + "." + name» obj = new «name»(«FOR attr : it.getBuilderConstructorParameters() SEPARATOR ", "»«attr.getGetAccessor()»()«ENDFOR»);
			«val List<NamedElement> attrs = newArrayList()»
			«attrs.addAll(it.getBuilderAttributes())»
			«attrs.addAll(it.getBuilderReferences().filter(r | !r.many).toList)»
			«attrs.removeAll(it.getBuilderConstructorParameters())»
			«FOR prop : attrs»
				obj.set«prop.name.toFirstUpper()»(«prop.name»);
			«ENDFOR»
			«val refs = it.getBuilderReferences().filter(r | r.many).toList»
			«refs.removeAll(it.getBuilderConstructorParameters())»
			«FOR prop : refs»
				obj.get«prop.name.toFirstUpper()»().addAll(«prop.name»);
			«ENDFOR»

			return obj;
		}		
	}

	'''
}

def static String assignAttributeInConstructor(NamedElement it) {
	'''
		«IF it.metaType == typeof(Reference) && (it as Reference).many »
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
		public «obj.name»Builder add«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
			get«name.toFirstUpper()»().add(«name.singular()»Element);
			return this;
		};
	'''
}


def static String builderAttribute(Attribute it) {
	'''
		protected «it.getImplTypeName()» «name»;
	'''
}

def static String builderAttributeSetter(Attribute it, DomainObject obj) {
	'''
		«it.formatJavaDoc()»
		public «obj.name»Builder «name»(«it.getTypeName()» val) {
			this.«name» = val;
			return this;
		}
	'''
}

def static String builderSingleReferenceSetter(Reference it, DomainObject obj) {
	'''
		«it.formatJavaDoc()»
		public «obj.name»Builder «name»(«it.getTypeName()» «name») {
			this.«name» = «name»;
			return this;
		};
	'''
}


}
