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

import java.util.List
import javax.inject.Inject
import org.eclipse.xtext.EcoreUtil2
import org.sculptor.dsl.sculptordsl.DslAnyProperty
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslAttribute
import org.sculptor.dsl.sculptordsl.DslBasicType
import org.sculptor.dsl.sculptordsl.DslCollectionType
import org.sculptor.dsl.sculptordsl.DslCommandEvent
import org.sculptor.dsl.sculptordsl.DslComplexType
import org.sculptor.dsl.sculptordsl.DslConsumer
import org.sculptor.dsl.sculptordsl.DslDataTransferObject
import org.sculptor.dsl.sculptordsl.DslDependency
import org.sculptor.dsl.sculptordsl.DslDiscriminatorType
import org.sculptor.dsl.sculptordsl.DslDomainEvent
import org.sculptor.dsl.sculptordsl.DslDomainObject
import org.sculptor.dsl.sculptordsl.DslDomainObjectOperation
import org.sculptor.dsl.sculptordsl.DslDtoAttribute
import org.sculptor.dsl.sculptordsl.DslDtoReference
import org.sculptor.dsl.sculptordsl.DslEntity
import org.sculptor.dsl.sculptordsl.DslEnum
import org.sculptor.dsl.sculptordsl.DslEnumAttribute
import org.sculptor.dsl.sculptordsl.DslEnumParameter
import org.sculptor.dsl.sculptordsl.DslEnumValue
import org.sculptor.dsl.sculptordsl.DslEvent
import org.sculptor.dsl.sculptordsl.DslHttpMethod
import org.sculptor.dsl.sculptordsl.DslInheritanceType
import org.sculptor.dsl.sculptordsl.DslModule
import org.sculptor.dsl.sculptordsl.DslParameter
import org.sculptor.dsl.sculptordsl.DslPublish
import org.sculptor.dsl.sculptordsl.DslReference
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslResource
import org.sculptor.dsl.sculptordsl.DslResourceOperation
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslServiceDependency
import org.sculptor.dsl.sculptordsl.DslServiceOperation
import org.sculptor.dsl.sculptordsl.DslSimpleDomainObject
import org.sculptor.dsl.sculptordsl.DslSubscribe
import org.sculptor.dsl.sculptordsl.DslTrait
import org.sculptor.dsl.sculptordsl.DslValueObject
import org.sculptor.dsl.sculptordsl.DslVisibility
import org.sculptor.generator.check.CheckCrossLink
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.CommandEvent
import sculptormetamodel.DataTransferObject
import sculptormetamodel.DiscriminatorType
import sculptormetamodel.DomainEvent
import sculptormetamodel.DomainObject
import sculptormetamodel.Event
import sculptormetamodel.InheritanceType
import sculptormetamodel.NamedElement
import sculptormetamodel.Repository
import sculptormetamodel.Resource
import sculptormetamodel.SculptormetamodelFactory
import sculptormetamodel.Service

class DslTransformation {

	private static val SculptormetamodelFactory FACTORY = SculptormetamodelFactory::eINSTANCE

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

	@Inject extension CheckCrossLink checkCrossLink
	
	def create FACTORY.createApplication transform(DslApplication app) {
		val List<DslModule> allDslModules = EcoreUtil2::eAllOfType(app, typeof(DslModule))
		initPropertiesHook()
		setGlobalApp(it)
		allDslModules.forEach[checkCrossLink()]
		setDoc(app.doc)
		setName(app.name)
		setBasePackage(app.basePackage)
		modules.addAll(allDslModules.map[e | transform(e)])
		// have to transform the dependencies afterwards, otherwise strange errors
		allDslModules.map[services].flatten.forEach[transformDependencies(it)]
		allDslModules.map[resources].flatten.forEach[transformDependencies(it)]
		allDslModules.map[consumers].flatten.forEach[transformDependencies(it)]
		// TODO
		// No transformations for all DslSimpleDomainObject subtypes (DslBasicType, DslEnum, DslDomainObject, DslDataTransferObject, DslTrait)
		allDslModules.map[getDomainObjects()].flatten.filter[it instanceof DslDomainObject].map[(it as DslDomainObject)]
			.forEach[d | transformDependencies(d)]
		allDslModules.map[getDomainObjects()].flatten.filter[it instanceof DslDomainObject].map[(it as DslDomainObject)]
			.filter(d | d.scaffold).forEach(d | scaffold(d))

		allDslModules.map[resources].flatten.filter(r | r.scaffold).forEach(r | scaffold(r))
	}

	def create FACTORY.createModule transform(DslModule module) {
		setApplication(getGlobalApp())
		setDoc(module.doc)
		setName(module.name)
		setHint(module.hint)
		setExternal(!isModuleToBeGenerated(module.name))
		setBasePackage(module.basePackage)
		domainObjects.addAll(module.domainObjects.map[e | transform(e)])
		services.addAll(module.services.map[e | transform(e)])
		resources.addAll(module.resources.map[e | transform(e)])
		consumers.addAll(module.consumers.map[e | transform(e)])
	}

