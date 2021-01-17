package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.Property;
import org.sculptor.framework.domain.PropertyWithExpression;

import java.util.Date;

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
}
