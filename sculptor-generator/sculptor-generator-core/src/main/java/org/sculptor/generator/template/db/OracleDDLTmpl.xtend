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

import java.util.Set
import javax.inject.Inject
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.DomainObject
import sculptormetamodel.Enum
import sculptormetamodel.Reference
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class OracleDDLTmpl {

	@Inject extension DbHelperBase dbHelperBase
	@Inject extension DbHelper dbHelper
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

def String ddl(Application it) {
	val manyToManyRelations = it.resolveManyToManyRelations(true)
	fileOutput("dbschema/" + name + "_ddl.sql", OutputSlot::TO_GEN_RESOURCES, '''
	«IF isDdlDropToBeGenerated()»    
	-- ###########################################
	-- # Drop
	-- ###########################################
	-- Drop index
		«it.getDomainObjectsInCreateOrder(false).map[dropIndex(it)].join()»

	-- Drop many to many relations
		«it.resolveManyToManyRelations(false).map[dropTable(it)].join()»
	-- Drop normal entities
		«it.getDomainObjectsInCreateOrder(false).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).map[dropTable(it)].join()»

	-- Drop pk sequence
		«dropSequence(it)»
	«ENDIF»
	-- ###########################################
	-- # Create
	-- ###########################################
	-- Create pk sequence
		«createSequence(it)»

	-- Create normal entities
		«it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).map[createTable(it)].join()»

	-- Create many to many relations
		«manyToManyRelations.map[createTable(it)]»

	-- Primary keys
		«it.getDomainObjectsInCreateOrder(true).filter(d | d.attributes.exists(a|a.name == "id")).map[idPrimaryKey(it)].join()»
		«manyToManyRelations.map[manyToManyPrimaryKey(it)]»

	-- Unique constraints
		«it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))) .map[uniqueConstraint(it)].join()»

	-- Foreign key constraints
		«it.getDomainObjectsInCreateOrder(true).filter(d | d.^extends != null && !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).map[extendsForeignKeyConstraint(it)].join()»

		«it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).map[foreignKeyConstraint(it)].join()»
		«manyToManyRelations.map[foreignKeyConstraint(it)].join()»

	-- Index
		«it.getDomainObjectsInCreateOrder(true).map[index(it)].join()»

	'''
	)
}

def String dropSequence(Application it) {
	'''
	drop sequence hibernate_sequence;
	'''
}

def String createSequence(Application it) {
	'''
	create sequence hibernate_sequence;
	'''
}

def String dropTable(DomainObject it) {
	'''
	DROP TABLE «getDatabaseName(it)» CASCADE«IF dbProduct == "oracle"» CONSTRAINTS PURGE«ENDIF»;
	'''
}


def String createTable(DomainObject it) {
	'''
	«val alreadyUsedColumns = <String>newHashSet()»
	CREATE TABLE «getDatabaseName(it)» (
	«columns(it, false, alreadyUsedColumns)»
	«IF isInheritanceTypeSingleTable(it)»«inheritanceSingleTable(it, alreadyUsedColumns)»«ENDIF»
	«IF ^extends != null»«extendsForeignKeyColumn(it, !alreadyUsedColumns.isEmpty)»«ENDIF»
	)«afterCreateTable(it)»;
	'''
}

def String afterCreateTable(DomainObject it) {
	'''
	«IF hasHint(it, "tablespace")»
	TABLESPACE «getHint(it, "tablespace").toUpperCase()»«ENDIF»
	'''
}

def String columns(DomainObject it, boolean initialComma, Set<String> alreadyDone) {
	val currentAttributes = it.attributes.filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName()) || e.isSystemAttributeToPutLast())]
	alreadyDone.addAll(currentAttributes.map[e | e.getDatabaseName()])

	val currentBasicTypeReferences = it.getBasicTypeReferences().filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName()))]
	alreadyDone.addAll(currentBasicTypeReferences.map[e | e.getDatabaseName()])

	val currentEnumReferences = it.getEnumReferences().filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName()))]
	alreadyDone.addAll(currentEnumReferences.map[e | e.getDatabaseName()])

	val currentUniManyToThisReferences = if (it.module == null) <Reference>newHashSet else it.module.application.modules.map[domainObjects].flatten.map[references].flatten.filter[e | !e.transient && e.to == it && e.many && e.opposite == null && e.isInverse()].filter[e | !(alreadyDone.contains(e.getDatabaseName()))].toSet
	alreadyDone.addAll(currentUniManyToThisReferences.map[e | e.getDatabaseName()])

	val currentOneReferences = it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).filter[e | !((e.isOneToOne() && e.isInverse()) || alreadyDone.contains(e.getDatabaseName()))].toSet
	alreadyDone.addAll(currentOneReferences.map[e | e.getDatabaseName()])

	val currentSystemAttributesToPutLast = it.attributes.filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName()) || ! e.isSystemAttributeToPutLast() )]
	alreadyDone.addAll(currentSystemAttributesToPutLast.map[e | e.getDatabaseName()])

	'''
	«IF initialComma && !currentAttributes.isEmpty»,
	«ENDIF»
	«FOR a : currentAttributes SEPARATOR ",\n"»«column(a, "")»
		«IF (initialComma || !currentAttributes.isEmpty) && !currentOneReferences.isEmpty»,
		«ENDIF»
	«ENDFOR»
	«FOR r : currentOneReferences SEPARATOR ",\n"»«foreignKeyColumn(r)»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty) && !currentUniManyToThisReferences.isEmpty»,
	«ENDIF»
	«ENDFOR»
	«FOR r : currentUniManyToThisReferences SEPARATOR ",\n"»«uniManyForeignKeyColumn(r)»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty) && !currentBasicTypeReferences.isEmpty »,
	«ENDIF»
	«ENDFOR»
	«FOR r : currentBasicTypeReferences SEPARATOR ",\n"»«containedColumns(r, "", false)»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty || !currentBasicTypeReferences.isEmpty) && !currentEnumReferences.isEmpty »,
	«ENDIF»
	«ENDFOR»
	«FOR r : currentEnumReferences SEPARATOR ",\n"»«enumColumn(r, "", false)»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty || !currentBasicTypeReferences.isEmpty || !currentEnumReferences.isEmpty) && !currentSystemAttributesToPutLast.isEmpty »,
	«ENDIF»
	«ENDFOR»
	«FOR a : currentSystemAttributesToPutLast SEPARATOR ",\n"»«column(a, "")»
	«ENDFOR»
	'''
}

