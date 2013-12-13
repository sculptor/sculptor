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

package org.sculptor.generator.util;

import java.util.ArrayList;
import java.util.Collections;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.inject.Inject;

import sculptormetamodel.Application;
import sculptormetamodel.Attribute;
import sculptormetamodel.BasicType;
import sculptormetamodel.DomainObject;
import sculptormetamodel.Entity;
import sculptormetamodel.Enum;
import sculptormetamodel.EnumConstructorParameter;
import sculptormetamodel.EnumValue;
import sculptormetamodel.Inheritance;
import sculptormetamodel.Module;
import sculptormetamodel.NamedElement;
import sculptormetamodel.Reference;
import sculptormetamodel.SculptormetamodelFactory;
import sculptormetamodel.impl.SculptormetamodelFactoryImpl;

public class DbHelperBase {

	private static final String ID_ATTRIBUTE_NAME = "id";

	@Inject private HelperBase helperBase;
	@Inject private PropertiesBase propBase;
	@Inject private SingularPluralConverter singularPluralConverter;

	public List<DomainObject> getDomainObjectsInCreateOrder(Application application, Boolean ascending) {
		List<DomainObject> all = getAllDomainObjects(application);
		List<DomainObject> orderedClasses = new ArrayList<DomainObject>();
		Set<DomainObject> handledClasses = new HashSet<DomainObject>();

		for (DomainObject domainObject : all) {
			addClassRecursive(domainObject, orderedClasses, handledClasses);
		}

		if (!ascending) {
			Collections.reverse(orderedClasses);
		}

		return orderedClasses;
	}

	/**
	 * @return all persistent DomainObjects
	 */
	public List<DomainObject> getAllDomainObjects(Application application) {
		List<DomainObject> all = new ArrayList<DomainObject>();
		List<Module> modules = HelperBase.sortByName(application.getModules());
		for (Module m : modules) {
			if (m.isExternal()) {
				continue;
			}
			List<DomainObject> domainObjects = HelperBase.sortByName(m.getDomainObjects());
			for (DomainObject d : domainObjects) {
				if (helperBase.isPersistent(d) && includeInDdl(d)) {
					all.add(d);
				}
			}
		}
		return all;
	}

	private boolean includeInDdl(DomainObject domainObj) {
		return !helperBase.hasHintImpl(domainObj.getHint(), "skipddl");
	}

	private void addClassRecursive(DomainObject domainObject, List<DomainObject> orderedClasses,
			Set<DomainObject> handledClasses) {
		if (handledClasses.contains(domainObject)) {
			// already added
			return;
		}
		if (domainObject instanceof BasicType) {
			// no tables for BasicType
			return;
		}

		if (!helperBase.isPersistent(domainObject) || !includeInDdl(domainObject)) {
			// no tables for non persistent ValueObject
			return;
		}

		if (domainObject.getModule().isExternal()) {
			return;
		}

		// add current class, will break recursion if referred again
		handledClasses.add(domainObject);

		// we must have the referenced super class first, due to foreign key
		if (domainObject.getExtends() != null) {
			addClassRecursive(domainObject.getExtends(), orderedClasses, handledClasses);
		}

		// we must have the referenced classes first, due to foreign keys
		for (Reference ref : getAllOneReferences(domainObject)) {
			addClassRecursive(ref.getTo(), orderedClasses, handledClasses);
		}

		if (!orderedClasses.contains(domainObject)) {
			orderedClasses.add(domainObject);
		}

	}

	public String getDiscriminatorColumnDatabaseType(Inheritance inheritance) {
		// create an Attribute so that we can reuse existing logic for
		// databaseType
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Attribute attr = factory.createAttribute();
		if (inheritance.getDiscriminatorColumnName() == null) {
			attr.setName(propBase.getProperty("db.discriminatorColumnName"));
		} else {
			attr.setName(inheritance.getDiscriminatorColumnName());
		}
		attr.setType("discriminatorType." + inheritance.getDiscriminatorType().getLiteral());
		if (inheritance.getDiscriminatorColumnLength() != null) {
			attr.setLength(inheritance.getDiscriminatorColumnLength());
		}

		return getDatabaseType(attr);
	}

	public String getDatabaseType(Attribute attribute) {
		String databaseTypeProperty = attribute.getDatabaseType();
		String databaseType;
		if (databaseTypeProperty == null) {
			databaseType = getDefaultDbType(attribute.getType());
		} else {
			databaseType = databaseTypeProperty;
		}

		String length = getDatabaseLength(attribute);
		if (length != null && databaseType.indexOf('(') == -1) {
			databaseType += ("(" + length + ")");
		}

		return databaseType;
	}

