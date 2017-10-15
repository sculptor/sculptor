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
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DomainEvent
import sculptormetamodel.DomainObject
import sculptormetamodel.DomainObjectOperation
import sculptormetamodel.Entity
import sculptormetamodel.Module
import sculptormetamodel.Reference
import sculptormetamodel.RepositoryOperation
import sculptormetamodel.Resource
import sculptormetamodel.Service
import sculptormetamodel.ServiceOperation
import sculptormetamodel.Trait
import sculptormetamodel.ValueObject

/**
 * Overridable helper methods for enriching generator meta model.
 */
@ChainOverridable
class TransformationHelper {
	@Inject extension DbHelper dbHelper
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties
	
	def boolean isModifyDynamicFindersEnabled() {
		true
	}

	def boolean isModifyPagingOperationsEnabled() {
		true
	}

	def dispatch void addIfNotExists(DomainObject domainObject, Attribute a) {
		if (!domainObject.attributes.exists(e | e.name == a.name))
			domainObject.attributes.add(a)
	}

	def dispatch void addIfNotExists(DomainObject domainObject, Reference r) {
		if (!domainObject.references.exists(e | r.name == r.name))
			domainObject.references.add(r)
	}

	def dispatch void addIfNotExists(DomainObject domainObject, DomainObjectOperation op) {
		if (((op.parameters.size != 1) || !domainObject.attributes.exists(e | "set" + e.name.toFirstUpper() == op.name))
			&& (!op.parameters.isEmpty || !domainObject.attributes.exists(e | e.getGetAccessor() == op.name))
			&& !domainObject.operations.exists(e | e.name == op.name && e.type == op.type && e.parameters.size == op.parameters.size))
			domainObject.operations.add(op)
	}

	def void serviceAddDefaultValues(Module module) {
		module.services.forEach[it.addDefaultValues()]
	}

	def void resourceAddDefaultValues(Module module) {
		module.resources.forEach[it.addDefaultValues()]
	}

	def void modifyModuleDatabaseNames(Module module) {
		module.getNonEnumDomainObjects().forEach[it.modifyDatabaseNames()]
	}

