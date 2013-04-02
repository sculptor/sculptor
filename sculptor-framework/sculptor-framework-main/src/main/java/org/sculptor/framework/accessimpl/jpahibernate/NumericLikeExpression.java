package org.sculptor.framework.accessimpl.jpahibernate;

import org.hibernate.Criteria;
import org.hibernate.EntityMode;
import org.hibernate.HibernateException;
import org.hibernate.criterion.CriteriaQuery;
import org.hibernate.criterion.Criterion;
import org.hibernate.dialect.Dialect;
import org.hibernate.dialect.PostgreSQLDialect;
import org.hibernate.engine.TypedValue;

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
		if ( dialect instanceof PostgreSQLDialect ) {
			return columns[0] + "::text "+ (ignoreCase ? "ilike" : "like") +" ?";
		} else {
			return (ignoreCase ? dialect.getLowercaseFunction() + '(' + columns[0] + ")" : columns[0]) + " like ?";
		}
	}
}