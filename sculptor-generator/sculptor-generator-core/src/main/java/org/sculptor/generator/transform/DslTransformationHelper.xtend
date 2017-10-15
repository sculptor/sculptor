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
import org.sculptor.dsl.sculptordsl.DslAttribute
import org.sculptor.dsl.sculptordsl.DslCollectionType
import org.sculptor.dsl.sculptordsl.DslComplexType
import org.sculptor.dsl.sculptordsl.DslDiscriminatorType
import org.sculptor.dsl.sculptordsl.DslDtoAttribute
import org.sculptor.dsl.sculptordsl.DslDtoReference
import org.sculptor.dsl.sculptordsl.DslReference
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslResource
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslVisibility
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.GenericAccessObjectManager
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.DiscriminatorType
import sculptormetamodel.DomainObject
import sculptormetamodel.Resource

/**
 * Overridable helper methods for transforming DSL meta model to generator meta model.
 */
@ChainOverridable
class DslTransformationHelper {

	@Inject var GenericAccessObjectManager genericAccessObjectManager

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

	def String convertVisibility(DslVisibility dslVisibility) {
		if (dslVisibility === null)
			"public"
		else
			dslVisibility.toString()
	}

	def String convertCollectionType(DslComplexType dslComplexType) {
		if (dslComplexType === null)
			null
		else if (dslComplexType.mapCollectionType !== null)
			dslComplexType.mapCollectionType
		else
			convertCollectionTypeEnum(dslComplexType.collectionType)
	}

	def String convertCollectionTypeEnum(DslCollectionType collectionType) {
		if (collectionType === null || collectionType == DslCollectionType.NONE)
			null
		else
			collectionType.toString()
	}

	def DiscriminatorType mapDiscriminatorType(DslDiscriminatorType dslDiscriminatorType) {
		switch (dslDiscriminatorType) {
			case DslDiscriminatorType.CHAR :
				DiscriminatorType.CHAR
			case DslDiscriminatorType.INTEGER :
				DiscriminatorType.INTEGER
			default :
				DiscriminatorType.STRING
		}
	}

	def String buildOrderColumnHint(DslReference reference) {
		if (reference.orderColumnName !== null) "orderColumn="+reference.orderColumnName else "orderColumn"
	}

	def boolean isGapClassToBeGenerated(DslService dslService) {
		if (hasGapOperations(dslService))
			true
		else
			isGapClassToBeGenerated(dslService.gapClass, dslService.noGapClass)
	}

	def boolean isGapClassToBeGenerated(DslResource dslResource) {
		if (hasGapOperations(dslResource))
			true
		else
			isGapClassToBeGenerated(dslResource.gapClass, dslResource.noGapClass)
	}

	def boolean isGapClassToBeGenerated(DslRepository dslRepository) {
		if (hasGapOperations(dslRepository))
			true
		else
			isGapClassToBeGenerated(dslRepository.gapClass, dslRepository.noGapClass)
	}

	def boolean hasGapOperations(DslService dslService) {
		dslService.operations.exists(op | !scaffoldOperations().contains(op.name) && op.delegateHolder === null)
	}

	def boolean hasGapOperations(DslResource dslResource) {
		dslResource.operations.exists(op | op.delegateHolder === null)
	}

	def boolean hasGapOperations(DslRepository dslRepository) {
		dslRepository.operations.exists(op |
			!scaffoldOperations().contains(op.name) &&
			!op.delegateToAccessObject && op.accessObjectName === null &&
			!op.isGenericAccessObject)
	}

	def private boolean isGenericAccessObject(DslRepositoryOperation operation) {
		genericAccessObjectManager.getStrategy(operation.name) !== null
	}

	def String handleValidation(DslAttribute attribute) {
		(if (attribute.validate !== null) attribute.validate else "") +
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

	def String handleValidation(DslDtoAttribute attribute) {
		(if (attribute.validate !== null) attribute.validate else "") +
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

	def String handleValidation(DslReference reference) {
		(if (reference.validate !== null) reference.validate else "") +
		handleParameterizedAnnotation("size", "min,max,message", reference.size, reference.validate) +
		handleBooleanAnnotation("notNull", !reference.nullable, reference.nullableMessage, reference.validate) +
		handleBooleanAnnotation("notEmpty", reference.notEmpty, reference.notEmptyMessage, reference.validate) +
		handleBooleanAnnotation("valid", reference.valid, reference.validMessage, reference.validate)
	}

	def String handleValidation(DslDtoReference reference) {
		(if (reference.validate !== null) reference.validate else "") +
		handleParameterizedAnnotation("size", "min,max,message", reference.size, reference.validate) +
		handleBooleanAnnotation("notNull", !reference.nullable, reference.nullableMessage, reference.validate) +
		handleBooleanAnnotation("valid", reference.valid, reference.validMessage, reference.validate)
	}

	def void scaffold(DomainObject domainObject) {
		domainObject.scaffoldRepository
		domainObject.scaffoldService
	}

	def void scaffoldRepository(DomainObject domainObject) {
		if (domainObject.repository === null)
			domainObject.addRepository
		domainObject.repository.addRepositoryScaffoldOperations
	}

	def void scaffoldService(DomainObject domainObject) {
		val serviceName = domainObject.name + "Service"
		if (!domainObject.module.services.exists[s | s.name == serviceName])
			domainObject.module.addService(serviceName)
		domainObject.module.services.filter[s | s.name == serviceName].forEach[addServiceScaffoldOperations(domainObject.repository)]
	}

	def void scaffold(Resource resource) {
		val serviceName = resource.domainResourceName + "Service"
		val delegateService = resource.module.application.modules.map[services].flatten.findFirst(e|e.name == serviceName)
		resource.addResourceScaffoldOperations(delegateService)
	}

}
