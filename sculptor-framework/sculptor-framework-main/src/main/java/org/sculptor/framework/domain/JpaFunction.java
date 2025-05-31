package org.sculptor.framework.domain;

import org.sculptor.framework.domain.expression.ExpressionConverter;

import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;

public interface JpaFunction {
	public Expression prepareFunction(CriteriaBuilder cb, Expression left, ExpressionConverter ec);
}