	def create FACTORY.createService transform(DslService service) {
		setModule((service.eContainer as DslModule).transform)
		setDoc(service.doc)
		setName(service.name)
		setGapClass(service.isGapClassToBeGenerated())
		setWebService(service.webService)
		setHint(service.hint)
		// these hints will probably be replaced by real keywords in DSL
		setRemoteInterface(if (hasHint("notRemote")) false else true)
		setLocalInterface(if (hasHint("notLocal")) false else true)
		if (service.subscribe != null)
			setSubscribe(service.subscribe.transform)
		operations.addAll(service.operations.map[op | op.transform])
	}

	def create FACTORY.createResource transform(DslResource resource) {
		setModule((resource.eContainer as DslModule).transform)
		setDoc(resource.doc)
		setName(resource.name)
		setGapClass(resource.isGapClassToBeGenerated())
		setHint(resource.hint)
		setPath(resource.path)
		operations.addAll(resource.operations.map[e | transform(e)])
	}

	def create FACTORY.createConsumer transform(DslConsumer consumer) {
		setModule((consumer.eContainer as DslModule).transform)
		setDoc(consumer.doc)
		setName(consumer.name)
		setHint(consumer.hint)
		if (consumer.messageRoot != null)
			setMessageRoot(consumer.messageRoot.transform)
		if (consumer.subscribe != null)
			setSubscribe(consumer.subscribe.transform)
		setChannel(if (consumer.channel == null && subscribe != null) subscribe.topic else consumer.channel)
		if (subscribe == null && channel != null)
			setSubscribe(createSubscribe(consumer, channel))
	}

	def create FACTORY.createSubscribe createSubscribe(DslConsumer consumer, String channel) {
		setTopic(channel)
	}

	def create FACTORY.createSubscribe transform(DslSubscribe subscribe) {
		setEventBus(subscribe.eventBus)
		setTopic(subscribe.topic)
	}

	def create FACTORY.createPublish transform(DslPublish publish) {
		setEventBus(publish.eventBus)
		setTopic(publish.topic)
		setEventType(if (publish.eventType == null) null else publish.eventType.transform)
		if (eventBus == null && eventType != null && eventType instanceof CommandEvent)
			setEventBus("commandBus")
	}

	def create FACTORY.createServiceOperation transform(DslServiceOperation operation) {
		setService((operation.eContainer as DslService).transform)
		setDoc(operation.doc)
		setName(operation.name)
		setVisibility(convertVisibility(operation.visibility))
		parameters.addAll(operation.parameters.map[e | transform(e)])
		setCollectionType(convertCollectionType(operation.returnType))
		setMapKeyType(if (operation.returnType == null) null else operation.returnType.mapKeyType)
		setMapKeyDomainObjectType(if (operation.returnType == null || operation.returnType.mapKeyDomainObjectType == null)
			null
		else
			operation.returnType.mapKeyDomainObjectType.transform)
		setType(if (operation.returnType == null) null else operation.returnType.type)
		setDomainObjectType(if (operation.returnType == null || operation.returnType.domainObjectType == null)
			null
		else
			operation.returnType.domainObjectType.transform)
		setThrows(operation.^throws)
		setHint(operation.hint)
		if (operation.publish != null)
			setPublish(operation.publish.transform)

		if ((operation.delegateHolder != null) && (operation.delegateHolder.delegate != null) && (operation.delegateHolder.delegate instanceof DslRepository))
			setDelegate((operation.delegateHolder.delegateOperation  as DslRepositoryOperation).transform)

		if ((operation.delegateHolder != null) && (operation.delegateHolder.delegate != null) && (operation.delegateHolder.delegate instanceof DslService))
			setServiceDelegate(((operation.delegateHolder.delegateOperation as DslServiceOperation)).transform)
	}

	def create FACTORY.createResourceOperation transform(DslResourceOperation operation) {
		setResource((operation.eContainer as DslResource).transform)
		setDoc(operation.doc)
		setName(operation.name)
		setVisibility(convertVisibility(operation.visibility))
		parameters.addAll(operation.parameters.map[e | transform(e)])
		setCollectionType(convertCollectionType(operation.returnType))
		setMapKeyType(if (operation.returnType == null) null else operation.returnType.mapKeyType)
		setMapKeyDomainObjectType(if (operation.returnType == null || operation.returnType.mapKeyDomainObjectType == null)
			null
		else
			operation.returnType.mapKeyDomainObjectType.transform)
		setType(if (operation.returnType == null) null else operation.returnType.type)
		setDomainObjectType(if (operation.returnType == null || operation.returnType.domainObjectType == null)
			null
		else
			operation.returnType.domainObjectType.transform)
		setThrows(operation.^throws)
		setHint(operation.hint)
		setPath(operation.path)
		setReturnString(operation.returnString)
		if (operation.httpMethod != null && operation.httpMethod != DslHttpMethod::NONE)
			setHttpMethod(operation.httpMethod.toString().mapHttpMethod())

		if ((operation.delegateHolder != null) && (operation.delegateHolder.delegate != null))
			setDelegate(((operation.delegateHolder.delegateOperation as DslServiceOperation)).transform)
	}

