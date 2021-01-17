package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.JpaFunction;

public interface ExpressionCast<T> extends Expression<T> {
	ExpressionNumeric<T> asInteger();

	ExpressionNumeric<T> asLong();

	ExpressionNumeric<T> asFloat();

	ExpressionNumeric<T> asDouble();

	ExpressionNumeric<T> asBigInteger();

	ExpressionNumeric<T> asBigDecimal();

	ExpressionDate<T> asDate();

	ExpressionDate<T> asTime();

	ExpressionDate<T> asTimestamp();

	ExpressionString<T> asString();

	ComplexExpression<T> function(String name, Class resultType, Object... arguments);

	ComplexExpression<T> function(JpaFunction jpaFunction);

	CaseWhen<T> caseExpr();
}
