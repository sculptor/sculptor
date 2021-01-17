package org.sculptor.framework.domain.expression;

public interface CaseWhen<T> {
	CaseCondition<T> when();

	CaseCondition<T> when(Expression<T> condition);
}
