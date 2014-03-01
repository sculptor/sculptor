package org.sculptor.generator.template.doc

import java.util.Set
import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.ext.UmlGraphHelper
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.Consumer
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Enum
import sculptormetamodel.EnumValue
import sculptormetamodel.Module
import sculptormetamodel.Operation
import sculptormetamodel.Reference
import sculptormetamodel.Service
import sculptormetamodel.Trait
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class UMLGraphTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties
	@Inject extension UmlGraphHelper umlGraphHelper

def String start(Application it) {
	val mods = it.visibleModules().toSet()
	'''
		/*detail 0 => subject area diagrams, including persistence diagram */
		«startSubjectAreaDiagrams(it, mods)»
		/*detail 1 => all */
		«start(it, mods, 1)»
		/*detail 2 => core domain */
		«IF it.existsCoreDomain()»
			«start(it, mods, 2)»
		«ENDIF»
		/*detail 3 => overview */
		«start(it, mods, 3)»
		/*detail 4 => module dependencies */
		«start(it, mods, 4)»
		/*Each module separatly */
		«IF mods.size > 1»
			«FOR m : mods»
			    «start(it, newHashSet(m), 0, "entity")»
				«start(it, newHashSet(m), 1)»
			«ENDFOR»
		«ENDIF»
	'''
}

def String startSubjectAreaDiagrams(Application it, Set<Module> focus) {
	'''
	«val subjectAreas = it.getSubjectAreas()»
		«FOR area : subjectAreas»
			«start(it, focus, 0, area)»
		«ENDFOR»
	'''
}

def String start(Application it, Set<Module> focus, int detail) {
	'''
	«start(it, focus, detail, null)»
	'''
}

def String start(Application it, Set<Module> focus, int detail, String subjectArea) {
	fileOutput(it.dotFileName(focus, detail, subjectArea), OutputSlot::TO_DOC,
		startContent(it, focus, detail, subjectArea))
}

def String startContent(Application it, Set<Module> focus, int detail, String subjectArea) {
'''
	«graphPropertiesStart(it)»	
	«focus.sortBy(e|e.name).map[m | subGraphForModule(m, focus, detail, subjectArea)].join()»
	«IF detail < 4»
		«InheritanceGraphProperties(it)»
		«it.getAllDomainObjects().filter(d|d.^extends != null && d.includeInDiagram(detail, subjectArea)).map[InheritanceToUML(it, focus, detail, subjectArea)].join()»
		«RelationGraphProperties(it)»
		
		«it.getAllReferences()
			.filter(e | !(e.to instanceof BasicType))
			.filter(e | !(e.to instanceof Enum))
			.filter(e | e.to.includeInDiagram(detail, subjectArea))
			.filter(e | e.from.includeInDiagram(detail, subjectArea))
			.sortBy(e | e.from.name + "->" + e.to.name + ": " + e.name)
			.map[r | RelationToUML(r, focus, detail, subjectArea)].join»
		«it.modules.map[services].flatten.map[ServiceDependenciesToUML(it, focus, detail, subjectArea)].join()»
	«ELSE»
		«focus.map[ModuleDependenciesToUML(it)].join»
	«ENDIF»
	«graphPropertiesEnd(it)»	
	'''	
}

def String graphPropertiesStart(Application it) {
	'''
	digraph G {
		fontsize = 10
		node [
			fontsize = 10
			fontname="arial"
			shape=plaintext
		]

		edge [
			fontsize = 10
		]
	'''
}

def String graphPropertiesEnd(Application it) {
	'''
	}
	'''
}

def String subGraphForModule(Module it, Set<Module> focus, int detail, String subjectArea) {
	'''
	«IF detail < 4»
		subgraph cluster«name» {
			label = "«name»"  
			«IF focus.contains(it)»
				«it.services.filter(e|e.includeInDiagram(detail, subjectArea)).sortBy(e|e.name).map[ServiceToUML(it, focus, detail)].join()»
				«it.consumers.filter(e|e.includeInDiagram(detail, subjectArea)).sortBy(e|e.name).map[ConsumerToUML(it, focus, detail)].join()»
				«it.domainObjects.filter(e|e.includeInDiagram(detail, subjectArea)).sortBy(e|e.name).map[ObjectToUML(it, focus, detail, subjectArea)].join()»
			«ENDIF»
		}
	«ELSE»
		«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="20" port="p" bgcolor="#«it.bgcolor()»">
		<tr><td>
			<table border="0" cellspacing="1" cellpadding="1">
				<tr><td> &laquo;«it.getStereoTypeName()»&raquo; </td></tr>
				<tr><td><font face="arialbd"  point-size="12.0"> «name» </font></td></tr>
			</table>
		</td></tr>	
		</table>>, fontname="arial", fontcolor="«it.fontcolor()»", fontsize=9.0];
	«ENDIF»
	'''
}


