package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.JpaFunction;
import org.sculptor.framework.domain.expression.fts.ExpressionFtsVector;

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

	ExpressionFtsVector<T> asFtsVector();

	ExpressionFtsVector<T> asFtsVector(String language);

	ComplexExpression<T> function(String name, Class resultType, Object... arguments);

	ComplexExpression<T> function(JpaFunction jpaFunction);

	CaseWhen<T> caseExpr();
}
