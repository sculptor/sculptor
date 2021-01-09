package org.sculptor.framework.domain.expression;

public interface ComplexExpression<T> extends ExpressionString<T>, ExpressionNumeric<T>, ExpressionDate<T> {
	// No possible with any function as parameter - SQL limitation
	// Have to be as root function ONLY

	ExpressionNumeric<T> count();

	ExpressionNumeric<T> countDistinct();
}
