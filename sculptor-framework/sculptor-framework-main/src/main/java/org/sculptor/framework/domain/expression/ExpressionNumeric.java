package org.sculptor.framework.domain.expression;

public interface ExpressionNumeric<T> extends ExpressionCast<T> {
	ExpressionNumeric<T> abs();

	ExpressionNumeric<T> neg();

	ExpressionNumeric<T> sqrt();

	ExpressionNumeric<T> add(Number num);

	ExpressionNumeric<T> add(Expression<T> expr);

	ExpressionNumeric<T> substract(Number num);

	ExpressionNumeric<T> substract(Expression<T> expr);

	ExpressionNumeric<T> multiply(Number num);

	ExpressionNumeric<T> multiply(Expression<T> expr);

	ExpressionNumeric<T> divide(Number num);

	ExpressionNumeric<T> divide(Expression<T> expr);

	ExpressionNumeric<T> mod(Number num);

	ExpressionNumeric<T> mod(Expression<T> expr);

	ExpressionNumeric<T> max();

	ExpressionNumeric<T> min();

	ExpressionNumeric<T> avg();

	ExpressionNumeric<T> sum();

	ExpressionNumeric<T> sumAsLong();

	ExpressionNumeric<T> sumAsDouble();
}
