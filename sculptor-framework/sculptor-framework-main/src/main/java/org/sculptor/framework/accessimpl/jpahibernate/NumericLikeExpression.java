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
package org.sculptor.framework.accessimpl.jpahibernate;

import org.hibernate.Criteria;
import org.hibernate.EntityMode;
import org.hibernate.HibernateException;
import org.hibernate.criterion.CriteriaQuery;
import org.hibernate.criterion.Criterion;
import org.hibernate.dialect.Dialect;
import org.hibernate.dialect.PostgreSQL82Dialect;
import org.hibernate.engine.spi.TypedValue;

public class NumericLikeExpression implements Criterion {
	private static final long serialVersionUID = 1L;

	private Object value;
	private String propertyName;
	private boolean ignoreCase;

	public NumericLikeExpression(String propertyName, String value, boolean ignoreCase) {
		this.value = ignoreCase ? value.toLowerCase() : value;
		this.propertyName=propertyName;
		this.ignoreCase=ignoreCase;
	}

	@Override
	public TypedValue[] getTypedValues(Criteria criteria,
			CriteriaQuery criteriaQuery) throws HibernateException {
		return new TypedValue[] { new TypedValue(
				new org.hibernate.type.StringType(), value, EntityMode.POJO) };
	}

	@Override
	public String toSqlString(Criteria criteria, CriteriaQuery criteriaQuery) throws HibernateException {
		String[] columns = criteriaQuery.getColumnsUsingProjection(criteria, propertyName);
		if (columns.length != 1) {
			throw new HibernateException("ilike may only be used with single-column properties");
		}

		Dialect dialect = criteriaQuery.getFactory().getDialect();
		if ( dialect instanceof PostgreSQL82Dialect ) {
			return columns[0] + "::text "+ (ignoreCase ? "ilike" : "like") +" ?";
		} else {
			return (ignoreCase ? dialect.getLowercaseFunction() + '(' + columns[0] + ")" : columns[0]) + " like ?";
		}
	}
}