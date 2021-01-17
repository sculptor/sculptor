package org.sculptor.framework.domain.expression;

public interface CaseRoot<T> extends CaseWhen<T> {
	ComplexExpression<T> otherwise();

	ComplexExpression<T> otherwise(Number result);

	ComplexExpression<T> otherwise(String result);

	ComplexExpression<T> otherwise(java.util.Date result);

	ComplexExpression<T> otherwise(Expression<T> result);

	ComplexExpression<T> end();
}
