package org.sculptor.framework.domain.expression;

import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.PropertyWithExpression;
import org.sculptor.framework.domain.expression.fts.ExpressionFtsQuery;

public class ExpressionBuilder {
	static LeafProperty emptyProp = new LeafProperty("", Expression.class);

	// Date
	public static <T> ExpressionDate<T> currentDate() {
		return ((PropertyWithExpression) emptyProp.expr()).currentDate();
	}

	public static <T> ExpressionDate<T> currentTime() {
		return ((PropertyWithExpression) emptyProp.expr()).currentTime();
	}

	public static <T> ExpressionDate<T> currentTimestamp() {
		return ((PropertyWithExpression) emptyProp.expr()).currentTimestamp();
	}

	public static <T> ExpressionFtsQuery<T> ftsQuery(String language, String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsQuery(language, query);
	}

	public static <T> ExpressionFtsQuery<T> ftsQuery(String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsQuery(query);
	}

	public static <T> ExpressionFtsQuery<T> ftsPlainQuery(String language, String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsPlainQuery(language, query);
	}

	public static <T> ExpressionFtsQuery<T> ftsPlainQuery(String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsPlainQuery(query);
	}

	public static <T> ExpressionFtsQuery<T> ftsPhraseQuery(String language, String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsPhraseQuery(language, query);
	}

	public static <T> ExpressionFtsQuery<T> ftsPhraseQuery(String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsPhraseQuery(query);
	}

	public static <T> ExpressionFtsQuery<T> ftsWebQuery(String language, String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsWebQuery(language, query);
	}

	public static <T> ExpressionFtsQuery<T> ftsWebQuery(String query) {
		return ((PropertyWithExpression) emptyProp.expr()).ftsWebQuery(query);
	}

}
