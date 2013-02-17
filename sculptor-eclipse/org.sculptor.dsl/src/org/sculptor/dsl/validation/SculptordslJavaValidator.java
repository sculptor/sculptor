/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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

package org.sculptor.dsl.validation;

import static java.util.Arrays.asList;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__COLLECTION_TYPE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__KEY;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__NAME;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__NOT_CHANGEABLE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__NOT_EMPTY;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__NULLABLE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__REQUIRED;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ANY_PROPERTY__SIZE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__ASSERT_FALSE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__ASSERT_TRUE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__CREDIT_CARD_NUMBER;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__DIGITS;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__EMAIL;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__FUTURE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__LENGTH;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__MAX;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__MIN;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__PAST;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ATTRIBUTE__RANGE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_BASIC_TYPE__NO_GAP_CLASS;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__ABSTRACT;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__BELONGS_TO;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__DISCRIMINATOR_VALUE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__EXTENDS_NAME;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__NOT_AGGREGATE_ROOT;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__NO_GAP_CLASS;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__REPOSITORY;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_DOMAIN_OBJECT__SCAFFOLD;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ENUM__ATTRIBUTES;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_ENUM__VALUES;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_MODULE__NAME;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_PARAMETER__NAME;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_PROPERTY__DATABASE_COLUMN;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__CACHE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__CASCADE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__DATABASE_JOIN_COLUMN;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__DATABASE_JOIN_TABLE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__INVERSE;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__OPPOSITE_HOLDER;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__ORDER_BY;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_REFERENCE__ORDER_COLUMN;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_SERVICE_REPOSITORY_OPTION__NAME;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_SERVICE_REPOSITORY_OPTION__NO_GAP_CLASS;
import static org.sculptor.dsl.sculptordsl.SculptordslPackage.Literals.DSL_SIMPLE_DOMAIN_OBJECT__NAME;

import java.util.HashSet;
import java.util.Set;
import java.util.regex.Pattern;

import org.eclipse.emf.ecore.EObject;
import org.eclipse.xtext.validation.Check;
import org.sculptor.dsl.DslHelper;
import org.sculptor.dsl.sculptordsl.DslAnyProperty;
import org.sculptor.dsl.sculptordsl.DslAttribute;
import org.sculptor.dsl.sculptordsl.DslBasicType;
import org.sculptor.dsl.sculptordsl.DslCollectionType;
import org.sculptor.dsl.sculptordsl.DslDataTransferObject;
import org.sculptor.dsl.sculptordsl.DslDomainObject;
import org.sculptor.dsl.sculptordsl.DslDomainObjectOperation;
import org.sculptor.dsl.sculptordsl.DslDtoAttribute;
import org.sculptor.dsl.sculptordsl.DslDtoReference;
import org.sculptor.dsl.sculptordsl.DslEntity;
import org.sculptor.dsl.sculptordsl.DslEnum;
import org.sculptor.dsl.sculptordsl.DslEnumAttribute;
import org.sculptor.dsl.sculptordsl.DslEnumValue;
import org.sculptor.dsl.sculptordsl.DslModule;
import org.sculptor.dsl.sculptordsl.DslParameter;
import org.sculptor.dsl.sculptordsl.DslProperty;
import org.sculptor.dsl.sculptordsl.DslReference;
import org.sculptor.dsl.sculptordsl.DslRepository;
import org.sculptor.dsl.sculptordsl.DslService;
import org.sculptor.dsl.sculptordsl.DslSimpleDomainObject;
import org.sculptor.dsl.sculptordsl.DslValueObject;

import com.google.common.collect.Sets;

public class SculptordslJavaValidator extends AbstractSculptordslJavaValidator implements IssueCodes {

