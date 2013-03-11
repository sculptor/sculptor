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
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.DomainObject
import sculptormetamodel.Reference

import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.db.MysqlDDLTmpl.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.DbHelperBase.*

class MysqlDDLTmpl {

def static String ddl(Application it) {
	fileOutput("dbschema/" + name + "_ddl.sql", 'TO_GEN_RESOURCES', '''
	«IF isDdlDropToBeGenerated()»    
	-- ###########################################
	-- # Drop entities
	-- ###########################################

	-- Many to many relations
		«it.resolveManyToManyRelations(false).forEach[dropTable(it)]»
	-- Normal entities
		«it.getDomainObjectsInCreateOrder(false).filter(e | !isInheritanceTypeSingleTable(getRootExtends(e.^extends))).forEach[dropTable(it)]»
	«ENDIF»
	-- ###########################################
	-- # Create new entities
	-- ###########################################

	-- Normal entities
		«it.getDomainObjectsInCreateOrder(true).filter[d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))].forEach[d | createTable(d,false)]»
		«it.getDomainObjectsInCreateOrder(true).filter[e | !isInheritanceTypeSingleTable(getRootExtends(e.^extends))].forEach[d | foreignKeyAlter(d)]»
	«it.getDomainObjectsInCreateOrder(true).filter(d | d.^extends != null && !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).forEach[extendsForeignKeyAlter(it)]»
	-- Many to many relations
		«it.resolveManyToManyRelations(true).forEach[r | createTable(r, true)]»

	'''
	)
}

def static String dropTable(DomainObject it) {
	'''
	DROP TABLE IF EXISTS «getDatabaseName(it)»;
	'''
}

def static String createTable(DomainObject it, Boolean manyToManyRelationTable) {
	'''
	«val Set<String> alreadyUsedColumns = newHashSet()»
	CREATE TABLE «getDatabaseName(it)» (
	«columns(it, manyToManyRelationTable, false, alreadyUsedColumns)»
	«IF isInheritanceTypeSingleTable(it)»«inheritanceSingleTable(it, alreadyUsedColumns)»«ENDIF»
	«IF ^extends != null»«extendsForeignKey(it, !alreadyUsedColumns.isEmpty)»«ENDIF»
	«uniqueConstraint(it) »
	)«afterCreateTable(it)»;
	'''
}

def static String afterCreateTable(DomainObject it) {
	'''
	'''
}

def static String columns(DomainObject it, Boolean manyToManyRelationTable, boolean initialComma, Set<String> alreadyDone) {
	val currentAttributes = attributes.filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName()) || e.isSystemAttributeToPutLast())]
	alreadyDone.addAll(currentAttributes.map(a | a.databaseName))
	val currentBasicTypeReferences = it.getBasicTypeReferences().filter[e | ! (e.transient || alreadyDone.contains(e.getDatabaseName()))]
	alreadyDone.addAll(currentBasicTypeReferences.map[e | e.databaseName])

	val currentEnumReferences = it.getEnumReferences().filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName()))]
	alreadyDone.addAll(currentEnumReferences.map[e | e.getDatabaseName()])

	val currentUniManyToThisReferences = if (it.module == null) <Reference>newArrayList() else module.application.modules.map[domainObjects].flatten.map[references].flatten.filter[e | !e.transient && e.to == it && e.many && e.opposite == null && e.isInverse() && !(alreadyDone.contains(e.databaseName))]
	alreadyDone.addAll(currentUniManyToThisReferences.map[e | e.getDatabaseName()])

/*
	«val currentOneReferences - = it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).reject(e | (e.isOneToOne() && e.isInverse()) || alreadyDone.contains(e.getDatabaseName()))»
	«FOR e : currentOneReferences»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»
	«val currentSystemAttributesToPutLast - = it.attributes.reject(e | e.transient || alreadyDone.contains(e.getDatabaseName()) || ! e.isSystemAttributeToPutLast() ) »
	«FOR e : currentSystemAttributesToPutLast»«alreadyDone.add(e.getDatabaseName()) -> ""»«ENDFOR»

	'''
	«IF initialComma && !currentAttributes.isEmpty»,
	«ENDIF»
	«it.currentAttributes SEPARATOR ",\n".forEach[column(it)("")]»
	«IF (initialComma || !currentAttributes.isEmpty) && !currentOneReferences.isEmpty»,
	«ENDIF»
	«it.currentOneReferences SEPARATOR ",\n".forEach[foreignKey(it)(manyToManyRelationTable)]»
	«IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty) && !currentUniManyToThisReferences.isEmpty»,
	«ENDIF»
	«it.currentUniManyToThisReferences SEPARATOR ",\n".forEach[uniManyForeignKey(it)]»
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
	*/
	""
}

def static String column(Attribute it, String prefix) {
	'''
	«column(it, prefix, false) »
	'''
}

