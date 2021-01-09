package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.Property;

public interface PredicateExpression<T> {
	//		PredicateExpression<T> fetchLazy();
//		PredicateExpression<T> fetchEager();
	ExpressionNumeric or(Property from);

	ExpressionNumeric and(Property from);
}
