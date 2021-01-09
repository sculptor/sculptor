package org.sculptor.framework.domain;

import org.sculptor.framework.domain.expression.ExpressionConverter;

import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.Expression;

public interface JpaFunction {
	public Expression prepareFunction(CriteriaBuilder cb, Expression left, ExpressionConverter ec);
}