def String column(Attribute it, String prefix) {
	'''
	«column(it, prefix, false) »
	'''
}

def String column(Attribute it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, it)» «getDatabaseType()»«if (parentIsNullable) "" else getDatabaseTypeNullability(it)»
	'''
}

def String enumColumn(Reference it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, it)» «getEnumDatabaseType(it)»«if (parentIsNullable) "" else getDatabaseTypeNullability(it)»
	'''
}

def String containedColumns(Reference it, String prefix, boolean parentIsNullable) {
	val containedAttributes  = it.to.attributes.filter[e | !e.transient]
	val containedEnumReferences  = it.to.references.filter[r | !r.transient && r.to instanceof Enum]
	val containedBasicTypeReferences  = it.to.references.filter[r | !r.transient && r.to instanceof BasicType]
	'''
		«FOR a : containedAttributes SEPARATOR ", "»
			«column(a, getDatabaseName(prefix, a), parentIsNullable || nullable)»
			«IF !containedEnumReferences.isEmpty»
				«IF !containedAttributes.isEmpty»,
				«ENDIF»
			«ENDIF»
		«ENDFOR»
		«FOR r : containedEnumReferences SEPARATOR ", "»
			«enumColumn(r, getDatabaseName(prefix, r), parentIsNullable || nullable)»
			«IF !containedBasicTypeReferences.isEmpty»
				«IF !containedAttributes.isEmpty || !containedEnumReferences.isEmpty»,
				«ENDIF»
			«ENDIF»
		«ENDFOR»
		«FOR b : containedBasicTypeReferences SEPARATOR ", "»
			«containedColumns(b, getDatabaseName(b), parentIsNullable || nullable)»
		«ENDFOR»
	'''
}

def String inheritanceSingleTable(DomainObject it, Set<String> alreadyUsedColumns) {
	'''
	,
	«discriminatorColumn(it) »
	«it.getAllSubclasses().map[s | columns(s,true, alreadyUsedColumns)]»
	'''
}