	def create FACTORY.createDomainObjectOperation transform(DslDomainObjectOperation operation) {
		setDomainObject((operation.eContainer as DslDomainObject).transform)
		setDoc(operation.doc)
		setName(operation.name)
		setAbstract(operation.^abstract)
		setVisibility(convertVisibility(operation.visibility))
		parameters.addAll(operation.parameters.map[e | transform(e)])
		setCollectionType(convertCollectionType(operation.returnType))
		setMapKeyType(if (operation.returnType == null) null else operation.returnType.mapKeyType)
		setMapKeyDomainObjectType(if (operation.returnType == null || operation.returnType.mapKeyDomainObjectType == null)
			null
		else
			operation.returnType.mapKeyDomainObjectType.transform)
		setType(if (operation.returnType == null) null else operation.returnType.type)
		setDomainObjectType(if (operation.returnType == null || operation.returnType.domainObjectType == null)
			null
		else
			operation.returnType.domainObjectType.transform)
		setThrows(operation.^throws)
		setHint(operation.hint)
	}

	def private String convertVisibility(DslVisibility dslVisibility) {
		if (dslVisibility == null)
			"public"
		else
			dslVisibility.toString()
	}

	def private String convertCollectionType(DslComplexType dslComplexType) {
		if (dslComplexType == null)
			null
		else if (dslComplexType.mapCollectionType != null)
			dslComplexType.mapCollectionType
		else
			convertCollectionTypeEnum(dslComplexType.collectionType)
	}

	def private String convertCollectionTypeEnum(DslCollectionType collectionType) {
		if (collectionType == null || collectionType == DslCollectionType::NONE)
			null
		else
			collectionType.toString()
	}

	def create FACTORY.createRepositoryOperation transform(DslRepositoryOperation operation) {
		setRepository((operation.eContainer as DslRepository).transform)
		setDoc(operation.doc)
		setName(operation.name)
		setVisibility(convertVisibility(operation.visibility))
		parameters.addAll(operation.parameters.map[e | transform(e)])
		setCollectionType(convertCollectionType(operation.returnType))
		setMapKeyType(if (operation.returnType == null) null else operation.returnType.mapKeyType)
		setMapKeyDomainObjectType(if (operation.returnType == null || operation.returnType.mapKeyDomainObjectType == null)
			null
		else
			operation.returnType.mapKeyDomainObjectType.transform)
		setType(if (operation.returnType == null) null else operation.returnType.type)
		setDomainObjectType(if (operation.returnType == null || operation.returnType.domainObjectType == null)
			null
		else
			operation.returnType.domainObjectType.transform)
		setThrows(operation.^throws)
		setHint(operation.hint)
		setDelegateToAccessObject(operation.delegateToAccessObject)
		setAccessObjectName(operation.accessObjectName)
		if (operation.publish != null)
			setPublish(operation.publish.transform)
		if (operation.cache)
			addHint("cache")

		if (operation.construct) it.addHint("construct")
		if (operation.build) it.addHint("build")
		if (operation.gapOperation) addHint("gap")
		if (operation.query != null) addHint("query=" + operation.query, ";")
		if (operation.^select != null) addHint("select=" + operation.^select, ";")
		if (operation.condition != null) addHint("condition=" + operation.condition, ";")
		if (operation.groupBy != null) addHint("groupBy=" + operation.groupBy, ";")
		if (operation.orderBy != null) addHint("orderBy=" + operation.orderBy, ";")
	}

	def create FACTORY.createParameter transform(DslParameter parameter) {
		setName(parameter.name)
		setDoc(parameter.doc)
		setCollectionType(convertCollectionType(parameter.parameterType))
		setMapKeyType(if (parameter.parameterType == null) null else parameter.parameterType.mapKeyType)
		setMapKeyDomainObjectType(if (parameter.parameterType == null || parameter.parameterType.mapKeyDomainObjectType == null)
			null
		else
			parameter.parameterType.mapKeyDomainObjectType.transform)
		setType(if(parameter.parameterType == null) null else parameter.parameterType.type)
		setDomainObjectType(if (parameter.parameterType == null || parameter.parameterType.domainObjectType == null)
			null
		else
			parameter.parameterType.domainObjectType.transform)
	}

	// this "method" is not used, it is kind of "abstract"
	def DomainObject transform(DslSimpleDomainObject domainObject) {
		if (domainObject instanceof DslEntity)
			(domainObject as DslEntity).transform
		else if (domainObject instanceof DslValueObject)
			(domainObject as DslValueObject).transform
		else if (domainObject instanceof DslEnum)
			(domainObject as DslEnum).transform
		else if (domainObject instanceof DslBasicType)
			(domainObject as DslBasicType).transform
		else {
			error("Wrong type of domainObject "+domainObject.name+"["+ (domainObject.^class.simpleName) +"] only DslEntity & DslValueObject are supported")
			null
		}
	}

