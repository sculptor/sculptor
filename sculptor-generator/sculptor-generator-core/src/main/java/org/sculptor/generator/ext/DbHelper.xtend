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

import java.util.Collection
import java.util.List
import java.util.Set
import javax.inject.Inject
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.DiscriminatorType
import sculptormetamodel.DomainObject
import sculptormetamodel.Inheritance
import sculptormetamodel.InheritanceType
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference
import sculptormetamodel.SculptormetamodelFactory

public class DbHelper {
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties
	@Inject extension DbHelperBase dbHelperBase
	@Inject extension Helper helper

	def String getCascade(Reference ref) {
		if (ref.cascade == null || ref.cascade == "")
			ref.getDerivedCascade()
		else
			ref.cascade
	}

	def boolean isDbOnDeleteCascade(Reference ref) {
		isDbResponsibleForOnDeleteCascade() && (getCascade(ref) != null) && (getCascade(ref).contains("delete") || getCascade(ref).contains("all"))
	}

	def String getFetch(Reference ref) {
		if (ref.fetch == "none")
			null
		else if (ref.fetch == null || ref.fetch == "")
			ref.getDerivedFetch()
		else
			ref.fetch
	}

	def private String getDerivedFetch(Reference ref) {
		if (isManyToMany(ref))
			null // no default fetch for manyToMany
		else if (ref.to.isEntityOrPersistentValueObject() && !ref.to.aggregateRoot)
			"join"  // join fetch within same aggregate boundary
		else
			null
	}

	def String getHibernateCacheUsage(Object obj) {
		switch (cacheProvider()) {
			case "EhCache" : "nonstrict-read-write"
			case "TreeCache" : "nonstrict-read-write"
			case "JbossTreeCache" : "transactional"
			case "DeployedTreeCache" : "transactional"
			default : "read-only"
		}
	}

	def dispatch String getDatabaseName(DomainObject domainObject) {
		domainObject.databaseTable
	}

	def dispatch String getDatabaseName(BasicType basicType) {
		basicType.name.toUpperCase()
	}

	def dispatch String getDatabaseName(Attribute attribute) {
		attribute.databaseColumn
	}

	def dispatch String getDatabaseName(Reference reference) {
		reference.databaseColumn
	}

	def dispatch String getDatabaseName(NamedElement element) {
		"UNKNOWN"
	}

	def String getDatabaseName(String dbColumnPrefix, NamedElement element) {
		var prefix=if (dbColumnPrefix != "" && !dbColumnPrefix.endsWith("_")) (dbColumnPrefix + "_") else dbColumnPrefix

		return (prefix + element.getDatabaseName()).removeTrailingUnderscore()
	}

	def private String removeTrailingUnderscore(String s) {
		if (s.endsWith("_"))
			s.substring(0, s.length - 1)
		else
			s
	}

	def String getDefaultDatabaseName(NamedElement element) {
		if (mongoDb() && element.name == "id")
			"_id"
		else if (isJpaProviderAppEngine() || nosql())
			element.name
		else
			element.getDefaultDatabaseName2()
	}

	def private String getDefaultDatabaseName2(NamedElement element) {
		dbHelperBase.getDatabaseNameBase(element)
	}

	def String truncateLongDatabaseName(String part1, String part2) {
		truncateLongDatabaseName(part1 + "_" + part2)
	}

	def String getListIndexDatabaseType() {
		createListIndexAttribute().getDatabaseType()
	}

	def private Attribute createListIndexAttribute() {
		val attr = SculptormetamodelFactory::eINSTANCE.createAttribute
		attr.setName("index")
		attr.setType("Integer")
		attr
	}

	def String getHibernateType(Attribute attribute) {
		mapHibernateType(attribute.type)
	}

	def String getForeignKeyName(Reference ref) {
		ref.databaseColumn
	}

	def String getDefaultForeignKeyName(Reference ref) {
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
				getDefaultForeignKeyNameBase(ref)
	}