	private static final Pattern DIGITS_PATTERN = Pattern.compile("[0-9]+[0-9]*");
	private static final Set<String> SUPPORTED_PRIMITIVE_TYPES = new HashSet<String>(asList("int", "long", "float",
			"double", "boolean"));
	private static final Set<String> SUPPORTED_TEMPORAL_TYPES = new HashSet<String>(asList("Date", "DateTime",
			"Timestamp"));
	private static final Set<String> SUPPORTED_NUMERIC_TYPES = new HashSet<String>(asList("int", "long", "float",
			"double", "Integer", "Long", "Float", "Double", "BigInteger", "BigDecimal"));
	private static final Set<String> SUPPORTED_BOOLEAN_TYPES = new HashSet<String>(asList("Boolean", "boolean"));

	@Check
	public void checkModuleNameStartsWithLowerCase(DslModule module) {
		if (module.getName() == null) {
			return;
		}
		if (!Character.isLowerCase(module.getName().charAt(0))) {
			warning("The module name should begin with a lower case letter", DSL_MODULE__NAME, UNCAPITALIZED_NAME,
					module.getName());
		}
	}

	@Check
	public void checkServiceNameStartsWithUpperCase(DslService service) {
		if (service.getName() == null) {
			return;
		}
		if (!Character.isUpperCase(service.getName().charAt(0))) {
			warning("The service name should begin with an upper case letter", DSL_SERVICE_REPOSITORY_OPTION__NAME,
					CAPITALIZED_NAME, service.getName());
		}
	}

	@Check
	public void checkRepositoryNameStartsWithUpperCase(DslRepository repository) {
		if (repository.getName() == null) {
			return;
		}
		if (!Character.isUpperCase(repository.getName().charAt(0))) {
			warning("The repository name should begin with an upper case letter", DSL_SERVICE_REPOSITORY_OPTION__NAME,
					CAPITALIZED_NAME, repository.getName());
		}
	}

	@Check
	public void checkDomainObjectNameStartsWithUpperCase(DslSimpleDomainObject domainObject) {
		if (domainObject.getName() == null) {
			return;
		}
		if (!Character.isUpperCase(domainObject.getName().charAt(0))) {
			warning("The domain object name should begin with an upper case letter", DSL_SIMPLE_DOMAIN_OBJECT__NAME,
					CAPITALIZED_NAME, domainObject.getName());
		}
	}

	@Check
	public void checkExtendsName(DslDataTransferObject domainObject) {
		checkExtendsName(domainObject, domainObject.getExtendsName());
	}

	@Check
	public void checkExtendsName(DslDomainObject domainObject) {
		checkExtendsName(domainObject, domainObject.getExtendsName());
	}

	private void checkExtendsName(DslSimpleDomainObject domainObject, String extendsName) {
		if (extendsName == null) {
			return;
		}
		if (extendsName.indexOf('.') != -1) {
			return;
		}

		if (DslHelper.getExtends(domainObject) == null) {
			error("Couldn't resolve reference to '" + extendsName + "'", DSL_DOMAIN_OBJECT__EXTENDS_NAME);
		}
	}

	/**
	 * Validation: SimpleDomainObject must not have circular inheritances.
	 */
	@Check
	public void checkInheritanceHierarchy(DslSimpleDomainObject domainObject) {
		if (isInheritanceCycle(domainObject)) {
			error("Circular inheritance detected", DSL_SIMPLE_DOMAIN_OBJECT__NAME);
		}
	}

	private boolean isInheritanceCycle(DslSimpleDomainObject domainObject) {
		Set<DslSimpleDomainObject> visited = Sets.newHashSet();
		DslSimpleDomainObject current = domainObject;
		while (current != null) {
			if (visited.contains(current)) {
				return true;
			}
			visited.add(current);
			current = DslHelper.getExtends(current);
		}
		return false;
	}

	@Check
	public void checkAbstract(DslDomainObject domainObject) {
		if (domainObject.isAbstract()) {
			return;
		}

		Set<String> result = new HashSet<String>();
		abstractOperations(domainObject, result);

		if (!result.isEmpty()) {
			error("The domain object should be declared abstract, since it defines abstract operations: " + result,
					DSL_DOMAIN_OBJECT__ABSTRACT);
		}
	}

