/*
	Generates summary documentation of the domain model.
 */

package org.sculptor.generator.template.doc

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class ModelDocTmpl {

def static String start(Application it) {
	'''
	«docHtml(it) FOR this»
	«ModelDocCss::docCss(it) FOR this»
	«it.modules.forEach[moduleDocHtml(it)]»
	'''
}

def static String docHtml(Application it) {
	'''
	'''
	fileOutput("DomainModelDoc.html", 'TO_GEN_RESOURCES', '''
	«val title = it."Summary Documentation of " + name + " Domain Model"»
	«header(it)(title)»

	<div id="wrap">
		
	<h1>«title»</h1>

	«menu(it)»
	«IF isUMLToBeGenerated()»
		«graph(it)»
	«ENDIF»
	«footer(it)»

	</div>
	</body>
	</html>
	'''
	)
	'''    
	'''
}

def static String moduleDocHtml(Module it) {
	'''
	'''
	fileOutput("DomainModelDoc-" + name + ".html", 'TO_GEN_RESOURCES', '''
	«val title = it."Summary Documentation of " + name + " module"»
	«header(it)(title + "(" + application.name + ")")»
	<div id="wrap">
			<a name="module_«name»"></a>
	<h1>«title» <a href="DomainModelDoc.html">(«application.name»)</a></h1>
	
	
	«moduleDocContent(it)»

	</div>
	</body>
	</html>	
	'''
	)
	'''
	'''
}

def static String header(Object it, String title) {
	'''
	<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
	<html>
	<head>
	<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
	<style type="text/css" media="screen,print">   
			@import url("DomainModelDoc.css");
			</style> 
	<title>«title»</title> 
	</head>
	<body>
	'''
}

def static String footer(Application it) {
	'''
	<div id="footer">
	<br/>
	<br/>
	</div>
	'''
}

def static String main(Application it) {
	'''
	<div id="main">
	«it.modules.sortBy(e|e.name).forEach[moduleDoc(it)]»
	</div>
	'''
}


def static String moduleDoc(Module it) {
	'''
	<a name="module_«name»"></a>
	<h2>Module «name»</h2>
	
	«moduleDocContent(it)»
	<hr/>
	'''
}

def static String moduleDocContent(Module it) {
	'''
	<p>«doc»</p>
	«menu(it)»
	«IF isUMLToBeGenerated()»
		«graph(it)»
	«ENDIF»
	
	<div id="services">
	<hr/>
	«it.services.sortBy(e|e.name).forEach[serviceDoc(it)]»
	</div>
	<div id="consumers">
	«it.consumers.sortBy(e|e.name).forEach[consumerDoc(it)]»
	</div>
	<div id="domainObjects">
	«it.domainObjects.sortBy(e|e.name).forEach[domainObjectDoc(it)]»
	</div>
	'''
}

def static String menu(Application it) {
	'''
	<div id="menu">
	«FOR m : modules.sortBy(e|e.name)»
		<h2><a href="DomainModelDoc-«m.name».html#module_«m.name»">«m.name»</a></h2>
			«menuItems(it) FOR m»
	«ENDFOR»
	</div>
	'''
}

def static String menu(Module it) {
	'''
	<div id="menu">
			«menuItems(it)»
	</div>
	'''
}

def static String menuItems(Module it) {
	'''
			<ul>
			«menuItem(it) FOREACH  {}.addAll(services)
				.addAll(consumers)
				.addAll(domainObjects)
				.sortBy(e | ((NamedElement) e).name)»
			</ul>
	'''
}

def static String menuItem(Object it) {
	'''
	'''
}

def static String menuItem(NamedElement it) {
	'''
				<li><a href="DomainModelDoc-«getModule().name».html#«name»">«name»</a></li>
	'''
}				

def static String graph(Application it) {
	'''
	<div id="graph">
		<hr/>
		<p><b>Modules</b></p>
		<a href="umlgraph-dependencies.dot.png">
		<img src="umlgraph-dependencies.dot.png" />
		</a>
		<hr/>
		<p><b>Overview</b></p>
		<a href="umlgraph-overview.dot.png">
		<img src="umlgraph-overview.dot.png" />
		</a>
	«IF existsCoreDomain()»
		<hr/>
		<p><b>Core Domain</b></p>
		<a href="umlgraph-core-domain.dot.png">
		<img src="umlgraph-core-domain.dot.png" />
		</a>
	«ENDIF»
	
	«FOR subjectArea : getSubjectAreas().reject(s|s == "entity")»
		<hr/>
		<p><b>Subject Area: «subjectArea»</b></p>
		<a href="umlgraph-«subjectArea».dot.png">
		<img src="umlgraph-«subjectArea».dot.png" />
		</a>
	«ENDFOR»
	
		<hr/>
		<p><b>Persistent Domain</b></p>
		<a href="umlgraph-entity.dot.png">
		<img src="umlgraph-entity.dot.png" />
		</a>
		<hr/>
		<p><b>All</b></p>
		<a href="umlgraph.dot.png">
		<img src="umlgraph.dot.png" />
		</a>
		<hr/>
	</div>
	'''
}

def static String graph(Module it) {
	'''
	<div id="module_graph">
	    <hr/>
	    <p><b>All in «name»</b></p>
		<a href="umlgraph-«name».dot.png">
		<img src="umlgraph-«name».dot.png" />
		</a>
		<hr/>
		<p><b>Persistent Domain in «name»</b></p>
		<a href="umlgraph-«this.application.modules.size > 1 ? name + "-" : ""»entity.dot.png">
		<img src="umlgraph-«this.application.modules.size > 1 ? name + "-" : ""»entity.dot.png" />
		</a>
	</div>
	'''
}

def static String serviceDoc(Service it) {
	'''
	<a name="«name»"></a>
	<h3>«name»</h3>
	<p>«doc»</p>
	«it.operations.sortBy(e| ((NamedElement) e).name).forEach[operationDoc(it)]»
	<hr/>
	'''
}

def static String operationDoc(Operation it) {
	'''
	<div id="operation">
	<b>«name»</b>
	<p>«doc»</p>
	«IF parameters.size > 0»
		<div id="operation_parameters">
		<p>Parameters:</p>
		<ul>
		«it.parameters.forEach[operationParameterDoc(it)]»
		</ul>
		</div>
	«ENDIF»
	«IF type != null || domainObjectType != null»
		<div id="operation_returns">
		<p>Returns:</p>
		<ul><li>«operationTypeDoc(it)» </li></ul>
		</div>
	«ENDIF»
	</div>
	'''
}

def static String operationParameterDoc(Parameter it) {
	'''
	<li>«operationTypeDoc(it)» «name»«IF doc != null»<br/>«doc»«ENDIF»</li>
	'''
}

def static String operationTypeDoc(DomainObjectTypedElement it) {
	'''
	«IF domainObjectType != null»
		«IF collectionType != null»«collectionType»&lt;«ENDIF»<a href="DomainModelDoc-«domainObjectType.module.name».html#«domainObjectType.name»">«domainObjectType.name»</a>«IF collectionType != null»&gt;«ENDIF»
	«ELSEIF type != null»
		«IF collectionType != null»«collectionType»&lt;«ENDIF»«type»«IF collectionType != null»&gt;«ENDIF»
	«ENDIF»
	'''
}

def static String consumerDoc(Consumer it) {
	'''
	<a name="«name»"></a>
	<h3>«name»</h3>
	<p>«doc»</p>
	<hr/>
	'''
}

def static String domainObjectDoc(DomainObject it) {
	'''
	<a name="«name»"></a>
	<h3>«name»</h3>
	«domainObjectCharacteristics(it)»
	<p>«doc»</p>
	<table>
		<thead>
			<th>Name</th>
			<th>Type</th>
			<th>Length</th>
			<th>Mandatory</th>
			<th>Changeable</th>
			<th>Description</th>
		</thead>

	«fieldDoc(it) FOREACH  {}.addAll(references.reject(r | r.transient)).addAll(attributes.reject(a | a.transient)).
			sortBy(e| ((NamedElement) e).name)»

	</table>
	«IF !operations.isEmpty»
		<p><i>Operations:</i></p>
		«it.operations.sortBy(e| ((NamedElement) e).name).forEach[operationDoc(it)]»
	«ENDIF»
	<hr/>
	'''
}

def static String domainObjectDoc(Enum it) {
	'''
	<a name="«name»"></a>
	<h3>«name»</h3>
	«domainObjectCharacteristics(it)»
	<p>«doc»</p>
	<table>
		<thead>
			<th>Name</th>
			<th>Description</th>
		</thead>

	«FOR val : values»
		<tr>
			<td>«val.name»</td>
			<td>«val.doc»</td>
		</tr>
	«ENDFOR»
	</table>
	<hr/>
	'''
}

	«DEFINE ^extendsCharacteristics FOR DomainObject»
	«IF ^extends != null»<p><i>^extends <a href="DomainModelDoc-«^extends.getModule().name».html#«^extends.name»">«^extends.name»</a></i></p>«ENDIF»
	'''
}

def static String domainObjectCharacteristics(DomainObject it) {
	'''
	<p>«IF isImmutable()»<i>Immutable</i>«ENDIF»</p>
	«(it)^extendsCharacteristics»
	«traitsCharacteristics(it)»
	'''
}

def static String domainObjectCharacteristics(Entity it) {
	'''
	<p><i>Entity</i>«IF !isAggregateRoot()», «notAggregateRootInfo(it)»«ENDIF»</p>
	«IF isImmutable()»<p><i>Immutable</i></p>«ENDIF»
	«(it)^extendsCharacteristics»
	«traitsCharacteristics(it)»
	'''
}

def static String notAggregateRootInfo(DomainObject it) {
	'''
	«val aggregateRootObject  = it.getAggregateRootObject()»
	not aggregate root, belongs to 
		<a href="DomainModelDoc-«aggregateRootObject.getModule().name».html#«aggregateRootObject.name»">«aggregateRootObject.name»</a>
	'''
}

def static String domainObjectCharacteristics(ValueObject it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» ValueObject</i>«IF !persistent», not persistent«ELSEIF !isAggregateRoot()», «notAggregateRootInfo(it)»«ENDIF»</p>
	«(it)^extendsCharacteristics»
	«traitsCharacteristics(it)»
	'''
}

