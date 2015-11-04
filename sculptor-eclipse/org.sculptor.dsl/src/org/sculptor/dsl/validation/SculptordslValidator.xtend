/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License")
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
package org.sculptor.dsl.validation

import com.google.common.collect.Sets
import java.util.HashSet
import java.util.Set
import java.util.regex.Pattern
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.validation.Check
import org.sculptor.dsl.DslHelper
import org.sculptor.dsl.sculptordsl.DslAnyProperty
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslAttribute
import org.sculptor.dsl.sculptordsl.DslBasicType
import org.sculptor.dsl.sculptordsl.DslCollectionType
import org.sculptor.dsl.sculptordsl.DslDataTransferObject
import org.sculptor.dsl.sculptordsl.DslDomainObject
import org.sculptor.dsl.sculptordsl.DslDtoAttribute
import org.sculptor.dsl.sculptordsl.DslDtoReference
import org.sculptor.dsl.sculptordsl.DslEntity
import org.sculptor.dsl.sculptordsl.DslEnum
import org.sculptor.dsl.sculptordsl.DslEnumAttribute
import org.sculptor.dsl.sculptordsl.DslEnumValue
import org.sculptor.dsl.sculptordsl.DslEvent
import org.sculptor.dsl.sculptordsl.DslModule
import org.sculptor.dsl.sculptordsl.DslParameter
import org.sculptor.dsl.sculptordsl.DslProperty
import org.sculptor.dsl.sculptordsl.DslReference
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslServiceOperation
import org.sculptor.dsl.sculptordsl.DslSimpleDomainObject
import org.sculptor.dsl.sculptordsl.DslValueObject

