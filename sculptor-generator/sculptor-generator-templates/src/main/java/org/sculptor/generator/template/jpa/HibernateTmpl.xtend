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
package org.sculptor.generator.template.jpa

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

@ChainOverridable
class HibernateTmpl {

	@Inject extension Helper helper
	@Inject extension Properties properties

def String hibernate(Application it) {
	'''
	«IF it.containsNonOrdinaryEnums()»
		«enumType(it)»
	«ENDIF»
	'''
}

def String enumType(Application it) {
	fileOutput(javaFileName(basePackage + ".util.EnumUserType"), OutputSlot.TO_GEN_SRC, '''
	package «basePackage».util;

/// Sculptor code formatter imports ///

	@SuppressWarnings("serial")
	public class EnumUserType extends org.hibernate.type.EnumType {

		@SuppressWarnings("unchecked")
		@Override
		public Object nullSafeGet(java.sql.ResultSet rs, String[] names«IF jpaProviderHibernate», org.hibernate.engine.spi.SharedSessionContractImplementor session«ENDIF», Object owner)
			throws org.hibernate.HibernateException, java.sql.SQLException {
			Object object = rs.getObject(names[0]);
			if (rs.wasNull()) {
				return null;
			}
			return org.sculptor.framework.util.EnumHelper.toEnum(returnedClass(), object);
		}

		@SuppressWarnings("rawtypes")
		@Override
		public void nullSafeSet(java.sql.PreparedStatement st, Object value, int index«IF jpaProviderHibernate», org.hibernate.engine.spi.SharedSessionContractImplementor session«ENDIF»)
			throws org.hibernate.HibernateException, java.sql.SQLException {
			if (value == null) {
				st.setNull(index, java.sql.Types.VARCHAR);
			} else {
				st.setObject(index, org.sculptor.framework.util.EnumHelper.toData((Enum) value), java.sql.Types.VARCHAR);
			}
		}

		@SuppressWarnings("unchecked")
		@Override
		public void setParameterValues(java.util.Properties properties) {
			super.setParameterValues(properties);
			if (org.sculptor.framework.util.EnumHelper.isIdentifierAttributeOfTypeString((Class<? extends Enum<?>>) returnedClass())) {
				properties.setProperty(TYPE, properties.getProperty(TYPE, "" + java.sql.Types.VARCHAR));
			} else {
				properties.setProperty(TYPE, properties.getProperty(TYPE, "" + java.sql.Types.INTEGER));
			}
			super.setParameterValues(properties);
		}
	}
	'''
	)
}

}
