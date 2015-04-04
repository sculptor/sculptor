/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *		http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.generator.transform

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.CommandEvent
import sculptormetamodel.DomainEvent
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Enum
import sculptormetamodel.Module
import sculptormetamodel.NamedElement
import sculptormetamodel.Operation
import sculptormetamodel.Parameter
import sculptormetamodel.Reference
import sculptormetamodel.Repository
import sculptormetamodel.RepositoryOperation
import sculptormetamodel.SculptormetamodelFactory
import sculptormetamodel.Service
import sculptormetamodel.Trait
import sculptormetamodel.ValueObject

/**
 * Enriches generator meta model.
 */
class Transformation {

	private static val SculptormetamodelFactory FACTORY = SculptormetamodelFactory::eINSTANCE

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties
	@Inject extension RestTransformation restTransformation
	@Inject extension TransformationHelper transformationHelper

	def Application modify(Application app) {
		initPropertiesHook()
		app.modules.map[domainObjects].flatten.filter[it instanceof Trait].forEach[modifyChangeable((it as Trait))]
		app.modules.map[domainObjects].flatten.forEach[mixin()]
		app.modules.map[domainObjects].flatten.forEach[modifyExtends()]
		app.modules.map[it.getNonEnumDomainObjects].flatten.forEach[modifyUuid()]
		if (isModifyDynamicFindersEnabled) {
			// Avoid concurrent modification exception because
			// modifyDynamicFinderOperations is inserting new operations to repository
			val opList = app.allRepositories.map[operations].flatten.filter [ e |
				!e.delegateToAccessObject && !e.isGenericAccessObject && e.isGeneratedFinder
			].toList
			opList.forEach[modifyDynamicFinderOperations()]
		}
		if (isModifyPagingOperationsEnabled) {
			app.allRepositories.forEach[modifyPagingOperations()]
		}
		app.getAllRepositories().forEach[addDefaultValues()]
		app.getAllRepositories().forEach[modifySubscriber()]
		app.modules.forEach[serviceAddDefaultValues()]
		app.modules.forEach[resourceAddDefaultValues()]
		app.modules.map[domainObjects].flatten.forEach[modifyBelongsToAggregate()]
		app.modules.map[domainObjects].flatten.filter[it instanceof ValueObject].forEach[modifySubclassesPersistent((it as ValueObject))]
		app.modules.map[domainObjects].flatten.filter[it instanceof ValueObject].forEach[modifyAbstractPersistent((it as ValueObject))]
		app.modules.map[domainObjects].flatten.filter[it instanceof Trait].forEach[modifyTrait((it as Trait))]
		app.modules.forEach[modify()]
		app.modules.forEach[modifyModuleDatabaseNames()]
		app.modules.forEach[modifyModuleReferencesDatabaseNames()]
		app.modules.map[resources].flatten.map[operations].flatten.forEach[addRestDefaults()]
		app
	}

	def void mixin(DomainObject domainObject) {
		domainObject.traits.reverseView.forEach[mixin(it as NamedElement, domainObject)]
	}

	def dispatch void mixin(Trait trait, DomainObject domainObject) {
		trait.attributes.forEach[mixin(it, domainObject)]
		trait.references.forEach[mixin(it, domainObject)]
		trait.operations.forEach[mixin(it, domainObject)]
	}

	def dispatch void mixin(Attribute att, DomainObject domainObject) {
		domainObject.addIfNotExists(att.mixinClone(domainObject))
	}

	def dispatch void mixin(Reference ref, DomainObject domainObject) {
		domainObject.addIfNotExists(ref.mixinClone(domainObject))
	}

	def dispatch void mixin(DomainObjectOperation op, DomainObject domainObject) {
		domainObject.addIfNotExists(op.mixinClone(domainObject))
	}

	def dispatch create FACTORY.createAttribute mixinClone(Attribute att, DomainObject domainObject) {
		setChangeable(att.changeable)
		setCollectionType(att.collectionType)
		setDatabaseColumn(att.databaseColumn)
		setDatabaseType(att.databaseType)
		setDoc(att.doc)
		setHint(att.hint)
		addHint("trait=" + att.getDomainObject().name)
		setIndex(att.index)
		setLength(att.length)
		setMapKeyType(att.mapKeyType)
		setName(att.name)
		setNaturalKey(att.naturalKey)
		setNullable(att.nullable)
		setRequired(att.required)
		setTransient(att.transient)
		setType(att.type)
		setValidate(att.validate)
		setVisibility(att.visibility)
	}