	private void abstractOperations(DslDomainObject domainObject, Set<String> result) {
		if (!isInheritanceCycle(domainObject)) {
			DslDomainObject domainObjectExtends = (DslDomainObject) DslHelper.getExtends(domainObject);
			if (domainObjectExtends != null) {
				abstractOperations(domainObjectExtends, result);
			}
		}
		for (DslDomainObjectOperation each : domainObject.getOperations()) {
			// we don't consider overloaded operations, only by name
			if (each.isAbstract()) {
				result.add(each.getName());
			} else {
				result.remove(each.getName());
			}
		}
	}

	@Check
	public void checkPropertyNameStartsWithLowerCase(DslAnyProperty prop) {
		if (prop.getName() == null) {
			return;
		}
		if (!Character.isLowerCase(prop.getName().charAt(0))) {
			warning("Attribute/reference should begin with a lower case letter", DSL_ANY_PROPERTY__NAME,
					UNCAPITALIZED_NAME, prop.getName());
		}
	}

	@Check
	public void checkParamterNameStartsWithLowerCase(DslParameter param) {
		if (param.getName() == null) {
			return;
		}
		if (!Character.isLowerCase(param.getName().charAt(0))) {
			warning("Parameter should begin with a lower case letter", DSL_PARAMETER__NAME, UNCAPITALIZED_NAME,
					param.getName());
		}
	}

	@Check
	public void checkRequired(DslProperty prop) {
		if (prop.isNotChangeable() && prop.isRequired()) {
			warning("The combination not changeable and required doesn't make sense, remove required",
					DSL_ANY_PROPERTY__REQUIRED);
		}
	}

	@Check
	public void checkKeyNotChangeable(DslProperty prop) {
		if (prop.isKey() && prop.isNotChangeable()) {
			warning("Key property is always not changeable", DSL_ANY_PROPERTY__NOT_CHANGEABLE);
		}
	}

	@Check
	public void checkKeyRequired(DslProperty prop) {
		if (prop.isKey() && prop.isRequired()) {
			warning("Key property is always required", DSL_ANY_PROPERTY__REQUIRED);
		}
	}

	@Check
	public void checkCollectionCache(DslReference ref) {
		if (ref.isCache() && ref.getCollectionType() == DslCollectionType.NONE) {
			error("Cache is only applicable for collections", DSL_REFERENCE__CACHE);
		}
	}

	@Check
	public void checkInverse(DslReference ref) {
		if (!ref.isInverse()) {
			return;
		}
		if (!(ref.getCollectionType() != DslCollectionType.NONE || (ref.getOppositeHolder() != null
				&& ref.getOppositeHolder().getOpposite() != null && ref.getOppositeHolder().getOpposite()
				.getCollectionType() == DslCollectionType.NONE))) {
			error("Inverse is only applicable for references with cardinality many, or one-to-one",
					DSL_REFERENCE__INVERSE);
		}
	}

	@Check
	public void checkJoinTable(DslReference ref) {
		if (ref.getDatabaseJoinTable() == null) {
			return;
		}

		if (isBidirectionalManyToMany(ref) && ref.getOppositeHolder().getOpposite().getDatabaseJoinTable() != null) {
			warning("Define databaseJoinTable only at one side of the many-to-many association",
					DSL_REFERENCE__DATABASE_JOIN_TABLE);
		}

		if (!(isBidirectionalManyToMany(ref) || (isUnidirectionalToMany(ref) && !ref.isInverse()))) {
			error("databaseJoinTable is only applicable for bidirectional many-to-many, or unidirectional to-many without inverse",
					DSL_REFERENCE__DATABASE_JOIN_TABLE);
		}
	}

