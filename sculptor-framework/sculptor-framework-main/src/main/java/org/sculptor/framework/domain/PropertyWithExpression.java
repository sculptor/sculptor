package org.sculptor.framework.domain;

import org.sculptor.framework.domain.expression.*;
import org.sculptor.framework.domain.expression.fts.ExpressionFtsQuery;
import org.sculptor.framework.domain.expression.fts.ExpressionFtsVector;
import org.sculptor.framework.domain.expression.fts.HighlightOptions;

import javax.persistence.criteria.CriteriaBuilder;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

import static org.sculptor.framework.domain.expression.fts.ExpressionFtsVector.DEFAULT_LANGUAGE;

public class PropertyWithExpression<T> implements ComplexExpression<T>, ExpressionFtsVector<T>, ExpressionFtsQuery<T> {
	Property<T> base;
	List<JpaFunction> functions = new ArrayList<>();

	PropertyWithExpression(Property<T> base) {
		this.base = base;
	}

	PropertyWithExpression(PropertyWithExpression<T> e) {
		this.base = e.base;
		this.functions = new ArrayList(e.functions);
	}

	public Property<T> getBase() {
		return base;
	}

	public List<JpaFunction> getFunctions() {
		return functions;
	}

	@Override
	public ComplexExpression<T> function(String name, Class resultType, Object... arguments) {
		functions.add((cb, left, ec) -> {
			for (int i = 0; i < arguments.length; i++) {
				if (arguments[i] == Expression.PREVIOUS_RESULT) {
					arguments[i] = left;
				}
			}
			return cb.function(name, resultType, ec.convertObjectArray(arguments));
		});
		return this;
	}

	@Override
	public ComplexExpression<T> function(JpaFunction jpaFunction) {
		functions.add(jpaFunction);
		return this;
	}