	def create FACTORY.createEntity transform(DslEntity domainObject) {
		setModule((domainObject.eContainer as DslModule).transform)
		setDoc(domainObject.doc)
		setName(domainObject.name)
		setPackage(domainObject.^package)
		setAbstract(domainObject.^abstract)
		setOptimisticLocking(!domainObject.notOptimisticLocking)
		setAuditable(!domainObject.notAuditable)
		setCache(domainObject.cache)
		setDatabaseTable(domainObject.databaseTable)
		setBelongsToAggregate(if (domainObject.belongsTo == null) null else domainObject.belongsTo.transform)
		setAggregateRoot(!domainObject.notAggregateRoot && (domainObject.belongsTo == null || domainObject.belongsTo == domainObject))
		setValidate(domainObject.validate)
		setGapClass(isGapClassToBeGenerated(domainObject.gapClass, domainObject.noGapClass))
		setHint(domainObject.hint)
		setDiscriminatorColumnValue(domainObject.discriminatorValue)
		setInheritance(domainObject.createInheritance())
		attributes.addAll(domainObject.attributes.map[e | transform(e)])
		references.addAll(domainObject.references.map[e | transform(e)])
		operations.addAll(domainObject.operations.map[e | transform(e)])
		domainObject.transformExtends(it)
		traits.addAll(domainObject.traits.map[e | transform(e)])
		if (domainObject.repository != null)
			setRepository(domainObject.repository.transform)
	}

	def create FACTORY.createValueObject transform(DslValueObject domainObject) {
		setModule((domainObject.eContainer as DslModule).transform)
		setDoc(domainObject.doc)
		setName(domainObject.name)
		setPackage(domainObject.^package)
		setAbstract(domainObject.^abstract)
		setOptimisticLocking(!domainObject.notOptimisticLocking)
		setImmutable(!domainObject.notImmutable)
		setCache(domainObject.cache)
		setDatabaseTable(domainObject.databaseTable)
		setBelongsToAggregate(if (domainObject.belongsTo == null) null else domainObject.belongsTo.transform)
		setAggregateRoot(!domainObject.notAggregateRoot && !domainObject.notPersistent && (domainObject.belongsTo == null || domainObject.belongsTo == domainObject))
		setPersistent(!domainObject.notPersistent)
		setValidate(domainObject.validate)
		setHint(domainObject.hint)
		setGapClass(isGapClassToBeGenerated(domainObject.gapClass, domainObject.noGapClass))
		setDiscriminatorColumnValue(domainObject.discriminatorValue)
		setInheritance(domainObject.createInheritance())
		attributes.addAll(domainObject.attributes.map[e | transform(e)])
		references.addAll(domainObject.references.map[e | transform(e)])
		operations.addAll(domainObject.operations.map[e | transform(e)])
		domainObject.transformExtends(it)
		traits.addAll(domainObject.traits.map[e | transform(e)])
		if (domainObject.repository != null)
			setRepository(domainObject.repository.transform)
	}

	// TODO: createDomainEvent or createCommandEvent?
	def create FACTORY.createDomainEvent transform(DslEvent event) {
		// Never used, only purpose is to be an 'abstract' placeholder
		error("Unexpected call to transform(DslEvent): " + event)
	}

	def create FACTORY.createDomainEvent transform(DslDomainEvent dslEvent) {
		transformCommonEventFeatures(it, dslEvent)
	}

	def create FACTORY.createCommandEvent transform(DslCommandEvent dslEvent) {
		transformCommonEventFeatures(it, dslEvent)
	}

	def transformCommonEventFeatures(Event event, DslEvent dslEvent) {
		event.setModule((dslEvent.eContainer as DslModule).transform)
		event.setDoc(dslEvent.doc)
		event.setName(dslEvent.name)
		event.setPackage(dslEvent.^package)
		event.setAbstract(dslEvent.^abstract)
		event.setOptimisticLocking(false)
		event.setCache(dslEvent.cache)
		event.setDatabaseTable(dslEvent.databaseTable)
		event.setBelongsToAggregate(if (dslEvent.belongsTo == null) null else dslEvent.belongsTo.transform)
		event.setAggregateRoot(!dslEvent.notAggregateRoot && dslEvent.persistent && (dslEvent.belongsTo == null || dslEvent.belongsTo == dslEvent))
		event.setPersistent(dslEvent.persistent)
		event.setValidate(dslEvent.validate)
		event.setHint(dslEvent.hint)
		event.setGapClass(isGapClassToBeGenerated(dslEvent.gapClass, dslEvent.noGapClass))
		event.setDiscriminatorColumnValue(dslEvent.discriminatorValue)
		event.setInheritance(dslEvent.createInheritance())
		event.attributes.addAll(dslEvent.attributes.map[e | transform(e)])
		event.references.addAll(dslEvent.references.map[e | transform(e)])
		event.operations.addAll(dslEvent.operations.map[e | transform(e)])
		dslEvent.transformExtendsEvent(event)
		event.traits.addAll(dslEvent.traits.map[e | transform(e)])
		if (dslEvent.repository != null)
			event.setRepository(dslEvent.repository.transform)
	}

