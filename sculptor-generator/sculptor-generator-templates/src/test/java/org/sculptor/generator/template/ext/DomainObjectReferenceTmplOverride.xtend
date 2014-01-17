package org.sculptor.generator.template.ext

import com.google.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.template.domain.DomainObjectReferenceTmpl
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Reference

@ChainOverride
class DomainObjectReferenceTmplOverride extends DomainObjectReferenceTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper

	override String bidirectionalReferenceAdd(Reference it) {
		'''
			
			«IF !isSetterPrivate()»
				/**
				 * Adds an object to the bidirectional many-to-one
				 * association in both ends.
				 * It is added the collection {@link #get«name.toFirstUpper()»}
				 * at this side and the association
				 * {@link «getTypeName()»#set«opposite.name.toFirstUpper()»}
				 * at the opposite side is set.
				 */
				«getVisibilityLitteralSetter()»void addTo«name.toFirstUpper().plural()»(«getTypeName()» «name.singular()»Element) {
					add«name.toFirstUpper().singular()»(«name.singular()»Element);
				};
			«ENDIF»
			
			«next.bidirectionalReferenceAdd(it)»
		'''
	}

}
