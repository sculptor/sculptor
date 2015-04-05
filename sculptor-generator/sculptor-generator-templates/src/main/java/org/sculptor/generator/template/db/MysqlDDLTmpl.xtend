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
package org.sculptor.generator.template.db

import java.util.Set
import javax.inject.Inject
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.BasicType
import sculptormetamodel.DomainObject
import sculptormetamodel.Reference
import org.sculptor.generator.chain.ChainOverridable

@ChainOverridable
class MysqlDDLTmpl {

	@Inject extension DbHelperBase dbHelperBase
	@Inject extension DbHelper dbHelper
	@Inject extension Helper helper
	@Inject extension Properties properties

def String ddl(Application it) {
	fileOutput("dbschema/" + name + "_ddl.sql", OutputSlot::TO_GEN_RESOURCES, '''
	«IF isDdlDropToBeGenerated()»    
		-- ###########################################
		-- # Drop entities
		-- ###########################################

		-- Many to many relations
		«it.resolveManyToManyRelations(false).map[dropTable(it)].join»

		-- Normal entities
		«it.getDomainObjectsInCreateOrder(false).filter(e | !isInheritanceTypeSingleTable(getRootExtends(e.^extends))).map[dropTable(it)].join»

		-- Drop pk sequence
		«dropSequence(it)»

	«ENDIF»
	-- ###########################################
	-- # Create entities
	-- ###########################################

	-- Create pk sequence
	«createSequence(it)»

	-- Normal entities
	
	«it.getDomainObjectsInCreateOrder(true).filter[d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))].map[d | createTable(d, false)].join»
	«it.getDomainObjectsInCreateOrder(true).filter[d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends))].map[d | foreignKeyAlter(d)].join»
	«it.getDomainObjectsInCreateOrder(true).filter[d | d.^extends != null && !isInheritanceTypeSingleTable(getRootExtends(d.^extends))].map[d | extendsForeignKeyAlter(d)].join»
	
	-- Many to many relations
	«it.resolveManyToManyRelations(true).map[r | createTable(r, true)].join»
	'''
	)
}

def String dropSequence(Application it) {
	'''
	«IF applicationServer == "jboss" || jpaProviderHibernate»
		DROP TABLE IF EXISTS hibernate_sequence;
	«ENDIF»
	'''
}

def String createSequence(Application it) {
	'''
	«IF applicationServer == "jboss" || jpaProviderHibernate»
		CREATE TABLE hibernate_sequence(next_val BIGINT);
	«ENDIF»
	'''
}

def String dropTable(DomainObject it) {
	'''
	DROP TABLE IF EXISTS «getDatabaseName(it)»;
	'''
}

def String createTable(DomainObject it, Boolean manyToManyRelationTable) {
	'''
	«val Set<String> alreadyUsedColumns = newHashSet()»
	CREATE TABLE «getDatabaseName(it)» (
		«columns(it, manyToManyRelationTable, false, alreadyUsedColumns)»«
		IF isInheritanceTypeSingleTable(it)»«
			inheritanceSingleTable(it, alreadyUsedColumns)»«
		ENDIF»«
		IF ^extends != null»«
			extendsForeignKey(it, !alreadyUsedColumns.isEmpty)»«
		ENDIF»«
		uniqueConstraint(it)»
	)«afterCreateTable(it)»;
	
	'''
}

def String afterCreateTable(DomainObject it) {
	'''
	'''
}

def String columns(DomainObject it, Boolean manyToManyRelationTable, boolean initialComma, Set<String> alreadyDone) {
	val currentAttributes = attributes.filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName) || e.isSystemAttributeToPutLast())].toList
	alreadyDone.addAll(currentAttributes.map[a | a.databaseName])
	val currentBasicTypeReferences = it.getBasicTypeReferences().filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName))].toList
	alreadyDone.addAll(currentBasicTypeReferences.map[e | e.databaseName])

	val currentEnumReferences = it.getEnumReferences().filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName))].toList
	alreadyDone.addAll(currentEnumReferences.map[e | e.getDatabaseName])

	val currentUniManyToThisReferences = if (it.module == null) <Reference>newArrayList() else module.application.modules.map[m | m.domainObjects].flatten.map[d | d.references].flatten.filter[r | !r.transient && r.to == it && r.many && r.opposite == null && r.isInverse() && !(alreadyDone.contains(r.databaseName))].toList
	alreadyDone.addAll(currentUniManyToThisReferences.map[e | e.getDatabaseName])

	val currentOneReferences = it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).filter[e | !((e.isOneToOne() && e.isInverse()) || alreadyDone.contains(e.getDatabaseName))].toList
	alreadyDone.addAll(currentOneReferences.map[e | e.getDatabaseName])

	val currentSystemAttributesToPutLast = it.attributes.filter[e | !(e.transient || alreadyDone.contains(e.getDatabaseName) || !e.isSystemAttributeToPutLast())].toList
	alreadyDone.addAll(currentSystemAttributesToPutLast.map[e | e.getDatabaseName])

	'''
	«IF initialComma && !currentAttributes.isEmpty»,
	«ENDIF»
	«currentAttributes.map[a | column(a, "")].join(",\n")»«
	IF (initialComma || !currentAttributes.isEmpty) && !currentOneReferences.isEmpty»«",\n\t"»
	«ENDIF»
	«currentOneReferences.map[e | foreignKey(e, manyToManyRelationTable)].join(",\n")»«
	IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty) && !currentUniManyToThisReferences.isEmpty»«",\n\t"»
	«ENDIF»
	«currentUniManyToThisReferences.map[e | uniManyForeignKey(e)].join(",\n")»«
	IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty) && !currentBasicTypeReferences.isEmpty»«",\n\t"»
	«ENDIF»
	«currentBasicTypeReferences.map[e | containedColumns(e, "", false)].join(",\n")»«
	IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty || !currentBasicTypeReferences.isEmpty) && !currentEnumReferences.isEmpty»«",\n\t"»
	«ENDIF»
	«currentEnumReferences.map[e | enumColumn(e, "", false)].join(",\n")»«
	IF ((initialComma || !currentAttributes.isEmpty) || !currentOneReferences.isEmpty || !currentUniManyToThisReferences.isEmpty || !currentBasicTypeReferences.isEmpty || !currentEnumReferences.isEmpty) && !currentSystemAttributesToPutLast.isEmpty»«",\n\t"»
	«ENDIF»
	«currentSystemAttributesToPutLast.map[e | column(e, "")].join(",\n")»'''
}