	def create FACTORY.createDataTransferObject transform(DslDataTransferObject dslDto) {
		setModule((dslDto.eContainer as DslModule).transform)
		setDoc(dslDto.doc)
		setName(dslDto.name)
		setPackage(dslDto.^package)
		setAbstract(dslDto.^abstract)
		setImmutable(false)
		setPersistent(false)
		setAggregateRoot(false)
		setValidate(dslDto.validate)
		setHint(dslDto.hint)
		setGapClass(isGapClassToBeGenerated(dslDto.gapClass, dslDto.noGapClass))
		attributes.addAll(dslDto.attributes.map[e | transform(e)])
		references.addAll(dslDto.references.map[e | transform(e)])
		dslDto.transformExtends(it)
	}

	def create FACTORY.createTrait transform(DslTrait dslTrait) {
		setModule((dslTrait.eContainer as DslModule).transform)
		setDoc(dslTrait.doc)
		setName(dslTrait.name)
		setPackage(dslTrait.^package)
		setAbstract(true)
		setAggregateRoot(false)
		setHint(dslTrait.hint)
		setGapClass(true)
		attributes.addAll(dslTrait.attributes.map[e | transform(e)])
		references.addAll(dslTrait.references.map[e | transform(e)])
		operations.addAll(dslTrait.operations.map[e | transform(e)])
	}

	def create FACTORY.createInheritance createInheritance(DslDomainObject domainObject) {
		setType(if (domainObject.inheritanceType == DslInheritanceType::SINGLE_TABLE)
			InheritanceType::SINGLE_TABLE
		else
			InheritanceType::JOINED)
		setDiscriminatorColumnName(domainObject.discriminatorColumn)
		setDiscriminatorColumnLength(domainObject.discriminatorLength)
		setDiscriminatorType(mapDiscriminatorType(domainObject.discriminatorType))
	}

	def private DiscriminatorType mapDiscriminatorType(DslDiscriminatorType dslDiscriminatorType) {
		switch (dslDiscriminatorType) {
			case DslDiscriminatorType::CHAR :
				DiscriminatorType::CHAR
			case DslDiscriminatorType::INTEGER :
				DiscriminatorType::INTEGER
			default :
				DiscriminatorType::STRING
		}
	}

	def private transformExtends(DslEntity dslDomainObject, DomainObject domainObject) {
		dslDomainObject.transformExtendsImpl(dslDomainObject.^extends, domainObject)
	}

	def private transformExtends(DslValueObject dslDomainObject, DomainObject domainObject) {
		dslDomainObject.transformExtendsImpl(dslDomainObject.^extends, domainObject)
	}

	def private dispatch transformExtendsEvent(DslEvent dslEvent, DomainObject domainObject) {
		// Never used, only purpose is to be an 'abstract' placeholder
		error("Unexpected call to transformExtends(DslEvent): " + dslEvent)
	}

	def private dispatch transformExtendsEvent(DslCommandEvent dslDomainObject, DomainObject domainObject) {
		dslDomainObject.transformExtendsImpl(dslDomainObject.^extends, domainObject)
	}

	def private dispatch transformExtendsEvent(DslDomainEvent dslDomainObject, DomainObject domainObject) {
		dslDomainObject.transformExtendsImpl(dslDomainObject.^extends, domainObject)
	}

	def private dispatch transformExtendsEvent(DslDomainEvent dslEvent, DomainEvent event) {
		if (dslEvent.^extends != null)
			event.setExtends(dslEvent.^extends.transform)

		if (dslEvent.extendsName != null)
			event.setExtendsName(dslEvent.extendsName)
	}

	def private transformExtendsImpl(DslDomainObject dslDomainObject, DslDomainObject dslExtendsDomainObject, DomainObject domainObject) {
		if (dslExtendsDomainObject != null)
			domainObject.setExtends(dslExtendsDomainObject.transform)

		if (dslDomainObject.extendsName != null)
			domainObject.setExtendsName(dslDomainObject.extendsName)
	}

	def private transformExtends(DslDataTransferObject dslDto, DataTransferObject dto) {
		if (dslDto.^extends != null)
			dto.setExtends(dslDto.^extends.transform)

		if (dslDto.extendsName != null)
			dto.setExtendsName(dslDto.extendsName)
	}

	def create FACTORY.createBasicType transform(DslBasicType domainObject) {
		setModule((domainObject.eContainer as DslModule).transform)
		setDoc(domainObject.doc)
		setName(domainObject.name)
		setPackage(domainObject.^package)
		setHint(domainObject.hint)
		setImmutable(!domainObject.notImmutable)
		setAggregateRoot(false)
		setGapClass(isGapClassToBeGenerated(domainObject.gapClass, domainObject.noGapClass))
		attributes.addAll(domainObject.attributes.map[e | transform(e)])
		references.addAll(domainObject.references.map[e | transform(e)])
		operations.addAll(domainObject.operations.map[e | transform(e)])
		traits.addAll(domainObject.traits.map[e | transform(e)])
	}

	def create FACTORY.createEnum transform(DslEnum domainObject) {
		setModule((domainObject.eContainer as DslModule).transform)
		setDoc(domainObject.doc)
		setName(domainObject.name)
		setPackage(domainObject.^package)
		setHint(domainObject.hint)
		setOrdinal(domainObject.ordinal)
		setAggregateRoot(false)
		attributes.addAll(domainObject.attributes.map[e | transform(e)])
		values.addAll(domainObject.values.map[e | transform(e)])
	}

