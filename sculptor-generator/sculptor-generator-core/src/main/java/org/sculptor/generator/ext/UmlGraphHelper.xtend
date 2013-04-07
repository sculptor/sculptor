/*
 * Copyright 2007-2013 The Fornax Project Team, including the original 
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

package org.sculptor.generator.ext

import java.util.List
import java.util.Set
import javax.inject.Inject
import org.sculptor.generator.util.PropertiesBase
import org.sculptor.generator.util.SingularPluralConverter
import sculptormetamodel.Application
import sculptormetamodel.BasicType
import sculptormetamodel.Consumer
import sculptormetamodel.DomainObject
import sculptormetamodel.Entity
import sculptormetamodel.Module
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.Service
import sculptormetamodel.ValueObject

public class UmlGraphHelper {
	@Inject var SingularPluralConverter singularPluralConverter

	@Inject extension PropertiesBase propertiesBase
	@Inject extension Helper helper

	def String referenceHeadLabel(Reference ref) {
		(if (ref.many) "0..n " else "") + ref.referenceLabelText()
	}

	def String referenceTailLabel(Reference ref) {
		if (ref.opposite == null)
			""
		else
			(if (ref.opposite.many) "0..n " else "") + ref.opposite.referenceLabelText()
	}

	def String referenceLabelText(Reference ref) {
		if (ref.name.toSingular().toLowerCase() == ref.to.name.toLowerCase())
			// almost same reference name as the to DomainObject, skip
			""
		else
			ref.name
	}

	def boolean isAggregate(Reference ref) {
		ref.isOneToMany() && ref.to.isEntityOrPersistentValueObject() && !ref.to.aggregateRoot
	}

	def String dotFileName(Application app, Set<Module> focus, int detail, String subjectArea) {
		val detailPart = if (detail == 0)
				"-" + subjectArea
			else if (detail == 1)
				""
			else if (detail == 2)
				"-core-domain"
			else if (detail == 3) 
				"-overview"
			else
				"-dependencies"

		if (focus.size == app.visibleModules.size)
			"umlgraph" + detailPart + ".dot"
		else 
			"umlgraph-" + focus.map[m|m.name].sortBy[it].join("-") + detailPart + ".dot"
	}

	def Set<DomainObject> serviceOperationDependencies(Service from) {
		val Set<DomainObject> retVal = newHashSet()

		retVal.addAll(from.operations.map[parameters].flatten.filter[e|e.domainObjectType != null].map[domainObjectType].toSet)
		retVal.addAll(from.operations.filter[e|e.domainObjectType != null].map[domainObjectType].toSet)

		retVal
	}

	// Get all the subject areas used throughout the application
	def dispatch Set<String> getSubjectAreas(Application application) {
		val retVal = newArrayList("entity")

		retVal.addAll(application.visibleModules().map[domainObjects].flatten.map[d | d.getSubjectAreas()].flatten)
		retVal.addAll(application.visibleModules().map[services].flatten.map[s | s.getSubjectAreas()].flatten)

		retVal.filterNull.toSet
	}

	def dispatch List<String> getSubjectAreas(NamedElement elem) {
		if (elem.hasHint("umlgraph.subject"))
			elem.getHint("umlgraph.subject").replaceAll(" ", "").split("\\|").toList
		else
			newArrayList()
	}

	def Set<Module> moduleDependencies(Module from) {
		val List<Module> retVal=newArrayList
		retVal.addAll(from.domainObjects.map[references].flatten.map[e|e.to.module])
		retVal.addAll(from.domainObjects.filter[e|e.getExtends != null].map[e|e.getExtends.module])
		retVal.addAll(from.services.map[s | s.serviceDependencies as List<Service>].flatten.map[module])
		retVal.addAll(from.services.map[s | s.serviceOperationDependencies].flatten.map[module])
		retVal.addAll(from.consumers.map[serviceDependencies as List<Service>].flatten.map[module])

		retVal.filter[e | e != from].toSet
	}

	def visibleModules(Application app) {
		app.modules.filter[e | e.visible()]
	}

	def boolean visible(NamedElement elem) {
		!elem.hide
	}

	def dispatch boolean hide(DomainObject elem) {
		elem.hasHideHint || elem.module.hide
	}

	def dispatch boolean hide(Service elem) {
		elem.hasHideHint || elem.module.hide
	}

	def dispatch boolean hide(Consumer elem) {
		elem.hasHideHint || elem.module.hide
	}

	def dispatch boolean hide(NamedElement elem) {
		elem.hasHideHint
	}

	def private hasHideHint(NamedElement elem) {
		elem.getHint("umlgraph") == "hide"
	}

	def boolean isShownInView(DomainObject domainObject, Set<Module> focus, int detail, String subjectArea) {
		detail < 4 && domainObject.visible() && focus.contains(domainObject.module)
			&& (detail != 0 || domainObject.isInSubjectArea(subjectArea))
			&& (!(domainObject instanceof sculptormetamodel.Enum) && !(domainObject instanceof BasicType) 
				|| (domainObject instanceof sculptormetamodel.Enum && getBooleanProperty("generate.umlgraph.enum"))
				|| (domainObject instanceof BasicType && getBooleanProperty("generate.umlgraph.basicType"))
				|| (focus.size != domainObject.module.application.visibleModules().size))
	}

	def bgcolor(NamedElement elem) {
		if (elem.hasHint("umlgraph.bgcolor"))
			elem.getHint("umlgraph.bgcolor")
		else
			bgcolorFromProperty(elem)
	}

	def fontcolor(NamedElement elem) {
		if (elem.hasHint("umlgraph.fontcolor"))
			elem.getHint("umlgraph.fontcolor")
		else
			fontcolorFromProperty(elem)

	}

	def String getStereoTypeName(NamedElement elem) {
		elem.simpleMetaTypeName()
	}

	def private bgcolorFromProperty(NamedElement elem) {
		val prop1 = "umlgraph.bgcolor." + (if (elem.isCoreDomain()) "core." else "") + elem.getStereoTypeName()
		val prop2 = "umlgraph.bgcolor." + elem.getStereoTypeName()

		if (hasProperty(prop1))
			getProperty(prop1)
		else if (hasProperty(prop2))
			getProperty(prop2)
		else
			"D0D0D0"
	}

	def private fontcolorFromProperty(NamedElement elem) {
		val prop1 = "umlgraph.fontcolor." + (if (elem.isCoreDomain()) "core." else "") + elem.getStereoTypeName()
		val prop2 = "umlgraph.fontcolor." + elem.getStereoTypeName()
		if (hasProperty(prop1))
			getProperty(prop1)
		else if (hasProperty(prop2))
			getProperty(prop2)
		else
			"black"
	}

	def existsCoreDomain(Application app) {
		app.modules.exists(e|e.isCoreDomain())
			|| app.modules.map[domainObjects as List<DomainObject>].flatten.exists(e|e.isCoreDomain())
			|| app.modules.map[services as List<Service>].flatten.exists(e|e.isCoreDomain())
			|| app.modules.map[consumers as List<Consumer>].flatten.exists(e|e.isCoreDomain())
	}

	def dispatch boolean isCoreDomain(DomainObject elem) {
		elem.hasCoreDomainHint() || elem.module.isCoreDomain()
	}

	def dispatch boolean isCoreDomain(Service elem) {
		elem.hasCoreDomainHint() || elem.module.isCoreDomain()
	}

	def dispatch boolean isCoreDomain(Consumer elem) {
		elem.hasCoreDomainHint() || elem.module.isCoreDomain()
	}

	def dispatch boolean isCoreDomain(NamedElement elem) {
		elem.hasCoreDomainHint()
	}

	def private boolean hasCoreDomainHint(NamedElement elem) {
		elem.getHint("umlgraph") == "core"
	}

	def showCompartment(NamedElement elem, int detail) {
		detail <= 1 || (detail == 2 && elem.isCoreDomain())
	}

	def String labeldistance(Reference ref) {
		getProperty("umlgraph.labeldistance")
	}

	def String labelangle(Reference ref) {
		getProperty("umlgraph.labelangle")
	}

	// Return true if the given element should be included in the diagram at the given level of detail and for the given subjectArea
	def boolean includeInDiagram(NamedElement elem, int detail, String subjectArea) {
		elem.visible() && (detail != 0 || elem.isInSubjectArea(subjectArea))
	}

	def dispatch boolean isInSubjectArea(ValueObject v, String subjectArea) {
		if ("entity" == subjectArea) v.isPersistent() else v.getSubjectAreas().contains(subjectArea)
	}

	def dispatch boolean isInSubjectArea(Entity e, String subjectArea) {
		if ("entity" == subjectArea) e.isPersistent() else e.getSubjectAreas().contains(subjectArea)
	}

	def dispatch boolean isInSubjectArea(NamedElement elem, String subjectArea) {
		elem.getSubjectAreas().contains(subjectArea)
	}

	def String toSingular(String str) {
		singularPluralConverter.toSingular(str)
	}
}