	public String getEnumDatabaseType(Reference reference) {
		Attribute enumAttribute = getEnumAttribute((Enum) reference.getTo());
		if (helperBase.hasHintImpl(reference.getHint(), "databaseLength"))
			enumAttribute.setLength(helperBase.getHintImpl(reference.getHint(), "databaseLength"));
		return getDatabaseType(enumAttribute);
	}

	public String getEnumDatabaseType(Enum _enum) {
		return getDatabaseType(getEnumAttribute(_enum));
	}

	public String getEnumType(Enum _enum) {
		return getEnumAttribute(_enum).getType();
	}

	public String getEnumDatabaseLength(Enum _enum) {
		return getEnumAttribute(_enum).getLength();
	}

	private Attribute getEnumKeyAttribute(Enum _enum) {
		List<Attribute> enumAttributes = _enum.getAttributes();
		for (Attribute attribute : enumAttributes) {
			if (attribute.isNaturalKey()) {
				return attribute;
			}
		}

		return createDefaultEnumAttribute();
	}

	private Attribute createDefaultEnumAttribute() {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Attribute attr = factory.createAttribute();
		attr.setType("String");
		return attr;
	}

	private boolean hasNaturalKeyAttribute(Enum _enum) {
		return (getEnumKeyAttribute(_enum).isNaturalKey());
	}

	private Attribute getEnumAttribute(Enum _enum) {
		Attribute attribute = getEnumKeyAttribute(_enum);
		if (_enum.isOrdinal()) {
			attribute.setType("int");
			attribute.setLength(null);
		} else {
			if (helperBase.hasHintImpl(_enum.getHint(), "databaseLength")) {
				attribute.setType("String");
				attribute.setLength(helperBase.getHintImpl(_enum.getHint(), "databaseLength"));
			} else {
				attribute.setType(attribute.getType() != null ? attribute.getType() : "String");
				attribute.setLength(calcEnumDatabaseLength(_enum));
			}
		}
		return attribute;
	}

	private String calcEnumDatabaseLength(Enum _enum) {
		int maxLength = 0;
		if (hasNaturalKeyAttribute(_enum)) {
			int attributePosition = 0;
			for (Attribute attribute : (List<Attribute>) _enum.getAttributes()) {
				if (attribute.isNaturalKey()) {
					for (EnumValue enumValue : (List<EnumValue>) _enum.getValues()) {
						EnumConstructorParameter enumParam = (EnumConstructorParameter) enumValue.getParameters().get(
								attributePosition);
						maxLength = calcMaxLength(enumParam.getValue(), maxLength);
					}
					break;
				}
				attributePosition++;
			}
		}
		if (maxLength == 0) {
			for (EnumValue value : (List<EnumValue>) _enum.getValues()) {
				maxLength = calcMaxLength(value.getName(), maxLength);
			}
		}
		return "" + maxLength;
	}

	private int calcMaxLength(String value, int maxLength) {
		int length = value.length();
		if (value.startsWith("\"")) {
			length = length - 2;
		}
		return (maxLength < length) ? length : maxLength;
	}

	public String getDatabaseTypeNullability(Attribute attribute) {
		if (!attribute.isNullable() || attribute.isNaturalKey()) {
			return " NOT NULL";
		}
		return "";
	}

	public String getDatabaseTypeNullability(Reference reference) {
		if (!reference.isNullable() || reference.isNaturalKey()) {
			return " NOT NULL";
		}
		return "";
	}

	public String getDatabaseLength(Attribute attribute) {
		if (attribute.getLength() == null) {
			return getDefaultDbLength(attribute.getType());
		} else {
			return attribute.getLength();
		}
	}

	private String getDefaultDbType(String javaType) {
		return propBase.getDbType(javaType);
	}

	private String getDefaultDbLength(String javaType) {
		return propBase.getDbLength(javaType);
	}

	public String getDatabaseNameBase(NamedElement element) {
		String name = element.getName();
		name = convertDatabaseName(name);
		return name;
	}

	private String convertDatabaseName(String name) {
		if (propBase.getBooleanProperty("db.useUnderscoreNaming")) {
			name = CamelCaseConverter.camelCaseToUnderscore(name);
		}
		name = truncateLongDatabaseName(name);
		name = name.toUpperCase();
		return name;
	}

	public String truncateLongDatabaseName(String name) {
		int max = propBase.getMaxDbName();
		return truncateLongDatabaseName(name, max);
	}

