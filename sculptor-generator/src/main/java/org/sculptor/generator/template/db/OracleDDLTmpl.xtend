/*
 * Copyright 2007 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.db

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class OracleDDLTmpl {

def static String ddl(Application it) {
	'''
	«val manyToManyRelations = it.resolveManyToManyRelations(true)»
	'''
	fileOutput("dbschema/" + name + "_ddl.sql", 'TO_GEN_RESOURCES', '''
	«IF isDdlDropToBeGenerated()»    
	-- ###########################################
	-- # Drop
	-- ###########################################
	-- Drop index
		«it.getDomainObjectsInCreateOrder(false).forEach[dropIndex(it)]»

	-- Drop many to many relations
		«it.resolveManyToManyRelations(false).forEach[dropTable(it)]»
	-- Drop normal entities
		«it.getDomainObjectsInCreateOrder(false).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).forEach[dropTable(it)]»

	-- Drop pk sequence
		«dropSequence(it)»
	«ENDIF»
	-- ###########################################
	-- # Create
	-- ###########################################
	-- Create pk sequence
		«createSequence(it)»

	-- Create normal entities
		«it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).forEach[createTable(it)]»

	-- Create many to many relations
		«it.manyToManyRelations.forEach[createTable(it)]»

	-- Primary keys
		«it.getDomainObjectsInCreateOrder(true).filter(d | d.attributes.exists(a|a.name == "id")).forEach[idPrimaryKey(it)]»
		«it.manyToManyRelations.forEach[manyToManyPrimaryKey(it)]»

	-- Unique constraints
		«it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))) .forEach[uniqueConstraint(it)]»

	-- Foreign key constraints
		«it.getDomainObjectsInCreateOrder(true).filter(d | d.^extends != null && !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).forEach[(it)^extendsForeignKeyConstraint]»

		«it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).forEach[foreignKeyConstraint(it)]»
		«it.manyToManyRelations.forEach[foreignKeyConstraint(it)]»

	-- Index
		«it.getDomainObjectsInCreateOrder(true).forEach[index(it)]»

	'''
	)
	'''
	'''
}

def static String dropSequence(Application it) {
	'''
	drop sequence hibernate_sequence;
	'''
}

def static String createSequence(Application it) {
	'''
	create sequence hibernate_sequence;
	'''
}

def static String dropTable(DomainObject it) {
	'''
	DROP TABLE «getDatabaseName()» CASCADE«IF dbProduct() == "oracle"» CONSTRAINTS PURGE«ENDIF»;
	'''
}


def static String createTable(DomainObject it) {
	'''
	«val alreadyUsedColumns = it.{}.toSet()»
	CREATE TABLE «getDatabaseName()» (
	«columns(it)(false, alreadyUsedColumns)»
	«IF isInheritanceTypeSingleTable()»«inheritanceSingleTable(it)(alreadyUsedColumns)»«ENDIF»
	«IF ^extends != null»«(it)^extendsForeignKeyColumn(!alreadyUsedColumns.isEmpty)»«ENDIF»
	)«afterCreateTable(it)»;
	'''
}

def static String afterCreateTable(DomainObject it) {
	'''
	«IF hasHint("tablespace")»
	TABLESPACE «getHint("tablespace").toUpperCase()»«ENDIF»
	'''
}

def static String columns(DomainObject it, boolean initialComma, Set[String] alreadyDone) {
	'''
	«val currentAttributes - = it.attributes.reject(e | e.transient || alreadyDone.contains(e.getDatabaseName()) || e.isSystemAttributeToPutLast() ) »
	«FOR e : currentAttributes»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»
	«val currentBasicTypeReferences - = it.getBasicTypeReferences().reject(e | e.transient || alreadyDone.contains(e.getDatabaseName())) »
	«FOR e : currentBasicTypeReferences»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»
	«val currentEnumReferences - = it.getEnumReferences().reject(e | e.transient || alreadyDone.contains(e.getDatabaseName())) »
	«FOR e : currentEnumReferences»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»
	«val currentUniManyToThisReferences - = it.module == null ? {} : module.application.modules.domainObjects.references.filter(e | !e.transient && e.to == this && e.many && e.opposite == null && e.isInverse()).reject(e|alreadyDone.contains(e.getDatabaseName())) »
	«FOR e : currentUniManyToThisReferences»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»
	«val currentOneReferences - = it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).reject(e | (e.isOneToOne() && e.isInverse()) || alreadyDone.contains(e.getDatabaseName()))»
	«FOR e : currentOneReferences»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»
	«val currentSystemAttributesToPutLast - = it.attributes.reject(e | e.transient || alreadyDone.contains(e.getDatabaseName()) || ! e.isSystemAttributeToPutLast() ) »
	«FOR e : currentSystemAttributesToPutLast»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»
	«IF initialComma && !currentAttributes.isEmpty»,
	«ENDIF»
	«it.currentAttributes SEPARATOR ",\n".forEach[column(it)("")]»
	«IF (initialComma || !currentAttributes.isEmpty) && !currentOneReferences.isEmpty»,
	«ENDIF»
	«it.currentOneReferences SEPARATOR ",\n".forEach[foreignKeyColumn(it)]»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty) && !currentUniManyToThisReferences.isEmpty»,
	«ENDIF»
	«it.currentUniManyToThisReferences SEPARATOR ",\n".forEach[uniManyForeignKeyColumn(it)]»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty) && !currentBasicTypeReferences.isEmpty »,
	«ENDIF»
	«it.currentBasicTypeReferences SEPARATOR ",\n".forEach[containedColumns(it)("", false)]»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty || !currentBasicTypeReferences.isEmpty) && !currentEnumReferences.isEmpty »,
	«ENDIF»
	«it.currentEnumReferences SEPARATOR ",\n".forEach[enumColumn(it)("", false)]»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty || !currentBasicTypeReferences.isEmpty || !currentEnumReferences.isEmpty) && !currentSystemAttributesToPutLast.isEmpty »,
	«ENDIF»
	«it.currentSystemAttributesToPutLast SEPARATOR ",\n".forEach[column(it)("")]»
	'''
}

def static String column(Attribute it, String prefix) {
	'''
	«column(it)(prefix, false) »
	'''
}

def static String column(Attribute it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, this)» «getDatabaseType()»«parentIsNullable ? "" : getDatabaseTypeNullability()»
	'''
}

def static String enumColumn(Reference it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, this)» «getEnumDatabaseType()»«parentIsNullable ? "" : getDatabaseTypeNullability()»
	'''
}

def static String containedColumns(Reference it, String prefix, boolean parentIsNullable) {
	'''
	«val containedAttributes  = it.to.attributes.reject(e | e.transient)»
	«val containedEnumReferences  = it.to.references.filter(r | !r.transient && r.to.metaType == Enum)»
	«val containedBasicTypeReferences  = it.to.references.filter(r | !r.transient && r.to.metaType == BasicType)»
		«it.containedAttributes SEPARATOR ", "-.forEach[column(it)(getDatabaseName(prefix, this), parentIsNullable || nullable)]»«IF !containedEnumReferences.isEmpty»«IF !containedAttributes.isEmpty»,
		«ENDIF»«ENDIF»«it.containedEnumReferences SEPARATOR ", "-.forEach[enumColumn(it)(getDatabaseName(prefix, this), parentIsNullable || nullable)]»«IF !containedBasicTypeReferences.isEmpty»«IF !containedAttributes.isEmpty || !containedEnumReferences.isEmpty»,
		«ENDIF»«ENDIF»«it.containedBasicTypeReferences SEPARATOR ", "-.forEach[containedColumns(it)(getDatabaseName(), parentIsNullable || nullable)]»
	'''
}

def static String inheritanceSingleTable(DomainObject it, Set[String] alreadyUsedColumns) {
	'''
	,
	«discriminatorColumn(it) »
	«it.getAllSubclasses() .forEach[columns(it)(true, alreadyUsedColumns)]»
	'''
}

def static String discriminatorColumn(DomainObject it) {
	'''
		«inheritance.discriminatorColumnName()» «inheritance.getDiscriminatorColumnDatabaseType()» NOT NULL	'''
}

def static String idPrimaryKey(DomainObject it) {
	'''
	ALTER TABLE «getDatabaseName()» ADD CONSTRAINT PK_«getDatabaseName()»
	PRIMARY KEY («attributes.filter(a | a.name == "id").first().getDatabaseName()»)
	«afterIdPrimaryKey(it)»;
	'''
}

def static String afterIdPrimaryKey(DomainObject it) {
	'''
	«usingIndexTablespace(it)»
	'''
}

def static String manyToManyPrimaryKey(DomainObject it) {
	'''
	ALTER TABLE «getDatabaseName()» ADD CONSTRAINT PK_«getDatabaseName()»
	PRIMARY KEY («FOR r SEPARATOR ", " : references»«r.getForeignKeyName()»«ENDFOR»)
	«afterManyToManyPrimaryKey(it)»;
	'''
}

def static String afterManyToManyPrimaryKey(DomainObject it) {
	'''
	«usingIndexTablespace(it)»
	'''
}

def static String usingIndexTablespace(DomainObject it) {
	'''
	«IF hasHint("tablespace")»	USING INDEX TABLESPACE «getHint("tablespace").toUpperCase()»«ENDIF»
	'''
}

def static String foreignKeyColumn(Reference it) {
	'''
		«IF hasOpposite() && "list" == opposite.getCollectionType()»
		«opposite.getListIndexColumnName()» «getListIndexDatabaseType()»,
		«ENDIF»
		«getForeignKeyName()» «getForeignKeyType() »
	'''
}

def static String uniManyForeignKeyColumn(Reference it) {
	'''
		«IF "list" == getCollectionType()»
		«getListIndexColumnName()» «getListIndexDatabaseType()»,
		«ENDIF»
		«getOppositeForeignKeyName()» «from.getForeignKeyType() »
	'''
}

	«DEFINE ^extendsForeignKeyColumn(boolean initialComma) FOR DomainObject»
	«IF initialComma»,
	«ENDIF»
		«^extends.getExtendsForeignKeyName()» «^extends.getForeignKeyType() » NOT NULL
	'''
}

def static String foreignKeyConstraint(DomainObject it) {
	'''
		«it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).reject(e|e.isOneToOne() && e.isInverse()).forEach[foreignKeyConstraint(it)]»
		«it.references.filter(r | !r.transient && r.many && r.opposite == null && r.isInverse() && (r.to.hasOwnDatabaseRepresentation())).forEach[uniManyForeignKeyConstraint(it)]»
	'''
}

def static String foreignKeyConstraint(Reference it) {
	'''
	ALTER TABLE «from.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName())»
	FOREIGN KEY («getForeignKeyName()») REFERENCES «to.getRootExtends().getDatabaseName()» («to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»
	;
	«foreignKeyIndex(it)»
	'''
}

def static String foreignKeyIndex(Reference it) {
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(from.getDatabaseName(), getForeignKeyName())» ON «from.getDatabaseName()» («getForeignKeyName()»);
	'''
}

def static String uniManyForeignKeyConstraint(Reference it) {
	'''
	ALTER TABLE «to.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(to.getDatabaseName(), from.getDatabaseName())»
	FOREIGN KEY («getOppositeForeignKeyName()») REFERENCES «from.getRootExtends().getDatabaseName()» («from.getRootExtends().getIdAttribute().getDatabaseName()»)
	;
	«uniManyForeignKeyIndex(it)»
	'''
}

def static String uniManyForeignKeyIndex(Reference it) {
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(to.getDatabaseName(), getOppositeForeignKeyName())» ON «to.getDatabaseName()» («getOppositeForeignKeyName()»);
	'''
}

	«DEFINE ^extendsForeignKeyConstraint FOR DomainObject»
	ALTER TABLE «getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(getDatabaseName(), ^extends.getDatabaseName())»
	FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()» («^extends.getRootExtends().getIdAttribute().getDatabaseName()»)
	;
	«(it)^extendsForeignKeyIndex»
	'''
}

	«DEFINE ^extendsForeignKeyIndex FOR DomainObject»
	CREATE INDEX IX_«truncateLongDatabaseName(getDatabaseName(), ^extends.getExtendsForeignKeyName())» ON «getDatabaseName()» («^extends.getExtendsForeignKeyName()»);
	'''
}

def static String uniqueConstraint(DomainObject it) {
	'''
	«IF hasUniqueConstraints()»
	ALTER TABLE «getDatabaseName()»
	«IF attributes.exists(a | a.isUuid()) »
		ADD CONSTRAINT UQ_«getDatabaseName()» UNIQUE (UUID)
		«ELSE»ADD CONSTRAINT UQ_«getDatabaseName()» UNIQUE («FOR key SEPARATOR ", "  : getAllNaturalKeys()»«
	  		IF key.isBasicTypeReference()»«FOR a SEPARATOR ", " : ((Reference) key).to.getAllNaturalKeys()»«getDatabaseName(key.getDatabaseName(), a)»«ENDFOR»«
	  		ELSE»«key.getDatabaseName()»« ENDIF»«
	  		ENDFOREACH»)
	«ENDIF»
	«afterUniqueConstraint(it)»;
	«ENDIF»
	'''
}

def static String afterUniqueConstraint(DomainObject it) {
	'''
	«usingIndexTablespace(it)»
	'''
}

def static String index(DomainObject it) {
	'''
	«it.attributes.filter(a | a.index == true).forEach[index(it)("", this)]»
	«it.getBasicTypeReferences().forEach[containedColumnIndex(it)]»
	«IF isInheritanceTypeSingleTable()»
	«discriminatorIndex(it)»
	«ENDIF»
	'''
}

def static String containedColumnIndex(Reference it) {
	'''
		«it.to.attributes.filter(a | a.index == true).forEach[index(it)(getDatabaseName() + "_", from)]»
	'''
}

def static String index(Attribute it, String prefix, DomainObject domainObject) {
	'''
	«LET (domainObject.^extends != null && isInheritanceTypeSingleTable(domainObject.getRootExtends())) ?  domainObject.getRootExtends() :
	domainObject
	AS actualDomainObject »
	CREATE INDEX IX_«truncateLongDatabaseName(actualDomainObject.getDatabaseName(), getDatabaseName(prefix, this))»
		ON «actualDomainObject.getDatabaseName()» («getDatabaseName(prefix, this)» ASC)
	«afterIndex(it)(prefix, domainObject)»;
	'''
}

def static String afterIndex(Attribute it, String prefix, DomainObject domainObject) {
	'''
	«IF domainObject.hasHint("tablespace")»    TABLESPACE «domainObject.getHint("tablespace").toUpperCase()»«ENDIF»
	'''
}

def static String discriminatorIndex(DomainObject it) {
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(getDatabaseName(), inheritance.discriminatorColumnName())»
		ON «getDatabaseName()» («inheritance.discriminatorColumnName()» ASC)
	;
	'''
}

def static String dropIndex(DomainObject it) {
	'''
	«it.attributes.filter(a | a.index == true).forEach[dropIndex(it)("", this)]»
	«it.getBasicTypeReferences().forEach[dropContainedColumnIndex(it)]»
	«IF isInheritanceTypeSingleTable()»
	«dropDiscriminatorIndex(it)»
	«ENDIF»
	'''
}

def static String dropContainedColumnIndex(Reference it) {
	'''
		«it.to.attributes.filter(a | a.index == true).forEach[dropIndex(it)(getDatabaseName() + "_", from)]»
	'''
}

def static String dropIndex(Attribute it, String prefix, DomainObject domainObject) {
	'''
	«LET (domainObject.^extends != null && isInheritanceTypeSingleTable(domainObject.getRootExtends())) ?  domainObject.getRootExtends() :
	domainObject
	AS actualDomainObject »
	DROP INDEX IX_«truncateLongDatabaseName(actualDomainObject.getDatabaseName(), getDatabaseName(prefix, this))»;
	'''
}

def static String dropDiscriminatorIndex(DomainObject it) {
	'''
	DROP INDEX IX_«truncateLongDatabaseName(getDatabaseName(), inheritance.discriminatorColumnName())»;
	'''
}

}