def String column(Attribute it, String prefix) {
	column(it, prefix, false)
}

def String column(Attribute it, String prefix, boolean parentIsNullable) {
	'''«getDatabaseName(prefix, it)» «getDatabaseType(it)»«if (parentIsNullable) "" else getDatabaseTypeNullability(it)»«
	IF name == "id"» AUTO_INCREMENT PRIMARY KEY«ENDIF»«
	IF index»,
	INDEX («getDatabaseName(prefix, it)»)«ENDIF»'''
}

def String containedColumns(Reference it, String prefix, boolean parentIsNullable) {
	val containedAttributes = it.to.attributes.filter[a | !a.transient]
	val containedEnumReferences = it.to.references.filter(r | !r.transient && r.to instanceof sculptormetamodel.Enum)
	val containedBasicTypeReferences = it.to.references.filter(r | !r.transient && r.to instanceof BasicType)
	'''«containedAttributes.map[a | column(a, getDatabaseName(prefix, it), parentIsNullable || it.nullable)].join(",\n")»«
	IF !containedEnumReferences.isEmpty»«IF !containedAttributes.isEmpty»«",\n"»«
	ENDIF»«ENDIF»«
	containedEnumReferences.map[enumColumn(it, getDatabaseName(prefix, it), parentIsNullable || nullable)].join(",\n")»«
	IF !containedBasicTypeReferences.isEmpty»«IF !containedAttributes.isEmpty || !containedEnumReferences.isEmpty»«",\n"»«
	ENDIF»«ENDIF»«containedBasicTypeReferences.map[containedColumns(it, it.getDatabaseName(), parentIsNullable || nullable)].join(",\n")»'''
}

def String enumColumn(Reference it, String prefix, boolean parentIsNullable) {
	'''«getDatabaseName(prefix, it)» «getEnumDatabaseType(it)»«if (parentIsNullable) "" else getDatabaseTypeNullability(it)»'''
}

def String inheritanceSingleTable(DomainObject it, Set<String> alreadyUsedColumns) {
	'''
	,
	«discriminatorColumn(it)»
	«it.getAllSubclasses().map[columns(it, false, true, alreadyUsedColumns)].join»'''
}

def String discriminatorColumn(DomainObject it) {
	'''
		«inheritance.discriminatorColumnName()» «inheritance.getDiscriminatorColumnDatabaseType()» NOT NULL,
			INDEX («inheritance.discriminatorColumnName()»)'''
}