	@Check
	public void checkJoinColumn(DslReference ref) {
		if (ref.getDatabaseJoinColumn() == null) {
			return;
		}

		if (!(isUnidirectionalToMany(ref) && !ref.isInverse())) {
			error("databaseJoinColumn is only applicable for unidirectional to-many without inverse",
					DSL_REFERENCE__DATABASE_JOIN_COLUMN);
		}
	}

	private boolean isUnidirectionalToMany(DslReference ref) {
		return ref.getCollectionType() != DslCollectionType.NONE && ref.getOppositeHolder() == null;
	}

	private boolean isBidirectionalManyToMany(DslReference ref) {
		return (ref.getCollectionType() != DslCollectionType.NONE && ref.getOppositeHolder() != null
				&& ref.getOppositeHolder().getOpposite() != null && ref.getOppositeHolder().getOpposite()
				.getCollectionType() != DslCollectionType.NONE);
	}

	@Check
	public void checkNullable(DslReference ref) {
		if (ref.isNullable() && ref.getCollectionType() != DslCollectionType.NONE) {
			error("Nullable isn't applicable for references with cardinality many (" + ref.getCollectionType() + ")",
					DSL_ANY_PROPERTY__NULLABLE);
		}
	}

	/**
	 * For bidirectional one-to-many associations it should only be possible to
	 * define databaseColumn on the reference pointing to the one-side.
	 */
	@Check
	public void checkDatabaseColumnForBidirectionalOneToMany(DslReference ref) {
		if (ref.getDatabaseColumn() == null) {
			return;
		}
		if (ref.getCollectionType() != DslCollectionType.NONE && ref.getOppositeHolder() != null
				&& ref.getOppositeHolder().getOpposite() != null
				&& ref.getOppositeHolder().getOpposite().getCollectionType() == DslCollectionType.NONE) {
			error("databaseColumn should be defined at the opposite side", DSL_PROPERTY__DATABASE_COLUMN);
		}
	}

	@Check
	public void checkOpposite(DslReference ref) {
		if (ref.getOppositeHolder() == null || ref.getOppositeHolder().getOpposite() == null) {
			return;
		}
		if (!(ref.getOppositeHolder().getOpposite().getOppositeHolder() != null && ref.getOppositeHolder()
				.getOpposite().getOppositeHolder().getOpposite() == ref)) {
			error("Opposite should specify this reference as opposite: "
					+ ref.getOppositeHolder().getOpposite().getName() + " <-> " + ref.getName(),
					DSL_REFERENCE__OPPOSITE_HOLDER);
		}
	}

	@Check
	public void checkChangeableCollection(DslReference ref) {
		if (ref.isNotChangeable() && ref.getCollectionType() != DslCollectionType.NONE) {
			warning("x-to-many references are never changeable, the content of the collection is always changeable",
					DSL_ANY_PROPERTY__NOT_CHANGEABLE);
		}
	}

	@Check
	public void checkOrderBy(DslReference ref) {
		if (ref.getOrderBy() != null && (!isBag(ref) && !isList(ref))) {
			error("orderBy only applicable for Bag or List collections", DSL_REFERENCE__ORDER_BY);
		}
	}

	@Check
	public void checkOrderColumn(DslReference ref) {
		if (ref.isOrderColumn() && !isList(ref)) {
			error("orderColumn only applicable for List collections", DSL_REFERENCE__ORDER_COLUMN);
		}
	}

	@Check
	public void checkOrderByOrOrderColumn(DslReference ref) {
		if (ref.getOrderBy() != null && ref.isOrderColumn()) {
			error("use either orderBy or orderColumn for List collections", DSL_REFERENCE__ORDER_BY);
		}
	}

	private boolean isBag(DslReference ref) {
		return ref.getCollectionType() == DslCollectionType.BAG;
	}

	private boolean isList(DslReference ref) {
		return ref.getCollectionType() == DslCollectionType.LIST;
	}