	def create FACTORY.createEnumValue transform(DslEnumValue enumValue) {
		setName(enumValue.name)
		setDoc(enumValue.doc)
		parameters.addAll(enumValue.parameters.map[e | transform(e)])
	}

	def create FACTORY.createEnumConstructorParameter transform(DslEnumParameter parameter) {
		if (parameter.value == null)
			setValue("" + parameter.integerValue)
		else
			setValue(parameter.value)
	}

	def create FACTORY.createAttribute transform(DslEnumAttribute attribute) {
		setDoc(attribute.doc)
		setName(attribute.name)
		setType(attribute.type)
		setNaturalKey(attribute.key)
	}

	def NamedElement transform(DslAnyProperty prop) {
		// Never used, only purpose is to be an 'abstract' placeholder
		error("Unexpected call to transform(DslAnyProperty): " + prop)
		null
	}

	def create FACTORY.createAttribute transform(DslAttribute attribute) {
		setDoc(attribute.doc)
		setName(attribute.name)
		setType(attribute.type)
		setCollectionType(convertCollectionTypeEnum(attribute.collectionType))
		setNaturalKey(attribute.key)
		setChangeable(!attribute.notChangeable)
		setRequired(attribute.required)
		setNullable(attribute.nullable)
		setIndex(attribute.index)
		setLength(attribute.length)
		setValidate(attribute.handleValidation())
		setDatabaseType(attribute.databaseType)
		setDatabaseColumn(attribute.databaseColumn)
		setHint(attribute.hint)
		setTransient(attribute.transient)
		setVisibility(convertVisibility(attribute.visibility))
	}

	def create FACTORY.createReference transform(DslReference reference) {
		setFrom((reference.eContainer as DslSimpleDomainObject).transform)
		setDoc(reference.doc)
		setName(reference.name)
		setCollectionType(convertCollectionTypeEnum(reference.collectionType))
		setMany(reference.collectionType != null && reference.collectionType != DslCollectionType::NONE)
		setNaturalKey(reference.key)
		setChangeable(!reference.notChangeable)
		setRequired(reference.required)
		setNullable(reference.nullable)
		setCache(reference.cache)
		setInverse(reference.inverse)
		setCascade(reference.cascade)
		setFetch(reference.fetch)
		setOrderBy(reference.orderBy)
		setTo(reference.domainObjectType.transform)
		setDatabaseColumn(reference.databaseColumn)
		setDatabaseJoinTable(reference.databaseJoinTable)
		setDatabaseJoinColumn(reference.databaseJoinColumn)
		setValidate(reference.handleValidation())
		setHint(reference.hint)
		setTransient(reference.transient)
		setVisibility(convertVisibility(reference.visibility))
		if (reference.oppositeHolder != null && reference.oppositeHolder.opposite != null)
			setOpposite(reference.oppositeHolder.opposite.transform)

		if (reference.orderColumn) addHint(buildOrderColumnHint(reference))
		// backwards compatible hint
		if (hasHint("joinTableName")) setDatabaseJoinTable(getHint("joinTableName"))
		if (hasHint("joinColumnName")) setDatabaseJoinColumn(getHint("joinColumnName"))
		
	}

	def private String buildOrderColumnHint(DslReference reference) {
		if (reference.orderColumnName != null) "orderColumn="+reference.orderColumnName else "orderColumn"
	}

	def create FACTORY.createAttribute transform(DslDtoAttribute attribute) {
		setDoc(attribute.doc)
		setName(attribute.name)
		setType(attribute.type)
		setCollectionType(convertCollectionTypeEnum(attribute.collectionType))
		setNaturalKey(attribute.key)
		setChangeable(!attribute.notChangeable)
		setRequired(attribute.required)
		setNullable(attribute.nullable)
		setValidate(attribute.handleValidation())
		setHint(attribute.hint)
		setTransient(attribute.transient)
		setVisibility(convertVisibility(attribute.visibility))
	}

	def create FACTORY.createReference transform(DslDtoReference reference) {
		setFrom((reference.eContainer as DslSimpleDomainObject).transform)
		setDoc(reference.doc)
		setName(reference.name)
		setCollectionType(convertCollectionTypeEnum(reference.collectionType))
		setMany(reference.collectionType != null && reference.collectionType != DslCollectionType::NONE)
		setNaturalKey(reference.key)
		setChangeable(!reference.notChangeable)
		setRequired(reference.required)
		setNullable(reference.nullable)
		setTo(reference.domainObjectType.transform)
		setValidate(reference.handleValidation())
		setHint(reference.hint)
		setTransient(reference.transient)
		setVisibility(convertVisibility(reference.visibility))
	}

	def create FACTORY.createRepository transform(DslRepository repository) {
		setAggregateRoot((repository.eContainer as DslDomainObject).transform)
		setDoc(repository.doc)
		setName(repository.name)
		setGapClass(repository.isGapClassToBeGenerated())
		setHint(repository.hint)
		if (repository.subscribe != null)
			setSubscribe(repository.subscribe.transform)

		operations.addAll(repository.operations.map[e | transform(e)])
	}

