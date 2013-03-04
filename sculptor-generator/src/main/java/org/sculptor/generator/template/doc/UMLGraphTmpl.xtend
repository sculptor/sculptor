package org.sculptor.generator.template.doc

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class UMLGraphTmpl {

def static String start(Application it) {
	'''
	«val mods = it.visibleModules().toSet()»
		/*detail 0 => subject area diagrams, including persistence diagram */
		«startSubjectAreaDiagrams(it)(mods) FOR this»
		/*detail 1 => all */
		«start(it)(mods, 1)»
		/*detail 2 => core domain */
		«IF existsCoreDomain()»
			«start(it)(mods, 2)»
		«ENDIF»
		/*detail 3 => overview */
		«start(it)(mods, 3)»
		/*detail 4 => module dependencies */
		«start(it)(mods, 4)»
		/*Each module separatly */
		«IF mods.size > 1»
			«FOR m : mods»
			    «start(it)({m}.toSet(), 0, "entity")»
				«start(it)({m}.toSet(), 1)»
			«ENDFOR»
		«ENDIF»
	'''
}

def static String startSubjectAreaDiagrams(Application it, Set[Module] focus) {
	'''
	«val subjectAreas = it.this.getSubjectAreas()»
		«FOR area : subjectAreas»
			«start(it)(focus, 0, area)»
		«ENDFOR»
	'''
}

def static String start(Application it, Set[Module] focus, int detail) {
	'''
	«start(it)(focus, detail, null) FOR this»
	'''
}

def static String start(Application it, Set[Module] focus, int detail, String subjectArea) {
	'''
	«debugTrace("start() focus=" + focus + ", detail=" + detail + ", subjectArea=" + subjectArea)»
	'''
	fileOutput(dotFileName(focus, detail, subjectArea), 'TO_GEN_RESOURCES', '''
	«graphPropertiesStart(it)»	
	«it.focus.sortBy(e|e.name).forEach[subGraphForModule(it)(focus, detail, subjectArea)]»
	«IF detail < 4»
		«InheritanceGraphProperties(it)»
		«it.getAllDomainObjects().filter(d|d.^extends != null && d.includeInDiagram(detail, subjectArea)).forEach[InheritanceToUML(it)(focus, detail, subjectArea)]»
		«RelationGraphProperties(it)»
		«RelationToUML(it)(focus, detail, subjectArea) FOREACH getAllReferences() .reject(e | e.to.metaType == BasicType)
			.reject(e | e.to.metaType == Enum)
			.reject(e | e.to.includeInDiagram(detail, subjectArea) == false)
			.reject(e | e.from.includeInDiagram(detail, subjectArea) == false)
			.sortBy(e | e.from.name + "->" + e.to.name + ": " + e.name)»
		«it.modules.services.forEach[ServiceDependenciesToUML(it)(focus, detail, subjectArea)]»
	«ELSE»
		«it.focus.forEach[ModuleDependenciesToUML(it)]»
	«ENDIF»
	«graphPropertiesEnd(it)»	
	'''
	)
	'''    
	'''
}


def static String graphPropertiesStart(Application it) {
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

def static String graphPropertiesEnd(Application it) {
	'''
	}
	'''
}

def static String subGraphForModule(Module it, Set[Module] focus, int detail, String subjectArea) {
	'''
	«IF detail < 4»
		subgraph cluster«name» {
			label = "«name»"  
			«IF focus.contains(this)»
				«it.services.filter(e|e.includeInDiagram(detail, subjectArea)).sortBy(e|e.name).forEach[ServiceToUML(it)(focus, detail)]»
				«it.consumers.filter(e|e.includeInDiagram(detail, subjectArea)).sortBy(e|e.name).forEach[ConsumerToUML(it)(focus, detail)]»
				«it.domainObjects.filter(e|e.includeInDiagram(detail, subjectArea)).sortBy(e|e.name).forEach[ObjectToUML(it)(focus, detail, subjectArea)]»
			«ENDIF»
		}
	«ELSE»
		«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="20" port="p" bgcolor="#«bgcolor()»">
		<tr><td>
			<table border="0" cellspacing="1" cellpadding="1">
				<tr><td> &laquo;«getStereoTypeName()»&raquo; </td></tr>
				<tr><td><font face="arialbd"  point-size="12.0"> «name» </font></td></tr>
			</table>
		</td></tr>	
		</table>>, fontname="arial", fontcolor="«fontcolor()»", fontsize=9.0];
	«ENDIF»
	'''
}


def static String InheritanceGraphProperties(Application it) {
	'''
	edge [arrowhead = "empty"]
	'''
}

def static String RelationGraphProperties(Application it) {
	'''
	edge [arrowhead = "none"]
	'''
}

def static String ServiceToUML(Service it, Set[Module] focus, int detail) {
	'''
	«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="0" port="p" bgcolor="#«bgcolor()»" >
	<tr><td>
	<table border="0" cellspacing="1" cellpadding="1">
		<tr><td> &laquo;«getStereoTypeName()»&raquo; </td></tr>
		<tr><td><font face="arialbd"  point-size="12.0"> «name» </font></td></tr>
	</table></td></tr>
	«IF showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
		«it.operations.forEach[OperationToUML(it)]»
			</table>		
		</td></tr>
	«ENDIF»
	</table>>, fontname="arial", fontcolor="«fontcolor()»", fontsize=9.0];
	'''
}

def static String OperationToUML(Operation it) {
	'''
				<tr><td align="left">«this.name»</td></tr>			
	'''
}

def static String ServiceDependenciesToUML(Service it, Set[Module] focus, int detail, String subjectArea) {
	'''
	«IF focus.contains(module) && includeInDiagram(detail, subjectArea)»
		edge [arrowtail="none" arrowhead = "open" headlabel = "" taillabel = "" style = "dashed"]
		«FOR dep : serviceOperationDependencies()»
			«IF dep.isShownInView(focus, detail, subjectArea) »
				«name» -> «dep.name»
			«ENDIF»
		«ENDFOR»
	«ENDIF»
	'''
}

def static String ConsumerToUML(Consumer it, Set[Module] focus, int detail) {
	'''
	«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="0" port="p" bgcolor="#«bgcolor()»">
	<tr><td>
	<table border="0" cellspacing="1" cellpadding="1">
		<tr><td> &laquo;«getStereoTypeName()»&raquo; </td></tr>
		<tr><td><font face="arialbd"  point-size="12.0"> «name» </font></td></tr>
	</table></td></tr>
	«IF showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
				<tr><td align="left">onMessage</td></tr>
			</table>		
		</td></tr>
	«ENDIF»
	</table>>, fontname="arial", fontcolor="«fontcolor()»", fontsize=9.0];
	'''
}

def static String ObjectToUML(DomainObject it, Set[Module] focus, int detail, String subjectArea) {
	'''
	«IF isShownInView(focus, detail, subjectArea) »
	«name» [label=<<table border="0" cellborder="1" cellspacing="0" cellpadding="0" port="p" bgcolor="#«bgcolor()»">
	<tr><td>
	<table border="0" cellspacing="1" cellpadding="1">
		<tr><td> &laquo;«getStereoTypeName()»&raquo; </td></tr>
		<tr><td>«IF this.^abstract»<font face="arialbi"  point-size="12.0"> «name» </font>
				«ELSE»<font face="arialbd"  point-size="12.0"> «name» </font>«ENDIF»</td></tr>
	</table></td></tr>
	«IF metaType == Enum && showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
			«it.((Enum) this).values.forEach[EnumValueToUML(it)]»
			</table>		
		</td></tr> 
	«ENDIF »
	«LET attributes.exists(e | !e.isSystemAttribute() && e.visible()) || references.exists(e | e.to.metaType == BasicType && e.visible())
			|| references.exists(e | e.to.metaType == Enum && e.visible())
			|| references.exists(e | !focus.contains(e.to.module) && e.visible()) 
			AS existsAttributesCompartment»
	«IF existsAttributesCompartment && showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">	
		«it.attributes.reject(e|e.isSystemAttribute() || e.hide()).forEach[AttributeToUML(it)]»
		«it.references.filter(e | e.to.metaType == BasicType && e.visible()).forEach[BasicTypeAttributeToUML(it)]»
		«it.references.filter(e | e.to.metaType == Enum && e.visible()).forEach[EnumAttributeToUML(it)]»
		«it.references.filter( e | e.to.metaType != Enum && e.to.metaType != BasicType && !focus.contains(e.to.module) && e.visible()).forEach[NonFocusReferenceToUML(it)]»
			</table>		
		</td></tr>
	«ENDIF»
	«IF operations.exists(e | e.isPublicVisibility() && e.visible()) && showCompartment(detail)»
		<tr><td>
			<table border="0" cellspacing="0" cellpadding="1">
			«it.operations.filter(e | e.isPublicVisibility() && e.visible()).forEach[OperationToUML(it)]»
			</table>		
		</td></tr>
	«ENDIF»
	</table>>, fontname="arial", fontcolor="«fontcolor()»", fontsize=9.0];
	«ENDIF»
	'''
}

/*Skip Traits */
def static String ObjectToUML(Trait it, Set[Module] focus, int detail, String subjectArea) {
	'''
	'''
}

def static String AttributeToUML(Attribute it) {
	'''
		«IF !this.isSystemAttribute()»
			«IF this.naturalKey» 
				<tr><td align="left"><font face="arialbd"> * «this.name» : «this.type» </font> </td></tr>			
			«ELSE»
				<tr><td align="left"> + «this.name» : «this.type» </td></tr>
			«ENDIF»
		
		«ENDIF»
	'''
}

def static String BasicTypeAttributeToUML(Reference it) {
	'''
		«IF this.naturalKey» 
			<tr><td align="left"><font face="arialbd"> * «this.name» : «this.to.name» </font> </td></tr>			
		«ELSE»
			<tr><td align="left"> + «this.name» : «this.to.name» </td></tr>
		«ENDIF»
	'''
}

def static String EnumAttributeToUML(Reference it) {
	'''
		«IF this.naturalKey» 
			<tr><td align="left"><font face="arialbd"> * «this.name» : «this.to.name» </font> </td></tr>			
		«ELSE»
			<tr><td align="left"> + «this.name» : «this.to.name» </td></tr>
		«ENDIF»
	'''
}

def static String NonFocusReferenceToUML(Reference it) {
	'''
	«LET (collectionType != null ? collectionType + "&lt;" : "") + to.name +
		 (collectionType != null ? "&gt;" : "")  AS typeStr»
		«IF this.naturalKey» 
			<tr><td align="left"><font face="arialbd"> * «this.name» : «typeStr» </font> </td></tr>			
		«ELSE»
			<tr><td align="left"> + «this.name» : «typeStr» </td></tr>
		«ENDIF»
	'''
}

def static String EnumValueToUML(EnumValue it) {
	'''
			<tr><td align="left"> + «this.name»</td></tr>
	'''
}

def static String OperationToUML(DomainObjectOperation it) {
	'''
			<tr><td align="left">«this.name»()</td></tr>
	'''
}

def static String InheritanceToUML(DomainObject it, Set[Module] focus, int detail, String subjectArea) {
	'''
	«IF this.isShownInView(focus, detail, subjectArea) && ^extends.isShownInView(focus, detail, subjectArea) »
		«name»:p -> «^extends.name»:p
	«ENDIF»
	'''
}

def static String RelationToUML(Reference it, Set[Module] focus, int detail, String subjectArea) {
	'''
	«IF from.isShownInView(focus, detail, subjectArea) && to.isShownInView(focus, detail, subjectArea)»

		«IF isAggregate() »
			edge [arrowtail="diamond" arrowhead = "none" « ELSEIF this.opposite == null -»
			edge [arrowtail="none" arrowhead = "open" « ELSE -»
		   	edge [arrowtail="none" arrowhead = "none" « ENDIF »headlabel="«detail > 1 ? "" : this.referenceHeadLabel()»" taillabel="«detail > 1 ? "" : this.referenceTailLabel()»" labeldistance="«labeldistance()»" labelangle="«labelangle()»"]
	
		«this.from.name» -> «this.to.name»
	«ENDIF»
	'''
}

def static String ModuleDependenciesToUML(Module it) {
	'''
	«it.moduleDependencies().forEach[ModuleDependencyToUML(it)(this)]»
	'''
}

def static String ModuleDependencyToUML(Module it, Module from) {
	'''
		edge [arrowtail="none" arrowhead = "open" headlabel = "" taillabel = "" style = "dashed"]
		«from.name» -> «this.name»
	'''
}
}