	def dispatch create FACTORY.createReference mixinClone(Reference ref, DomainObject domainObject) {
		setCache(ref.cache)
		setCascade(ref.cascade)
		setChangeable(ref.changeable)
		setCollectionType(ref.collectionType)
		setDatabaseColumn(ref.databaseColumn)
		setDatabaseJoinColumn(ref.databaseJoinColumn)
		setDatabaseJoinTable(ref.databaseJoinTable)
		setDoc(ref.doc)
		setFetch(ref.fetch)
		setFrom(domainObject)
		setHint(ref.hint)
		addHint("trait=" + ref.getDomainObject().name)
		setInverse(ref.inverse)
		setMany(ref.many)
		setName(ref.name)
		setNaturalKey(ref.naturalKey)
		setNullable(ref.nullable)
		// opposite not supported
		setOrderBy(ref.orderBy)
		setRequired(ref.required)
		setTransient(ref.transient)
		setTo(ref.to)
		setValidate(ref.validate)
		setVisibility(ref.visibility)
	}

	def dispatch create FACTORY.createDomainObjectOperation mixinClone(DomainObjectOperation op, DomainObject domainObject) {
		setAbstract(op.^abstract)
		setCollectionType(op.collectionType)
		setDoc(op.doc)
		setDomainObjectType(op.domainObjectType)
		setHint(op.hint)
		addHint("trait=" + op.domainObject.name)
		setMapKeyType(op.mapKeyType)
		setName(op.name)
		parameters.addAll(op.parameters.map[it.mixinClone(op, domainObject)])
		setPublish(op.publish)
		setThrows(op.^throws)
		setType(op.type)
		setVisibility(op.visibility)
	}

	def create FACTORY.createParameter mixinClone(Parameter param, DomainObjectOperation op, DomainObject domainObject) {
		setCollectionType(param.collectionType)
		setDoc(param.doc)
		setDomainObjectType(param.domainObjectType)
		setHint(param.hint)
		setMapKeyType(param.mapKeyType)
		setName(param.name)
		setType(param.type)
	}

	def void modify(Module module) {
		module.setPersistenceUnit(if (module.hasHint("persistenceUnit")) module.getHint("persistenceUnit") else module.application.persistenceUnitName())
		if (isServiceContextToBeGenerated())
			module.services.forEach[modifyServiceContextParameter()]
		module.services.forEach[modifySubscriber()]
		module.services.forEach[modifyApplicationException()]
		module.services.forEach[modifyGapClass()]
		module.resources.forEach[modifyGapClass()]
		module.domainObjects.forEach[modifyGapClass()]
		module.getNonEnumDomainObjects().filter(d | d.^extends == null).forEach[modifyIdAttribute()]
		module.getNonEnumDomainObjects().forEach[modifyAuditable()]
		module.getNonEnumDomainObjects().forEach[modifyChangeable()]
		module.getNonEnumDomainObjects().forEach[modifyTransient()]
		module.getNonEnumDomainObjects().forEach[modifyOptimisticLocking()]
		module.domainObjects.filter[it instanceof DomainEvent].forEach[modifyDomainEvent((it as DomainEvent))]
		module.domainObjects.filter[it instanceof CommandEvent].forEach[modifyCommandEvent((it as CommandEvent))]

		module.domainObjects.filter[it instanceof Enum].forEach[modifyEnum((it as Enum))]
		module.domainObjects.forEach[modifyInheritance()]
	}

	def void modifyDomainEvent(DomainEvent event) {
		if (event.^extends != null)
			(event.^extends as DomainEvent).modifyDomainEvent()
		if (!event.getAllAttributes().exists(e|e.name == "recorded"))
			event.attributes.add(0, createEventTimestamp(event, "recorded"))
		if (!event.getAllAttributes().exists(e|e.name == "occurred"))
			event.attributes.add(0, createEventTimestamp(event, "occurred"))
	}

	def void modifyCommandEvent(CommandEvent event) {
		val newOccurred = createEventTimestamp(event, "occurred")
		newOccurred.setIndex(true)
		if (event.^extends != null)
			(event.^extends as CommandEvent).modifyCommandEvent()
		if (!event.getAllAttributes().exists(e|e.name == "recorded"))
			event.attributes.add(0, createEventTimestamp(event, "recorded"))
		if (!event.getAllAttributes().exists(e|e.name == "occurred"))
			event.attributes.add(0, newOccurred)
	}

