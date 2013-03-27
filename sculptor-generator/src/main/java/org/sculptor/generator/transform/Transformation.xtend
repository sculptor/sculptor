/*
 * Copyright 2007 The Fornax Project Team, including the original
 * author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use it file except in compliance with the License.
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
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.CommandEvent
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainEvent
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Entity
import sculptormetamodel.Enum
import sculptormetamodel.Module
import sculptormetamodel.Operation
import sculptormetamodel.Parameter
import sculptormetamodel.Reference
import sculptormetamodel.Repository
import sculptormetamodel.RepositoryOperation
import sculptormetamodel.Resource
import sculptormetamodel.SculptormetamodelFactory
import sculptormetamodel.Service
import sculptormetamodel.ServiceOperation
import sculptormetamodel.Trait
import sculptormetamodel.ValueObject

class Transformation {
	private static val SculptormetamodelFactory FACTORY = SculptormetamodelFactory::eINSTANCE

	@Inject extension DbHelper dbHelper
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

	def Application modify(Application app) {
		initPropertiesHook()
		app.modules.map[domainObjects].flatten.filter[it instanceof Trait].forEach[modifyChangeable((it as Trait))]
		app.modules.map[domainObjects].flatten.forEach[mixin()]
		app.modules.map[domainObjects].flatten.forEach[modifyExtends()]
		app.modules.map[it.getNonEnumDomainObjects].flatten.forEach[modifyUuid()]
		app.getAllRepositories().map[operations].flatten.filter(e | !e.delegateToAccessObject && !e.isGenericAccessObject() && e.isGeneratedFinder()).forEach[modifyDynamicFinderOperations()]
		app.getAllRepositories().forEach[modifyPagingOperations()]
		app.getAllRepositories().forEach[addDefaultValues()]
		app.getAllRepositories().forEach[modifySubscriber()]
		app.modules.forEach[serviceAddDefaultValues()]
		app.modules.forEach[resourceAddDefaultValues()]
		app.modules.map[domainObjects].flatten.forEach[modifyBelongsToAggregate()]
		app.modules.map[domainObjects].flatten.filter[it instanceof ValueObject].forEach[modifySubclassesPersistent((it as ValueObject))]
		app.modules.map[domainObjects].flatten.filter[it instanceof ValueObject].forEach[modifyAbstractPersistent((it as ValueObject))]
		app.modules.map[domainObjects].flatten.filter[it instanceof Trait].forEach[modifyTrait((it as Trait))]
		app.modules.forEach[modify()]
		app.modules.forEach[modifyDatabaseNames()]
		app.modules.forEach[modifyReferencesDatabaseNames()]
		// TODO restDefaults
		// app.modules.map[resources].flatten.map[operations].flatten.forEach[addRestDefaults()]
		app
	}

	def void mixin(DomainObject domainObject) {
		domainObject.traits.reverse.forEach[mixin(domainObject)]
	}

	def dispatch void mixin(Trait trait, DomainObject domainObject) {
		trait.attributes.forEach[mixin(domainObject)]
		trait.references.forEach[mixin(domainObject)]
		trait.operations.forEach[mixin(domainObject)]
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

	def dispatch addIfNotExists(DomainObject domainObject, Attribute a) {
		if (!domainObject.attributes.exists(e | e.name == a.name))
			domainObject.attributes.add(a)
	}

	def dispatch addIfNotExists(DomainObject domainObject, Reference r) {
		if (!domainObject.references.exists(e | r.name == r.name))
			domainObject.references.add(r)
	}

	def dispatch addIfNotExists(DomainObject domainObject, DomainObjectOperation op) {
		if (((op.parameters.size != 1) || !domainObject.attributes.exists(e | "set" + e.name.toFirstUpper() == op.name))
			&& (!op.parameters.isEmpty || !domainObject.attributes.exists(e | e.getGetAccessor() == op.name))
			&& !domainObject.operations.exists(e | e.name == op.name && e.type == op.type && e.parameters.size == op.parameters.size))
			domainObject.operations.add(op)
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

	def serviceAddDefaultValues(Module module) {
		module.services.forEach[it.addDefaultValues()]
	}

	def resourceAddDefaultValues(Module module) {
		module.resources.forEach[it.addDefaultValues()]
	}

	def modify(Module module) {
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

	def dispatch modifyDatabaseNames(Module module) {
		module.getNonEnumDomainObjects().forEach[it.modifyDatabaseNames()]
	}

	def dispatch modifyReferencesDatabaseNames(Module module) {
		module.getNonEnumDomainObjects().forEach[it.modifyReferencesDatabaseNames()]
	}

	def dispatch void modifyServiceContextParameter(Service service) {
		if (!service.webService)
			service.operations.forEach[it.modifyServiceContextParameter]
	}

	def dispatch void modifyServiceContextParameter(ServiceOperation operation) {
		if (!operation.isEventSubscriberOperation())
			// no method in ext language to add obj first in a list, using Java instead
			addServiceContextParameter(operation)
	}

	def void modifyApplicationException(Service service) {
		service.operations.forEach[modifyApplicationExceptionOperation()]
	}

	def modifyApplicationExceptionOperation(ServiceOperation operation) {
		if (operation.^throws == "ApplicationException")
			operation.setThrows(applicationExceptionClass())
	}

	// when using scaffold method names gapClass is wrong and must be redefined
	def dispatch modifyGapClass(Service service) {
		if (!service.gapClass && !service.operations.isEmpty && service.operations.exists(op | op.isImplementedInGapClass()))
			service.setGapClass(true)
	}

	def dispatch modifyGapClass(Resource resource) {
		if (!resource.gapClass && !resource.operations.isEmpty && resource.operations.exists(op | op.isImplementedInGapClass()))
			resource.setGapClass(true)
	}

	def dispatch modifyGapClass(DomainObject domainObject) {
		if (domainObject.operations.exists(op | op.isImplementedInGapClass()))
			domainObject.setGapClass(true)
	}

	def modifyTransient(DomainObject domainObject) {
		if (domainObject.isPersistent())
			domainObject.references.filter(e | !e.isEnumReference() && !e.to.isPersistent()).forEach[it.modifyTransientToTrue()]
	}

	def modifyTransientToTrue(Reference reference) {
		reference.setTransient(true)
	}

	def dispatch void modifyChangeable(DomainObject domainObject) {
		defaultModifyChangeable(domainObject)
	}

	def dispatch void modifyChangeable(ValueObject valueObject) {
		defaultModifyChangeable(valueObject)
		if (valueObject.immutable) {
			valueObject.attributes.filter(a | a.name != "uuid").forEach[modifyChangeableToFalse()]
			valueObject.references.filter(r | !r.many).forEach[modifyChangeableToFalse()]
		}
	}

	def dispatch void modifyChangeable(DataTransferObject dto) {
		dto.attributes.filter(a | a.naturalKey).forEach[it.modifyChangeableToFalse()]
		dto.references.filter(r | r.naturalKey).forEach[it.modifyChangeableToFalse()]
	}

	def dispatch void modifyChangeable(Trait trait) {
		trait.attributes.filter(a | a.naturalKey).forEach[modifyChangeableToFalse()]
		trait.references.filter(r | r.naturalKey).forEach[modifyChangeableToFalse()]
	}

	def defaultModifyChangeable(DomainObject domainObject) {
		domainObject.attributes.filter(a | a == domainObject.getIdAttribute()).forEach[modifyChangeableToFalse()]
		domainObject.attributes.filter(a | a.naturalKey).forEach[modifyChangeableToFalse()]
		domainObject.references.filter(r | r.naturalKey).forEach[modifyChangeableToFalse()]
	}

	def dispatch modifyChangeableToFalse(Attribute attribute) {
		attribute.setChangeable(false)
	}

	def dispatch modifyChangeableToFalse(Reference reference) {
		reference.setChangeable(false)
	}

	def dispatch modifyAuditable(Entity entity) {
		if (!isAuditableToBeGenerated())
			entity.setAuditable(false)

		if (entity.auditable && (entity.^extends == null || !((entity.^extends as Entity).auditable)))
			addAuditable(entity)
		else
			null
	}

	def dispatch modifyAuditable(DomainObject domainObject) {
		null
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

	def dispatch modifySubscriber(Service service) {
		if (service.subscribe != null && !service.operations.exists(e|e.name == "receive"))
			service.operations.add(createSubscriberRecieve(service))
	}

	def create FACTORY.createServiceOperation createSubscriberRecieve(Service service) {
		setName("receive")
		parameters.add(createSubscriberRecieveEventParam(it))
	}

	def dispatch modifySubscriber(Repository repository) {
		if (repository.subscribe != null && !repository.operations.exists(e|e.name == "receive"))
			repository.operations.add(createSubscriberRecieve(repository))
	}

	def create FACTORY.createRepositoryOperation createSubscriberRecieve(Repository repository) {
		setName("receive")
		parameters.add(createSubscriberRecieveEventParam(it))
	}

	def create FACTORY.createParameter createSubscriberRecieveEventParam(Operation op) {
		setName("event")
		setType(fw("event.Event"))
	}

	def dispatch modifyOptimisticLocking(DomainObject domainObject) {
		if (isOptimisticLockingToBeGenerated() && domainObject.optimisticLocking && (domainObject.^extends == null || !domainObject.^extends.optimisticLocking))
			addVersionAttribute(domainObject)
		else
			null
	}

	def dispatch modifyOptimisticLocking(ValueObject valueObject) {
		if (isOptimisticLockingToBeGenerated() && valueObject.persistent && !valueObject.immutable && valueObject.optimisticLocking && (valueObject.^extends == null || !valueObject.^extends.optimisticLocking))
			addVersionAttribute(valueObject)
		else
			null
	}

	def dispatch modifyOptimisticLocking(Trait trait) {
		null
	}

	def dispatch modifyOptimisticLocking(BasicType basicType) {
		null
	}

	def dispatch modifyDatabaseNames(DomainObject domainObject) {
		if (domainObject.databaseTable == null)
			domainObject.setDatabaseTable(domainObject.getDefaultDatabaseName())
		domainObject.attributes.forEach[it.modifyDatabaseColumn()]
	}

	def dispatch modifyDatabaseNames(ValueObject valueObject) {
		if (valueObject.persistent) {
			if (valueObject.databaseTable == null)
				valueObject.setDatabaseTable(valueObject.getDefaultDatabaseName())
			valueObject.attributes.forEach[modifyDatabaseColumn()]
		}
	}

	def dispatch modifyDatabaseNames(BasicType basicType) {
		basicType.attributes.forEach[modifyDatabaseColumn()]
	}

	def dispatch modifyReferencesDatabaseNames(DomainObject domainObject) {
		if (domainObject.isPersistent())
			domainObject.references.forEach[modifyDatabaseColumn()]
	}

	def dispatch void modifyDatabaseColumn(Attribute attribute) {
		if (attribute.databaseColumn == null)
			(if (attribute.name == "id" && getBooleanProperty("db.useTablePrefixedIdColumn"))
				attribute.setDatabaseColumn(attribute.getDomainObject().getDatabaseName() + "_" + attribute.getDefaultDatabaseName())
			else
				attribute.setDatabaseColumn(attribute.getDefaultDatabaseName()))
	}

	def dispatch void modifyDatabaseColumn(Reference reference) {
		if (reference.databaseColumn == null)
			reference.setDatabaseColumn(reference.getDefaultForeignKeyName())
	}

	def dispatch modifyIdAttribute(BasicType basicType) {
		null
	}

	def dispatch modifyIdAttribute(DataTransferObject dto) {
		null
	}

	def dispatch modifyIdAttribute(Trait trait) {
		null
	}

	def dispatch modifyIdAttribute(ValueObject valueObject) {
		if (valueObject.persistent)
			addIdAttribute(valueObject)
		else
			null
	}

	def dispatch modifyIdAttribute(DomainObject domainObject) {
		addIdAttribute(domainObject)
	}

	def DomainObject addIdAttribute(DomainObject domainObject) {
		if (domainObject.attributes.exists(a | a.name == "id"))
			null
		else
			addIdAttributeImpl(domainObject)
	}

	def modifyExtends(DomainObject domainObject) {
		if (domainObject.extendsName != null) {
			val matchingDomainObject = findDomainObjectByName(domainObject.module.application, domainObject.extendsName)
			if (matchingDomainObject != null) {
				domainObject.setExtends(matchingDomainObject)
				domainObject.setExtendsName(null)
			}
		}
	}

	def modifyBelongsToAggregate(DomainObject domainObject) {
		if (domainObject.belongsToAggregate == null)
			domainObject.setBelongsToAggregate(domainObject.getAggregateRootObject())
	}

	def private DomainObject findDomainObjectByName(Application app, String domainObjectName) {
		val match = app.modules.map[domainObjects].flatten.filter(e | e.name == domainObjectName)
		if (match.isEmpty) null else match.head
	}

	def dispatch modifySubclassesPersistent(ValueObject domainObject) {
		if (!domainObject.persistent)
			domainObject.getAllSubclasses().filter[it instanceof ValueObject].forEach[(it as ValueObject).setPersistent(false)]
	}

	// different defaults for DomainEvent
	def dispatch modifySubclassesPersistent(DomainEvent domainObject) {
		if (domainObject.persistent)
			domainObject.getAllSubclasses().filter[it instanceof ValueObject].forEach[(it as ValueObject).setPersistent(true)]
	}

	def modifyAbstractPersistent(ValueObject domainObject) {
		if (domainObject.^abstract && !domainObject.getAllSubclasses().filter[it instanceof ValueObject].exists(e|(e as ValueObject).persistent))
			domainObject.setPersistent(false)
	}

	def modifyTrait(Trait trait) {
		trait.attributes.forEach[addDerivedTraitPropertyAccessors(trait)]
		trait.references.forEach[addDerivedTraitPropertyAccessors(trait)]
	}

	def dispatch addDerivedTraitPropertyAccessors(Attribute att, Trait trait) {
		val getter = createDerivedTraitGetter(trait, att)
		val setter = createDerivedTraitSetter(trait, att)
		if (!trait.operations.exists(e|e.name == getter.name && e.type == getter.type && e.parameters.isEmpty))
			trait.operations.add(getter)
		if (!att.changeable && trait.operations.exists(e|e.name == setter.name && e.type == setter.type && e.parameters.size == 1 && e.parameters.get(0).type == att.type))
			trait.operations.add(setter)
	}

	def dispatch addDerivedTraitPropertyAccessors(Reference ref, Trait trait) {
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

	def void modifyUuid(DomainObject domainObject) {
		if (domainObject.^extends != null)
			domainObject.^extends.modifyUuid()
		if (domainObject.hasOwnDatabaseRepresentation() &&
				!domainObject.hasUuidAttribute() &&
				!domainObject.hasNaturalKey() &&
				(!domainObject.^abstract || domainObject.getSubclasses().isEmpty || !domainObject.getSubclasses().forall(sub | sub.hasNaturalKey())))
			domainObject.addUuidAttribute()
	}

	def private boolean hasUuidAttribute(DomainObject domainObject) {
		domainObject.getAllAttributes().exists(e | e.name == "uuid")
	}

	def modifyInheritance(DomainObject domainObject) {
		if (!domainObject.hasSubClass()) domainObject.setInheritance(null)
		if (domainObject.hasSuperClass() && domainObject.getRootExtends().isInheritanceTypeSingleTable()) domainObject.setInheritance(null)
		if (!domainObject.hasSuperClass()) domainObject.setDiscriminatorColumnValue(null)
	}

	def modifyPagingOperations(Repository repository) {
		val pagingOperations = repository.operations.filter(e | e.hasPagingParameter())
		val pagedFindAll = pagingOperations.findFirst(e|e.name == "findAll")
		val pagedFindByQuery = pagingOperations.findFirst(e|e.name == "findByQuery")
		pagingOperations.forEach[modifyPagingOperation()]
		if (!isJpa2() && pagedFindAll != null && !pagedFindAll.hasHint("countQuery") && !pagedFindAll.hasHint("countOperation")) {
			pagedFindAll.addCountAllHint()
			if (!repository.operations.exists(e|e.name == "countAll"))
				repository.operations.add(createCountAll(repository))
		}
		if (!isJpa2() && (pagedFindByQuery != null || pagingOperations.exists(e|e.hasHint("countQuery"))) &&
			!repository.operations.exists(e|e.name == "findByQuery" && e.parameters.exists(p|p.name == "useSingleResult")))
			repository.operations.add(createFindByQuerySingleResult(repository, true))
	}

	def private addCountAllHint(RepositoryOperation pagedFindAll) {
		val base = if (pagedFindAll.hint == null) "" else (pagedFindAll.hint + ", ")
		pagedFindAll.setHint(base + "countOperation=countAll")
	}

	def private create FACTORY.createRepositoryOperation createFindByQuerySingleResult(Repository repository, boolean useSingleResult) {
		it.setName("findByQuery")
		it.setVisibility("protected")
		it.setRepository(repository)
		if (useSingleResult)
			it.parameters.add(createUseSingleResultParameter(it))
	}

	def private create FACTORY.createParameter createUseSingleResultParameter(RepositoryOperation operation) {
		it.setName("useSingleResult")
		it.setType("boolean")
	}

	def private create FACTORY.createRepositoryOperation createCountAll(Repository repository) {
		it.setName("countAll")
		it.setVisibility("protected")
		it.setRepository(repository)
	}

	def modifyPagingOperation(RepositoryOperation op) {
		if ((op.type == "PagedResult" || op.type == null) && op.domainObjectType == null) {
			op.setType("PagedResult")
			op.setDomainObjectType(op.repository.aggregateRoot)
		}
	}

	def modifyDynamicFinderOperations(RepositoryOperation op) {
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

	def modifyQueryOperations(RepositoryOperation op) {
		if (op.collectionType == null && !op.repository.operations.exists(e|e.name == "findByQuery" && e.parameters.exists(p|p.name == "useSingleResult")))
			op.repository.operations.add(createFindByQuerySingleResult(op.repository, true))
		if (op.collectionType != null && !op.repository.operations.exists(e|e.name == "findByQuery"))
			op.repository.operations.add(createFindByQuerySingleResult(op.repository, false))
	}

	def modifyConditionOperations(RepositoryOperation op) {
		if (op.collectionType == null && !op.repository.operations.exists(e|e.name == "findByCondition" && e.parameters.exists(p|p.name == "useSingleResult")))
			op.repository.operations.add(createFindByCondition(op.repository, true))
		if (op.collectionType != null && !op.repository.operations.exists(e|e.name == "findByCondition"))
			op.repository.operations.add(createFindByCondition(op.repository, false))
	}

	def private create FACTORY.createRepositoryOperation createFindByCondition(Repository repository, boolean useSingleResult) {
		it.setName("findByCondition")
		it.setVisibility("protected")
		it.setRepository(repository)
		it.parameters.add(createParameter(it, "condition", "java.util.List<org.fornax.cartridges.sculptor.framework.accessapi.ConditionalCriteria>"))
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