def static String domainObjectCharacteristics(BasicType it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» BasicType</i></p>
	«traitsCharacteristics(it)»
	'''
}

def static String domainObjectCharacteristics(Enum it) {
	'''
	<p><i>Enum</i></p>
	'''
}

def static String domainObjectCharacteristics(DataTransferObject it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» DTO</i></p>
	«(it)^extendsCharacteristics»
	'''
}

def static String domainObjectCharacteristics(DomainEvent it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» DomainEvent</i></p>
	«(it)^extendsCharacteristics»
	«traitsCharacteristics(it)»
	'''
}

def static String domainObjectCharacteristics(CommandEvent it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» CommandEvent</i></p>
	«(it)^extendsCharacteristics»
	«traitsCharacteristics(it)»
	'''
}

def static String domainObjectCharacteristics(Trait it) {
	'''
	<p><i>Trait</i></p>
	'''
}

def static String traitsCharacteristics(DomainObject it) {
	'''
	«IF !traits.isEmpty»<p><i>«FOR t : traits» with <a href="DomainModelDoc-«t.getModule().name».html#«t.name»">«t.name»</a>«ENDFOR»</i></p>«ENDIF»
	'''
}

def static String fieldDoc(Object it) {
	'''
	'''
}

def static String fieldDoc(Attribute it) {
	'''
	«val isDto = it.getDomainObject().metaType == DataTransferObject»
	<tr>
		<td>«IF naturalKey»<b>«ENDIF»«name»«IF naturalKey»</b>«ENDIF»</td>
		<td>«IF collectionType != null»«collectionType»&lt;«ENDIF»«type»«IF collectionType != null»&gt;«ENDIF»</td>
		<td>«IF isDto || collectionType != null || getDatabaseLength() == null»&nbsp;«ELSE»«getDatabaseLength()»«ENDIF»</td>
		<td>«IF (isDto && !required) || (!isDto && nullable)»&nbsp;«ELSE»X«ENDIF»</td>
		<td>«IF changeable»X«ELSE»&nbsp;«ENDIF»</td>
		<td>«description(it)»</td>
	</tr>
	'''
}