	@Override
	public ExpressionNumeric<T> abs() {
		functions.add((cb, left, ec) -> cb.abs(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> neg() {
		functions.add((cb, left, ec) -> cb.neg(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> sqrt() {
		functions.add((cb, left, ec) -> cb.sqrt(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> add(Number num) {
		functions.add((cb, left, ec) -> cb.sum(left, num));
		return this;
	}

	@Override
	public ExpressionNumeric<T> add(Expression<T> expr) {
		functions.add((cb, left, ec) -> cb.sum(left, ec.convertObject(expr)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> substract(Number num) {
		functions.add((cb, left, ec) -> cb.diff(left, ec.convertObject(num)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> substract(Expression<T> expr) {
		functions.add((cb, left, ec) -> cb.diff(left, ec.convertObject(expr)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> divide(Number num) {
		functions.add((cb, left, ec) -> cb.quot(left, ec.convertObject(num)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> divide(Expression<T> expr) {
		functions.add((cb, left, ec) -> cb.quot(left, ec.convertObject(expr)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> multiply(Number num) {
		functions.add((cb, left, ec) -> cb.prod(left, ec.convertObject(num)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> multiply(Expression<T> expr) {
		functions.add((cb, left, ec) -> cb.prod(left, ec.convertObject(expr)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> mod(Number num) {
		functions.add((cb, left, ec) -> cb.mod(left, ec.convertObject(num)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> mod(Expression<T> expr) {
		functions.add((cb, left, ec) -> cb.mod(left, ec.convertObject(expr)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> asInteger() {
		functions.add((cb, left, ec) -> left.as(Integer.class));
		return this;
	}

	@Override
	public ExpressionNumeric<T> asLong() {
		functions.add((cb, left, ec) -> left.as(Long.class));
		return this;
	}

	@Override
	public ExpressionNumeric<T> asFloat() {
		functions.add((cb, left, ec) -> left.as(Float.class));
		return this;
	}

	@Override
	public ExpressionNumeric<T> asDouble() {
		functions.add((cb, left, ec) -> left.as(Double.class));
		return this;
	}

	@Override
	public ExpressionNumeric<T> asBigInteger() {
		functions.add((cb, left, ec) -> left.as(BigInteger.class));
		return this;
	}

	@Override
	public ExpressionNumeric<T> asBigDecimal() {
		functions.add((cb, left, ec) -> left.as(BigDecimal.class));
		return this;
	}

	@Override
	public ExpressionString<T> asString() {
		functions.add((cb, left, ec) -> left.as(String.class));
		return this;
	}

	@Override
	public ExpressionDate<T> asDate() {
		functions.add((cb, left, ec) -> left.as(Date.class));
		return this;
	}

	@Override
	public ExpressionDate<T> asTime() {
		functions.add((cb, left, ec) -> left.as(Time.class));
		return this;
	}

	@Override
	public ExpressionDate<T> asTimestamp() {
		functions.add((cb, left, ec) -> left.as(Timestamp.class));
		return this;
	}

	@Override
	public ExpressionNumeric<T> second() {
		functions.add((cb, left, ec) -> cb.function("second", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> minute() {
		functions.add((cb, left, ec) -> cb.function("minute", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> hour() {
		functions.add((cb, left, ec) -> cb.function("hour", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> day() {
		functions.add((cb, left, ec) -> cb.function("day", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> week() {
		functions.add((cb, left, ec) -> cb.function("week", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> month() {
		functions.add((cb, left, ec) -> cb.function("month", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> quarter() {
		functions.add((cb, left, ec) -> cb.function("quarter", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> year() {
		functions.add((cb, left, ec) -> cb.function("year", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> dayOfWeek() {
		functions.add((cb, left, ec) -> cb.function("dow", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> dayOfYear() {
		functions.add((cb, left, ec) -> cb.function("doy", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionString<T> coalesce(Object value) {
		functions.add((cb, left, ec) -> cb.coalesce(left, ec.convertObject(value)));
		return this;
	}

	@Override
	public ExpressionString<T> nvl(Object value) {
		functions.add((cb, left, ec) -> cb.coalesce(left, ec.convertObject(value)));
		return this;
	}

	@Override
	public ExpressionString<T> nullif(Object value) {
		functions.add((cb, left, ec) -> cb.nullif(left, (Expression<?>) ec.convertObject(value)));
		return this;
	}

	@Override
	public ExpressionString<T> prepend(Object value) {
		functions.add((cb, left, ec) -> cb.concat(ec.convertObject(value), left));
		return this;
	}

	@Override
	public ExpressionString<T> append(Number num) {
		functions.add((cb, left, ec) -> cb.concat(left, num.toString()));
		return this;
	}

	@Override
	public ExpressionString<T> append(String value) {
		functions.add((cb, left, ec) -> cb.concat(left, value));
		return this;
	}

	@Override
	public ExpressionString<T> append(Expression<T> property) {
		functions.add((cb, left, ec) -> cb.concat(left, ec.convertObject(property)));
		return this;
	}

	@Override
	public ExpressionString<T> join(String separator, Expression<T>... properties) {
		functions.add((cb, left, ec) -> {
			Object[] args = new Object[properties.length + 2];
			args[0] = separator;
			args[1] = left;
			System.arraycopy(properties, 0, args, 2, properties.length);
			javax.persistence.criteria.Expression[] exprs = ec.convertObjectArray(args);
			return cb.function("join", String.class, exprs);
		});
		return this;
	}

	@Override
	public ExpressionString<T> leftPad(int length, String value) {
		functions.add((cb, left, ec) -> {
			javax.persistence.criteria.Expression[] expr = new javax.persistence.criteria.Expression[] {
					left,
					cb.literal(length),
					cb.literal(value)
			};
			return cb.function("lpad", String.class, expr);
		});
		return this;
	}

	@Override
	public ExpressionString<T> rightPad(int length, String value) {
		functions.add((cb, left, ec) -> {
			javax.persistence.criteria.Expression[] expr = new javax.persistence.criteria.Expression[] {
					left,
					cb.literal(length),
					cb.literal(value)
			};
			return cb.function("rpad", String.class, expr);
		});
		return this;
	}

	@Override
	public ExpressionNumeric<T> length() {
		functions.add((cb, left, ec) -> cb.length(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> indexOf(String pattern) {
		functions.add((cb, left, ec) -> cb.locate(left, pattern));
		return this;
	}

	@Override
	public ExpressionNumeric<T> indexOf(String pattern, int from) {
		functions.add((cb, left, ec) -> cb.locate(left, pattern, from));
		return this;
	}

	@Override
	public ExpressionString<T> toLower() {
		functions.add((cb, left, ec) -> cb.lower(left));
		return this;
	}

	@Override
	public ExpressionString<T> toUpper() {
		functions.add((cb, left, ec) -> cb.upper(left));
		return this;
	}

	// Standard CriteriaBuilder.substring() is broken (WARN when using 2 arguments only)
	@Override
	public ExpressionString<T> substring(int from) {
		functions.add((cb, left, ec) -> cb.function("substr", String.class, left, cb.literal(from)));
		return this;
	}

	@Override
	public ExpressionString<T> substring(int from, int to) {
		functions.add((cb, left, ec) -> cb.function("substr", String.class, left, cb.literal(from), cb.literal(to)));
		return this;
	}

	@Override
	public ExpressionString<T> substring(Expression<T> from) {
		functions.add((cb, left, ec) -> cb.substring((javax.persistence.criteria.Expression<String>) left
				, ec.convertObject(from)));
		return this;
	}

	@Override
	public ExpressionString<T> substring(Expression<T> from, Expression<T> to) {
		functions.add((cb, left, ec) -> cb.substring((javax.persistence.criteria.Expression<String>) left
				, ec.convertObject(from), ec.convertObject(to)));
		return this;
	}

	@Override
	public ExpressionString<T> substring(int from, Expression<T> to) {
		functions.add((cb, left, ec) -> cb.substring((javax.persistence.criteria.Expression<String>) left
				, ec.convertObject(from), ec.convertObject(to)));
		return this;
	}

	@Override
	public ExpressionString<T> substring(Expression<T> from, int to) {
		functions.add((cb, left, ec) -> cb.substring((javax.persistence.criteria.Expression<String>) left
				, ec.convertObject(from), ec.convertObject(to)));
		return this;
	}

	@Override
	public ExpressionString<T> left(int to) {
		functions.add((cb, left, ec) -> cb.substring(left, 1, to));
		return this;
	}

	@Override
	public ExpressionString<T> left(Expression<T> to) {
		functions.add((cb, left, ec) -> cb.substring(left, cb.literal(1), ec.convertObject(to)));
		return this;
	}

	@Override
	public ExpressionString<T> right(int from) {
		functions.add((cb, left, ec) -> cb.function("right", String.class, left, cb.literal(from)));
		return this;
	}

	@Override
	public ExpressionString<T> right(Expression<T> from) {
		functions.add((cb, left, ec) -> cb.function("right", String.class, left, ec.convertObject(from)));
		return this;
	}

	@Override
	public ExpressionString<T> trimBoth() {
		functions.add((cb, left, ec) -> cb.trim(CriteriaBuilder.Trimspec.BOTH, left));
		return this;
	}

	@Override
	public ExpressionString<T> trimLeading() {
		functions.add((cb, left, ec) -> cb.trim(CriteriaBuilder.Trimspec.LEADING, left));
		return this;
	}

	@Override
	public ExpressionString<T> trimTrailing() {
		functions.add((cb, left, ec) -> cb.trim(CriteriaBuilder.Trimspec.TRAILING, left));
		return this;
	}

	@Override
	public ExpressionString<T> trimBoth(char t) {
		functions.add((cb, left, ec) -> cb.trim(CriteriaBuilder.Trimspec.BOTH, t, left));
		return this;
	}

	@Override
	public ExpressionString<T> trimLeading(char t) {
		functions.add((cb, left, ec) -> cb.trim(CriteriaBuilder.Trimspec.LEADING, t, left));
		return this;
	}

	@Override
	public ExpressionString<T> trimTrailing(char t) {
		functions.add((cb, left, ec) -> cb.trim(CriteriaBuilder.Trimspec.TRAILING, t, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> max() {
		functions.add((cb, left, ec) -> cb.max(left));
		return this;
	}

	@Override
	public ExpressionString<T> maxAsString() {
		functions.add((cb, left, ec) -> cb.greatest(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> min() {
		functions.add((cb, left, ec) -> cb.min(left));
		return this;
	}

	@Override
	public ExpressionString<T> minAsString() {
		functions.add((cb, left, ec) -> cb.least(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> avg() {
		functions.add((cb, left, ec) -> cb.avg(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> sum() {
		functions.add((cb, left, ec) -> cb.sum(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> sumAsLong() {
		functions.add((cb, left, ec) -> cb.sumAsLong(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> sumAsDouble() {
		functions.add((cb, left, ec) -> cb.sumAsDouble(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> count() {
		functions.add((cb, left, ec) -> cb.count(left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> countDistinct() {
		functions.add((cb, left, ec) -> cb.countDistinct(left));
		return this;
	}

	@Override
	public CaseWhen<T> caseExpr() {
		CaseExpressionBuilder<T> caseExpressionBuilder = new CaseExpressionBuilder(this);
		functions.add(caseExpressionBuilder);
		return caseExpressionBuilder;
	}

	// Full text search support for PostgreSQL
	@Override
	public ExpressionFtsVector<T> asFtsVector() {
		functions.add((cb, left, ec) -> cb.function("toFtsVector", String.class, cb.literal(DEFAULT_LANGUAGE), left));
		return this;
	}

	@Override
	public ExpressionFtsVector<T> asFtsVector(String lang) {
		functions.add((cb, left, ec) -> cb.function("toFtsVector", String.class, cb.literal(lang), left));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(ExpressionFtsQuery query) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(DEFAULT_LANGUAGE)
				, left
				, ec.convertObject(query)
				, cb.literal("")));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(String query) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(DEFAULT_LANGUAGE)
				, left
				, cb.function("ftsQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query))
				, cb.literal("")));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(ExpressionFtsQuery query, HighlightOptions options) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(DEFAULT_LANGUAGE)
				, left
				, ec.convertObject(query)
				, cb.literal(options.toSpecString())));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(String query, HighlightOptions options) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(DEFAULT_LANGUAGE)
				, left
				, cb.function("ftsQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query))
				, cb.literal(options.toSpecString())));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(String language, ExpressionFtsQuery query) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(language)
				, left
				, ec.convertObject(query)
				, cb.literal("")));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(String language, String query) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(language)
				, left
				, cb.function("ftsQuery", String.class, cb.literal(language), cb.literal(query))
				, cb.literal("")));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(String language, ExpressionFtsQuery query, HighlightOptions options) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(language)
				, left
				, ec.convertObject(query)
				, cb.literal(options.toSpecString())));
		return this;
	}

	@Override
	public ExpressionString<T> ftsHighlight(String language, String query, HighlightOptions options) {
		functions.add((cb, left, ec) -> cb.function("ftsHighlight", String.class
				, cb.literal(language)
				, left
				, cb.function("ftsQuery", String.class, cb.literal(language), cb.literal(query))
				, cb.literal(options.toSpecString())));
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query) {
		functions.add((cb, left, ec) -> cb.function("ftsRank", String.class, left, ec.convertObject(query)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query, int normalization) {
		functions.add((cb, left, ec) -> cb.function("ftsRank", String.class, left, ec.convertObject(query), cb.literal(normalization)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD) {
		functions.add((cb, left, ec) -> {
			String rank = "{" + weightD + "," + weightC + "," + weightB + "," + weightA + "}";
			return cb.function("ftsRank", String.class, cb.literal(rank), left
					, ec.convertObject(query), cb.literal(ExpressionFtsVector.NORM_DEFAULT));
		});
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRank(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD, int normalization) {
		functions.add((cb, left, ec) -> {
			String rank = "{" + weightD + "," + weightC + "," + weightB + "," + weightA + "}";
			return cb.function("ftsRank", String.class, cb.literal(rank), left, ec.convertObject(query), cb.literal(normalization));
		});
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query) {
		functions.add((cb, left, ec) -> cb.function("ftsRankCd", String.class, left, ec.convertObject(query)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query, int normalization) {
		functions.add((cb, left, ec) -> cb.function("ftsRankCd", String.class, left, ec.convertObject(query), cb.literal(normalization)));
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD) {
		functions.add((cb, left, ec) -> {
			String rank = "{" + weightD + "," + weightC + "," + weightB + "," + weightA + "}";
			return cb.function("ftsRankCd", String.class, cb.literal(rank), left, ec.convertObject(query));
		});
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsRankCd(ExpressionFtsQuery query, float weightA, float weightB, float weightC, float weightD, int normalization) {
		functions.add((cb, left, ec) -> {
			String rank = "{" + weightD + "," + weightC + "," + weightB + "," + weightA + "}";
			return cb.function("ftsRankCd", String.class, cb.literal(rank), left
					, ec.convertObject(query), cb.literal(normalization));
		});
		return this;
	}

	@Override
	public ExpressionFtsVector<T> ftsStrip() {
		functions.add((cb, left, ec) -> cb.function("ftsStrip", String.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsLength() {
		functions.add((cb, left, ec) -> cb.function("ftsLength", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionNumeric<T> ftsNumNode() {
		functions.add((cb, left, ec) -> cb.function("ftsNumNode", Integer.class, left));
		return this;
	}

	@Override
	public ExpressionFtsVector<T> ftsSetWeightA() {
		functions.add((cb, left, ec) -> cb.function("ftsSetWeight", String.class, left, cb.literal("A")));
		return this;
	}

	@Override
	public ExpressionFtsVector<T> ftsSetWeightB() {
		functions.add((cb, left, ec) -> cb.function("ftsSetWeight", String.class, left, cb.literal("B")));
		return this;
	}

	@Override
	public ExpressionFtsVector<T> ftsSetWeightC() {
		functions.add((cb, left, ec) -> cb.function("ftsSetWeight", String.class, left, cb.literal("C")));
		return this;
	}

	@Override
	public ExpressionFtsVector<T> ftsSetWeightD() {
		functions.add((cb, left, ec) -> cb.function("ftsSetWeight", String.class, left, cb.literal("D")));
		return this;
	}

	@Override
	public ExpressionFtsVector<T> ftsConcat(ExpressionFtsVector<T> other) {
		functions.add((cb, left, ec) -> cb.function("ftsConcat", String.class, left, ec.convertObject(other)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsQuery(String query) {
		functions.add((cb, left, ec) -> cb.function("ftsQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsQuery(String lang, String query) {
		functions.add((cb, left, ec) -> cb.function("ftsQuery", String.class, cb.literal(lang), cb.literal(query)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsPlainQuery(String query) {
		functions.add((cb, left, ec) -> cb.function("ftsPlainQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsPlainQuery(String lang, String query) {
		functions.add((cb, left, ec) -> cb.function("ftsPlainQuery", String.class, cb.literal(lang), cb.literal(query)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsPhraseQuery(String query) {
		functions.add((cb, left, ec) -> cb.function("ftsPhraseQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsPhraseQuery(String lang, String query) {
		functions.add((cb, left, ec) -> cb.function("ftsPhraseQuery", String.class, cb.literal(lang), cb.literal(query)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsWebQuery(String query) {
		functions.add((cb, left, ec) -> cb.function("ftsWebQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query)));
		return this;
	}

	public ExpressionFtsQuery<T> ftsWebQuery(String lang, String query) {
		functions.add((cb, left, ec) -> cb.function("ftsWebQuery", String.class, cb.literal(lang), cb.literal(query)));
		return this;
	}

	@Override
	public ExpressionFtsQuery<T> andFtsQuery(ExpressionFtsQuery query) {
		functions.add((cb, left, ec) -> cb.function("ftsAnd", String.class, left, ec.convertObject(query)));
		return this;
	}

	@Override
	public ExpressionFtsQuery<T> andFtsQuery(String query) {
		functions.add((cb, left, ec) -> cb.function("ftsAnd", String.class, left
				, cb.function("ftsQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query))));
		return this;
	}

	@Override
	public ExpressionFtsQuery<T> orFtsQuery(ExpressionFtsQuery query) {
		functions.add((cb, left, ec) -> cb.function("ftsOr", String.class, left, ec.convertObject(query)));
		return this;
	}

	@Override
	public ExpressionFtsQuery<T> orFtsQuery(String query) {
		functions.add((cb, left, ec) -> cb.function("ftsOr", String.class, left
				, cb.function("ftsQuery", String.class, cb.literal(DEFAULT_LANGUAGE), cb.literal(query))));
		return this;
	}

	@Override
	public ExpressionFtsQuery<T> notFtsQuery() {
		functions.add((cb, left, ec) -> cb.function("ftsNot", String.class, left));
		return this;
	}

	// Support for creating date, time and timestamp from Expression without column
	public ExpressionDate<T> currentDate() {
		functions.add((cb, left, ec) -> cb.currentDate());
		return this;
	}

	public ExpressionDate<T> currentTime() {
		functions.add((cb, left, ec) -> cb.currentTime());
		return this;
	}

	public ExpressionDate<T> currentTimestamp() {
		functions.add((cb, left, ec) -> cb.currentTimestamp());
		return this;
	}

}