import static java.util.Arrays.*
import static org.sculptor.dsl.sculptordsl.SculptordslPackage$Literals.*

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.sculptor.dsl.SculptordslExtensions.*
import org.eclipse.emf.ecore.EAttribute

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class SculptordslValidator extends AbstractSculptordslValidator implements IssueCodes {

	private val DIGITS_PATTERN = Pattern.compile("[0-9]+[0-9]*")
	private val SUPPORTED_PRIMITIVE_TYPES = new HashSet<String>(asList("int", "long", "float", "double", "boolean"))
	private val SUPPORTED_TEMPORAL_TYPES = new HashSet<String>(asList("Date", "DateTime", "Timestamp"))
	private val SUPPORTED_NUMERIC_TYPES = new HashSet<String>(
		asList("int", "long", "float", "double", "Integer", "Long", "Float", "Double", "BigInteger", "BigDecimal"))
	private val SUPPORTED_BOOLEAN_TYPES = new HashSet<String>(asList("Boolean", "boolean"))

	@Check
	def checkModuleNameStartsWithLowerCase(DslModule module) {
		if (module.name == null) {
			return
		}
		if (!Character.isLowerCase(module.name.charAt(0))) {
			warning("The module name should begin with a lower case letter", DSL_MODULE__NAME, UNCAPITALIZED_NAME,
					module.name)
		}
	}

	@Check
	def checkServiceNameStartsWithUpperCase(DslService service) {
		if (service.name == null) {
			return
		}
		if (!Character.isUpperCase(service.name.charAt(0))) {
			warning("The service name should begin with an upper case letter", DSL_SERVICE_REPOSITORY_OPTION__NAME,
					CAPITALIZED_NAME, service.name)
		}
	}

	@Check
	def checkRepositoryNameStartsWithUpperCase(DslRepository repository) {
		if (repository.name == null) {
			return
		}
		if (!Character.isUpperCase(repository.name.charAt(0))) {
			warning("The repository name should begin with an upper case letter", DSL_SERVICE_REPOSITORY_OPTION__NAME,
					CAPITALIZED_NAME, repository.name)
		}
	}

	@Check
	def checkDomainObjectNameStartsWithUpperCase(DslSimpleDomainObject domainObject) {
		if (domainObject.name== null) {
			return
		}
		if (!Character.isUpperCase(domainObject.name.charAt(0))) {
			warning("The domain object name should begin with an upper case letter", DSL_SIMPLE_DOMAIN_OBJECT__NAME,
					CAPITALIZED_NAME, domainObject.name)
		}
	}

	@Check
	def checkExtendsName(DslDataTransferObject domainObject) {
		checkExtendsName(domainObject, domainObject.getExtendsName(), DSL_DATA_TRANSFER_OBJECT__EXTENDS_NAME)
	}

	@Check
	def checkExtendsName(DslDomainObject domainObject) {
		checkExtendsName(domainObject, domainObject.getExtendsName(), DSL_DOMAIN_OBJECT__EXTENDS_NAME)
	}

	def private checkExtendsName(DslSimpleDomainObject domainObject, String extendsName, EAttribute attributeFeature) {
		if (extendsName == null) {
			return
		}
		if (extendsName.indexOf('.') != -1) {
			return
		}
		if (DslHelper.getExtends(domainObject) == null) {
			error("Couldn't resolve reference to '" + extendsName + "'", attributeFeature)
		}
	}

	/**
	 * Validation: SimpleDomainObject must not have circular inheritances.
	 */
	@Check
	def checkInheritanceHierarchy(DslSimpleDomainObject domainObject) {
		if (isInheritanceCycle(domainObject)) {
			error("Circular inheritance detected", DSL_SIMPLE_DOMAIN_OBJECT__NAME)
		}
	}

	def private boolean isInheritanceCycle(DslSimpleDomainObject domainObject) {
		val visited = Sets.newHashSet
		var current = domainObject
		while (current != null) {
			if (visited.contains(current)) {
				return true
			}
			visited.add(current)
			current = DslHelper.getExtends(current)
		}
		return false
	}

	@Check
	def checkAbstract(DslDomainObject domainObject) {
		if (domainObject.^abstract) {
			return
		}

		val result = new HashSet<String>()
		abstractOperations(domainObject, result)

		if (!result.isEmpty()) {
			error("The domain object should be declared abstract, since it defines abstract operations: " + result,
					DSL_DOMAIN_OBJECT__ABSTRACT)
		}
	}

	def private void abstractOperations(DslDomainObject domainObject, Set<String> result) {
		if (!isInheritanceCycle(domainObject)) {
			val domainObjectExtends = DslHelper.getExtends(domainObject) as DslDomainObject
			if (domainObjectExtends != null) {
				abstractOperations(domainObjectExtends, result)
			}
		}
		domainObject.operations.forEach[
			// we don't consider overloaded operations, only by name
			if (it.^abstract) {
				result.add(it.name)
			} else {
				result.remove(it.name)
			}
		]
	}

	@Check
	def checkPropertyNameStartsWithLowerCase(DslAnyProperty prop) {
		if (prop.name == null) {
			return
		}
		if (!Character.isLowerCase(prop.name.charAt(0))) {
			warning("Attribute/reference should begin with a lower case letter", DSL_ANY_PROPERTY__NAME,
					UNCAPITALIZED_NAME, prop.name)
		}
	}

	@Check
	def checkParamterNameStartsWithLowerCase(DslParameter param) {
		if (param.name == null) {
			return
		}
		if (!Character.isLowerCase(param.name.charAt(0))) {
			warning("Parameter should begin with a lower case letter", DSL_PARAMETER__NAME, UNCAPITALIZED_NAME,
					param.name)
		}
	}

	@Check
	def checkRequired(DslProperty prop) {
		if (prop.notChangeable && prop.required) {
			warning("The combination not changeable and required doesn't make sense, remove required",
					DSL_ANY_PROPERTY__REQUIRED)
		}
	}

	@Check
	def checkKeyNotChangeable(DslProperty prop) {
		if (prop.key && prop.isNotChangeable()) {
			warning("Key property is always not changeable", DSL_ANY_PROPERTY__NOT_CHANGEABLE)
		}
	}

	@Check
	def checkKeyRequired(DslProperty prop) {
		if (prop.key && prop.isRequired()) {
			warning("Key property is always required", DSL_ANY_PROPERTY__REQUIRED)
		}
	}

	@Check
	def checkCollectionCache(DslReference ref) {
		if (ref.isCache() && ref.collectionType == DslCollectionType.NONE) {
			error("Cache is only applicable for collections", DSL_REFERENCE__CACHE)
		}
	}

	@Check
	def checkInverse(DslReference ref) {
		if (!ref.isInverse()) {
			return
		}
		if (!(ref.collectionType != DslCollectionType.NONE || (ref.getOppositeHolder() != null
				&& ref.getOppositeHolder().getOpposite() != null && ref.getOppositeHolder().getOpposite()
				.collectionType == DslCollectionType.NONE))) {
			error("Inverse is only applicable for references with cardinality many, or one-to-one",
					DSL_REFERENCE__INVERSE)
		}
	}

	@Check
	def checkJoinTable(DslReference ref) {
		if (ref.getDatabaseJoinTable() == null) {
			return
		}

		if (isBidirectionalManyToMany(ref) && ref.getOppositeHolder().getOpposite().getDatabaseJoinTable() != null) {
			warning("Define databaseJoinTable only at one side of the many-to-many association",
					DSL_REFERENCE__DATABASE_JOIN_TABLE)
		}

		if (!(isBidirectionalManyToMany(ref) || (isUnidirectionalToMany(ref) && !ref.isInverse()))) {
			error("databaseJoinTable is only applicable for bidirectional many-to-many, or unidirectional to-many without inverse",
					DSL_REFERENCE__DATABASE_JOIN_TABLE)
		}
	}

	@Check
	def checkJoinColumn(DslReference ref) {
		if (ref.getDatabaseJoinColumn() == null) {
			return
		}

		if (!(isUnidirectionalToMany(ref) && !ref.isInverse())) {
			error("databaseJoinColumn is only applicable for unidirectional to-many without inverse",
					DSL_REFERENCE__DATABASE_JOIN_COLUMN)
		}
	}

	def private boolean isUnidirectionalToMany(DslReference ref) {
		ref.collectionType != DslCollectionType.NONE && ref.getOppositeHolder() == null
	}

	def private boolean isBidirectionalManyToMany(DslReference ref) {
		(ref.collectionType != DslCollectionType.NONE && ref.getOppositeHolder() != null
				&& ref.getOppositeHolder().getOpposite() != null && ref.getOppositeHolder().getOpposite()
				.collectionType != DslCollectionType.NONE)
	}

	@Check
	def checkNullable(DslReference ref) {
		if (ref.nullable && ref.collectionType != DslCollectionType.NONE) {
			error("Nullable isn't applicable for references with cardinality many (" + ref.collectionType + ")",
					DSL_ANY_PROPERTY__NULLABLE)
		}
	}

	/**
	 * For bidirectional one-to-many associations it should only be possible to
	 * define databaseColumn on the reference pointing to the one-side.
	 */
	@Check
	def checkDatabaseColumnForBidirectionalOneToMany(DslReference ref) {
		if (ref.getDatabaseColumn() == null) {
			return
		}
		if (ref.collectionType != DslCollectionType.NONE && ref.getOppositeHolder() != null
				&& ref.getOppositeHolder().getOpposite() != null
				&& ref.getOppositeHolder().getOpposite().collectionType == DslCollectionType.NONE) {
			error("databaseColumn should be defined at the opposite side", DSL_PROPERTY__DATABASE_COLUMN)
		}
	}

	@Check
	def checkOpposite(DslReference ref) {
		if (ref.getOppositeHolder() == null || ref.getOppositeHolder().getOpposite() == null) {
			return
		}
		if (!(ref.getOppositeHolder().getOpposite().getOppositeHolder() != null && ref.getOppositeHolder()
				.getOpposite().getOppositeHolder().getOpposite() == ref)) {
			error("Opposite should specify this reference as opposite: "
					+ ref.getOppositeHolder().getOpposite().name + " <-> " + ref.name,
					DSL_REFERENCE__OPPOSITE_HOLDER)
		}
	}

	@Check
	def checkChangeableCollection(DslReference ref) {
		if (ref.isNotChangeable() && ref.collectionType != DslCollectionType.NONE) {
			warning("x-to-many references are never changeable, the content of the collection is always changeable",
					DSL_ANY_PROPERTY__NOT_CHANGEABLE)
		}
	}

	@Check
	def checkOrderBy(DslReference ref) {
		if (ref.getOrderBy() != null && (!isBag(ref) && !isList(ref))) {
			error("orderBy only applicable for Bag or List collections", DSL_REFERENCE__ORDER_BY)
		}
	}

	@Check
	def checkOrderColumn(DslReference ref) {
		if (ref.isOrderColumn() && !isList(ref)) {
			error("orderColumn only applicable for List collections", DSL_REFERENCE__ORDER_COLUMN)
		}
	}

	@Check
	def checkOrderByOrOrderColumn(DslReference ref) {
		if (ref.getOrderBy() != null && ref.isOrderColumn()) {
			error("use either orderBy or orderColumn for List collections", DSL_REFERENCE__ORDER_BY)
		}
	}

	def private boolean isBag(DslReference ref) {
		return ref.collectionType == DslCollectionType.BAG
	}

	def private boolean isList(DslReference ref) {
		return ref.collectionType == DslCollectionType.LIST
	}

	@Check
	def checkNullableKey(DslProperty prop) {
		if (prop.key && prop.nullable) {
			val parent = prop.eContainer()
			if (!hasAtLeastOneNotNullableKeyElement(parent)) {
				error("Natural key must not be nullable. Composite keys must have at least one not nullable property.",
						DSL_ANY_PROPERTY__NULLABLE)
			}
		}
	}

	def private boolean hasAtLeastOneNotNullableKeyElement(EObject parent) {
		var keyCount = 0
		var nullableKeyCount = 0
		for (EObject each : parent.eContents()) {
			if (each instanceof DslAttribute) {
				if (each.key) {
					keyCount = keyCount + 1
					if (each.nullable) {
						nullableKeyCount = nullableKeyCount + 1
					}
				}
			} else if (each instanceof DslReference) {
				if (each.key) {
					keyCount = keyCount + 1
					if (each.nullable) {
						nullableKeyCount = nullableKeyCount + 1
					}
				}
			} else if (each instanceof DslDtoAttribute) {
				if (each.key) {
					keyCount = keyCount + 1
					if (each.nullable) {
						nullableKeyCount = nullableKeyCount + 1
					}
				}
			} else if (each instanceof DslDtoReference) {
				if (each.key) {
					keyCount = keyCount + 1
					if (each.nullable) {
						nullableKeyCount = nullableKeyCount + 1
					}
				}
			}
		}

		return (keyCount - nullableKeyCount) >= 1
	}

	@Check
	def checkKeyNotManyRefererence(DslReference ref) {
		if (ref.key && ref.collectionType != DslCollectionType.NONE) {
			error("Natural key can't be a many refererence.", DSL_ANY_PROPERTY__KEY)
		}
	}

	@Check
	def checkCascade(DslReference ref) {
		if (ref.getCascade() != null && ref.getDomainObjectType() instanceof DslBasicType) {
			error("Cascade is not applicable for BasicType", DSL_REFERENCE__CASCADE)
		}
		if (ref.getCascade() != null && ref.getDomainObjectType() instanceof DslEnum) {
			error("Cascade is not applicable for enum", DSL_REFERENCE__CASCADE)
		}
	}

	@Check
	def checkCache(DslReference ref) {
		if (ref.isCache() && ref.getDomainObjectType() instanceof DslBasicType) {
			error("Cache is not applicable for BasicType", DSL_REFERENCE__CACHE)
		}
		if (ref.isCache() && ref.getDomainObjectType() instanceof DslEnum) {
			error("Cache is not applicable for enum", DSL_REFERENCE__CACHE)
		}
	}

	@Check
	def checkRepositoryName(DslRepository repository) {
		if (repository.name != null && !repository.name.endsWith("Repository")) {
			error("Name of repository must end with 'Repository'", DSL_SERVICE_REPOSITORY_OPTION__NAME)
		}
	}

	@Check
	def checkEnumReference(DslReference ref) {
		if (ref.getDomainObjectType() instanceof DslEnum && ref.collectionType != DslCollectionType.NONE) {
			val notPersistentVO = ((ref.eContainer() instanceof DslValueObject)
					&& (ref.eContainer as DslValueObject).notPersistent)
			if (!notPersistentVO) {
				error("Collection of enum is not supported", DSL_ANY_PROPERTY__COLLECTION_TYPE)
			}
		}
	}

	@Check
	def checkEnumValues(DslEnum dslEnum) {
		if (dslEnum.values.isEmpty()) {
			error("At least one enum value must be defined", DSL_ENUM__VALUES)
		}
	}

	@Check
	def checkEnumAttributes(DslEnum dslEnum) {
		if (dslEnum.values.isEmpty()) {
			return
		}
		if (dslEnum.attributes.isEmpty()) {
			return
		}
		val attSize = dslEnum.attributes.size()
		for (DslEnumValue each : dslEnum.values) {
			if (each.getParameters().size() != attSize) {
				error("Enum attribute not defined", DSL_ENUM__VALUES)
				return
			}
		}
	}

	@Check
	def checkEnumParameter(DslEnum dslEnum) {
		if (dslEnum.values.isEmpty()) {
			return
		}
		val expectedSize = dslEnum.values.get(0).parameters.size
		for (DslEnumValue each : dslEnum.values) {
			if (each.getParameters().size() != expectedSize) {
				error("Enum values must have same number of parameters", DSL_ENUM__VALUES)
				return
			}
		}
	}

	@Check
	def checkEnumImplicitAttribute(DslEnum dslEnum) {
		if (dslEnum.values.isEmpty()) {
			return
		}
		if (!dslEnum.attributes.isEmpty()) {
			return
		}
		for (DslEnumValue each : dslEnum.values) {
			if (each.getParameters().size() > 1) {
				error("Only one implicit value attribute is allowed", DSL_ENUM__VALUES)
				return
			}
		}
	}

	@Check
	def checkEnumAttributeKey(DslEnum dslEnum) {
		if (dslEnum.values.isEmpty()) {
			return
		}
		var count = 0
		for (DslEnumAttribute each : dslEnum.attributes) {
			if (each.key) {
				count = count + 1
			}
		}
		if (count > 1) {
			error("Only one enum attribute can be defined as key", DSL_ENUM__ATTRIBUTES)
		}
	}

	@Check
	def checkEnumOrdinal(DslEnum dslEnum) {
		val hint = dslEnum.hint
		if (hint != null && hint.contains("ordinal")) {
			for (DslEnumAttribute attr : dslEnum.attributes) {
				if (attr.key) {
					error("ordinal is not allowed for enums with a key attribute", DSL_ENUM__ATTRIBUTES)
					return
				}
			}
			for (DslEnumValue each : dslEnum.values) {
				if (each.getParameters().size() == 1 && dslEnum.attributes.isEmpty()) {
					error("ordinal is not allowed for enum with implicit value", DSL_ENUM__VALUES)
					return
				}
			}
		}
	}

	@Check
	def checkEnumOrdinalOrDatabaseLength(DslEnum dslEnum) {
		val hint = dslEnum.hint
		if (hint != null && hint.contains("ordinal") && hint.contains("databaseLength")) {
			error("ordinal in combination with databaseLength is not allowed", DSL_ENUM__ATTRIBUTES)
		}
	}

	@Check
	def checkEnumDatabaseLength(DslEnum dslEnum) {
		val hint = dslEnum.hint
		if (hint != null && hint.contains("databaseLength")) {
			for (DslEnumAttribute attr : dslEnum.attributes) {
				if (attr.key && !attr.type.equals("String")) {
					error("databaseLength is not allowed for enums not having a key of type String", DSL_ENUM__ATTRIBUTES)
					return
				}
			}
		}
	}

	@Check
	def checkGap(DslService service) {
		if (service.gapClass && service.noGapClass) {
			error("Unclear specification of gap", DSL_SERVICE_REPOSITORY_OPTION__NO_GAP_CLASS)
		}
	}

	@Check
	def checkGap(DslRepository repository) {
		if (repository.gapClass && repository.noGapClass) {
			error("Unclear specification of gap", DSL_SERVICE_REPOSITORY_OPTION__NO_GAP_CLASS)
		}
	}

	@Check
	def checkGap(DslDomainObject domainObj) {
		if (domainObj.gapClass && domainObj.noGapClass) {
			error("Unclear specification of gap", DSL_DOMAIN_OBJECT__NO_GAP_CLASS)
		}
	}

	@Check
	def checkGap(DslBasicType domainObj) {
		if (domainObj.gapClass && domainObj.noGapClass) {
			error("Unclear specification of gap", DSL_BASIC_TYPE__NO_GAP_CLASS)
		}
	}

	@Check
	def checkDiscriminatorValue(DslEntity domainObj) {
		if (domainObj.discriminatorValue != null && domainObj.^extends == null) {
			error("discriminatorValue can only be used when you extend another Entity",
					DSL_DOMAIN_OBJECT__DISCRIMINATOR_VALUE)
		}
	}

	@Check
	def checkDiscriminatorValue(DslValueObject domainObj) {
		if (domainObj.discriminatorValue != null && domainObj.^extends == null) {
			error("discriminatorValue can only be used when you extend another ValueObject",
					DSL_DOMAIN_OBJECT__DISCRIMINATOR_VALUE)
		}
	}

	@Check
	def checkRepositoryOnlyForAggregateRoot(DslDomainObject domainObj) {
		if (domainObj.getRepository() != null && belongsToAggregate(domainObj)) {
			error("Only aggregate roots can have Repository", DSL_DOMAIN_OBJECT__REPOSITORY)
		}
	}

	@Check
	def checkBelongsToRefersToAggregateRoot(DslDomainObject domainObj) {
		if (domainObj.belongsTo != null && belongsToAggregate(domainObj.belongsTo)) {
			error("belongsTo should refer to the aggregate root DomainObject", DSL_DOMAIN_OBJECT__BELONGS_TO)
		}
	}

	def private boolean belongsToAggregate(DslDomainObject domainObj) {
		return (domainObj.notAggregateRoot || domainObj.belongsTo != null)
	}

	@Check
	def checkAggregateRootOnlyForPersistentValueObject(DslValueObject domainObj) {
		if (belongsToAggregate(domainObj) && domainObj.isNotPersistent()) {
			error("not aggregateRoot is only applicable for persistent ValueObjects",
					DSL_DOMAIN_OBJECT__NOT_AGGREGATE_ROOT)
		}
	}

	@Check
	def checkLength(DslAttribute attr) {
		if (attr.getLength() == null) {
			return
		}
		if (!isString(attr)) {
			error("length is only relevant for strings", DSL_ATTRIBUTE__LENGTH)
		}
		if (!DIGITS_PATTERN.matcher(attr.getLength()).matches()) {
			error("length value should be numeric, e.g. length = \"10\"", DSL_ATTRIBUTE__LENGTH)
		}
	}

	@Check
	def checkNullable(DslAttribute attr) {
		if (attr.nullable && isPrimitive(attr)) {
			error("nullable is not relevant for primitive types", DSL_ANY_PROPERTY__NULLABLE)
		}
	}

	@Check
	def checkCreditCardNumber(DslAttribute attr) {
		if (attr.isCreditCardNumber() && !isString(attr)) {
			error("creditCardNumber is only relevant for strings", DSL_ATTRIBUTE__CREDIT_CARD_NUMBER)
		}
	}

	@Check
	def checkEmail(DslAttribute attr) {
		if (attr.isEmail() && !isString(attr)) {
			error("email is only relevant for strings", DSL_ATTRIBUTE__EMAIL)
		}
	}

	@Check
	def checkNotEmpty(DslAttribute attr) {
		if (attr.isNotEmpty() && !(isString(attr) || isCollection(attr))) {
			error("notEmpty is only relevant for strings or collection types", DSL_ANY_PROPERTY__NOT_EMPTY)
		}
	}

	@Check
	def checkNotEmpty(DslReference ref) {
		if (ref.isNotEmpty() && !isCollection(ref)) {
			error("notEmpty is only relevant for collection types", DSL_ANY_PROPERTY__NOT_EMPTY)
		}
	}

	@Check
	def checkSize(DslReference ref) {
		if (ref.getSize() == null) {
			return
		}
		if (!isCollection(ref)) {
			error("size is only relevant for collection types", DSL_ANY_PROPERTY__SIZE)
		}
	}

	@Check
	def checkPast(DslAttribute attr) {
		if (attr.isPast() && !isTemporal(attr)) {
			error("past is only relevant for temporal types", DSL_ATTRIBUTE__PAST)
		}
	}

	@Check
	def checkFuture(DslAttribute attr) {
		if (attr.isFuture() && !isTemporal(attr)) {
			error("future is only relevant for temporal types", DSL_ATTRIBUTE__FUTURE)
		}
	}

	@Check
	def checkMin(DslAttribute attr) {
		if (attr.getMin() == null) {
			return
		}
		if (!isNumeric(attr)) {
			error("min is only relevant for numeric types", DSL_ATTRIBUTE__MIN)
		}
	}

	@Check
	def checkMax(DslAttribute attr) {
		if (attr.getMax() == null) {
			return
		}
		if (!isNumeric(attr)) {
			error("max is only relevant for numeric types", DSL_ATTRIBUTE__MAX)
		}
	}

	@Check
	def checkRange(DslAttribute attr) {
		if (attr.getRange() != null && !isNumeric(attr)) {
			error("range is only relevant for numeric types", DSL_ATTRIBUTE__RANGE)
		}
	}

	@Check
	def checkDigits(DslAttribute attr) {
		if (attr.getDigits() != null && !isNumeric(attr)) {
			error("digits is only relevant for numeric types", DSL_ATTRIBUTE__DIGITS)
		}
	}

	@Check
	def checkAssertTrue(DslAttribute attr) {
		if (attr.isAssertTrue() && !isBoolean(attr)) {
			error("assertTrue is only relevant for boolean types", DSL_ATTRIBUTE__ASSERT_TRUE)
		}
	}

	@Check
	def checkAssertFalse(DslAttribute attr) {
		if (attr.isAssertFalse() && !isBoolean(attr)) {
			error("assertFalse is only relevant for boolean types", DSL_ATTRIBUTE__ASSERT_FALSE)
		}
	}

	@Check
	def checkScaffoldValueObject(DslValueObject valueObj) {
		if (valueObj.isScaffold() && valueObj.isNotPersistent()) {
			error("Scaffold not useful for not-persistent ValueObject.", DSL_DOMAIN_OBJECT__SCAFFOLD)
		}
	}

	@Check
	def checkScaffoldEvent(DslEvent event) {
		if (event.isScaffold() && !event.isPersistent()) {
			error("Scaffold not useful for not-persistent event.", DSL_DOMAIN_OBJECT__SCAFFOLD, NON_PERSISTENT_EVENT,
				DSL_DOMAIN_OBJECT__SCAFFOLD.name)
		}
	}

	@Check
	def checkRepositoryEvent(DslEvent event) {
		if (event.repository != null && !event.isPersistent()) {
			error("Repository not useful for not-persistent event.", DSL_DOMAIN_OBJECT__REPOSITORY,
				NON_PERSISTENT_EVENT, DSL_DOMAIN_OBJECT__REPOSITORY.name)
		}
	}

	def private boolean isString(DslAttribute attribute) {
		return "String".equals(attribute.type) && !isCollection(attribute)
	}

	def private boolean isCollection(DslAttribute attribute) {
		return attribute.collectionType != null && attribute.collectionType != DslCollectionType.NONE
	}

	def private boolean isCollection(DslReference ref) {
		return ref.collectionType != null && ref.collectionType != DslCollectionType.NONE
	}

	def private boolean isPrimitive(DslAttribute attribute) {
		return SUPPORTED_PRIMITIVE_TYPES.contains(attribute.type) && !isCollection(attribute)
	}

	def private boolean isTemporal(DslAttribute attribute) {
		return SUPPORTED_TEMPORAL_TYPES.contains(attribute.type) && !isCollection(attribute)
	}

	def private boolean isNumeric(DslAttribute attribute) {
		return SUPPORTED_NUMERIC_TYPES.contains(attribute.type) && !isCollection(attribute)
	}

	def private boolean isBoolean(DslAttribute attribute) {
		return SUPPORTED_BOOLEAN_TYPES.contains(attribute.type) && !isCollection(attribute)
	}

	@Check
	def checkDomainObjectDuplicateName(DslSimpleDomainObject obj) {
		if (obj.name != null && obj.rootContainer.eAllOfClass(typeof(DslSimpleDomainObject)).filter [it.name == obj.name].size > 1) {
			error("Duplicate name.  There is already an existing Domain Object named '"
				+ obj.name + "'.", DSL_SIMPLE_DOMAIN_OBJECT__NAME, obj.name
			);  
		}
	}

	@Check
	def checkServiceDuplicateName(DslService service) {
		if (service.name != null && service.rootContainer.eAllOfType(typeof(DslService)).filter [it.name == service.name].size > 1) {
			error("Duplicate name.  There is already an existing Service named '"
				+ service.name + "'.", DSL_SERVICE_REPOSITORY_OPTION__NAME, service.name
			);  
		}
	}

	@Check
	def checkRepositoryDuplicateName(DslRepository repository) {
		if (repository.name != null && repository.rootContainer.eAllOfClass(typeof(DslRepository)).filter [it.name == repository.name].size > 1) {
			error("Duplicate name.  There is already an existing Repository named '"
				+ repository.name + "'.", DSL_SERVICE_REPOSITORY_OPTION__NAME, repository.name
			);  
		}
	}

	@Check
	def checkModuleDuplicateName(DslModule module) {
		if (module.name != null && module.rootContainer.eAllOfClass(typeof(DslModule)).filter [it.name == module.name].size > 1) {
			error("Duplicate name.  There is already an existing Module named '"
				+ module.name + "'.", DSL_MODULE__NAME, module.name
			);  
		}
	}
	
	@Check
	def checkApplicationDuplicateName(DslApplication app) {
		if (app.name != null && app.rootContainer.eAllOfClass(typeof(DslApplication)).filter [it.name == app.name].size > 1) {
			error("Duplicate name.  There is already an existing Application named '"
				+ app.name + "'.", DSL_APPLICATION__NAME, app.name
			);  
		}
	}

	/**
	 * Type matches a domain object, but due to missing '-', comes in as a DslAttribute rather than a DslReference
	 */
	@Check
	def checkMissingReferenceNotationWithNoCollection(DslAttribute attr) {
		if(attr.type != null && attr.collectionType == DslCollectionType.NONE &&
			attr.domainObjectsForAttributeType.empty == false) {
			warning("Use - " + attr.type, DSL_ATTRIBUTE__TYPE, attr.type)
		}
	}

	/**
	 * Type for collection matches a domain object, but due to missing '-', comes in as a DslAttribute rather than a DslReference
	 */
	@Check
	def checkMissingReferenceNotationWithCollection(DslAttribute attr) {
		if(attr.type != null && attr.collectionType != DslCollectionType.NONE &&
			attr.domainObjectsForAttributeType.empty == false) {
			warning("Use - " + attr.collectionType + "<" + attr.type + ">", DSL_ATTRIBUTE__TYPE, attr.type)
		}
	}

	@Check
	def checkMissingDomainObjectInServiceOperationReturnType(DslServiceOperation it) {
		if(returnType != null && returnType.domainObjectType == null && returnType.type != null &&
		   returnType.firstDomainObjectForType != null) {
			warning("Use @" + returnType.type, DSL_SERVICE_OPERATION__RETURN_TYPE, returnType.type)
		}
	}

	@Check
	def checkMissingDomainObjectInRepositoryOperationReturnType(DslRepositoryOperation it) {
		if(returnType != null && returnType.domainObjectType == null && returnType.type != null &&
		   returnType.firstDomainObjectForType != null) {
			warning("Use @" + returnType.type, DSL_REPOSITORY_OPERATION__RETURN_TYPE, returnType.type)
		}
	}

	@Check
	def checkMissingDomainObjectInParameter(DslParameter it) {
		if(parameterType != null && parameterType.domainObjectType == null && parameterType.type != null &&
		   parameterType.firstDomainObjectForType != null) {
			warning("Use @" + parameterType.type, DSL_PARAMETER__PARAMETER_TYPE, parameterType.type)
		}
	}

	@Check
	def checkApplicationBasepackageNameIsAllLowerCase(DslApplication application) {
		if (application.basePackage == null) {
			return
		}
		if (!application.basePackage.isAllLowerCase) {
			warning("The basepackage name should be in lower case", DSL_APPLICATION__BASE_PACKAGE,
				ALL_LOWERCASE_NAME, application.basePackage)
		}
	}

	@Check
	def checkModuleBasepackageNameIsAllLowerCase(DslModule module) {
		if (module.basePackage == null) {
			return
		}
		if (!module.basePackage.isAllLowerCase) {
			warning("The basepackage name should be in lower case", DSL_MODULE__BASE_PACKAGE, ALL_LOWERCASE_NAME,
				module.basePackage)
		}
	}

	def private boolean isAllLowerCase(String name) {
		!name.toCharArray.exists[char|Character.isUpperCase(char)]
	}

}