	public String truncateLongDatabaseName(String name, Integer max) {
		if (name.length() <= max) {
			return name; // no problem
		} else if (propBase.getBooleanProperty("db.errorWhenTooLongName")) {
			throw new RuntimeException("Generation aborted due to too long database name: " + name);
		} else {
			String hash = String.valueOf(Math.abs(name.hashCode()));
			hash = "0" + hash; // make sure that it is at least 2 chars
			hash = hash.substring(hash.length() - 2); // use 2 last characters
			String truncated = name.substring(0, max - hash.length()) + hash;
			return truncated;
		}
	}

	public String getDefaultForeignKeyNameBase(Reference ref) {
		String name;
		if (ref.isMany()) {
			name = singularPluralConverter.toSingular(ref.getName());
		} else {
			name = ref.getName();
		}
		DomainObject to = ref.getTo();
		name += idSuffix(name, to);
		return convertDatabaseName(name);
	}

	public String getDefaultOppositeForeignKeyName(Reference ref) {
		if (ref.getOpposite() == null) {
			return getForeignKeyNameForUnidirectionalToManyWithJoinTable(ref);
		} else {
			return getDefaultForeignKeyNameBase(ref.getOpposite());
		}
	}

	private String getForeignKeyNameForUnidirectionalToManyWithJoinTable(Reference ref) {
		if (ref.getDatabaseJoinColumn() != null) {
			return ref.getDatabaseJoinColumn();
		}

		DomainObject from = ref.getFrom();
		String name = from.getDatabaseTable();
		if (name == null) {
			name = from.getName();
		}
		name += idSuffix(name, from);
		return convertDatabaseName(name);
	}

	public String getExtendsForeignKeyName(DomainObject extendedClass) {
		Attribute idAttribute = getIdAttribute(extendedClass);
		checkIdAttribute(extendedClass, idAttribute);
		String name = extendedClass.getDatabaseTable();
		name += idSuffix(name, extendedClass);
		return name;
	}

	private String idSuffix(String name, DomainObject to) {
		if (useIdSuffixInForeignKey()) {
			Attribute idAttribute = getIdAttribute(to);
			if (idAttribute != null) {
				String idName = idAttribute.getDatabaseColumn().toUpperCase();
				String convertedName = convertDatabaseName(name);
				if (idName.equals(convertedName) && idName.startsWith(to.getDatabaseTable())) {
					idName = idName.substring(to.getDatabaseTable().length());
				} else if (idName.startsWith(convertedName)) {
					idName = idName.substring(convertedName.length());
				}
				if (idName.startsWith("_")) {
					return idName;
				} else {
					return ("_" + idName);
				}
			}
		}
		return "";
	}

	private boolean useIdSuffixInForeignKey() {
		return propBase.getBooleanProperty("db.useIdSuffixInForeigKey");
	}

	protected Attribute getIdAttribute(DomainObject domainObject) {
		Attribute idAttribute = getAttributeWithName(ID_ATTRIBUTE_NAME, domainObject);
		if ((idAttribute == null) && (domainObject.getExtends() != null)) {
			// look in extended DomainOject, recursive call
			idAttribute = getIdAttribute(domainObject.getExtends());
		}
		return idAttribute;
	}

	private Attribute getAttributeWithName(String name, DomainObject domainObject) {
		for (Object obj : domainObject.getAttributes()) {
			Attribute attribute = (Attribute) obj;
			if (attribute.getName().equals(name)) {
				return attribute;
			}
		}
		// not found
		return null;
	}

	public String getForeignKeyType(Reference ref) {
		DomainObject referencedClass = ref.getTo();
		return getForeignKeyType(referencedClass) + getDatabaseTypeNullability(ref);
	}

	public String getForeignKeyType(DomainObject referencedClass) {
		Attribute idAttribute = getIdAttribute(referencedClass);
		checkIdAttribute(referencedClass, idAttribute);
		String type = getDatabaseType(idAttribute);
		return type;
	}

	private void checkIdAttribute(DomainObject referencedClass, Attribute idAttribute) {
		if (idAttribute == null) {
			throw new IllegalArgumentException("Referenced class " + referencedClass.getName() + " doesn't contain 'id' attribute");
		}
	}

