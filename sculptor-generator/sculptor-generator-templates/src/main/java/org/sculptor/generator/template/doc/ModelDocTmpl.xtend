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
package org.sculptor.generator.template.doc

import java.util.List
import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.ext.UmlGraphHelper
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.CommandEvent
import sculptormetamodel.Consumer
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainEvent
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectTypedElement
import sculptormetamodel.Entity
import sculptormetamodel.Enum
import sculptormetamodel.Module
import sculptormetamodel.NamedElement
import sculptormetamodel.Operation
import sculptormetamodel.Parameter
import sculptormetamodel.Reference
import sculptormetamodel.Service
import sculptormetamodel.Trait
import sculptormetamodel.ValueObject

/**
 * Generates summary documentation of the domain model.
 */
@ChainOverridable
class ModelDocTmpl {

	@Inject var ModelDocCssTmpl modelDocCssTmpl

	@Inject extension DbHelperBase dbHelperBase
	@Inject extension Helper helper
	@Inject extension Properties properties
	@Inject extension UmlGraphHelper umlGraphHelper

def void start(Application it) {
	docHtml(it)
	modelDocCssTmpl.docCss(it)
	it.modules.map[m | moduleDocHtml(m)].join()
}

def String docHtml(Application it) {
	val title = "Summary Documentation of " + name + " Domain Model"
	fileOutput("DomainModelDoc.html", OutputSlot.TO_DOC, '''
	«header(it, title)»

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
}

def String moduleDocHtml(Module it) {
	val title = "Summary Documentation of " + name + " module"
	fileOutput("DomainModelDoc-" + name + ".html", OutputSlot.TO_DOC, '''
	«header(it, title + "(" + application.name + ")")»
	<div id="wrap">
			<a name="module_«name»"></a>
	<h1>«title» <a href="DomainModelDoc.html">(«application.name»)</a></h1>
	
	
	«moduleDocContent(it)»

	</div>
	</body>
	</html>	
	'''
	)
}

def String header(Object it, String title) {
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

def String footer(Application it) {
	'''
	<div id="footer">
	<br/>
	<br/>
	</div>
	'''
}

def String main(Application it) {
	'''
	<div id="main">
	«it.modules.sortBy(e|e.name).map[moduleDoc(it)].join()»
	</div>
	'''
}


def String moduleDoc(Module it) {
	'''
	<a name="module_«name»"></a>
	<h2>Module «name»</h2>
	
	«moduleDocContent(it)»
	<hr/>
	'''
}

def String moduleDocContent(Module it) {
	'''
	<p>«doc»</p>
	«menu(it)»
	«IF isUMLToBeGenerated()»
		«graph(it)»
	«ENDIF»
	
	<div id="services">
	<hr/>
	«it.services.sortBy(e|e.name).map[e | serviceDoc(e)].join()»
	</div>
	<div id="consumers">
	«it.consumers.sortBy(e|e.name).map[e | consumerDoc(e)].join()»
	</div>
	<div id="domainObjects">
	«it.domainObjects.filter[d | ! (d instanceof Enum)]
		.sortBy(e|e.name).map[e | domainObjectDoc(e)].join()»
	«it.domainObjects.filter[d | d instanceof Enum]
		.sortBy(e|e.name).map[e | enumDoc(e as Enum)].join()»
	</div>
	'''
}

def dispatch String menu(Application it) {
	'''
	<div id="menu">
	«FOR m : modules.sortBy(e|e.name)»
		<h2><a href="DomainModelDoc-«m.name».html#module_«m.name»">«m.name»</a></h2>
			«menuItems(m)»
	«ENDFOR»
	</div>
	'''
}

def dispatch String menu(Module it) {
	'''
	<div id="menu">
			«menuItems(it)»
	</div>
	'''
}

def String menuItems(Module it) {
	val List<NamedElement> el = newArrayList()
	el.addAll(services)
	el.addAll(consumers)
	el.addAll(domainObjects)

	'''
		<ul>
			«el.sortBy[name].map[e | menuItem(e)].join»
		</ul>
	'''
}

def dispatch String menuItem(Object it) {
	'''
	'''
}

def dispatch String menuItem(NamedElement it) {
	'''
				<li><a href="DomainModelDoc-«it.getModule().name».html#«name»">«name»</a></li>
	'''
}

def dispatch String graph(Application it) {
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
	«IF it.existsCoreDomain()»
		<hr/>
		<p><b>Core Domain</b></p>
		<a href="umlgraph-core-domain.dot.png">
		<img src="umlgraph-core-domain.dot.png" />
		</a>
	«ENDIF»
	
	«FOR subjectArea : it.getSubjectAreas().filter(s|s != "entity")»
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

def dispatch String graph(Module it) {
	'''
	<div id="module_graph">
	    <hr/>
	    <p><b>All in «name»</b></p>
		<a href="umlgraph-«name».dot.png">
		<img src="umlgraph-«name».dot.png" />
		</a>
		<hr/>
		<p><b>Persistent Domain in «name»</b></p>
		<a href="umlgraph-«if (it.application.modules.size > 1) name + "-" else ""»entity.dot.png">
		<img src="umlgraph-«if (it.application.modules.size > 1) name + "-" else ""»entity.dot.png" />
		</a>
	</div>
	'''
}

def String serviceDoc(Service it) {
	'''
	<a name="«name»"></a>
	<h3>«name»</h3>
	<p>«doc»</p>
	«it.operations.sortBy(e| e.name).map[operationDoc(it)].join()»
	<hr/>
	'''
}

def String operationDoc(Operation it) {
	'''
	<div id="operation">
	<b>«name»</b>
	<p>«doc»</p>
	«IF parameters.size > 0»
		<div id="operation_parameters">
		<p>Parameters:</p>
		<ul>
		«it.parameters.map[operationParameterDoc(it)].join()»
		</ul>
		</div>
	«ENDIF»
	«IF type !== null || domainObjectType !== null»
		<div id="operation_returns">
		<p>Returns:</p>
		<ul><li>«operationTypeDoc(it)» </li></ul>
		</div>
	«ENDIF»
	</div>
	'''
}

def String operationParameterDoc(Parameter it) {
	'''
	<li>«operationTypeDoc(it)» «name»«IF doc !== null»<br/>«doc»«ENDIF»</li>
	'''
}

def String operationTypeDoc(DomainObjectTypedElement it) {
	'''
	«IF domainObjectType !== null»
		«IF collectionType !== null»«collectionType»&lt;«ENDIF»<a href="DomainModelDoc-«domainObjectType.module.name».html#«domainObjectType.name»">«domainObjectType.name»</a>«IF collectionType !== null»&gt;«ENDIF»
	«ELSEIF type !== null»
		«IF collectionType !== null»«collectionType»&lt;«ENDIF»«type»«IF collectionType !== null»&gt;«ENDIF»
	«ENDIF»
	'''
}

def String consumerDoc(Consumer it) {
	'''
	<a name="«name»"></a>
	<h3>«name»</h3>
	<p>«doc»</p>
	<hr/>
	'''
}

def String domainObjectDoc(DomainObject it) {
	val List<NamedElement> el = newArrayList()
	el.addAll(references.filter(r | !r.transient).toList)
	el.addAll(attributes.filter(a | !a.transient).toList)

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

	«el.sortBy[e | e.name].map[m | fieldDoc(m)].join»

	</table>
	«IF !operations.isEmpty»
		<p><i>Operations:</i></p>
		«it.operations.sortBy(e | e.name).map[operationDoc(it)].join»
	«ENDIF»
	<hr/>
	'''
}

def String enumDoc(Enum it) {
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

	«FOR eVal : values»
		<tr>
			<td>«eVal.name»</td>
			<td>«eVal.doc»</td>
		</tr>
	«ENDFOR»
	</table>
	<hr/>
	'''
}

def String extendsCharacteristics (DomainObject it) {
	'''
	«IF ^extends !== null»<p><i>^extends <a href="DomainModelDoc-«^extends.getModule().name».html#«^extends.name»">«^extends.name»</a></i></p>«ENDIF»
	'''
}

def dispatch String domainObjectCharacteristics(DomainObject it) {
	'''
	<p>«IF it.isImmutable()»<i>Immutable</i>«ENDIF»</p>
	«extendsCharacteristics(it)»
	«traitsCharacteristics(it)»
	'''
}

def dispatch String domainObjectCharacteristics(Entity it) {
	'''
	<p><i>Entity</i>«IF !isAggregateRoot()», «notAggregateRootInfo(it)»«ENDIF»</p>
	«IF it.isImmutable()»<p><i>Immutable</i></p>«ENDIF»
	«extendsCharacteristics(it)»
	«traitsCharacteristics(it)»
	'''
}

def String notAggregateRootInfo(DomainObject it) {
	val aggregateRootObject  = it.getAggregateRootObject()
	if (aggregateRootObject !== null) '''
			not aggregate root, belongs to 
				<a href="DomainModelDoc-«aggregateRootObject?.getModule().name».html#«aggregateRootObject.name»">«aggregateRootObject.name»</a>
	''' else ""
}

def dispatch String domainObjectCharacteristics(ValueObject it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» ValueObject</i>«IF !persistent», not persistent«ELSEIF !isAggregateRoot()», «notAggregateRootInfo(it)»«ENDIF»</p>
	«extendsCharacteristics(it)»
	«traitsCharacteristics(it)»
	'''
}

def dispatch String domainObjectCharacteristics(BasicType it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» BasicType</i></p>
	«traitsCharacteristics(it)»
	'''
}

def dispatch String domainObjectCharacteristics(Enum it) {
	'''
	<p><i>Enum</i></p>
	'''
}

def dispatch String domainObjectCharacteristics(DataTransferObject it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» DTO</i></p>
	«extendsCharacteristics(it)»
	'''
}

def dispatch String domainObjectCharacteristics(DomainEvent it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» DomainEvent</i></p>
	«extendsCharacteristics(it)»
	«traitsCharacteristics(it)»
	'''
}

def dispatch String domainObjectCharacteristics(CommandEvent it) {
	'''
	<p><i>«IF isImmutable()»Immutable «ENDIF» CommandEvent</i></p>
	«extendsCharacteristics(it)»
	«traitsCharacteristics(it)»
	'''
}

def dispatch String domainObjectCharacteristics(Trait it) {
	'''
	<p><i>Trait</i></p>
	'''
}

def String traitsCharacteristics(DomainObject it) {
	'''
	«IF !traits.isEmpty»<p><i>«FOR t : traits» with <a href="DomainModelDoc-«t.getModule().name».html#«t.name»">«t.name»</a>«ENDFOR»</i></p>«ENDIF»
	'''
}

def dispatch String fieldDoc(Object it) {
	'''
	'''
}

def dispatch String fieldDoc(Attribute it) {
	'''
	«val isDto = it.getDomainObject() instanceof DataTransferObject»
	<tr>
		<td>«IF naturalKey»<b>«ENDIF»«name»«IF naturalKey»</b>«ENDIF»</td>
		<td>«IF collectionType !== null»«collectionType»&lt;«ENDIF»«type»«IF collectionType !== null»&gt;«ENDIF»</td>
		<td>«IF isDto || collectionType !== null || it.getDatabaseLength() === null»&nbsp;«ELSE»«it.getDatabaseLength()»«ENDIF»</td>
		<td>«IF (isDto && !required) || (!isDto && nullable)»&nbsp;«ELSE»X«ENDIF»</td>
		<td>«IF changeable»X«ELSE»&nbsp;«ENDIF»</td>
		<td>«description(it)»</td>
	</tr>
	'''
}

def String description(Attribute it) {
	'''
	«IF name == "id" && doc === null »
		Generated unique id (GID pk)
	«ELSEIF name == "createdBy" && doc === null »
		Information about who created the object
	«ELSEIF name == "lastUpdatedBy" && doc === null »
		Information about who last updated the object
	«ELSEIF name == "createdDate" && doc === null »
		Creation timestamp of the object
	«ELSEIF name == "lastUpdated" && doc === null »
		Last updated timestamp of the object
	«ELSEIF name == "version" && doc === null »
		Update counter used for optimistic locking
	«ELSEIF name == "uuid" && doc === null »
		Unique id needed for equals and hashCode, since there is no natural key
	«ELSE »
		«doc»
	«ENDIF »
	'''
}

def dispatch String fieldDoc(Reference it) {
	'''
	«val isDto = it.from instanceof DataTransferObject»
	<tr>
		<td>«IF naturalKey»<b>«ENDIF»«name»«IF naturalKey»</b>«ENDIF»</td>
		<td>«IF collectionType !== null»«collectionType»&lt;«ENDIF»<a href="DomainModelDoc-«to.module.name».html#«to.name»">«to.name»</a>«IF collectionType !== null»&gt;«ENDIF»</td>
		<td>&nbsp;</td>
		<td>«IF (isDto && !required) || (!isDto && nullable)»&nbsp;«ELSE»X«ENDIF»</td>
		<td>«IF changeable»X«ELSE»&nbsp;«ENDIF»</td>
		<td>«doc»</td>
	</tr>
	'''
}

}
