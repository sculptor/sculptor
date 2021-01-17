package org.sculptor.framework.domain.expression;

public interface CaseConditionRoot<T> {
	CaseWhen<T> not();

	CaseWhen<T> and();

	CaseWhen<T> or();

	CaseWhen<T> lbrace();

	CaseConditionRoot<T> rbrace();

	CaseRoot<T> than();

	CaseRoot<T> than(String result);

	CaseRoot<T> than(Number result);

	CaseRoot<T> than(java.util.Date result);

	CaseRoot<T> than(Expression<T> result);
}