	public List<DomainObject> resolveManyToManyRelations(Application application, Boolean ascending) {
		// first, find all many-to-many references
		Set<Reference> manyToManyReferences = new HashSet<Reference>();
		List<DomainObject> domainObjects = getAllDomainObjects(application);
		for (DomainObject domainObject : domainObjects) {
			for (Reference ref : getAllManyReferences(domainObject)) {
				if (!helperBase.isPersistent(ref.getTo()) || !includeInDdl(ref.getTo())) {
					// skip this reference, since it refers to a non persistent
					// object
					continue;
				}
				if (ref.isTransient()) {
					// skip this reference, since it is transient
					continue;
				}
				Reference opposite = ref.getOpposite();
				// undirectional many references are designed in db as
				// many-to-many, except when inverse is defined to true
				if ((opposite == null && !ref.isInverse())
						|| (opposite != null && opposite.isMany() && !opposite.isTransient() && !manyToManyReferences
								.contains(opposite))) {
					manyToManyReferences.add(ref);
				}
			}
		}
		// then, create an fictive DomainObject for each many-to-many reference
		List<DomainObject> manyToManyClasses = new ArrayList<DomainObject>();
		for (Reference ref : manyToManyReferences) {
			DomainObject relObj = createFictiveManyToManyObject(ref);
			manyToManyClasses.add(relObj);
		}

		manyToManyClasses = HelperBase.sortByName(manyToManyClasses);

		if (!ascending) {
			Collections.reverse(manyToManyClasses);
		}
		return manyToManyClasses;

	}

	public DomainObject createFictiveManyToManyObject(Reference ref) {
		DomainObject relObj;
		if (ref.getFrom() instanceof Entity || ref.getTo() instanceof Entity) {
			relObj = SculptormetamodelFactory.eINSTANCE.createEntity();
		} else {
			// many-to-many between two value objects is not likely (good
			// design) but whatever...
			relObj = SculptormetamodelFactory.eINSTANCE.createValueObject();
		}
		String name = getManyToManyJoinTableName(ref);
		relObj.setName(name.toUpperCase());
		relObj.setDatabaseTable(getDatabaseNameBase(relObj));
		relObj.setAbstract(true);

		Reference ref1 = SculptormetamodelFactory.eINSTANCE.createReference();
		ref1.setTo(ref.getTo());
		ref1.setName(singularPluralConverter.toSingular(ref.getName()));
		ref1.setDatabaseColumn(ref.getDatabaseColumn());
		ref1.setFrom(relObj);
		relObj.getReferences().add(ref1);

		Reference ref2 = SculptormetamodelFactory.eINSTANCE.createReference();
		ref2.setTo(ref.getFrom());
		if (ref.getOpposite() == null) {
			// use table name of from obj, it doesn't matter that we loose
			// upper/lower case
			ref2.setName(helperBase.toFirstLower(ref.getFrom().getName()));
			ref2.setDatabaseColumn(getForeignKeyNameForUnidirectionalToManyWithJoinTable(ref));
		} else {
			ref2.setName(singularPluralConverter.toSingular(ref.getOpposite().getName()));
			ref2.setDatabaseColumn(ref.getOpposite().getDatabaseColumn());
		}
		ref2.setFrom(relObj);
		relObj.getReferences().add(ref2);

		String tablespaceHint = helperBase.getHintImpl(ref.getFrom().getHint(), "tablespace");
		if (tablespaceHint != null) {
			helperBase.addHint(relObj, "tablespace=" + tablespaceHint);
		}

		return relObj;
	}

	public String getManyToManyJoinTableName(Reference ref) {
		if (ref.getDatabaseJoinTable() != null) {
			return ref.getDatabaseJoinTable();
		}
		if (ref.getOpposite() != null && ref.getOpposite().getDatabaseJoinTable() != null) {
			return ref.getOpposite().getDatabaseJoinTable();
		}

		String name1 = ref.getDatabaseColumn();
		name1 = removeIdSuffix(name1, ref.getTo());
		String name2;
		if (ref.getOpposite() == null) {
			name2 = (ref.getFrom().getDatabaseTable() != null) ? ref.getFrom().getDatabaseTable() : ref.getFrom().getName()
					.toUpperCase();
		} else {
			name2 = ref.getOpposite().getDatabaseColumn();
			name2 = removeIdSuffix(name2, ref.getOpposite().getTo());
		}

		return getJoinTableName(name1, name2, true);
	}

	public String getElementCollectionTableName(Attribute attribute) {
		String hintParam = "databaseJoinTableName";
		if (helperBase.hasHintImpl(attribute.getHint(), hintParam)) {
			return helperBase.getHintImpl(attribute.getHint(), hintParam);
		}

		String name1 = singularPluralConverter.toSingular(attribute.getDatabaseColumn().toLowerCase()).toUpperCase();
		String name2 = ((DomainObject) attribute.eContainer()).getDatabaseTable();

		return getJoinTableName(name1, name2, false);
	}

