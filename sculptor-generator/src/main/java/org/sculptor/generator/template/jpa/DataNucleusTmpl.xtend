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

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class DataNucleusTmpl {

def static String dataNucleus(Application it) {
	'''
		«IF containsNonOrdinaryEnums()»
	    «enumMappingClass(it)»
	    «enumLiteralClass(it)»
	    «enumPlugin(it)»
	    «manifest(it)»
		«ENDIF»
		«IF isTestToBeGenerated()»
			«dataNucleusTestProperties(it)»
			«testDdl(it)»
		«ENDIF»
	'''
}

def static String dataNucleusTestProperties(Application it) {
	'''
	'''
	fileOutput("datanucleus-test.properties", 'TO_GEN_RESOURCES_TEST', '''
	datanucleus.ConnectionDriverName=org.hsqldb.jdbcDriver
	datanucleus.ConnectionURL=jdbc:hsqldb:mem:«name.toLowerCase()»
	datanucleus.ConnectionUserName=sa
	datanucleus.ConnectionPassword=
	'''
	)
	'''
	'''
}

def static String enumPlugin(Application it) {
	'''
	'''
	fileOutput("plugin.xml", 'TO_GEN_RESOURCES', '''
	<?xml version="1.0"?>
	<plugin>
		<extension point="org.datanucleus.store_mapping">
	«FOR enum : getAllEnums().filter(e|!e.isOrdinaryEnum())»
		«enumPluginMapping(it) FOR enum»
	«ENDFOR»
		</extension>
		<extension point="org.datanucleus.store.rdbms.sql_expression">
			<sql-expression mapping-class="«basePackage».util.EnumMapping"
				literal-class="org.datanucleus.store.rdbms.sql.expression.ParameterEnumLiteral"
				expression-class="org.datanucleus.store.rdbms.sql.expression.EnumExpression"/>
		</extension>
	</plugin>
	'''
	)
	'''
	'''
}

def static String enumPluginMapping(Enum it) {
	'''
			<mapping java-type="«getDomainPackage() + "." + name»"
				mapping-class="«getApplicationBasePackage()».util.EnumMapping"/>
	'''
}

def static String manifest(Application it) {
	'''
	'''
	fileOutput("META-INF/MANIFEST.MF", 'TO_GEN_RESOURCES', '''
	Manifest-Version: 1.0
	Bundle-ManifestVersion: 2
	Bundle-Name: enumplugin
	Bundle-SymbolicName: org.datanucleus.enumplugin
	Bundle-Version: 1.0.0
	'''
	)
	'''
	'''
}

def static String enumMappingClass(Application it) {
	'''
	'''
	fileOutput(javaFileName(basePackage + ".util.EnumMapping"), '''
	package «basePackage».util;

	import java.math.BigInteger;

	import org.datanucleus.ClassNameConstants;
	import org.datanucleus.metadata.FieldRole;
	import org.datanucleus.store.ExecutionContext;
	import org.fornax.cartridges.sculptor.framework.util.EnumHelper;

	public class EnumMapping ^extends org.datanucleus.store.mapped.mapping.EnumMapping {

		@Override
		@SuppressWarnings("rawtypes")
		public void setObject(ExecutionContext ec, Object preparedStatement, int[] exprIndex, Object value)
		{
			if (value == null)
			{
				getDatastoreMapping(0).setObject(preparedStatement, exprIndex[0], null);
			}
			else if (datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_STRING) ||
				     datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_INTEGER))
			{
				if (value instanceof String)
				{
				    getDatastoreMapping(0).setString(preparedStatement, exprIndex[0], (String)value);
				}
				else if (value instanceof BigInteger)
				{
				    getDatastoreMapping(0).setInt(preparedStatement, exprIndex[0], ((BigInteger)value).intValue());
				}
				else
				{
				    getDatastoreMapping(0).setObject(preparedStatement, exprIndex[0], EnumHelper.toData((Enum)value));
				}
			}
			else
			{
				super.setObject(ec, preparedStatement, exprIndex, value);
			}
		}

		@Override
		@SuppressWarnings("rawtypes")
		public Object getObject(ExecutionContext ec, Object resultSet, int[] exprIndex)
		{
			if (exprIndex == null)
			{
				return null;
			}

			if (getDatastoreMapping(0).getObject(resultSet, exprIndex[0]) == null)
			{
				return null;
			}
			else if (datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_STRING) ||
				     datastoreJavaType.equals(ClassNameConstants.JAVA_LANG_INTEGER))
			{
				Object value = getDatastoreMapping(0).getObject(resultSet, exprIndex[0]);
				Class enumType = null;
				if (mmd == null)
				{
				    enumType = ec.getClassLoaderResolver().classForName(type);
				}
				else
				{
				    enumType = mmd.getType();
				    if (roleForMember == FieldRole.ROLE_COLLECTION_ELEMENT)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getCollection().getElementType());
				    }
				    else if (roleForMember == FieldRole.ROLE_ARRAY_ELEMENT)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getArray().getElementType());
				    }
				    else if (roleForMember == FieldRole.ROLE_MAP_KEY)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getMap().getKeyType());
				    }
				    else if (roleForMember == FieldRole.ROLE_MAP_VALUE)
				    {
				        enumType = ec.getClassLoaderResolver().classForName(mmd.getMap().getValueType());
				    }
				}
				return EnumHelper.toEnum(enumType, value);
			}
			else
			{
				return super.getObject(ec, resultSet, exprIndex);
			}
		}
	}
	'''
	)
	'''
	'''
}

def static String enumLiteralClass(Application it) {
	'''
	'''
	fileOutput(javaFileName("org.datanucleus.store.rdbms.sql.expression.ParameterEnumLiteral"), '''
	package org.datanucleus.store.rdbms.sql.expression;

	import org.datanucleus.ClassNameConstants;
	import org.datanucleus.store.mapped.mapping.JavaTypeMapping;
	import org.datanucleus.store.rdbms.sql.SQLStatement;
	import org.fornax.cartridges.sculptor.framework.util.EnumHelper;

/**
 * Representation of an Enum literal.
 */
	public class ParameterEnumLiteral ^extends EnumLiteral
	{
		public ParameterEnumLiteral(SQLStatement stmt, JavaTypeMapping mapping, Object value, String parameterName) {
			super(stmt, mapping, value, parameterName);
			setDelegate(mapping);
		}

		@Override
		public void setJavaTypeMapping(JavaTypeMapping mapping)
		{
			super.setJavaTypeMapping(mapping);
			setDelegate(mapping);
		}

		private void setDelegate(JavaTypeMapping mapping) {
			if (mapping.getJavaTypeForDatastoreMapping(0).equals(ClassNameConstants.JAVA_LANG_STRING))
			{
				delegate = new StringLiteral(stmt, mapping,
				    (getValue() != null ? EnumHelper.toData((Enum<?>)getValue()) : null), parameterName);
			}
			else
			{
				delegate = new IntegerLiteral(stmt, mapping,
				    (getValue() != null ? EnumHelper.toData((Enum<?>)getValue()) : null), parameterName);
			}
		}
	}
	'''
	)
	'''
	'''
}

/*
		This is hopefully a temporary workaround for DataNucleus.
		DataNucleus is not generating primary keys on manytomany jointables
 */
def static String testDdl(Application it) {
	'''
	«val manyToManyRelations = it.resolveManyToManyRelations(true)»
	'''
	fileOutput("dbunit/ddl_additional.sql", 'TO_GEN_RESOURCES_TEST', '''
		«it.manyToManyRelations.forEach[OracleDDLTmpl::manyToManyPrimaryKey(it)]»
	'''
	)
	'''
	'''
}
}
