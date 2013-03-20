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

import javax.inject.Inject
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application
import sculptormetamodel.Enum
import sculptormetamodel.Module
import sculptormetamodel.Reference

class HibernateTmpl {

	@Inject extension DbHelper dbHelper
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

def String hibernate(Application it) {
	'''
	«IF isJpa1()»
		«it.modules.map[enumTypedefFile(it)].join()»e
		«IF isJpaAnnotationToBeGenerated()»
			«hibenateCfgFile(it)»
		«ENDIF»
	«ENDIF»
	«IF isJpa2() && it.containsNonOrdinaryEnums()»
			«enumType(it)»
	«ENDIF»
	'''
}

def String header(Object it) {
	'''
	<?xml version="1.0"?>
	<!DOCTYPE hibernate-mapping PUBLIC
		"-//Hibernate/Hibernate Mapping DTD//EN"
		"http://hibernate.sourceforge.net/hibernate-mapping-3.0.dtd" >

	<hibernate-mapping>
	'''
}

def String enumTypedefFile(Module it) {
	val enums = it.domainObjects.filter(d | d instanceof sculptormetamodel.Enum)
	if (!enums.isEmpty) {
		fileOutput(it.getResourceDir("hibernate") + it.getEnumTypeDefFileName(), OutputSlot::TO_GEN_RESOURCES, '''
					«header(it) »
					«enums.map[e | enumTypedef(e as Enum)]»
				</hibernate-mapping>
		'''
		)
	}
}

def String enumTypedef(Enum it) {
	val identifierAttribute  = it.getIdentifierAttribute()
	'''
		<typedef name="«name»"
			class="«enumUserTypeClass()»">
		<param name="enumClass">«getDomainPackage()».«name»</param>
		«IF identifierAttribute != null »
		<param name="identifierMethod">«identifierAttribute.getGetAccessor()»</param>
		<param name="valueOfMethod">from«identifierAttribute.name.toFirstUpper()»</param>
		«ENDIF»
		</typedef>
	'''
}

def String enumReference(Reference it, String dbColumnPrefix) {
	'''
		<property name="«name»" type="«to.name»" «IF !nullable» not-null="true"«ENDIF»  «IF (getDatabaseName(dbColumnPrefix, it)) != name.toUpperCase()»column="«getDatabaseName(dbColumnPrefix, it)»"«ENDIF»/>
	'''
}

def String hibenateCfgFile(Application it) {
	fileOutput("hibernate.cfg.xml", OutputSlot::TO_GEN_RESOURCES, '''
	<!DOCTYPE hibernate-configuration PUBLIC "-//Hibernate/Hibernate Configuration DTD 3.0//EN"
		"http://hibernate.sourceforge.net/hibernate-configuration-3.0.dtd">

	<hibernate-configuration>
	    <session-factory>
	    «hibenateCfgMappedResources(it)»
		/*extension point for additional configuration of the Hibernate SessionFactory */
		<!-- add additional configuration properties in SpecialCases.xpt by "AROUND hibernateTmpl.hibenateCfgAdditions FOR Application" -->
	    «hibenateCfgAdditions(it)»
	    </session-factory>
	</hibernate-configuration>
	'''
	)
}

def String hibenateCfgMappedResources(Application it) {
	'''
	«it.modules.sortBy(e|e.name).map[hibenateCfgMappedResources(it)].join()»
	'''
}

def String hibenateCfgMappedResources(Module it) {
	'''
	/* set mapping of Hibernate Types here, can't be set in persistence.xml */
	«IF !domainObjects.filter[d | d instanceof Enum].isEmpty»
		<mapping resource="«it.getResourceDir("hibernate") + it.getEnumTypeDefFileName()»"/>
	«ENDIF»
	'''
}

/*extension point for additional configuration of the Hibernate SessionFactory */
def String hibenateCfgAdditions(Application it) {
	'''
	'''
}

def String enumType(Application it) {
	fileOutput(javaFileName(basePackage + ".util.EnumUserType"), OutputSlot::TO_GEN_SRC, '''
	package «basePackage».util;

	import java.sql.PreparedStatement;
	import java.sql.ResultSet;
	import java.sql.SQLException;
	import java.sql.Types;
	import java.util.Properties;

	import org.sculptor.framework.util.EnumHelper;
	import org.hibernate.HibernateException;
	«IF isJpaProviderHibernate4()»
	import org.hibernate.engine.spi.SessionImplementor;
	«ENDIF»
	import org.hibernate.type.EnumType;

	@SuppressWarnings("serial")
	public class EnumUserType ^extends EnumType {
		@Override
		public Object nullSafeGet(ResultSet rs, String[] names«IF isJpaProviderHibernate4()»,SessionImplementor session«ENDIF», Object owner)
			throws HibernateException, SQLException {
			Object object = rs.getObject(names[0]);
			if (rs.wasNull()) {
				return null;
			}
			return EnumHelper.toEnum(returnedClass(), object);
		}

		@SuppressWarnings("rawtypes")
		@Override
		public void nullSafeSet(PreparedStatement st, Object value, int index«IF isJpaProviderHibernate4()»,SessionImplementor session«ENDIF»)
			throws HibernateException, SQLException {
			if (value == null) {
				st.setNull(index, sqlTypes()[0]);
			} else {
				st.setObject(index, EnumHelper.toData((Enum) value), sqlTypes()[0]);
			}
		}

		@Override
		public void setParameterValues(Properties properties) {
			// set default type to varchar
			super.setParameterValues(properties);
			try {
				returnedClass().getMethod("fromValue",String.class);
				properties.setProperty(TYPE,properties.getProperty(TYPE, "" + Types.VARCHAR));
			} catch (Exception e) {
				properties.setProperty(TYPE,properties.getProperty(TYPE, "" + Types.INTEGER));
			}
			super.setParameterValues(properties);
		}
	}
	'''
	)
}
}