def String InheritanceGraphProperties(Application it) {
	'''
	edge [arrowhead = "empty"]
	'''
}

def String RelationGraphProperties(Application it) {
	'''
	edge [arrowhead = "none"]
	'''
}

def String ServiceToUML(Service it, Set<Module> focus, int detail) {
	'''
	«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="0" port="p" bgcolor="#«it.bgcolor()»" >
	<tr><td>
	<table border="0" cellspacing="1" cellpadding="1">
		<tr><td> &laquo;«it.getStereoTypeName()»&raquo; </td></tr>
		<tr><td><font face="arialbd"  point-size="12.0"> «name» </font></td></tr>
	</table></td></tr>
	«IF it.showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
		«it.operations.map[OperationToUML(it)].join()»
			</table>		
		</td></tr>
	«ENDIF»
	</table>>, fontname="arial", fontcolor="«it.fontcolor()»", fontsize=9.0];
	'''
}

def dispatch String OperationToUML(Operation it) {
	'''
				<tr><td align="left">«it.name»</td></tr>			
	'''
}

def String ServiceDependenciesToUML(Service it, Set<Module> focus, int detail, String subjectArea) {
	'''
	«IF focus.contains(module) && it.includeInDiagram(detail, subjectArea)»
		edge [arrowtail="none" arrowhead = "open" headlabel = "" taillabel = "" style = "dashed"]
		«FOR dep : it.serviceOperationDependencies()»
			«IF dep.isShownInView(focus, detail, subjectArea) »
				«name» -> «dep.name»
			«ENDIF»
		«ENDFOR»
	«ENDIF»
	'''
}

def String ConsumerToUML(Consumer it, Set<Module> focus, int detail) {
	'''
	«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="0" port="p" bgcolor="#«it.bgcolor()»">
	<tr><td>
	<table border="0" cellspacing="1" cellpadding="1">
		<tr><td> &laquo;«it.getStereoTypeName()»&raquo; </td></tr>
		<tr><td><font face="arialbd"  point-size="12.0"> «name» </font></td></tr>
	</table></td></tr>
	«IF it.showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
				<tr><td align="left">onMessage</td></tr>
			</table>		
		</td></tr>
	«ENDIF»
	</table>>, fontname="arial", fontcolor="«it.fontcolor()»", fontsize=9.0];
	'''
}

def String ObjectToUML(DomainObject it, Set<Module> focus, int detail, String subjectArea) {
	'''
	«IF it.isShownInView(focus, detail, subjectArea) »
	«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="0" port="p" bgcolor="#«it.bgcolor()»">
	<tr><td>
	<table border="0" cellspacing="1" cellpadding="1">
		<tr><td> &laquo;«it.getStereoTypeName()»&raquo; </td></tr>
		<tr><td>«IF it.^abstract»<font face="arialbi"  point-size="12.0"> «name» </font>
				«ELSE»<font face="arialbd"  point-size="12.0"> «name» </font>«ENDIF»</td></tr>
	</table></td></tr>
	«IF it instanceof sculptormetamodel.Enum && it.showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
			«(it as Enum).values.map[EnumValueToUML(it)].join()»
			</table>		
		</td></tr> 
	«ENDIF »
	«val existsAttributesCompartment = attributes.exists(e | !e.isSystemAttribute() && e.visible()) || references.exists(e | e.to instanceof BasicType && e.visible())
			|| references.exists(e | e.to instanceof sculptormetamodel.Enum && e.visible())
			|| references.exists(e | !focus.contains(e.to.module) && e.visible())»
	«IF existsAttributesCompartment && it.showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
		«it.attributes.filter[e|!(e.isSystemAttribute() || e.hide())].map[AttributeToUML(it)].join»
		«it.references.filter(e | e.to instanceof BasicType && e.visible()).map[BasicTypeAttributeToUML(it)].join»
		«it.references.filter(e | e.to instanceof sculptormetamodel.Enum && e.visible()).map[EnumAttributeToUML(it)].join»
		«it.references.filter( e | !(e.to instanceof sculptormetamodel.Enum) && !(e.to instanceof BasicType) && !focus.contains(e.to.module) && e.visible()).map[NonFocusReferenceToUML(it)].join()»
			</table>		
		</td></tr>
	«ENDIF»
	«IF operations.exists(e | e.isPublicVisibility() && e.visible()) && it.showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">
			«it.operations.filter(e | e.isPublicVisibility() && e.visible()).map[OperationToUML(it)].join()»
			</table>		
		</td></tr>
	«ENDIF»
	</table>>, fontname="arial", fontcolor="«it.fontcolor()»", fontsize=9.0];
	«ENDIF»
	'''
}