def static String description(Attribute it) {
	'''
	«IF name == "id" && doc == null »
		Generated unique id (GID pk)
	«ELSEIF name == "createdBy" && doc == null »
		Information about who created the object
	«ELSEIF name == "lastUpdatedBy" && doc == null »
		Information about who last updated the object
	«ELSEIF name == "createdDate" && doc == null »
		Creation timestamp of the object
	«ELSEIF name == "lastUpdated" && doc == null »
		Last updated timestamp of the object
	«ELSEIF name == "version" && doc == null »
		Update counter used for optimistic locking
	«ELSEIF name == "uuid" && doc == null »
		Unique id needed for equals and hashCode, since there is no natural key
	«ELSE »
		«doc»
	«ENDIF »
	'''
}

def static String fieldDoc(Reference it) {
	'''
	«val isDto = it.from.metaType == DataTransferObject»
	<tr>
		<td>«IF naturalKey»<b>«ENDIF»«name»«IF naturalKey»</b>«ENDIF»</td>
		<td>«IF collectionType != null»«collectionType»&lt;«ENDIF»<a href="DomainModelDoc-«to.module.name».html#«to.name»">«to.name»</a>«IF collectionType != null»&gt;«ENDIF»</td>
		<td>&nbsp;</td>
		<td>«IF (isDto && !required) || (!isDto && nullable)»&nbsp;«ELSE»X«ENDIF»</td>
		<td>«IF changeable»X«ELSE»&nbsp;«ENDIF»</td>
		<td>«doc»</td>
	</tr>
	'''
}

}
