package generator

import com.google.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.template.domain.DomainObjectReferenceTmpl
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Reference

@ChainOverride
/**
 * Override DomainObjectReferenceTmpl to add 'addTo*' methods for bidirectional and unidirectional references.
 */
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
			
			// Delegate to next template in chain so regular add method gets generated as well
			«next.bidirectionalReferenceAdd(it)»
		'''
	}

	override String unidirectionalReferenceAdd(Reference it) {
		'''
		«IF !it.isSetterPrivate()»
			/**
			 * Adds an object to the unidirectional to-many
			 * association.
			 * It is added the collection {@link #get«name.toFirstUpper()»}.
			 */
			«it.getVisibilityLitteralSetter()»void addTo«name.toFirstUpper().singular()»(«it.getTypeName()» «name.singular()»Element) {
				get«name.toFirstUpper()»().add(«name.singular()»Element);
			};
		«ENDIF»

		// Delegate to next template in chain so regular add method gets generated as well
		«next.unidirectionalReferenceAdd(it)»
		'''
	}
}
