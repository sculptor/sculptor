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

import java.util.UUID
import java.util.concurrent.atomic.AtomicInteger
import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.PropertiesBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application
import sculptormetamodel.Attribute
import sculptormetamodel.Enum
import sculptormetamodel.Reference
import sculptormetamodel.DomainObject;
import java.util.Date
import java.text.SimpleDateFormat

@ChainOverridable
class DbUnitTmpl {
	@Inject extension DbHelperBase dbHelperBase
	@Inject extension DbHelper dbHelper
	@Inject extension Helper helper
	@Inject extension Properties properties
	@Inject extension PropertiesBase propertiesBase;

def String emptyDbunitTestData(Application it) {
	fileOutput("dbunit/EmptyDatabase.xml", OutputSlot.TO_GEN_RESOURCES_TEST, '''
		«dbunitTestDataContent(it) »
	'''
	)
}

def String singleDbunitTestData(Application it) {
	if (getDbUnitDataSetFile !== null)
		fileOutput(getDbUnitDataSetFile(), OutputSlot.TO_RESOURCES_TEST, dbunitTestDataContent(it))
	else
		""
}

def String dbunitTestDataContent(Application it) {
	val manyToManyRelations = it.resolveManyToManyRelations(true)
	'''
	<?xml version='1.0' encoding='UTF-8'?>
	<dataset>
		«val domainObjects  = it.getDomainObjectsInCreateOrder(true).filter(d | !isInheritanceTypeSingleTable(getRootExtends(d.^extends)))» 
		«FOR domainObject  : domainObjects» 
			«var comment = new StringBuilder()»
			«for (refs : domainObject.references.filter(r | !r.many)) {
				var String c = genEnumComment(refs);
				if (c !== null) {
					comment.append("\n").append(c)
				}
			}»
			«IF comment.length > 0»
			<!--
				Enums for entity: «domainObject.name»
				«comment»
			-->
			«ENDIF»
			«IF dbunitTestDataRowsAll === 0»
				<«domainObject.getDatabaseName()» />
			«ELSE»
				«var fullNo=randomInRange(dbunitTestDataRowsFull())»
				«var mixedNo=randomInRange(dbunitTestDataRowsMixed())»
				«var minimalNo=randomInRange(dbunitTestDataRowsMinimal())»
				«dbunitTestDataRow(domainObject, fullNo, 100, dbunitTestDataIdBase)»
				«dbunitTestDataRow(domainObject, mixedNo, dbunitTestDataRowsMixedProbability(), dbunitTestDataIdBase + fullNo)»
				«dbunitTestDataRow(domainObject, minimalNo, 0, dbunitTestDataIdBase + fullNo + mixedNo)»
			«ENDIF»
		«ENDFOR» 
		«FOR domainObject  : manyToManyRelations» 
			«IF dbunitTestDataRowsAll === 0»
				<«domainObject.getDatabaseName()» />
			«ELSE»
				«FOR j : 0..(dbunitTestDataRowsAll)»
					«FOR k : 0..(dbunitTestDataRowsAll)»
						«val AtomicInteger offset = new AtomicInteger(0)»
						<«domainObject.getDatabaseName()»
							«domainObject.references.map[a | " " + a.getDatabaseName() + "=\"" + ((offset.getAndAdd(1) == 0 ? j : k) + dbunitTestDataIdBase) + "\"\n"].join()»
						/>
					«ENDFOR»
				«ENDFOR»
			«ENDIF»
		«ENDFOR» 
	</dataset>
	'''
}

def String dbunitTestDataRow(DomainObject domainObject, int rows, int probability, int base) {
	'''
		«FOR index : 0..(rows - 1)»
			<«domainObject.getDatabaseName()»
				«domainObject.attributes.filter(attr | !attr.isNullable() || randomInProbability(probability))
					.map[attr | " " + attr.getDatabaseName() + "=\"" + genValue(index + base, attr) + "\"\n"].join()»
				«domainObject.references.filter(ref | (!ref.isNullable() || randomInProbability(probability)) && !ref.many)
					.map[ref | " " + ref.getDatabaseName() + "=\""
						+ genRefValue(Math.min(index + base, dbunitTestDataRowsAll + dbunitTestDataIdBase), ref)
						+ "\"\n"
					].join()»
			/>
		«ENDFOR»
	'''
}

def String genValue(int id, Attribute attr) {
	var uType = attr.type.toUpperCase();
	if (attr.name == "id") {
		Integer.toString(id)
	} else if (attr.name == "uuid") {
		UUID.randomUUID().toString();
	} else if (attr.name == "version") {
		Integer.toString((Math.random() * 10) as int)
	} else if (attr.name == "createdBy") {
		"test"
	} else if (attr.name == "lastUpdatedBy") {
		"test"
	} else if (uType.indexOf("STRING") != -1 || uType.indexOf("TEXT") != -1) {
		genString(attr.name, attr.length, id)
	} else if (uType.indexOf("INT") != -1 || uType.indexOf("LONG") != -1) {
		genInt();
	} else if (uType.indexOf("DATE") != -1) {
		genDate()
	} else if (uType.indexOf("TIME") != -1) {
		genTime()
	} else if (uType.indexOf("BOOL") != -1) {
		genBoolean()
	} else {
		generateValue(attr)
	}
}

def String genEnumComment(Reference ref) {
	if (ref.isEnumReference()) {
		'''«FOR value : (ref.to as Enum).values BEFORE ref.name + " = " SEPARATOR ' | '»«value.name»«ENDFOR»'''
	} else {
		null
	}
}

def String genRefValue(int id, Reference ref) {
	if (ref.isEnumReference()) {
		var values = (ref.to as Enum).values;
		values.get((Math.random() * values.size) as int).name
	} else {
		Integer.toString(id)
	}
}
	
def String genString(String name, String length, int id) {
	var maxLength = length === null ? 100 : Integer.parseInt(length)
	var key = genUniqKey(id, name)
	var keyLength = key.length
	if (maxLength <= keyLength) {
		return key.substring(0, maxLength)
	}

	var genLength = maxLength > 10 ? genInt(maxLength - 10) + 10 : maxLength
	var result = new StringBuilder(maxLength)
	var int w = 0
	for (var i = 0; i < genLength; i++) {
		if (i % 3 == 2 && Math.random() * 3 > 2) {
			result.append(" ")
			w = 0
		} else if (w > 6) {
			result.append(" ")
			w = 0
		} else {
			w++
			var Double rVal = Math.random() * 26 + 97
			var char ch = rVal.intValue() as char
			result.append(ch)
		}
	}
	var namePos = genInt(genLength - keyLength);
	namePos = namePos < 0 ? 0 : namePos;
	result.replace(namePos, namePos, key);
	if (result.length > maxLength) {
		result.delete(maxLength, result.length)
	}
	result.toString()
}
def String genInt() {
	Integer.toString(genInt(Integer.MAX_VALUE))
}
def int genInt(int range) {
	(Math.random() * range) as int;
}
def String genDate() {
	var date = new Date((System.currentTimeMillis + Math.random * 10_000_000_000d - 5_000_000_000d) as long);
	var dateFormat = new SimpleDateFormat("yyyy-MM-dd");
	dateFormat.format(date)
}
def String genTime() {
	var date = new Date((System.currentTimeMillis + Math.random * 10_000_000_000d - 5_000_000_000d) as long);
	var timeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss.SSS");
	timeFormat.format(date)
}
def String genBoolean() {
	Math.random() < 0.5d ? "true" : "false"
}
def String generateValue(Attribute attr) {
	"Unknown type '" + attr.type + "' - Override DbUnitTmpl.generateValue(Attribute attr)"
}
def String genUniqKey(int id, String fieldName) {
	return "#" + fieldName.toUpperCase + id;
}
}