	def create FACTORY.createAttribute createEventTimestamp(DomainObject event, String name) {
		it.setName(name)
		it.setType("Timestamp")
		it.setChangeable(false)
	}

	def dispatch void modifySubscriber(Service service) {
		if (service.subscribe != null && !service.operations.exists(e|e.name == "receive"))
			service.operations.add(createSubscriberReceive(service))
	}

	def create FACTORY.createServiceOperation createSubscriberReceive(Service service) {
		setName("receive")
		parameters.add(createSubscriberReceiveEventParam(it))
	}

	def dispatch void modifySubscriber(Repository repository) {
		if (repository.subscribe != null && !repository.operations.exists(e|e.name == "receive"))
			repository.operations.add(createSubscriberReceive(repository))
	}

	def create FACTORY.createRepositoryOperation createSubscriberReceive(Repository repository) {
		setName("receive")
		parameters.add(createSubscriberReceiveEventParam(it))
	}

	def create FACTORY.createParameter createSubscriberReceiveEventParam(Operation op) {
		setName("event")
		setType(fw("event.Event"))
	}

	def void modifyTrait(Trait trait) {
		trait.attributes.forEach[addDerivedTraitPropertyAccessors(trait)]
		trait.references.forEach[addDerivedTraitPropertyAccessors(trait)]
	}

	def dispatch void addDerivedTraitPropertyAccessors(Attribute att, Trait trait) {
		val getter = createDerivedTraitGetter(trait, att)
		val setter = createDerivedTraitSetter(trait, att)
		if (!trait.operations.exists(e|e.name == getter.name && e.type == getter.type && e.parameters.isEmpty))
			trait.operations.add(getter)
		if (att.changeable && !trait.operations.exists(e|e.name == setter.name && e.type == setter.type && e.parameters.size == 1 && e.parameters.get(0).type == att.type))
			trait.operations.add(setter)
	}

	def dispatch void addDerivedTraitPropertyAccessors(Reference ref, Trait trait) {
		val getter = createDerivedTraitGetter(trait, ref)
		val setter = createDerivedTraitSetter(trait, ref)
		if (!trait.operations.exists(e|e.name == getter.name && e.domainObjectType == getter.domainObjectType && e.parameters.isEmpty))
			trait.operations.add(getter)
		if (ref.changeable && !ref.many && !trait.operations.exists(e|e.name == setter.name && e.domainObjectType == setter.domainObjectType && e.parameters.size == 1 && e.parameters.get(0).domainObjectType == ref.to))
			trait.operations.add(setter)
	}

	def dispatch create FACTORY.createDomainObjectOperation createDerivedTraitGetter(Trait trait, Attribute att) {
		it.setName(att.getGetAccessor())
		it.setAbstract(true)
		it.addHint("trait=" + trait.name)
		it.setType(att.type)
		it.setCollectionType(att.collectionType)
		it.setMapKeyType(att.mapKeyType)
		it.setDoc(att.doc)
		it.setVisibility(att.visibility)
	}

	def dispatch create FACTORY.createDomainObjectOperation createDerivedTraitGetter(Trait trait, Reference ref) {
		it.setName("get" + ref.name.toFirstUpper())
		it.setAbstract(true)
		it.addHint("trait=" + trait.name)
		it.setDomainObjectType(ref.to)
		it.setCollectionType(ref.collectionType)
		it.setDoc(ref.doc)
		it.setVisibility(ref.visibility)
	}

	def dispatch create FACTORY.createDomainObjectOperation createDerivedTraitSetter(Trait trait, Attribute att) {
		it.setName("set" + att.name.toFirstUpper())
		it.setAbstract(true)
		it.setDoc(att.doc)
		it.setVisibility(att.visibility)
		it.parameters.add(createDerivedTraitSetterParameter(trait, att))
	}

	def dispatch create FACTORY.createDomainObjectOperation createDerivedTraitSetter(Trait trait, Reference ref) {
		it.setName("set" + ref.name.toFirstUpper())
		it.setAbstract(true)
		it.setDoc(ref.doc)
		it.setVisibility(ref.visibility)
		it.parameters.add(createDerivedTraitSetterParameter(trait, ref))
	}