	@Check
	public void checkNullableKey(DslProperty prop) {
		if (prop.isKey() && prop.isNullable()) {
			EObject parent = prop.eContainer();
			if (!hasAtLeastOneNotNullableKeyElement(parent)) {
				error("Natural key must not be nullable. Composite keys must have at least one not nullable property.",
						DSL_ANY_PROPERTY__NULLABLE);
			}
		}
	}

	private boolean hasAtLeastOneNotNullableKeyElement(EObject parent) {
		int keyCount = 0;
		int nullableKeyCount = 0;
		for (EObject each : parent.eContents()) {
			if (each instanceof DslAttribute) {
				DslAttribute eachProp = (DslAttribute) each;
				if (eachProp.isKey()) {
					keyCount++;
					if (eachProp.isNullable()) {
						nullableKeyCount++;
					}
				}
			} else if (each instanceof DslReference) {
				DslReference eachProp = (DslReference) each;
				if (eachProp.isKey()) {
					keyCount++;
					if (eachProp.isNullable()) {
						nullableKeyCount++;
					}
				}
			} else if (each instanceof DslDtoAttribute) {
				DslDtoAttribute eachProp = (DslDtoAttribute) each;
				if (eachProp.isKey()) {
					keyCount++;
					if (eachProp.isNullable()) {
						nullableKeyCount++;
					}
				}
			} else if (each instanceof DslDtoReference) {
				DslDtoReference eachProp = (DslDtoReference) each;
				if (eachProp.isKey()) {
					keyCount++;
					if (eachProp.isNullable()) {
						nullableKeyCount++;
					}
				}
			}
		}

		return (keyCount - nullableKeyCount) >= 1;
	}

	@Check
	public void checkKeyNotManyRefererence(DslReference ref) {
		if (ref.isKey() && ref.getCollectionType() != DslCollectionType.NONE) {
			error("Natural key can't be a many refererence.", DSL_ANY_PROPERTY__KEY);
		}
	}

	@Check
	public void checkCascade(DslReference ref) {
		if (ref.getCascade() != null && ref.getDomainObjectType() instanceof DslBasicType) {
			error("Cascade is not applicable for BasicType", DSL_REFERENCE__CASCADE);
		}
		if (ref.getCascade() != null && ref.getDomainObjectType() instanceof DslEnum) {
			error("Cascade is not applicable for enum", DSL_REFERENCE__CASCADE);
		}
	}

	@Check
	public void checkCache(DslReference ref) {
		if (ref.isCache() && ref.getDomainObjectType() instanceof DslBasicType) {
			error("Cache is not applicable for BasicType", DSL_REFERENCE__CACHE);
		}
		if (ref.isCache() && ref.getDomainObjectType() instanceof DslEnum) {
			error("Cache is not applicable for enum", DSL_REFERENCE__CACHE);
		}
	}

	@Check
	public void checkRepositoryName(DslRepository repository) {
		if (repository.getName() != null && !repository.getName().endsWith("Repository")) {
			error("Name of repository must end with 'Repository'", DSL_SERVICE_REPOSITORY_OPTION__NAME);
		}
	}

	@Check
	public void checkEnumReference(DslReference ref) {
		if (ref.getDomainObjectType() instanceof DslEnum && ref.getCollectionType() != DslCollectionType.NONE) {
			boolean notPersistentVO = ((ref.eContainer() instanceof DslValueObject) && ((DslValueObject) ref
					.eContainer()).isNotPersistent());
			if (!notPersistentVO) {
				error("Collection of enum is not supported", DSL_ANY_PROPERTY__COLLECTION_TYPE);
			}
		}
	}

	@Check
	public void checkEnumValues(DslEnum dslEnum) {
		if (dslEnum.getValues().isEmpty()) {
			error("At least one enum value must be defined", DSL_ENUM__VALUES);
		}
	}