def static String column(Attribute it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, it)» «getDatabaseType()»«if (parentIsNullable) "" else getDatabaseTypeNullability(it)»«IF name == "id"» AUTO_INCREMENT PRIMARY KEY«ENDIF»
		«IF index»,
		INDEX («getDatabaseName(prefix, it)»)«ENDIF»
	'''
}

def static String containedColumns(Reference it, String prefix, boolean parentIsNullable) {
	'''
	«val containedAttributes  = it.to.attributes.filter[e | !e.transient]»
	«val containedEnumReferences  = it.to.references.filter(r | !r.transient && r.to instanceof sculptormetamodel.Enum)»
	«val containedBasicTypeReferences  = it.to.references.filter(r | !r.transient && r.to instanceof BasicType)»
		«containedAttributes.map[a | column(a, getDatabaseName(prefix, it), parentIsNullable || it.nullable)].join(", ")»«IF !containedEnumReferences.isEmpty»«IF !containedAttributes.isEmpty»,
		«ENDIF»«ENDIF»«containedEnumReferences.map[enumColumn(it, getDatabaseName(prefix, it), parentIsNullable || nullable)].join(", ")»«IF !containedBasicTypeReferences.isEmpty»«IF !containedAttributes.isEmpty || !containedEnumReferences.isEmpty»,
		«ENDIF»«ENDIF»«containedBasicTypeReferences.map[containedColumns(it, it.getDatabaseName(), parentIsNullable || nullable)].join(", ")»
	'''
}

def static String enumColumn(Reference it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, it)» «getEnumDatabaseType(it)»«if (parentIsNullable) "" else getDatabaseTypeNullability(it)»
	'''
}

def static String inheritanceSingleTable(DomainObject it, Set<String> alreadyUsedColumns) {
	'''
	,
	«discriminatorColumn(it) »
	«it.getAllSubclasses() .forEach[columns(it, false, true, alreadyUsedColumns)]»
	'''
}

def static String discriminatorColumn(DomainObject it) {
	'''
		«inheritance.discriminatorColumnName()» «inheritance.getDiscriminatorColumnDatabaseType()» NOT NULL,
		INDEX («inheritance.discriminatorColumnName()»)	'''
}

def static String foreignKey(Reference it, Boolean manyToManyRelationTable) {
	'''
		«IF it.hasOpposite() && "list" == opposite.getCollectionType()»
		«opposite.getListIndexColumnName()» «getListIndexDatabaseType()»,
		«ENDIF»
		«it.getForeignKeyName()» «it.getForeignKeyType()»«IF manyToManyRelationTable»,
		FOREIGN KEY («it.getForeignKeyName()») REFERENCES «to.getRootExtends().getDatabaseName()»(«to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»«ENDIF»
	'''
}

def static String foreignKeyAlter(DomainObject it) {
	'''
		«it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).filter[e | !(e.isOneToOne() && e.isInverse())].map[foreignKeyAlter(it)]»
		«it.references.filter(r | !r.transient && r.many && r.opposite == null && r.isInverse() && (r.to.hasOwnDatabaseRepresentation())).map[uniManyForeignKeyAlter(it)]»
	'''
}

def static String foreignKeyAlter(Reference it) {
	'''
	-- Reference from «from.name».«getForeignKeyName(it)» to «to.name»
	ALTER TABLE «from.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName(it))»
		FOREIGN KEY («getForeignKeyName(it)») REFERENCES «to.getRootExtends().getDatabaseName()»(«to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»;
	'''
}

def static String extendsForeignKey(DomainObject it, boolean initialComma) {
	'''
	«IF initialComma»,
	«ENDIF»
		«it.^extends.getExtendsForeignKeyName()» «it.^extends.getForeignKeyType()» NOT NULL	'''
}

def static extendsForeignKeyAlter(DomainObject it) {
	'''
	-- Entity «name» ^extends «^extends.getRootExtends().name»
	ALTER TABLE «getDatabaseName(it)» ADD CONSTRAINT FK_«getDatabaseName(it)»_«^extends.getExtendsForeignKeyName()»
		FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()»(«^extends.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

/*TODO: never called and possibly incorrect, remove? */
def static String discriminatorIndex(DomainObject it) {
	'''
	-- Index for discriminator in «^extends.getRootExtends().name»
	ALTER TABLE «getDatabaseName(it)» ADD INDEX `DTYPE`(`DTYPE`);
	ALTER TABLE «getDatabaseName(it)» ADD INDEX FK_«getDatabaseName(it)»_«^extends.getExtendsForeignKeyName()»
		FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()»(«^extends.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

def static String uniManyForeignKey(Reference it) {
	'''
		«IF "list" == getCollectionType()»
		«getListIndexColumnName(it)» «getListIndexDatabaseType()»,
		«ENDIF»
		«getOppositeForeignKeyName(it)» «from.getForeignKeyType()»
	'''
}

def static String uniManyForeignKeyAlter(Reference it) {
	'''
	-- Entity «to.name» inverse referenced from «from.name».«name»
	ALTER TABLE «to.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(to.getDatabaseName(), from.getDatabaseName())»
	FOREIGN KEY («getOppositeForeignKeyName(it)») REFERENCES «from.getRootExtends().getDatabaseName()»(«from.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

def static String uniqueConstraint(DomainObject it) {
	'''
	«IF hasUniqueConstraints(it)»,
	«IF attributes.exists(a | a.isUuid()) »
		CONSTRAINT UNIQUE («attributes.filter(a | a.isUuid()).head.getDatabaseName()»)
			«ELSE »
		CONSTRAINT UNIQUE («FOR key : getAllNaturalKeys(it) SEPARATOR ", "»« IF key.isBasicTypeReference()»
		«FOR a : (key as Reference).to.getAllNaturalKeys() SEPARATOR ", "»«getDatabaseName(getDatabaseName(key), a)»«ENDFOR»« ELSE»«key.getDatabaseName()»«
				ENDIF»«ENDFOR»)
	«ENDIF»
	«ENDIF»
	'''
}


}
