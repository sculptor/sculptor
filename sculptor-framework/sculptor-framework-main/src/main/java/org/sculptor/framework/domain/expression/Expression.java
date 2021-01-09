package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.PropertyWithExpression;

public interface Expression<T> {
	static LeafProperty emptyProp = new LeafProperty("", Expression.class);

	// Date
	static <T> ExpressionDate<T> currentDate() {
		return ((PropertyWithExpression) emptyProp.expr()).currentDate();
	}
	static <T> ExpressionDate<T> currentTime() {
		return ((PropertyWithExpression) emptyProp.expr()).currentTime();
	}
	static <T> ExpressionDate<T> currentTimestamp() {
		return ((PropertyWithExpression) emptyProp.expr()).currentTimestamp();
	}

	public static final String PREVIOUS_RESULT = "PREV_RESULT";

	// Generic function
//	Expression<T> function(String name, Class<?> resultType, Object... arguments);

//	PredicateExpression<T> eq(Object value);
//	PredicateExpression<T> ignoreCaseEq(Object value);
//	PredicateExpression<T> eq(Property<T> property);
//	PredicateExpression<T> between(Object value1, Object value2);
//	PredicateExpression<T> between(Object value1);
//	PredicateExpression<T> lessThan(Object value);
//	PredicateExpression<T> lessThanOrEqual(Object value);
//	PredicateExpression<T> greaterThan(Object value);
//	PredicateExpression<T> greaterThanOrEqual(Object value);
//	PredicateExpression<T> lessThan(Property<T> property);
//	PredicateExpression<T> lessThanOrEqual(Property<T> property);
//	PredicateExpression<T> greaterThan(Property<T> property);
//	PredicateExpression<T> greaterThanOrEqual(Property<T> property);
//	PredicateExpression<T> like(Object value);
//	PredicateExpression<T> ignoreCaseLike(Object value);
//	PredicateExpression<T> in(Object... values);
//	PredicateExpression<T> in(Collection<?> values);
//	PredicateExpression<T> isNull();
//	PredicateExpression<T> isNotNull();
//	PredicateExpression<T> isEmpty();
//	PredicateExpression<T> isNotEmpty();
//
//	 Condition
//	SimpleCaseWhen<T> caseExpr();
//
//	interface SimpleCaseWhen<T> {
//		public SimpleCaseThan<T> when(PredicateExpression<T> condition);
//		SimpleCaseWhen<T> otherwise(Number result);
//		SimpleCaseWhen<T> otherwise(String result);
//		SimpleCaseWhen<T> otherwise(Property<T> result);
//		Expression<T> end();
//	}
//
//	interface SimpleCaseThan<T> {
//		SimpleCaseWhen<T> than(Expression<T> result);
//		SimpleCaseWhen<T> than(String result);
//		SimpleCaseWhen<T> than(Number result);
//	}

}