def String discriminatorColumn(DomainObject it) {
	'''
		«inheritance.discriminatorColumnName()» «inheritance.getDiscriminatorColumnDatabaseType()» NOT NULL	'''
}

def String idPrimaryKey(DomainObject it) {
	'''
	ALTER TABLE «getDatabaseName(it)» ADD CONSTRAINT PK_«getDatabaseName(it)»
	PRIMARY KEY («attributes.filter[a | a.name == "id"].head.getDatabaseName()»)
	«afterIdPrimaryKey(it)»;
	'''
}

def String afterIdPrimaryKey(DomainObject it) {
	'''
	«usingIndexTablespace(it)»
	'''
}

def String manyToManyPrimaryKey(DomainObject it) {
	'''
	ALTER TABLE «getDatabaseName(it)» ADD CONSTRAINT PK_«getDatabaseName(it)»
	PRIMARY KEY («FOR r : references SEPARATOR ", "»«r.getForeignKeyName()»«ENDFOR»)
	«afterManyToManyPrimaryKey(it)»;
	'''
}

def String afterManyToManyPrimaryKey(DomainObject it) {
	'''
	«usingIndexTablespace(it)»
	'''
}

def String usingIndexTablespace(DomainObject it) {
	'''
	«IF hasHint(it, "tablespace")»	USING INDEX TABLESPACE «getHint(it, "tablespace").toUpperCase()»«ENDIF»
	'''
}

def String foreignKeyColumn(Reference it) {
	'''
		«IF it.hasOpposite() && "list" == opposite.getCollectionType()»
		«opposite.getListIndexColumnName()» «getListIndexDatabaseType()»,
		«ENDIF»
		«getForeignKeyName(it)» «getForeignKeyType(it) »
	'''
}

def String uniManyForeignKeyColumn(Reference it) {
	'''
		«IF "list" == getCollectionType()»
		«getListIndexColumnName(it)» «getListIndexDatabaseType()»,
		«ENDIF»
		«getOppositeForeignKeyName(it)» «from.getForeignKeyType() »
	'''
}

def String extendsForeignKeyColumn(DomainObject it, boolean initialComma) {
	'''
	«IF initialComma»,
	«ENDIF»
		«^extends.getExtendsForeignKeyName()» «^extends.getForeignKeyType() » NOT NULL
	'''
}

def dispatch String foreignKeyConstraint(DomainObject it) {
	'''
		«it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).filter[e | !(e.isOneToOne() && e.isInverse())].map[foreignKeyConstraint(it)]»
		«it.references.filter(r | !r.transient && r.many && r.opposite == null && r.isInverse() && (r.to.hasOwnDatabaseRepresentation())).map[uniManyForeignKeyConstraint(it)].join()»
	'''
}

def dispatch String foreignKeyConstraint(Reference it) {
	'''
	ALTER TABLE «from.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName(it))»
	FOREIGN KEY («getForeignKeyName(it)») REFERENCES «to.getRootExtends().getDatabaseName()» («to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»
	;
	«foreignKeyIndex(it)»
	'''
}

def String foreignKeyIndex(Reference it) {
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(from.getDatabaseName(), getForeignKeyName(it))» ON «from.getDatabaseName()» («getForeignKeyName(it)»);
	'''
}

def String uniManyForeignKeyConstraint(Reference it) {
	'''
	ALTER TABLE «to.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(to.getDatabaseName(), from.getDatabaseName())»
	FOREIGN KEY («getOppositeForeignKeyName(it)») REFERENCES «from.getRootExtends().getDatabaseName()» («from.getRootExtends().getIdAttribute().getDatabaseName()»)
	;
	«uniManyForeignKeyIndex(it)»
	'''
}

def String uniManyForeignKeyIndex(Reference it) {
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(to.getDatabaseName(), getOppositeForeignKeyName(it))» ON «to.getDatabaseName()» («getOppositeForeignKeyName(it)»);
	'''
}

def String extendsForeignKeyConstraint (DomainObject it) {
	'''
	ALTER TABLE «getDatabaseName(it)» ADD CONSTRAINT FK_«truncateLongDatabaseName(getDatabaseName(it), ^extends.getDatabaseName())»
	FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()» («^extends.getRootExtends().getIdAttribute().getDatabaseName()»)
	;
	«extendsForeignKeyIndex(it)»
	'''
}

