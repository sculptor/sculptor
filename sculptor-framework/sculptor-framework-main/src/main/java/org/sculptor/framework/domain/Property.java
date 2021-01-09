package org.sculptor.framework.domain;

import org.sculptor.framework.domain.expression.ComplexExpression;
import org.sculptor.framework.domain.expression.Expression;
import org.sculptor.framework.domain.expression.ExpressionNumeric;

import java.io.Serializable;

public interface Property<T> extends Serializable, Expression<T> {
	String getName();

	ComplexExpression<T> expr();
}
