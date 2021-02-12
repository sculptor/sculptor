package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.PropertyWithExpression;
import org.sculptor.framework.domain.expression.fts.ExpressionFtsQuery;

public interface Expression<T> {
	public static final String PREVIOUS_RESULT = "PREV_RESULT";
}