	public String getElementCollectionTableName(Reference reference) {
		if (reference.getDatabaseJoinTable() != null) {
			return reference.getDatabaseJoinTable();
		}

		String name1 = reference.getDatabaseColumn();
		name1 = removeIdSuffix(name1, reference.getTo());
		String name2;
		if (reference.getOpposite() == null) {
			name2 = (reference.getFrom().getDatabaseTable() != null) ? reference.getFrom().getDatabaseTable() : reference.getFrom()
					.getName().toUpperCase();
		} else {
			name2 = reference.getOpposite().getDatabaseColumn();
			name2 = removeIdSuffix(name2, reference.getOpposite().getTo());
		}

		return getJoinTableName(name1, name2, false);
	}

	private String getJoinTableName(String name1, String name2, boolean ordered) {
		int max = propBase.getMaxDbName();
		if ((name1.length() > (max - 6)) && (name2.length() > (max - 6))) {
			// both names are long, truncate both
			name1 = name1.substring(0, (max / 2));
			name2 = name2.substring(0, (max / 2));
		}

		if ((name1.length() + name2.length() + 1) > max) {
			// too long, truncate the longest name
			if (name1.length() > name2.length()) {
				name1 = name1.substring(0, (max - name2.length() - 1));
			} else {
				name2 = name2.substring(0, (max - name1.length() - 1));
			}
		}

		// order them in some well defined way, like alphabetic order
		if (ordered) {
			String name;
			if (name1.compareTo(name2) < 0) {
				name = name1 + "_" + name2;
			} else {
				name = name2 + "_" + name1;
			}
			return name;
		}

		return name2 + "_" + name1;
	}

	private String removeIdSuffix(String name, DomainObject to) {
		String idSuffix = idSuffix(name, to);
		if (idSuffix.equals("")) {
			return name;
		}
		if (name.endsWith(idSuffix)) {
			return name.substring(0, name.length() - idSuffix.length());
		}
		return name;
	}

	/**
	 * Inverse attribute for many-to-many associations.
	 */
	public boolean isInverse(Reference ref) {
		if (ref.isInverse()) {
			return true;
		}
		if (!ref.isInverse() && (ref.getOpposite() != null) && ref.getOpposite().isInverse()) {
			return false;
		}
		if (ref.getOpposite() == null) {
			return false;
		}
		// inverse not defined on any side, use this algorithm
		String name1 = ref.getTo().getName();
		String name2 = ref.getFrom().getName();

		// use a well defined algorithm, like alphabetic order
		// A -> B inverse=false
		// B -> A inverse= true
		return (name1.compareTo(name2) < 0);
	}

	/**
	 * List of references with multiplicity > 1
	 */
	private List<Reference> getAllManyReferences(DomainObject domainObject) {
		List<Reference> allReferences = domainObject.getReferences();
		List<Reference> allManyReferences = new ArrayList<Reference>();
		for (Reference ref : allReferences) {
			if (ref.isMany()) {
				allManyReferences.add(ref);
			}
		}
		return allManyReferences;
	}

	/**
	 * List of references with multiplicity = 1
	 */
	private List<Reference> getAllOneReferences(DomainObject domainObject) {
		List<Reference> allReferences = domainObject.getReferences();
		List<Reference> allOneReferences = new ArrayList<Reference>();
		for (Reference ref : allReferences) {
			if (!ref.isMany()) {
				allOneReferences.add(ref);
			}
		}
		return allOneReferences;
	}

	public String getDerivedCascade(Reference ref) {
		boolean inSameModule = ref.getFrom().getModule().equals(ref.getTo().getModule());
		boolean biDirectional = ref.getOpposite() != null;
		boolean aggregate = helperBase.isEntityOrPersistentValueObject(ref.getTo()) && !ref.getTo().isAggregateRoot();
		boolean oneToMany = biDirectional && ref.isMany() && !ref.getOpposite().isMany();
		boolean manyToMany = biDirectional && ref.isMany() && ref.getOpposite().isMany();
		boolean oneToOne = biDirectional && !ref.isMany() && !ref.getOpposite().isMany();

		if (aggregate) {
			if (oneToMany) {
				return propBase.getDefaultCascade("aggregate.oneToMany");
			} else {
				return propBase.getDefaultCascade("aggregate");
			}
		}

		if (!inSameModule) {
			return null;
		}

		if (manyToMany) {
			return isInverse(ref) ? null : propBase.getDefaultCascade("manyToMany");
		}

		if (oneToMany) {
			return propBase.getDefaultCascade("oneToMany");
		}

		if (oneToOne) {
			return propBase.getDefaultCascade("oneToOne");
		}

		if (!biDirectional && ref.isMany()) {
			return propBase.getDefaultCascade("toMany");
		}

		if (!biDirectional && !ref.isMany()) {
			return propBase.getDefaultCascade("toOne");
		}

		return null;
	}

}
