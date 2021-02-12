package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.expression.fts.ExpressionFtsQuery;
import org.sculptor.framework.domain.expression.fts.HighlightOptions;

public interface ExpressionString<T> extends ExpressionCast<T> {
	// String
	ExpressionString<T> coalesce(Object value);

	ExpressionString<T> nvl(Object value);

	ExpressionString<T> nullif(Object value);

	ExpressionString<T> prepend(Object value);

	ExpressionString<T> append(Number num);

	ExpressionString<T> append(String value);

	ExpressionString<T> append(Expression<T> property);

	ExpressionString<T> join(String separator, Expression<T>... properties);

	ExpressionString<T> leftPad(int length, String value);

	ExpressionString<T> rightPad(int length, String value);

	ExpressionNumeric<T> length();

	ExpressionNumeric<T> indexOf(String pattern);

	ExpressionNumeric<T> indexOf(String pattern, int from);

	ExpressionString<T> toLower();

	ExpressionString<T> toUpper();

	ExpressionString<T> substring(int from);

	ExpressionString<T> substring(int from, int to);

	ExpressionString<T> substring(Expression<T> from);

	ExpressionString<T> substring(Expression<T> from, Expression<T> to);

	ExpressionString<T> substring(int from, Expression<T> to);

	ExpressionString<T> substring(Expression<T> from, int to);

	ExpressionString<T> left(int to);

	ExpressionString<T> left(Expression<T> to);

	ExpressionString<T> right(int from);

	ExpressionString<T> right(Expression<T> from);

	ExpressionString<T> trimBoth();

	ExpressionString<T> trimLeading();

	ExpressionString<T> trimTrailing();

	ExpressionString<T> trimBoth(char t);

	ExpressionString<T> trimLeading(char t);

	ExpressionString<T> trimTrailing(char t);

	ExpressionString<T> maxAsString();

	ExpressionString<T> minAsString();

	ExpressionString<T> ftsHighlight(String query);

	ExpressionString<T> ftsHighlight(ExpressionFtsQuery query);

	ExpressionString<T> ftsHighlight(String query, HighlightOptions options);

	ExpressionString<T> ftsHighlight(ExpressionFtsQuery query, HighlightOptions options);

	ExpressionString<T> ftsHighlight(String language, String query);

	ExpressionString<T> ftsHighlight(String language, ExpressionFtsQuery query);

	ExpressionString<T> ftsHighlight(String language, String query, HighlightOptions options);

	ExpressionString<T> ftsHighlight(String language, ExpressionFtsQuery query, HighlightOptions options);
}