	@Check
	public void checkEnumAttributes(DslEnum dslEnum) {
		if (dslEnum.getValues().isEmpty()) {
			return;
		}
		if (dslEnum.getAttributes().isEmpty()) {
			return;
		}
		int attSize = dslEnum.getAttributes().size();
		for (DslEnumValue each : dslEnum.getValues()) {
			if (each.getParameters().size() != attSize) {
				error("Enum attribute not defined", DSL_ENUM__VALUES);
				return;
			}
		}
	}

	@Check
	public void checkEnumParameter(DslEnum dslEnum) {
		if (dslEnum.getValues().isEmpty()) {
			return;
		}
		int expectedSize = dslEnum.getValues().get(0).getParameters().size();
		for (DslEnumValue each : dslEnum.getValues()) {
			if (each.getParameters().size() != expectedSize) {
				error("Enum values must have same number of parameters", DSL_ENUM__VALUES);
				return;
			}
		}
	}

	@Check
	public void checkEnumImplicitAttribute(DslEnum dslEnum) {
		if (dslEnum.getValues().isEmpty()) {
			return;
		}
		if (!dslEnum.getAttributes().isEmpty()) {
			return;
		}
		for (DslEnumValue each : dslEnum.getValues()) {
			if (each.getParameters().size() > 1) {
				error("Only one implicit value attribute is allowed", DSL_ENUM__VALUES);
				return;
			}
		}
	}

	@Check
	public void checkEnumAttributeKey(DslEnum dslEnum) {
		if (dslEnum.getValues().isEmpty()) {
			return;
		}
		int count = 0;
		for (DslEnumAttribute each : dslEnum.getAttributes()) {
			if (each.isKey()) {
				count++;
			}
		}
		if (count > 1) {
			error("Only one enum attribute can be defined as key", DSL_ENUM__ATTRIBUTES);
		}
	}

	@Check
	public void checkEnumOrdinal(DslEnum dslEnum) {
		if (!dslEnum.getHint().contains("ordinal")) {
			return;
		}
		for (DslEnumAttribute attr : dslEnum.getAttributes()) {
			if (attr.isKey()) {
				error("ordinal is not allowed for enums with a key attribute", DSL_ENUM__ATTRIBUTES);
				return;
			}
		}
		for (DslEnumValue each : dslEnum.getValues()) {
			if (each.getParameters().size() == 1 && dslEnum.getAttributes().isEmpty()) {
				error("ordinal is not allowed for enum with implicit value", DSL_ENUM__VALUES);
				return;
			}
		}
	}

	@Check
	public void checkEnumOrdinalOrDatabaseLength(DslEnum dslEnum) {
		if (dslEnum.getHint().contains("ordinal") && dslEnum.getHint().contains("databaseLength")) {
			error("ordinal in combination with databaseLength is not allowed", DSL_ENUM__ATTRIBUTES);
		}
	}

	@Check
	public void checkEnumDatabaseLength(DslEnum dslEnum) {
		if (!dslEnum.getHint().contains("databaseLength")) {
			return;
		}
		for (DslEnumAttribute attr : dslEnum.getAttributes()) {
			if (attr.isKey() && !attr.getType().equals("String")) {
				error("databaseLength is not allowed for enums not having a key of type String", DSL_ENUM__ATTRIBUTES);
				return;
			}
		}
	}

	@Check
	public void checkGap(DslService service) {
		if (service.isGapClass() && service.isNoGapClass()) {
			error("Unclear specification of gap", DSL_SERVICE_REPOSITORY_OPTION__NO_GAP_CLASS);
		}
	}

	@Check
	public void checkGap(DslRepository repository) {
		if (repository.isGapClass() && repository.isNoGapClass()) {
			error("Unclear specification of gap", DSL_SERVICE_REPOSITORY_OPTION__NO_GAP_CLASS);
		}
	}

