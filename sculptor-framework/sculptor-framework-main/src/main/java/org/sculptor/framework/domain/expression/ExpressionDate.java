package org.sculptor.framework.domain.expression;

public interface ExpressionDate<T> extends ExpressionCast<T> {
	// Date part extraction
	ExpressionNumeric<T> second();

	ExpressionNumeric<T> minute();

	ExpressionNumeric<T> hour();

	ExpressionNumeric<T> day();

	ExpressionNumeric<T> week();

	ExpressionNumeric<T> month();

	ExpressionNumeric<T> quarter();

	ExpressionNumeric<T> year();

	ExpressionNumeric<T> dayOfWeek();

	ExpressionNumeric<T> dayOfYear();
}
