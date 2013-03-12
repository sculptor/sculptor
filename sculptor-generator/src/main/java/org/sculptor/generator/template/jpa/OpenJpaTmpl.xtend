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

package org.sculptor.generator.template.jpa

import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.template.db.OracleDDLTmpl
import sculptormetamodel.Application

import static org.sculptor.generator.ext.DbHelper.*
import static org.sculptor.generator.ext.Properties.*
import static org.sculptor.generator.template.jpa.OpenJpaTmpl.*

import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.DbHelperBase.*

class OpenJpaTmpl {

def static String openJpa(Application it) {
	'''
		«IF isJodaDateTimeLibrary()»
		«jodaStrategy(it)»
		«ENDIF»
		«IF it.containsNonOrdinaryEnums()»
			«enumStrategy(it)»
		«ENDIF»
		«IF isTestToBeGenerated()»
			«testDdl(it)»
		«ENDIF»
	'''
}

def static String jodaStrategy(Application it) {
	fileOutput(javaFileName(basePackage +".util.JodaHandler"), OutputSlot::TO_GEN_SRC, '''
	package «basePackage».util;

	import org.apache.openjpa.jdbc.identifier.DBIdentifier;
	import org.apache.openjpa.jdbc.kernel.JDBCStore;
	import org.apache.openjpa.jdbc.meta.ValueMapping;
	import org.apache.openjpa.jdbc.meta.strats.AbstractValueHandler;
	import org.apache.openjpa.jdbc.schema.Column;
	import org.apache.openjpa.jdbc.schema.ColumnIO;
	import org.apache.openjpa.jdbc.sql.DBDictionary;
	import org.apache.openjpa.meta.JavaTypes;
	import org.joda.time.DateTime;
	import org.joda.time.LocalDate;

	@SuppressWarnings("serial")
	public class JodaHandler ^extends AbstractValueHandler {

		@Override
		public Object toObjectValue(ValueMapping vm, Object value) {
			if (value == null) {
				return null;
			}
			if ("LocalDate".equals(vm.getType().getSimpleName())) {
				return new LocalDate(value);
			}
			else if ("DateTime".equals(vm.getType().getSimpleName())) {
				return new DateTime(value);
			}
			else {
				throw new IllegalArgumentException(
				        "value can not be converted to LocalDate/DateTime");
			}
		}

		@Override
		public Object toDataStoreValue(ValueMapping vm, Object value, JDBCStore store) {
			if (value == null) {
				return null;
			}
			if (value instanceof DateTime) {
				return ((DateTime) value).toDate();
			}
			else if (value instanceof LocalDate) {
				return ((LocalDate) value).toDateTimeAtStartOfDay().toDate();
			}
			else {
				throw new IllegalArgumentException(
				        "value is not of type LocalDate/DateTime");
			}
		}

		@Deprecated
		public Column[] map(ValueMapping vm, String name, ColumnIO io, boolean adapt) {
			DBDictionary dict = vm.getMappingRepository().getDBDictionary();
			DBIdentifier colName = DBIdentifier.newColumn(name, dict != null ? dict.delimitAll() : false);
			return map(vm, colName, io, adapt);
		}

		public Column[] map(ValueMapping vm, DBIdentifier name, ColumnIO io, boolean adapt) {
			Column col = new Column();
			col.setIdentifier(name);
			col.setJavaType(JavaTypes.DATE);
			return new Column[] { col };
		}

		@Override
		public boolean isVersionable(ValueMapping vm) {
			return true;
		}
	}
	'''
	)
}

def static String enumStrategy(Application it) {
	fileOutput(javaFileName(basePackage +".util.EnumHandler"), OutputSlot::TO_GEN_SRC, '''
	package «basePackage».util;

	import org.apache.openjpa.jdbc.kernel.JDBCStore;
	import org.apache.openjpa.jdbc.meta.ValueMapping;
	import org.apache.openjpa.jdbc.meta.strats.EnumValueHandler;

	import org.sculptor.framework.util.EnumHelper;

	@SuppressWarnings("serial")
	public class EnumHandler ^extends EnumValueHandler {

		@Override
		public Object toObjectValue(ValueMapping vm, Object value) {
			if (value == null) {
				return null;
			}
			try {
				return EnumHelper.toEnum(vm.getType(), value);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}

		@SuppressWarnings("unchecked")
		@Override
		public Object toDataStoreValue(ValueMapping vm, Object value,
			JDBCStore store) {
			if (value == null) {
				return null;
			}
			try {
				return EnumHelper.toData((Enum)value);
			} catch (Exception e) {
				e.printStackTrace();
			}
			return null;
		}
	}
	'''
	)
}

/*
		This is hopefully a temporary workaround for OpenJPA.
		OpenJPA is not generating primary keys on manytomany jointables
 */
def static String testDdl(Application it) {
	val manyToManyRelations = it.resolveManyToManyRelations(true)
	fileOutput("dbunit/ddl.sql", OutputSlot::TO_GEN_RESOURCES_TEST, '''
		«manyToManyRelations.forEach[OracleDDLTmpl::manyToManyPrimaryKey(it)]»
	'''
	)
}
}