	@Check
	public void checkGap(DslDomainObject domainObj) {
		if (domainObj.isGapClass() && domainObj.isNoGapClass()) {
			error("Unclear specification of gap", DSL_DOMAIN_OBJECT__NO_GAP_CLASS);
		}
	}

	@Check
	public void checkGap(DslBasicType domainObj) {
		if (domainObj.isGapClass() && domainObj.isNoGapClass()) {
			error("Unclear specification of gap", DSL_BASIC_TYPE__NO_GAP_CLASS);
		}
	}

	@Check
	public void checkDiscriminatorValue(DslEntity domainObj) {
		if (domainObj.getDiscriminatorValue() != null && domainObj.getExtends() == null) {
			error("discriminatorValue can only be used when you extend another Entity",
					DSL_DOMAIN_OBJECT__DISCRIMINATOR_VALUE);
		}
	}

	@Check
	public void checkDiscriminatorValue(DslValueObject domainObj) {
		if (domainObj.getDiscriminatorValue() != null && domainObj.getExtends() == null) {
			error("discriminatorValue can only be used when you extend another ValueObject",
					DSL_DOMAIN_OBJECT__DISCRIMINATOR_VALUE);
		}
	}

	@Check
	public void checkRepositoryOnlyForAggregateRoot(DslDomainObject domainObj) {
		if (domainObj.getRepository() != null && belongsToAggregate(domainObj)) {
			error("Only aggregate roots can have Repository", DSL_DOMAIN_OBJECT__REPOSITORY);
		}
	}

	@Check
	public void checkBelongsToRefersToAggregateRoot(DslDomainObject domainObj) {
		if (domainObj.getBelongsTo() != null && belongsToAggregate(domainObj.getBelongsTo())) {
			error("belongsTo should refer to the aggregate root DomainObject", DSL_DOMAIN_OBJECT__BELONGS_TO);
		}
	}

	private boolean belongsToAggregate(DslDomainObject domainObj) {
		return (domainObj.isNotAggregateRoot() || domainObj.getBelongsTo() != null);
	}

	@Check
	public void checkAggregateRootOnlyForPersistentValueObject(DslValueObject domainObj) {
		if (belongsToAggregate(domainObj) && domainObj.isNotPersistent()) {
			error("not aggregateRoot is only applicable for persistent ValueObjects",
					DSL_DOMAIN_OBJECT__NOT_AGGREGATE_ROOT);
		}
	}

	@Check
	public void checkLength(DslAttribute attr) {
		if (attr.getLength() == null) {
			return;
		}
		if (!isString(attr)) {
			error("length is only relevant for strings", DSL_ATTRIBUTE__LENGTH);
		}
		if (!DIGITS_PATTERN.matcher(attr.getLength()).matches()) {
			error("length value should be numeric, e.g. length = \"10\"", DSL_ATTRIBUTE__LENGTH);
		}
	}

	@Check
	public void checkNullable(DslAttribute attr) {
		if (attr.isNullable() && isPrimitive(attr)) {
			error("nullable is not relevant for primitive types", DSL_ANY_PROPERTY__NULLABLE);
		}
	}

	@Check
	public void checkCreditCardNumber(DslAttribute attr) {
		if (attr.isCreditCardNumber() && !isString(attr)) {
			error("creditCardNumber is only relevant for strings", DSL_ATTRIBUTE__CREDIT_CARD_NUMBER);
		}
	}

	@Check
	public void checkEmail(DslAttribute attr) {
		if (attr.isEmail() && !isString(attr)) {
			error("email is only relevant for strings", DSL_ATTRIBUTE__EMAIL);
		}
	}

	@Check
	public void checkNotEmpty(DslAttribute attr) {
		if (attr.isNotEmpty() && !(isString(attr) || isCollection(attr))) {
			error("notEmpty is only relevant for strings or collection types", DSL_ANY_PROPERTY__NOT_EMPTY);
		}
	}

