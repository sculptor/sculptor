package org.sculptor.framework.domain.expression.fts;

import org.sculptor.framework.domain.expression.Expression;
import org.sculptor.framework.domain.expression.ExpressionNumeric;

public interface ExpressionFtsQuery<T> extends Expression<T> {
	ExpressionFtsQuery<T> andFtsQuery(ExpressionFtsQuery query);
	ExpressionFtsQuery<T> andFtsQuery(String query);
	ExpressionFtsQuery<T> orFtsQuery(ExpressionFtsQuery query);
	ExpressionFtsQuery<T> orFtsQuery(String query);
	ExpressionFtsQuery<T> notFtsQuery();
	ExpressionNumeric<T> ftsNumNode();
}
