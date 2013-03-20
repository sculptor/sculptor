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
import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Attribute
import sculptormetamodel.DomainObject
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference

class BuilderTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties
	@Inject private var DomainObjectAttributeTmpl domainObjectAttributeTmpl
	@Inject private var DomainObjectReferenceTmpl domainObjectReferenceTmpl
	@Inject private var DomainObjectConstructorTmpl domainObjectConstructorTmpl

def String builder(DomainObject it) {
	fileOutput(javaFileName(it.getBuilderFqn()), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «getBuilderPackage()»;
	«builderBody(it)»
	'''
	)
}

def String builderBody(DomainObject it) {
	'''

	/**
	 * Builder for «name» class.
	 */
	public class «it.getBuilderClassName()» {

		«it.getBuilderAttributes().map[a | domainObjectAttributeTmpl.attribute(a, false)].join()»

		«it.getBuilderReferences().filter(r| !r.many).map[e | domainObjectReferenceTmpl.oneReferenceAttribute(e, false)].join()»
		«it.getBuilderReferences().filter(r| r.many).map[e | domainObjectReferenceTmpl.manyReferenceAttribute(e, false)].join()»

		/**
		 * Static factory method for «it.getBuilderClassName()»
		 */
		public static «name»Builder «name.toFirstLower()»() {
			return new «name»Builder();
		}

		public «name»Builder() {
		}

		«IF !it.getBuilderConstructorParameters().isEmpty »
			public «name»Builder(«it.getBuilderConstructorParameters().map[p | domainObjectConstructorTmpl.parameterTypeAndName(p)].join(",")») {
			
				«FOR p : it.getBuilderConstructorParameters()»
					«assignAttributeInConstructor(p)»
				«ENDFOR»
			}
		«ENDIF»

		«it.getBuilderAttributes() .map[a | builderAttributeSetter(a, it)].join()»

		«it.getBuilderReferences().filter(r | !r.many).map[r | builderSingleReferenceSetter(r, it)].join()»
		«it.getBuilderReferences().filter(r| r.many).map[r | multiReferenceAdd(r, it)].join()»

		«it.getBuilderAttributes() .map[a | domainObjectAttributeTmpl.propertyGetter(a)].join()»

		«it.getBuilderReferences().filter(r| !r.many).map[r | domainObjectReferenceTmpl.oneReferenceGetter(r, false)].join()»
		«it.getBuilderReferences().filter(r| r.many).map[r | domainObjectReferenceTmpl.manyReferenceGetter(r, false)].join()»

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

def String assignAttributeInConstructor(NamedElement it) {
	'''
	«IF it instanceof Reference && (it as Reference).many »
		this.«name».addAll(«name»);
	«ELSE»
		this.«name» = «name»;
	«ENDIF»

	'''
}

def String multiReferenceAdd(Reference it, DomainObject obj) {
	'''
	/**
	 * Adds an object to the to-many
	 * association.
	 * It is added the collection {@link #get«name.toFirstUpper()»}.
	 */
	public «obj.name»Builder add«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
		get«name.toFirstUpper()»().add(«name.singular()»Element);
		return this;
	}
	'''
}


def String builderAttribute(Attribute it) {
	'''
	protected «it.getImplTypeName()» «name»;
	'''
}

def String builderAttributeSetter(Attribute it, DomainObject obj) {
	'''
	«it.formatJavaDoc()»
	public «obj.name»Builder «name»(«it.getTypeName()» val) {
		this.«name» = val;
		return this;
	}
	'''
}

def String builderSingleReferenceSetter(Reference it, DomainObject obj) {
	'''
	«it.formatJavaDoc()»
	public «obj.name»Builder «name»(«it.getTypeName()» «name») {
		this.«name» = «name»;
		return this;
	};
	'''
}


}