	@Check
	public void checkNotEmpty(DslReference ref) {
		if (ref.isNotEmpty() && !isCollection(ref)) {
			error("notEmpty is only relevant for collection types", DSL_ANY_PROPERTY__NOT_EMPTY);
		}
	}

	@Check
	public void checkSize(DslReference ref) {
		if (ref.getSize() == null) {
			return;
		}
		if (!isCollection(ref)) {
			error("size is only relevant for collection types", DSL_ANY_PROPERTY__SIZE);
		}
	}

	@Check
	public void checkPast(DslAttribute attr) {
		if (attr.isPast() && !isTemporal(attr)) {
			error("past is only relevant for temporal types", DSL_ATTRIBUTE__PAST);
		}
	}

	@Check
	public void checkFuture(DslAttribute attr) {
		if (attr.isFuture() && !isTemporal(attr)) {
			error("future is only relevant for temporal types", DSL_ATTRIBUTE__FUTURE);
		}
	}

	@Check
	public void checkMin(DslAttribute attr) {
		if (attr.getMin() == null) {
			return;
		}
		if (!isNumeric(attr)) {
			error("min is only relevant for numeric types", DSL_ATTRIBUTE__MIN);
		}
	}

	@Check
	public void checkMax(DslAttribute attr) {
		if (attr.getMax() == null) {
			return;
		}
		if (!isNumeric(attr)) {
			error("max is only relevant for numeric types", DSL_ATTRIBUTE__MAX);
		}
	}

	@Check
	public void checkRange(DslAttribute attr) {
		if (attr.getRange() != null && !isNumeric(attr)) {
			error("range is only relevant for numeric types", DSL_ATTRIBUTE__RANGE);
		}
	}

	@Check
	public void checkDigits(DslAttribute attr) {
		if (attr.getDigits() != null && !isNumeric(attr)) {
			error("digits is only relevant for numeric types", DSL_ATTRIBUTE__DIGITS);
		}
	}

	@Check
	public void checkAssertTrue(DslAttribute attr) {
		if (attr.isAssertTrue() && !isBoolean(attr)) {
			error("assertTrue is only relevant for boolean types", DSL_ATTRIBUTE__ASSERT_TRUE);
		}
	}

	@Check
	public void checkAssertFalse(DslAttribute attr) {
		if (attr.isAssertFalse() && !isBoolean(attr)) {
			error("assertFalse is only relevant for boolean types", DSL_ATTRIBUTE__ASSERT_FALSE);
		}
	}

	@Check
	public void checkScaffold(DslValueObject domainObj) {
		if (domainObj.isScaffold() && domainObj.isNotPersistent()) {
			error("Scaffold not useful for not persistent ValueObject.", DSL_DOMAIN_OBJECT__SCAFFOLD);
		}
	}

	private boolean isString(DslAttribute attribute) {
		return "String".equals(attribute.getType()) && !isCollection(attribute);
	}

	private boolean isCollection(DslAttribute attribute) {
		return attribute.getCollectionType() != null && attribute.getCollectionType() != DslCollectionType.NONE;
	}

	private boolean isCollection(DslReference ref) {
		return ref.getCollectionType() != null && ref.getCollectionType() != DslCollectionType.NONE;
	}

	private boolean isPrimitive(DslAttribute attribute) {
		return SUPPORTED_PRIMITIVE_TYPES.contains(attribute.getType()) && !isCollection(attribute);
	}

	private boolean isTemporal(DslAttribute attribute) {
		return SUPPORTED_TEMPORAL_TYPES.contains(attribute.getType()) && !isCollection(attribute);
	}

	private boolean isNumeric(DslAttribute attribute) {
		return SUPPORTED_NUMERIC_TYPES.contains(attribute.getType()) && !isCollection(attribute);
	}

	private boolean isBoolean(DslAttribute attribute) {
		return SUPPORTED_BOOLEAN_TYPES.contains(attribute.getType()) && !isCollection(attribute);
	}

}