def String foreignKey(Reference it, Boolean manyToManyRelationTable) {
	'''
		«IF it.hasOpposite() && "list" == opposite.getCollectionType()»
			«opposite.getListIndexColumnName()» «getListIndexDatabaseType()»,
		«ENDIF»
		«it.getForeignKeyName()» «it.getForeignKeyType()»«IF manyToManyRelationTable»,
			FOREIGN KEY («it.getForeignKeyName()») REFERENCES «to.getRootExtends().getDatabaseName()»(«to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»«ENDIF»'''
}

def dispatch String foreignKeyAlter(DomainObject it) {
	'''
		«it.references.filter(r | !r.transient && !r.many && r.to.hasOwnDatabaseRepresentation()).filter[e | !(e.isOneToOne() && e.isInverse())].map[foreignKeyAlter(it)].join»
		«it.references.filter(r | !r.transient && r.many && r.opposite == null && r.isInverse() && (r.to.hasOwnDatabaseRepresentation())).map[uniManyForeignKeyAlter(it)].join»
	'''
}

def dispatch String foreignKeyAlter(Reference it) {
	'''
	-- Reference from «from.name».«getForeignKeyName(it)» to «to.name»
	ALTER TABLE «from.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(from.getDatabaseName(), getDatabaseName(it))»
		FOREIGN KEY («getForeignKeyName(it)») REFERENCES «to.getRootExtends().getDatabaseName()»(«to.getRootExtends().getIdAttribute().getDatabaseName()»)« IF (opposite != null) && opposite.isDbOnDeleteCascade()» ON DELETE CASCADE«ENDIF»;
	'''
}

def String extendsForeignKey(DomainObject it, boolean initialComma) {
	'''
	«IF initialComma»,
	«ENDIF»«
	it.^extends.getExtendsForeignKeyName()» «it.^extends.getForeignKeyType()» NOT NULL'''
}

def String extendsForeignKeyAlter(DomainObject it) {
	'''
	-- Entity «name» extends «^extends.getRootExtends().name»
	ALTER TABLE «getDatabaseName(it)» ADD CONSTRAINT FK_«getDatabaseName(it)»_«^extends.getExtendsForeignKeyName()»
		FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()»(«^extends.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

/*TODO: never called and possibly incorrect, remove? */
def String discriminatorIndex(DomainObject it) {
	'''
	-- Index for discriminator in «^extends.getRootExtends().name»
	ALTER TABLE «getDatabaseName(it)» ADD INDEX `DTYPE`(`DTYPE`);
	ALTER TABLE «getDatabaseName(it)» ADD INDEX FK_«getDatabaseName(it)»_«^extends.getExtendsForeignKeyName()»
		FOREIGN KEY («^extends.getExtendsForeignKeyName()») REFERENCES «^extends.getRootExtends().getDatabaseName()»(«^extends.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

def String uniManyForeignKey(Reference it) {
	'''
	«IF "list" == getCollectionType()»
		«getListIndexColumnName(it)» «getListIndexDatabaseType()»,
	«ENDIF»
	«getOppositeForeignKeyName(it)» «from.getForeignKeyType()»'''
}

def String uniManyForeignKeyAlter(Reference it) {
	'''
	-- Entity «to.name» inverse referenced from «from.name».«name»
	ALTER TABLE «to.getDatabaseName()» ADD CONSTRAINT FK_«truncateLongDatabaseName(to.getDatabaseName(), from.getDatabaseName())»
	FOREIGN KEY («getOppositeForeignKeyName(it)») REFERENCES «from.getRootExtends().getDatabaseName()»(«from.getRootExtends().getIdAttribute().getDatabaseName()»);
	'''
}

def String uniqueConstraint(DomainObject it) {
	'''
	«IF hasUniqueConstraints(it)»,
	«IF attributes.exists(a | a.isUuid()) »
		CONSTRAINT UNIQUE («attributes.filter(a | a.isUuid()).head.getDatabaseName()»)
	«ELSE »
		CONSTRAINT UNIQUE (
			«FOR key : getAllNaturalKeys(it) SEPARATOR ", "»
				«IF key.isBasicTypeReference()»
					«FOR a : (key as Reference).to.getAllNaturalKeys() SEPARATOR ", "»«
						getDatabaseName(getDatabaseName(key), a)»«
					ENDFOR»
				«ELSE»
					«key.getDatabaseName()»
				«ENDIF»
			«ENDFOR»
		)
	«ENDIF»
	«ENDIF»'''
}

}