	def transformDependencies(DslService service) {
		service.transform.serviceDependencies.addAll(
			(service.dependencies.map[e | transformServiceDependency(e)]).filter(s | s != null))
		service.transform.repositoryDependencies.addAll(
			service.dependencies.map[e | transformRepositoryDependency(e)].filter(r | r != null))
		service.transform.otherDependencies.addAll(
			service.dependencies.map[e | transformOtherDependency(e)].filter(r | r != null))
	}

	def transformDependencies(DslResource resource) {
		resource.transform.serviceDependencies.addAll(
			(resource.dependencies.map[e | transformServiceDependency(e)]).filter(s | s != null))
	}

	def transformDependencies(DslConsumer consumer) {
		consumer.transform.serviceDependencies.addAll(
			(consumer.dependencies.map[e | transformServiceDependency(e)]).filter(s | s != null))
		consumer.transform.repositoryDependencies.addAll(
			consumer.dependencies.map[e | transformRepositoryDependency(e)].filter(r | r != null))
		consumer.transform.otherDependencies.addAll(
			consumer.dependencies.map[e | transformOtherDependency(e)].filter(r | r != null))
	}

	def Repository transformRepositoryDependency(DslDependency dependency) {
		if (dependency.dependency != null && dependency.dependency instanceof DslRepository)
			(dependency.dependency as DslRepository).transform
		else
			null
	}

	def Service transformServiceDependency(DslServiceDependency dependency) {
		if (dependency.dependency != null)
			(dependency.dependency as DslService).transform
		else
			null
	}

	def Service transformServiceDependency(DslDependency dependency) {
		if (dependency.dependency != null && dependency.dependency instanceof DslService)
			(dependency.dependency as DslService).transform
		else
			null
	}

	def String transformOtherDependency(DslDependency dependency) {
		if (dependency.name == null)
			null
		else
			dependency.name
	}

	def transformDependencies(DslDomainObject domainObject) {
		if (domainObject.repository != null)
			domainObject.repository.transformDependencies
		else
			null
	}

	def transformDependencies(DslRepository repository) {
		repository.transform.repositoryDependencies.addAll(
			repository.dependencies.map[e | transformRepositoryDependency(e)].filter(r | r != null))
		repository.transform.otherDependencies.addAll(
			repository.dependencies.map[e | transformOtherDependency(e)].filter(r | r != null))
	}

	def scaffold(DslDomainObject domainObject) {
		domainObject.transform.scaffold()
	}

	def void scaffold(DomainObject domainObject) {
		if (domainObject.repository == null)
			domainObject.addRepository()

		domainObject.repository.addRepositoryScaffoldOperations()
		if (!domainObject.module.services.exists(s | s.name == (domainObject.name + "Service")))
			domainObject.module.addService(domainObject.name + "Service")
		domainObject.module.services.filter(s | s.name == (domainObject.name + "Service")).forEach[addServiceScaffoldOperations(domainObject.repository)]
	}

	def scaffold(DslResource resource) {
		resource.transform.scaffold()
	}

	def scaffold(Resource resource) {
		val serviceName = resource.getDomainResourceName() + "Service"
		val delegateService = resource.module.application.modules.map[services].flatten.findFirst(e|e.name == serviceName)
		resource.addResourceScaffoldOperations(delegateService)
	}

	def private boolean isGapClassToBeGenerated(DslService dslService) {
		if (hasGapOperations(dslService))
			true
		else
			isGapClassToBeGenerated(dslService.gapClass, dslService.noGapClass)
	}

	def private boolean isGapClassToBeGenerated(DslResource dslResource) {
		if (hasGapOperations(dslResource))
			true
		else
			isGapClassToBeGenerated(dslResource.gapClass, dslResource.noGapClass)
	}

	def private boolean isGapClassToBeGenerated(DslRepository dslRepository) {
		if (hasGapOperations(dslRepository))
			true
		else
			isGapClassToBeGenerated(dslRepository.gapClass, dslRepository.noGapClass)
	}

	def private boolean hasGapOperations(DslService dslService) {
		dslService.operations.exists(op | !scaffoldOperations().contains(op.name) && op.delegateHolder == null)
	}

	def private boolean hasGapOperations(DslResource dslResource) {
		dslResource.operations.exists(op | op.delegateHolder == null)
	}

	def private boolean hasGapOperations(DslRepository dslRepository) {
		dslRepository.operations.exists(op |
			!scaffoldOperations().contains(op.name) &&
			!op.delegateToAccessObject && op.accessObjectName == null &&
			!op.transform.isGenericAccessObject())
	}