	def void modifyModuleReferencesDatabaseNames(Module module) {
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

	def void modifyApplicationExceptionOperation(ServiceOperation operation) {
		if (operation.^throws == "ApplicationException")
			operation.setThrows(applicationExceptionClass())
	}

	// when using scaffold method names gapClass is wrong and must be redefined
	def dispatch void modifyGapClass(Service service) {
		if (!service.gapClass && !service.operations.isEmpty && service.operations.exists(op | op.isImplementedInGapClass()))
			service.setGapClass(true)
	}

	def dispatch void modifyGapClass(Resource resource) {
		if (!resource.gapClass && !resource.operations.isEmpty && resource.operations.exists(op | op.isImplementedInGapClass()))
			resource.setGapClass(true)
	}

	def dispatch void modifyGapClass(DomainObject domainObject) {
		if (domainObject.operations.exists(op | op.isImplementedInGapClass()))
			domainObject.setGapClass(true)
	}

	def void modifyTransient(DomainObject domainObject) {
		if (domainObject.isPersistent())
			domainObject.references.filter(e | !e.isEnumReference() && !e.to.isPersistent()).forEach[it.modifyTransientToTrue()]
	}

	def void modifyTransientToTrue(Reference reference) {
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

	def void defaultModifyChangeable(DomainObject domainObject) {
		domainObject.attributes.filter(a | a == domainObject.getIdAttribute()).forEach[modifyChangeableToFalse()]
		domainObject.attributes.filter(a | a.naturalKey).forEach[modifyChangeableToFalse()]
		domainObject.references.filter(r | r.naturalKey).forEach[modifyChangeableToFalse()]
	}

	def dispatch void modifyChangeableToFalse(Attribute attribute) {
		attribute.setChangeable(false)
	}

	def dispatch void modifyChangeableToFalse(Reference reference) {
		reference.setChangeable(false)
	}

	def dispatch void modifyAuditable(Entity entity) {
		if (!isAuditableToBeGenerated())
			entity.setAuditable(false)

		if (entity.auditable && (entity.^extends === null || !((entity.^extends as Entity).auditable)))
			addAuditable(entity)
	}

	def dispatch void modifyAuditable(DomainObject domainObject) {
	}

	def dispatch void modifyOptimisticLocking(DomainObject domainObject) {
		if (isOptimisticLockingToBeGenerated() && domainObject.optimisticLocking && (domainObject.^extends === null || !domainObject.^extends.optimisticLocking))
			addVersionAttribute(domainObject)
	}

	def dispatch void modifyOptimisticLocking(ValueObject valueObject) {
		if (isOptimisticLockingToBeGenerated() && valueObject.persistent && !valueObject.immutable && valueObject.optimisticLocking && (valueObject.^extends === null || !valueObject.^extends.optimisticLocking))
			addVersionAttribute(valueObject)
	}

	def dispatch void modifyOptimisticLocking(Trait trait) {
	}

	def dispatch void modifyOptimisticLocking(BasicType basicType) {
	}

	def dispatch void modifyDatabaseNames(DomainObject domainObject) {
		if (domainObject.databaseTable === null)
			domainObject.setDatabaseTable(domainObject.getDefaultDatabaseName())
		domainObject.attributes.forEach[it.modifyDatabaseColumn()]
	}

	def dispatch void modifyDatabaseNames(ValueObject valueObject) {
		if (valueObject.persistent) {
			if (valueObject.databaseTable === null)
				valueObject.setDatabaseTable(valueObject.getDefaultDatabaseName())
			valueObject.attributes.forEach[modifyDatabaseColumn()]
		}
	}

	def dispatch void modifyDatabaseNames(BasicType basicType) {
		basicType.attributes.forEach[modifyDatabaseColumn()]
	}

	def void modifyReferencesDatabaseNames(DomainObject domainObject) {
		if (domainObject.isPersistent())
			domainObject.references.forEach[modifyDatabaseColumn()]
	}

	def dispatch void modifyDatabaseColumn(Attribute attribute) {
		if (attribute.databaseColumn === null)
			(if (attribute.name == "id" && getBooleanProperty("db.useTablePrefixedIdColumn"))
				attribute.setDatabaseColumn(attribute.getDomainObject().getDatabaseName() + "_" + attribute.getDefaultDatabaseName())
			else
				attribute.setDatabaseColumn(attribute.getDefaultDatabaseName()))
	}

	def dispatch void modifyDatabaseColumn(Reference reference) {
		if (reference.databaseColumn === null)
			reference.setDatabaseColumn(reference.getDefaultForeignKeyName())
	}

	def dispatch void modifyIdAttribute(BasicType basicType) {
	}

	def dispatch void modifyIdAttribute(DataTransferObject dto) {
	}

	def dispatch void modifyIdAttribute(Trait trait) {
	}

	def dispatch void modifyIdAttribute(ValueObject valueObject) {
		if (valueObject.persistent)
			addIdAttribute(valueObject)
	}

	def dispatch void modifyIdAttribute(DomainObject domainObject) {
		addIdAttribute(domainObject)
	}

	def void addIdAttribute(DomainObject domainObject) {
		if (!domainObject.attributes.exists(a | a.name == "id"))
			addIdAttributeImpl(domainObject)
	}

	def void modifyExtends(DomainObject domainObject) {
		if (domainObject.extendsName !== null) {
			val matchingDomainObject = findDomainObjectByName(domainObject.module.application, domainObject.extendsName)
			if (matchingDomainObject !== null) {
				domainObject.setExtends(matchingDomainObject)
				domainObject.setExtendsName(null)
			}
		}
	}

	def void modifyBelongsToAggregate(DomainObject domainObject) {
		if (domainObject.belongsToAggregate === null)
			domainObject.setBelongsToAggregate(domainObject.getAggregateRootObject())
	}

	def private DomainObject findDomainObjectByName(Application app, String domainObjectName) {
		val match = app.modules.map[domainObjects].flatten.filter(e | e.name == domainObjectName)
		if (match.isEmpty)
			null
		else
			match.head
	}

	def dispatch void modifySubclassesPersistent(ValueObject domainObject) {
		if (!domainObject.persistent)
			domainObject.getAllSubclasses().filter[it instanceof ValueObject].forEach[(it as ValueObject).setPersistent(false)]
	}

	// different defaults for DomainEvent
	def dispatch void modifySubclassesPersistent(DomainEvent domainObject) {
		if (domainObject.persistent)
			domainObject.getAllSubclasses().filter[it instanceof ValueObject].forEach[(it as ValueObject).setPersistent(true)]
	}

	def void modifyAbstractPersistent(ValueObject domainObject) {
		if (domainObject.^abstract && !domainObject.getAllSubclasses().filter[it instanceof ValueObject].exists(e|(e as ValueObject).persistent))
			domainObject.setPersistent(false)
	}

	def void modifyUuid(DomainObject domainObject) {
		if (domainObject.^extends !== null)
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

	def void modifyInheritance(DomainObject domainObject) {
		if (!domainObject.hasSubClass())
			domainObject.setInheritance(null)
		if (domainObject.hasSuperClass() && domainObject.getRootExtends().isInheritanceTypeSingleTable())
			domainObject.setInheritance(null)
		if (!domainObject.hasSuperClass())
			domainObject.setDiscriminatorColumnValue(null)
	}

	def void addCountAllHint(RepositoryOperation pagedFindAll) {
		val base = if (pagedFindAll.hint === null) "" else (pagedFindAll.hint + ", ")
		pagedFindAll.setHint(base + "countOperation=countAll")
	}

	def void modifyPagingOperation(RepositoryOperation op) {
		if ((op.type == "PagedResult" || op.type === null) && op.domainObjectType === null) {
			op.setType("PagedResult")
			op.setDomainObjectType(op.repository.aggregateRoot)
		}
	}

}