	def dispatch create FACTORY.createParameter createDerivedTraitSetterParameter(Trait trait, Attribute att) {
		it.setName(att.name)
		it.setType(att.type)
		it.setCollectionType(att.collectionType)
		it.setMapKeyType(att.mapKeyType)
	}

	def dispatch create FACTORY.createParameter createDerivedTraitSetterParameter(Trait trait, Reference ref) {
		it.setName(ref.name)
		it.setDomainObjectType(ref.to)
		it.setCollectionType(ref.collectionType)
	}

	def void modifyPagingOperations(Repository repository) {
		val pagingOperations = repository.operations.filter(e | e.hasPagingParameter())
		val pagedFindAll = pagingOperations.findFirst(e|e.name == "findAll")
		val pagedFindByQuery = pagingOperations.findFirst(e|e.name == "findByQuery")
		pagingOperations.forEach[modifyPagingOperation()]
		if (!jpa() && pagedFindAll != null && !pagedFindAll.hasHint("countQuery") && !pagedFindAll.hasHint("countOperation")) {
			pagedFindAll.addCountAllHint()
			if (!repository.operations.exists(e|e.name == "countAll"))
				repository.operations.add(createCountAll(repository))
		}
		if (!jpa() && (pagedFindByQuery != null || pagingOperations.exists(e|e.hasHint("countQuery"))) &&
			!repository.operations.exists(e|e.name == "findByQuery" && e.parameters.exists(p|p.name == "useSingleResult")))
			repository.operations.add(createFindByQuerySingleResult(repository, true))
	}

	def create FACTORY.createRepositoryOperation createFindByQuerySingleResult(Repository repository, boolean useSingleResult) {
		it.setName("findByQuery")
		it.setVisibility("protected")
		it.setRepository(repository)
		if (useSingleResult)
			it.parameters.add(createUseSingleResultParameter(it))
	}

	def create FACTORY.createParameter createUseSingleResultParameter(RepositoryOperation operation) {
		it.setName("useSingleResult")
		it.setType("boolean")
	}

	def create FACTORY.createRepositoryOperation createCountAll(Repository repository) {
		it.setName("countAll")
		it.setVisibility("protected")
		it.setRepository(repository)
	}

	def void modifyDynamicFinderOperations(RepositoryOperation op) {
		if (op.type == null && op.domainObjectType == null) {
			op.setDomainObjectType(op.repository.aggregateRoot)
			op.setCollectionType("List")
		}
		if (op.hasHint("paged")) {
			op.parameters.add(createParameter(op, "pagingParameter", "PagingParameter"))
			op.setCollectionType("List")
			op.setType("PagedResult")
			op.setDomainObjectType(op.repository.aggregateRoot)
		}
		if (op.isQueryBased())
			op.modifyQueryOperations()
		else
			op.modifyConditionOperations()
	}

	def void modifyQueryOperations(RepositoryOperation op) {
		if (op.collectionType == null && !op.repository.operations.exists(e|e.name == "findByQuery" && e.parameters.exists(p|p.name == "useSingleResult")))
			op.repository.operations.add(createFindByQuerySingleResult(op.repository, true))
		if (op.collectionType != null && !op.repository.operations.exists(e|e.name == "findByQuery"))
			op.repository.operations.add(createFindByQuerySingleResult(op.repository, false))
	}

	def void modifyConditionOperations(RepositoryOperation op) {
		if (op.collectionType == null && !op.repository.operations.exists(e|e.name == "findByCondition" && e.parameters.exists(p|p.name == "useSingleResult")))
			op.repository.operations.add(createFindByCondition(op.repository, true))
		if (op.collectionType != null && !op.repository.operations.exists(e|e.name == "findByCondition"))
			op.repository.operations.add(createFindByCondition(op.repository, false))
	}

	def private create FACTORY.createRepositoryOperation createFindByCondition(Repository repository, boolean useSingleResult) {
		it.setName("findByCondition")
		it.setVisibility("protected")
		it.setRepository(repository)
		it.parameters.add(createParameter(it, "condition", "java.util.List<org.sculptor.framework.accessapi.ConditionalCriteria>"))
		if (useSingleResult) {
			it.setDomainObjectType(repository.aggregateRoot)
			it.setCollectionType(null)
			it.parameters.add(createParameter(it, "useSingleResult", "boolean"))
		}
	}

	def private create FACTORY.createParameter createParameter(RepositoryOperation operation, String name, String type) {
		it.setName(name)
		it.setType(type)
	}

}
