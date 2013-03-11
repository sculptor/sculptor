/*
 * Copyright 2007 The Fornax Project Team, including the original
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
package org.sculptor.generator.ext

import java.util.Set
import java.util.Collection
import java.util.List
import sculptormetamodel.SculptormetamodelFactory
import sculptormetamodel.DomainObject
import sculptormetamodel.BasicType
import sculptormetamodel.Attribute
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.InheritanceType
import sculptormetamodel.DiscriminatorType
import sculptormetamodel.Inheritance

import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import org.sculptor.generator.util.DbHelperBase

public class DbHelper {
	def static String getCascade(Reference ref) {
		if (ref.cascade == null || ref.cascade == "")
			ref.getDerivedCascade()
		else
			ref.cascade
	}

	def static boolean isDbOnDeleteCascade(Reference ref) {
		isDbResponsibleForOnDeleteCascade() && (ref.getCascade() != null) && (ref.getCascade().contains("delete") || ref.getCascade().contains("all"))
	}

	def static String getFetch(Reference ref) {
		if (ref.fetch == "none")
			null
		else if (ref.fetch == null || ref.fetch == "")
			ref.getDerivedFetch()
		else
			ref.fetch
	}

	def private static String getDerivedFetch(Reference ref) {
		if (isManyToMany(ref))
			null // no default fetch for manyToMany
		else  if (ref.to.isEntityOrPersistentValueObject() && !ref.to.aggregateRoot)
			"join"  // join fetch within same aggregate boundary
		else
			null
	}

	def static String getHibernateCacheUsage(Object obj) {
		switch (cacheProvider()) {
			case "EhCache" : "nonstrict-read-write"
			case "TreeCache" : "nonstrict-read-write"
			case "JbossTreeCache" : "transactional"
			case "DeployedTreeCache" : "transactional"
			default : "read-only"
		}
	}

	def static String getDatabaseName(DomainObject domainObject) {
		domainObject.databaseTable
	}

	def static String getDatabaseName(BasicType basicType) {
		basicType.name.toUpperCase()
	}

	def static String getDatabaseName(Attribute attribute) {
		attribute.databaseColumn
	}

	def static String getDatabaseName(Reference reference) {
		reference.databaseColumn
	}

	def static String getDatabaseName(NamedElement element) {
		"UNKNOWN"
	}

	def static String getDatabaseName(String dbColumnPrefix, NamedElement element) {
		var prefix=if (dbColumnPrefix != "" && !dbColumnPrefix.endsWith("_")) (dbColumnPrefix + "_") else dbColumnPrefix

		return (prefix + element.getDatabaseName()).removeTrailingUnderscore()
	}

	def private static String removeTrailingUnderscore(String s) {
		if (s.endsWith("_"))
			s.substring(0, s.length - 1)
		else
			s
	}

	def static String getDefaultDatabaseName(NamedElement element) {
		if (mongoDb() && element.name == "id")
			"_id"
		else if (isJpaProviderAppEngine() || nosql())
			element.name
		else
			element.getDefaultDatabaseName2()
	}

	def private static String getDefaultDatabaseName2(NamedElement element) {
		element.getDatabaseName()
	}

	def static String truncateLongDatabaseName(String part1, String part2) {
		truncateLongDatabaseName(part1 + "_" + part2)
	}

	def static String getListIndexDatabaseType() {
		createListIndexAttribute().getDatabaseType()
	}

	def private static Attribute createListIndexAttribute() {
		val attr = SculptormetamodelFactory::eINSTANCE.createAttribute
		attr.setName("index")
		attr.setType("Integer")
		attr
	}

	def static String getHibernateType(Attribute attribute) {
		mapHibernateType(attribute.type)
	}

	def static String getForeignKeyName(Reference ref) {
		ref.databaseColumn
	}

	def static String getDefaultForeignKeyName(Reference ref) {
		if (isJpaProviderAppEngine())
			ref.name
		else if (nosql())
			if (ref.isUnownedReference())
				ref.name + "Id" + (if (ref.many) "s" else "")
			else
				ref.name
		else
			if (ref.isUnidirectionalToManyWithoutJoinTable())
				ref.getDefaultOppositeForeignKeyName()
			else
				DbHelperBase::getDefaultForeignKeyName(ref)
	}

	def static String getOppositeForeignKeyName(Reference ref) {
		if (ref.opposite != null)
			ref.opposite.getForeignKeyName()
		else if (ref.isUnidirectionalToManyWithoutJoinTable())
			ref.databaseColumn
		else
			// unidirectional to-many with join table
			ref.getDefaultOppositeForeignKeyName()
	}

// getManyToManyJoinTableName() is used also for OnteToMany relationship with jointables
// TODO: JPA2 supports jointables for all types of relationships, if we like to support this to, maybe we need an more common solution to get the jointable name
// String getOneToManyJoinTableName(Reference ref) :
//	  JAVA org.fornax.cartridges.sculptor.generator.util.DatabaseGenerationHelper.getOneToManyJoinTableName(sculptormetamodel.Reference);

	// get unique list of join tables
	def static Set<? extends String> getJoinTableNames(Collection<DomainObject> domainObjects) {
		domainObjects.map[d | getJoinTableNames(d)].flatten().toSet()
	}

	// get join tables for this domain object
	def static Set<String> getJoinTableNames(DomainObject domainObject) {
		domainObject.references.filter[r | !r.transient && isManyToMany(r)
				&& r.to.hasOwnDatabaseRepresentation()].map[r | getManyToManyJoinTableName(r)].toSet

	}

	def static String getEnumDatabaseLength(Reference ref) {
		val length = getEnumDatabaseLength(ref.getEnum())
		getHintOrDefault(ref, "databaseLength", length)
	}

	def static boolean isOfTypeString(sculptormetamodel.Enum enum) {
		"String" == enum.getEnumType()
	}

	def static String getCascadeType(Reference ref) {
		val values = if (ref.getCascade() == null)
			null
		else
			ref.getCascade().split(',').map(e | mapCascadeType(e))
		toAnnotationFormat(values)
	}

	def private static String toAnnotationFormat(List<String> values) {
		if (values == null || values.isEmpty)
			null
		else if (values.size == 1)
			values.get(0)
		else
			"{" + values.toCommaSeparatedString() + "}"
	}

	def static String mapCascadeType(String cascade) {
		switch (cascade.trim()) {
			case "persist" : "javax.persistence.CascadeType.PERSIST"
			case "merge" : "javax.persistence.CascadeType.MERGE"
			case "remove" : "javax.persistence.CascadeType.REMOVE"
			case "refresh" : "javax.persistence.CascadeType.REFRESH"
			case "all" : "javax.persistence.CascadeType.ALL"
			case "all-delete-orphan" : "javax.persistence.CascadeType.ALL"
			default : null
		}
	}

	def static boolean isOrphanRemoval(String cascade) {
	isJpa2() && cascade != null && cascade.contains("all-delete-orphan")

	}

	def static boolean isOrphanRemoval(String cascade, Reference ref) {
		isJpa2() && (isOrphanRemoval(cascade) || !isAggregateRoot(ref.to))
	}

	def static String getHibernateCascadeType(Reference ref) {
		val values = if (ref.getCascade() == null)
			null
		else
			ref.getCascade().split(',').map[e | mapHibernateCascadeType(e)]
		toAnnotationFormat(values)
	}

	def static String mapHibernateCascadeType(String cascade) {
		switch (cascade.trim()) {
			case "all-delete-orphan" : (if (isJpa2()) null else "org.hibernate.annotations.CascadeType.DELETE_ORPHAN")
			case "delete-orphan" : (if (isJpa2()) null else "org.hibernate.annotations.CascadeType.DELETE_ORPHAN")
			case "delete" : "org.hibernate.annotations.CascadeType.DELETE"
			case "save-update" : "org.hibernate.annotations.CascadeType.SAVE_UPDATE"
			case "evict" : (if(isJpa2()) null else "org.hibernate.annotations.CascadeType.EVICT")
			case "replicate" : "org.hibernate.annotations.CascadeType.REPLICATE"
			case "lock" : "org.hibernate.annotations.CascadeType.LOCK"
			default : null
		}
	}

	def static String getHibernateCacheStrategy(Object obj) {
		switch (cacheProvider()) {
			case "EhCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.NONSTRICT_READ_WRITE"
			case "TreeCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.NONSTRICT_READ_WRITE"
			case "JbossTreeCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.TRANSACTIONAL"
			case "DeployedTreeCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.TRANSACTIONAL"
			default : "org.hibernate.annotations.CacheConcurrencyStrategy.READ_ONLY"
		}
	}

	def static String getFetchType(Reference ref) {
		switch (getFetch(ref)) {
			// case "select" : "javax.persistence.FetchType.LAZY"
			case "join" : "javax.persistence.FetchType.EAGER"
			case "eager" : "javax.persistence.FetchType.EAGER"
			case "lazy" : "javax.persistence.FetchType.LAZY"
			default : null // use default in jpa
		}
	}

	def static String getFetchType(Attribute att) {
		if (att.hasHint("fetch")) getFetchType(att.getHint("fetch")) else null
	}

	def static String getFetchType(String fetch) {
	switch (fetch) {
		// case "select" : "javax.persistence.FetchType.LAZY"
		case "join" : "javax.persistence.FetchType.EAGER"
		case "eager" : "javax.persistence.FetchType.EAGER"
		case "lazy" : "javax.persistence.FetchType.LAZY"
		default : null // use default in jpa
	}

	}

	def static String getHibernateFetchType(Reference ref) {
	switch (getFetch(ref)) {
		// case "join" : "org.hibernate.annotations.FetchMode.JOIN"
		// case "select" : "org.hibernate.annotations.FetchMode.SELECT"
		case "subselect" : "org.hibernate.annotations.FetchMode.SUBSELECT"
		default : null
	}

	}

	def static boolean isInheritanceTypeSingleTable(DomainObject domainObject) {
		(domainObject != null && domainObject.inheritance != null && domainObject.inheritance.type == InheritanceType::SINGLE_TABLE)
	}

	def static boolean isInheritanceTypeJoined(DomainObject domainObject) {
		(domainObject != null && domainObject.inheritance != null && domainObject.inheritance.type == InheritanceType::JOINED)
	}

	def static String getDiscriminatorType(DomainObject domainObject) {
		if (domainObject.inheritance.discriminatorType == null)
			null
		else
			"javax.persistence.DiscriminatorType." + domainObject.inheritance.discriminatorType
	}

	def static String getHbmDiscriminatorType(DomainObject domainObject) {
		switch (domainObject.inheritance.discriminatorType) {
			case DiscriminatorType::INTEGER :
				"int"
			case DiscriminatorType::CHAR :
				"char"
			default :
				null
		}
	}

	def static boolean isJodaDateTimeLibrary() {
		getDateTimeLibrary() == "joda"
	}

	def static boolean isJodaTemporal(Attribute attribute) {
		isTemporal(attribute) && isJodaDateTimeLibrary()
	}

	def static boolean hasOpposite(Reference ref) {
		ref.opposite != null
	}

	def static boolean isUnidirectionalToManyWithoutJoinTable(Reference ref) {
		ref.many && ref.isInverse() && !ref.hasOpposite
	}

	def static boolean isAggregateRoot(DomainObject domainObject) {
		domainObject.aggregateRoot
	}

	def private static boolean hasBasicTypeNaturalKey(DomainObject domainObject) {
		domainObject.getAllNaturalKeyReferences().filter[e | e.to instanceof BasicType].toList.size == 1
	}

	def static boolean hasClassLevelUniqueConstraints(DomainObject domainObject) {
		(domainObject.hasCompositeNaturalKey() || domainObject.hasBasicTypeNaturalKey())
			&& (domainObject == domainObject.getRootExtends()) && domainObject.getSubclasses().isEmpty
	}

	def static boolean hasUniqueConstraints(DomainObject domainObject) {
		domainObject.attributes.exists[a | a.isUuid()]
			|| (domainObject.hasNaturalKey()
				&& domainObject.getNaturalKeyAttributes() == domainObject.getAllNaturalKeyAttributes()
				&& domainObject.getNaturalKeyReferences() == domainObject.getAllNaturalKeyReferences()
			)
	}

	def static String discriminatorColumnName(Inheritance inheritance) {
		if (inheritance.discriminatorColumnName != null)
			inheritance.discriminatorColumnName
		else
			getProperty("db.discriminatorColumnName")
	}

	def static String discriminatorColumnLength(Inheritance inheritance) {
		val propertyName = getDbProduct + ".length.discriminatorType." + inheritance.discriminatorType
		if (inheritance.discriminatorColumnLength != null)
			inheritance.discriminatorColumnLength
		else if (hasProperty(propertyName))
			getProperty(propertyName)
		else
			null
	}

	def static String getEclipseLinkTargetDatabase(String persistenceUnitName) {
		getEclipseLinkTargetDatabase()
	}

	def static String getEclipseLinkTargetDatabase() {
		switch (getDbProduct) {
			case "oracle" :
				"Oracle"
			case "postgresql" :
				"PostgreSQL"
			case "mysql" :
				"MySQL"
			case "hsqldb-inmemory" :
				"HSQL"
			default :
				null
		}
	}

	def static String getListIndexColumnName(Reference ref) {
		val defaultName = ref.getDefaultDatabaseName() + "_INDEX"
		ifNullOrEmpty(ref.getHint("orderColumn"), defaultName)
	}

	def static boolean isAssociationOverrideNeeded(Reference ref) {
		ref.to.references.exists[e | !e.isBasicTypeReference() && !e.isEnumReference()]
	}

	// Return true if this is an attribute to put last in the DDL
	def static boolean isSystemAttributeToPutLast(Attribute attr) {
		getSystemAttributesToPutLast().contains(attr.name)
	}
}