	def String getOppositeForeignKeyName(Reference ref) {
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
	def dispatch Set<? extends String> getJoinTableNames(Collection<DomainObject> domainObjects) {
		domainObjects.map[d | getJoinTableNames(d)].flatten().toSet()
	}

	// get join tables for this domain object
	def dispatch Set<String> getJoinTableNames(DomainObject domainObject) {
		domainObject.references.filter[r | !r.transient && isManyToMany(r)
				&& r.to.hasOwnDatabaseRepresentation()].map[r | getManyToManyJoinTableName(r)].toSet

	}

	def String getEnumDatabaseLength(Reference ref) {
		val length = getEnumDatabaseLength(ref.getEnum())
		getHintOrDefault(ref, "databaseLength", length)
	}

	def boolean isOfTypeString(sculptormetamodel.Enum ^enum) {
		"String" == enum.getEnumType()
	}

	def String getCascadeType(Reference ref) {
		val values = if (getCascade(ref) == null)
			null
		else
			getCascade(ref).split(',').map[e | mapCascadeType(e)].filterNull.toList
		toAnnotationFormat(values)
	}

	def private String toAnnotationFormat(List<String> values) {
		if (values == null || values.isEmpty)
			null
		else if (values.size == 1)
			values.get(0)
		else
			"{" + values.toCommaSeparatedString() + "}"
	}

	def String mapCascadeType(String cascade) {
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

	def boolean isOrphanRemoval(String cascade) {
		isJpa2() && cascade != null && cascade.contains("all-delete-orphan")
	}

	def boolean isOrphanRemoval(String cascade, Reference ref) {
		isJpa2() && (isOrphanRemoval(cascade) || !isAggregateRoot(ref.to))
	}

	def String getHibernateCascadeType(Reference ref) {
		val values = if (getCascade(ref) == null)
			null
		else
			getCascade(ref).split(',').map[e | mapHibernateCascadeType(e)].filterNull.toList
		toAnnotationFormat(values)
	}

	def String mapHibernateCascadeType(String cascade) {
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

	def String getHibernateCacheStrategy(Object obj) {
		switch (cacheProvider()) {
			case "EhCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.NONSTRICT_READ_WRITE"
			case "TreeCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.NONSTRICT_READ_WRITE"
			case "JbossTreeCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.TRANSACTIONAL"
			case "DeployedTreeCache" : "org.hibernate.annotations.CacheConcurrencyStrategy.TRANSACTIONAL"
			default : "org.hibernate.annotations.CacheConcurrencyStrategy.READ_ONLY"
		}
	}

	def dispatch String getFetchType(Reference ref) {
		switch (getFetch(ref)) {
			// case "select" : "javax.persistence.FetchType.LAZY"
			case "join" : "javax.persistence.FetchType.EAGER"
			case "eager" : "javax.persistence.FetchType.EAGER"
			case "lazy" : "javax.persistence.FetchType.LAZY"
			default : null // use default in jpa
		}
	}

	def dispatch String getFetchType(Attribute att) {
		if (att.hasHint("fetch")) getFetchType(att.getHint("fetch")) else null
	}

	def dispatch String getFetchType(String fetch) {
		switch (fetch) {
			// case "select" : "javax.persistence.FetchType.LAZY"
			case "join" : "javax.persistence.FetchType.EAGER"
			case "eager" : "javax.persistence.FetchType.EAGER"
			case "lazy" : "javax.persistence.FetchType.LAZY"
			default : null // use default in jpa
		}
	}

	def String getHibernateFetchType(Reference ref) {
		switch (getFetch(ref)) {
			// case "join" : "org.hibernate.annotations.FetchMode.JOIN"
			// case "select" : "org.hibernate.annotations.FetchMode.SELECT"
			case "subselect" : "org.hibernate.annotations.FetchMode.SUBSELECT"
			default : null
		}
	}

	def boolean isInheritanceTypeSingleTable(DomainObject domainObject) {
		(domainObject != null && domainObject.inheritance != null && domainObject.inheritance.type == InheritanceType::SINGLE_TABLE)
	}

	def boolean isInheritanceTypeJoined(DomainObject domainObject) {
		(domainObject != null && domainObject.inheritance != null && domainObject.inheritance.type == InheritanceType::JOINED)
	}

	def String getDiscriminatorType(DomainObject domainObject) {
		if (domainObject.inheritance.discriminatorType == null)
			null
		else
			"javax.persistence.DiscriminatorType." + domainObject.inheritance.discriminatorType
	}

	def String getHbmDiscriminatorType(DomainObject domainObject) {
		switch (domainObject.inheritance.discriminatorType) {
			case DiscriminatorType::INTEGER :
				"int"
			case DiscriminatorType::CHAR :
				"char"
			default :
				null
		}
	}

	def boolean isJodaDateTimeLibrary() {
		getDateTimeLibrary() == "joda"
	}

	def boolean isJodaTemporal(Attribute attribute) {
		isTemporal(attribute) && isJodaDateTimeLibrary()
	}

	def boolean hasOpposite(Reference ref) {
		ref.opposite != null
	}

	def boolean isUnidirectionalToManyWithoutJoinTable(Reference ref) {
		ref.many && ref.isInverse() && !ref.hasOpposite
	}

	def boolean isAggregateRoot(DomainObject domainObject) {
		domainObject.aggregateRoot
	}

	def private boolean hasBasicTypeNaturalKey(DomainObject domainObject) {
		domainObject.getAllNaturalKeyReferences().filter[e | e.to instanceof BasicType].toList.size == 1
	}

	def boolean hasClassLevelUniqueConstraints(DomainObject domainObject) {
		(domainObject.hasCompositeNaturalKey() || domainObject.hasBasicTypeNaturalKey())
			&& (domainObject == domainObject.getRootExtends()) && domainObject.getSubclasses().isEmpty
	}

	def boolean hasUniqueConstraints(DomainObject domainObject) {
		domainObject.attributes.exists[a | a.isUuid()]
			|| (domainObject.hasNaturalKey()
				&& domainObject.getNaturalKeyAttributes() == domainObject.getAllNaturalKeyAttributes()
				&& domainObject.getNaturalKeyReferences() == domainObject.getAllNaturalKeyReferences()
			)
	}

	def String discriminatorColumnName(Inheritance inheritance) {
		if (inheritance.discriminatorColumnName != null)
			inheritance.discriminatorColumnName
		else
			getProperty("db.discriminatorColumnName")
	}

	def String discriminatorColumnLength(Inheritance inheritance) {
		val propertyName = getDbProduct + ".length.discriminatorType." + inheritance.discriminatorType
		if (inheritance.discriminatorColumnLength != null)
			inheritance.discriminatorColumnLength
		else if (hasProperty(propertyName))
			getProperty(propertyName)
		else
			null
	}

	def String getEclipseLinkTargetDatabase(String persistenceUnitName) {
		getEclipseLinkTargetDatabase()
	}

	def String getEclipseLinkTargetDatabase() {
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

	def String getListIndexColumnName(Reference ref) {
		val defaultName = ref.getDefaultDatabaseName() + "_INDEX"
		ifNullOrEmpty(ref.getHint("orderColumn"), defaultName)
	}

	def boolean isAssociationOverrideNeeded(Reference ref) {
		ref.to.references.exists[e | !e.isBasicTypeReference() && !e.isEnumReference()]
	}

	// Return true if this is an attribute to put last in the DDL
	def boolean isSystemAttributeToPutLast(Attribute attr) {
		getSystemAttributesToPutLast().contains(attr.name)
	}
}
