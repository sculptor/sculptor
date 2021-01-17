package org.sculptor.framework.domain.expression;

import java.util.Collection;

public interface CaseCondition<T> {
	CaseConditionRoot<T> eq(Object value);

	CaseConditionRoot<T> ignoreCaseEq(Object value);

	CaseConditionRoot<T> eq(Expression<T> property);

	CaseConditionRoot<T> between(Object from, Object to);

	Between<T> between(Object from);

	CaseConditionRoot<T> lessThan(Object value);

	CaseConditionRoot<T> lessThanOrEqual(Object value);

	CaseConditionRoot<T> greaterThan(Object value);

	CaseConditionRoot<T> greaterThanOrEqual(Object value);

	CaseConditionRoot<T> lessThan(Expression<T> property);

	CaseConditionRoot<T> lessThanOrEqual(Expression<T> property);

	CaseConditionRoot<T> greaterThan(Expression<T> property);

	CaseConditionRoot<T> greaterThanOrEqual(Expression<T> property);

	CaseConditionRoot<T> like(Object value);

	CaseConditionRoot<T> ignoreCaseLike(Object value);

	CaseConditionRoot<T> in(Object... values);

	CaseConditionRoot<T> in(Collection<?> values);

	CaseConditionRoot<T> isNull();

	CaseConditionRoot<T> isNotNull();

	CaseConditionRoot<T> isEmpty();

	CaseConditionRoot<T> isNotEmpty();
}