def String extendsForeignKeyIndex(DomainObject it) {
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(getDatabaseName(it), ^extends.getExtendsForeignKeyName())» ON «getDatabaseName(it)» («^extends.getExtendsForeignKeyName()»);
	'''
}

def String uniqueConstraint(DomainObject it) {
	'''
	«IF hasUniqueConstraints(it)»
	ALTER TABLE «getDatabaseName(it)»
	«IF attributes.exists(a | a.isUuid()) »
		ADD CONSTRAINT UQ_«getDatabaseName(it)» UNIQUE (UUID)
		«ELSE»ADD CONSTRAINT UQ_«getDatabaseName(it)» UNIQUE («FOR key : getAllNaturalKeys(it) SEPARATOR ", "»«
	  		IF key.isBasicTypeReference()»«FOR a : (key as Reference).to.getAllNaturalKeys() SEPARATOR ", "»«getDatabaseName(getDatabaseName(key), a)»«ENDFOR»«
	  		ELSE»«key.getDatabaseName()»«ENDIF»«
	  		ENDFOR»)
	«ENDIF»
	«afterUniqueConstraint(it)»;
	«ENDIF»
	'''
}

def String afterUniqueConstraint(DomainObject it) {
	'''
	«usingIndexTablespace(it)»
	'''
}

def String index(DomainObject it) {
	'''
	«it.attributes.filter[a | a.index == true].map[i | index(i, "", it)]»
	«it.getBasicTypeReferences().map[containedColumnIndex(it)].join()»
	«IF isInheritanceTypeSingleTable(it)»
	«discriminatorIndex(it)»
	«ENDIF»
	'''
}

def String containedColumnIndex(Reference it) {
	'''
		«it.to.attributes.filter(a | a.index == true).map[a | index(a, getDatabaseName(it) + "_", from)]»
	'''
}

def String index(Attribute it, String prefix, DomainObject domainObject) {
	var actualDomainObject = if (domainObject.^extends != null && isInheritanceTypeSingleTable(domainObject.getRootExtends())) domainObject.getRootExtends() else domainObject
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(actualDomainObject.getDatabaseName(), getDatabaseName(prefix, it))»
		ON «actualDomainObject.getDatabaseName()» («getDatabaseName(prefix, it)» ASC)
	«afterIndex(it, prefix, domainObject)»;
	'''
}

def String afterIndex(Attribute it, String prefix, DomainObject domainObject) {
	'''
	«IF domainObject.hasHint("tablespace")»    TABLESPACE «domainObject.getHint("tablespace").toUpperCase()»«ENDIF»
	'''
}

def String discriminatorIndex(DomainObject it) {
	'''
	CREATE INDEX IX_«truncateLongDatabaseName(getDatabaseName(it), inheritance.discriminatorColumnName())»
		ON «getDatabaseName(it)» («inheritance.discriminatorColumnName()» ASC)
	;
	'''
}

def String dropIndex(DomainObject it) {
	'''
	«it.attributes.filter(a | a.index == true).map[a | dropIndex(a, "", it)]»
	«it.getBasicTypeReferences().map[dropContainedColumnIndex(it)].join()»
	«IF isInheritanceTypeSingleTable(it)»
	«dropDiscriminatorIndex(it)»
	«ENDIF»
	'''
}

def String dropContainedColumnIndex(Reference it) {
	'''
		«it.to.attributes.filter(a | a.index == true).map[a | dropIndex(a, getDatabaseName(it) + "_", from)]»
	'''
}

def String dropIndex(Attribute it, String prefix, DomainObject domainObject) {
	var actualDomainObject = if (domainObject.^extends != null && isInheritanceTypeSingleTable(domainObject.getRootExtends())) domainObject.getRootExtends() else domainObject
	'''
	DROP INDEX IX_«truncateLongDatabaseName(actualDomainObject.getDatabaseName(), getDatabaseName(prefix, it))»;
	'''
}

def String dropDiscriminatorIndex(DomainObject it) {
	'''
	DROP INDEX IX_«truncateLongDatabaseName(getDatabaseName(it), inheritance.discriminatorColumnName())»;
	'''
}

}
