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

class MysqlDDLTmpl {

def static String ddl(Application it) {
	'''
	'''
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
		«it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).forEach[createTable(it)(false)]»
		«it.getDomainObjectsInCreateOrder(true).filter(e | !isInheritanceTypeSingleTable(getRootExtends(e.^extends))) .forEach[foreignKeyAlter(it)]»
	«it.getDomainObjectsInCreateOrder(true).filter(d | d.^extends != null && !isInheritanceTypeSingleTable(getRootExtends(d.^extends))).forEach[(it)^extendsForeignKeyAlter]»
	-- Many to many relations
		«it.resolveManyToManyRelations(true).forEach[createTable(it)(true)]»

	'''
	)
	'''
	'''
}

def static String dropTable(DomainObject it) {
	'''
	DROP TABLE IF EXISTS «getDatabaseName()»;
	'''
}

def static String createTable(DomainObject it, Boolean manyToManyRelationTable) {
	'''
	«val alreadyUsedColumns = it.{}.toSet()»
	CREATE TABLE «getDatabaseName()» (
	«columns(it)(manyToManyRelationTable, false, alreadyUsedColumns)»
	«IF isInheritanceTypeSingleTable()»«inheritanceSingleTable(it)(alreadyUsedColumns)»«ENDIF»
	«IF ^extends != null»«(it)^extendsForeignKey(!alreadyUsedColumns.isEmpty)»«ENDIF»
	«uniqueConstraint(it) »
	)«afterCreateTable(it)»;
	'''
}

def static String afterCreateTable(DomainObject it) {
	'''
	'''
}

def static String columns(DomainObject it, Boolean manyToManyRelationTable, boolean initialComma, Set[String] alreadyDone) {
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
}

def static String column(Attribute it, String prefix) {
	'''
	«column(it)(prefix, false) »
	'''
}

def static String column(Attribute it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, this)» «getDatabaseType()»«parentIsNullable ? "" : getDatabaseTypeNullability()»« IF name == "id"» AUTO_INCREMENT PRIMARY KEY«ENDIF-»«
		IF index»,
		INDEX («getDatabaseName(prefix, this)»)«ENDIF»
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

def static String enumColumn(Reference it, String prefix, boolean parentIsNullable) {
	'''
		«getDatabaseName(prefix, this)» «getEnumDatabaseType()»«parentIsNullable ? "" : getDatabaseTypeNullability()»	'''
}

def static String inheritanceSingleTable(DomainObject it, Set[String] alreadyUsedColumns) {
	'''
	,
	«discriminatorColumn(it) »
	«it.getAllSubclasses() .forEach[columns(it)(false, true, alreadyUsedColumns)]»
	'''
}

def static String discriminatorColumn(DomainObject it) {
	'''
		«inheritance.discriminatorColumnName()» «inheritance.getDiscriminatorColumnDatabaseType()» NOT NULL,
		INDEX («inheritance.discriminatorColumnName()»)	'''
}

def static String foreignKey(Reference it, Boolean manyToManyRelationTable) {
	'''
		«IF hasOpposite() && "list" == opposite.getCollectionType()»
		«opposite.getListIndexColumnName()» «getListIndexDatabaseType()»,
		«ENDIF»
		«getForeignKeyName()» «getForeignKeyType()»« IF manyToManyRelationTable-»,
		FOREIGN KEY («getForeignKeyName()») REFERENCES «to.getRootExtends().getDatabaseName()»(«to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»«ENDIF-»
	'''
}

def static String foreignKeyAlter(DomainObject it) {
	'''
		«it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).reject(e|e.isOneToOne() && e.isInverse()).forEach[foreignKeyAlter(it)]»
		«it.references.filter(r | !r.transient && r.many && r.opposite == null && r.isInverse() && (r.to.hasOwnDatabaseRepresentation())).forEach[uniManyForeignKeyAlter(it)]»
	'''
}

def static String foreignKeyAlter(Reference it) {
	'''
	-- Reference from «from.name».«getForeignKeyName()» to «to.name»
	ALTER TABLE «from.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName())»
		FOREIGN KEY («getForeignKeyName()») REFERENCES «to.getRootExtends().getDatabaseName()»(«to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»;
	'''
}

	«DEFINE ^extendsForeignKey(boolean initialComma) FOR DomainObject»
	«IF initialComma»,
	«ENDIF»
		«^extends.getExtendsForeignKeyName()» «^extends.getForeignKeyType()» NOT NULL	'''
}

	«DEFINE ^extendsForeignKeyAlter FOR DomainObject»
	-- Entity «name» ^extends «^extends.getRootExtends().name»
	ALTER TABLE «getDatabaseName()» ADD CONSTRAINT FK_«getDatabaseName()»_«^extends.getExtendsForeignKeyName()»
		FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()»(«^extends.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

/*TODO: never called and possibly incorrect, remove? */
def static String discriminatorIndex(DomainObject it) {
	'''
	-- Index for discriminator in «^extends.getRootExtends().name»
	ALTER TABLE «getDatabaseName()» ADD INDEX `DTYPE`(`DTYPE`);
	ALTER TABLE «getDatabaseName()» ADD INDEX FK_«getDatabaseName()»_«^extends.getExtendsForeignKeyName()»
		FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()»(«^extends.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

def static String uniManyForeignKey(Reference it) {
	'''
		«IF "list" == getCollectionType()»
		«getListIndexColumnName()» «getListIndexDatabaseType()»,
		«ENDIF»
		«getOppositeForeignKeyName()» «from.getForeignKeyType()»
	'''
}

def static String uniManyForeignKeyAlter(Reference it) {
	'''
	-- Entity «to.name» inverse referenced from «from.name».«name»
	ALTER TABLE «to.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(to.getDatabaseName(), from.getDatabaseName())»
	FOREIGN KEY («getOppositeForeignKeyName()») REFERENCES «from.getRootExtends().getDatabaseName()»(«from.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

def static String uniqueConstraint(DomainObject it) {
	'''
	«IF hasUniqueConstraints()»,
	«IF attributes.exists(a | a.isUuid()) »
		CONSTRAINT UNIQUE («attributes.filter(a | a.isUuid()).first().getDatabaseName()»)
			«ELSE »
		CONSTRAINT UNIQUE («FOR key SEPARATOR ", "  : getAllNaturalKeys()»« IF key.isBasicTypeReference()»«FOREACH
					((Reference) key).to.getAllNaturalKeys() AS a SEPARATOR ", "»«getDatabaseName(key.getDatabaseName(), a)»«ENDFOR»« ELSE»«key.getDatabaseName()»«
				ENDIF»«ENDFOR»)
	«ENDIF»
	«ENDIF»
	'''
}


}