/*Skip Traits */
def String TraitToUML(Trait it, Set<Module> focus, int detail, String subjectArea) {
	'''
	'''
}

def String AttributeToUML(Attribute it) {
	'''
		«IF !it.isSystemAttribute()»
			«IF naturalKey» 
				<tr><td align="left"><font face="arialbd"> * «name» : «type» </font> </td></tr>			
			«ELSE»
				<tr><td align="left"> + «name» : «type» </td></tr>
			«ENDIF»
		«ENDIF»
	'''
}

def String BasicTypeAttributeToUML(Reference it) {
	'''
		«IF naturalKey» 
			<tr><td align="left"><font face="arialbd"> * «name» : «to.name» </font> </td></tr>			
		«ELSE»
			<tr><td align="left"> + «name» : «to.name» </td></tr>
		«ENDIF»
	'''
}

def String EnumAttributeToUML(Reference it) {
	'''
		«IF naturalKey» 
			<tr><td align="left"><font face="arialbd"> * «name» : «to.name» </font> </td></tr>			
		«ELSE»
			<tr><td align="left"> + «name» : «to.name» </td></tr>
		«ENDIF»
	'''
}

def String NonFocusReferenceToUML(Reference it) {
	val typeStr = (if (collectionType != null) collectionType + "&lt;" else "") + to.name + (if (collectionType != null) "&gt;" else "")
	'''
		«IF naturalKey» 
			<tr><td align="left"><font face="arialbd"> * «name» : «typeStr» </font> </td></tr>			
		«ELSE»
			<tr><td align="left"> + «name» : «typeStr» </td></tr>
		«ENDIF»
	'''
}

def String EnumValueToUML(EnumValue it) {
	'''
			<tr><td align="left"> + «name»</td></tr>
	'''
}

def dispatch String OperationToUML(DomainObjectOperation it) {
	'''
			<tr><td align="left">«name»()</td></tr>
	'''
}

def String InheritanceToUML(DomainObject it, Set<Module> focus, int detail, String subjectArea) {
	'''
	«IF it.isShownInView(focus, detail, subjectArea) && ^extends.isShownInView(focus, detail, subjectArea) »
		«name»:p -> «^extends.name»:p
	«ENDIF»
	'''
}

def String RelationToUML(Reference it, Set<Module> focus, int detail, String subjectArea) {
	'''
	«IF from.isShownInView(focus, detail, subjectArea) && to.isShownInView(focus, detail, subjectArea)»

		«IF it.isAggregate() »
			edge [arrowtail="diamond" arrowhead = "none" «ELSEIF opposite == null»
			edge [arrowtail="none" arrowhead = "open" «ELSE»
			edge [arrowtail="none" arrowhead = "none" «ENDIF»headlabel="«if (detail > 1) "" else it.referenceHeadLabel()»" taillabel="«if (detail > 1) "" else it.referenceTailLabel()»" labeldistance="«it.labeldistance()»" labelangle="«it.labelangle()»"]

		«from.name» -> «to.name»
	«ENDIF»
	'''
}

def String ModuleDependenciesToUML(Module it) {
	'''
	«it.moduleDependencies().map[m | ModuleDependencyToUML(m, it)].join()»
	'''
}

def String ModuleDependencyToUML(Module it, Module from) {
	'''
		edge [arrowtail="none" arrowhead = "open" headlabel = "" taillabel = "" style = "dashed"]
		«from.name» -> «name»
	'''
}
}