	def private String handleValidation(DslAttribute attribute) {
		(if (attribute.validate != null) attribute.validate else "") +
		handleParameterizedAnnotation("digits", "integer,fraction,message", attribute.digits, attribute.validate) +
		handleParameterizedAnnotation("size", "min,max,message", attribute.size, attribute.validate) +
		handleBooleanAnnotation("assertTrue", attribute.assertTrue, attribute.assertTrueMessage, attribute.validate) +
		handleBooleanAnnotation("assertFalse", attribute.assertFalse, attribute.assertFalseMessage, attribute.validate) +
		handleBooleanAnnotation("notNull", !attribute.nullable && !attribute.type.isPrimitiveType(), attribute.nullableMessage, attribute.validate) +
		handleBooleanAnnotation("future", attribute.future, attribute.futureMessage, attribute.validate) +
		handleBooleanAnnotation("past", attribute.past, attribute.pastMessage, attribute.validate) +
		handleSimpleAnnotation("min", attribute.min, attribute.validate) +
		handleSimpleAnnotation("max", attribute.max, attribute.validate) +
		handleSimpleAnnotation("decimalMin", attribute.decimalMin, attribute.validate) +
		handleSimpleAnnotation("decimalMax", attribute.decimalMax, attribute.validate) +
		handleParameterizedAnnotation("pattern", "regexp,message", attribute.pattern, attribute.validate) +
		handleBooleanAnnotation("creditCardNumber", attribute.creditCardNumber, attribute.creditCardNumberMessage, attribute.validate) +
		handleBooleanAnnotation("email", attribute.email, attribute.emailMessage, attribute.validate) +
		handleBooleanAnnotation("notEmpty", attribute.notEmpty, attribute.notEmptyMessage, attribute.validate) +
		handleBooleanAnnotation("notBlank", attribute.notBlank, attribute.notBlankMessage, attribute.validate) +
		handleParameterizedAnnotation("scriptAssert", "lang,script,alias,message", attribute.scriptAssert, attribute.validate) +
		handleParameterizedAnnotation("url", "protocol,host,port,message", attribute.url, attribute.validate) +
		handleParameterizedAnnotation("range", "min,max,message", attribute.range, attribute.validate) +
		handleParameterizedAnnotation("length", "max,min,message", attribute.length, attribute.validate)
		
	}

	def private String handleValidation(DslDtoAttribute attribute) {
		(if (attribute.validate != null) attribute.validate else "") +
		handleParameterizedAnnotation("digits", "integer,fraction,message", attribute.digits, attribute.validate) +
		handleParameterizedAnnotation("size", "min,max,message", attribute.size, attribute.validate) +
		handleBooleanAnnotation("assertTrue", attribute.assertTrue, attribute.assertTrueMessage, attribute.validate) +
		handleBooleanAnnotation("assertFalse", attribute.assertFalse, attribute.assertFalseMessage, attribute.validate) +
		handleBooleanAnnotation("notNull", !attribute.nullable && !attribute.type.isPrimitiveType(), attribute.nullableMessage, attribute.validate) +
		handleBooleanAnnotation("future", attribute.future, attribute.futureMessage, attribute.validate) +
		handleBooleanAnnotation("past", attribute.past, attribute.pastMessage, attribute.validate) +
		handleSimpleAnnotation("min", attribute.min, attribute.validate) +
		handleSimpleAnnotation("max", attribute.max, attribute.validate) +
		handleSimpleAnnotation("decimalMin", attribute.decimalMin, attribute.validate) +
		handleSimpleAnnotation("decimalMax", attribute.decimalMax, attribute.validate) +
		handleParameterizedAnnotation("pattern", "regexp,message", attribute.pattern, attribute.validate) +
		handleBooleanAnnotation("creditCardNumber", attribute.creditCardNumber, attribute.creditCardNumberMessage, attribute.validate) +
		handleBooleanAnnotation("email", attribute.email, attribute.emailMessage, attribute.validate) +
		handleBooleanAnnotation("notEmpty", attribute.notEmpty, attribute.notEmptyMessage, attribute.validate) +
		handleBooleanAnnotation("notBlank", attribute.notBlank, attribute.notBlankMessage, attribute.validate) +
		handleParameterizedAnnotation("scriptAssert", "lang,script,alias,message", attribute.scriptAssert, attribute.validate) +
		handleParameterizedAnnotation("url", "protocol,host,port,message", attribute.url, attribute.validate) +
		handleParameterizedAnnotation("range", "min,max,message", attribute.range, attribute.validate) +
		handleParameterizedAnnotation("length", "max,min,message", attribute.length, attribute.validate)
		
	}

	def private String handleValidation(DslReference reference) {
		(if (reference.validate != null) reference.validate else "") +
		handleParameterizedAnnotation("size", "min,max,message", reference.size, reference.validate) +
		handleBooleanAnnotation("notNull", !reference.nullable, reference.nullableMessage, reference.validate) +
		handleBooleanAnnotation("notEmpty", reference.notEmpty, reference.notEmptyMessage, reference.validate) +
		handleBooleanAnnotation("valid", reference.valid, reference.validMessage, reference.validate)
		
	}

	def private String handleValidation(DslDtoReference reference) {
		(if (reference.validate != null) reference.validate else "") +
		handleParameterizedAnnotation("size", "min,max,message", reference.size, reference.validate) +
		handleBooleanAnnotation("notNull", !reference.nullable, reference.nullableMessage, reference.validate) +
		handleBooleanAnnotation("valid", reference.valid, reference.validMessage, reference.validate)
		
	}
}
