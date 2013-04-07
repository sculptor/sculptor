/*
 * Copyright 2007 The Fornax Project Team, including the original
 * author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR placeholders OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.generator.util;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Converts a given "jpql" query string to a query dsl using simple text
 * replacement. Actually only ConditionalCriteria and a subset of jpql is
 * supported.
 * 
 * @author Oliver Ringel
 * 
 */
public interface QueryConverter {

	public String toQueryDsl();

	static abstract class AbstractQueryConverter implements QueryConverter {

		protected String query = "";
		protected String aggregateRoot = null;

		protected String select = "";
		protected String from = "";
		protected String orderBy = "";
		protected String groupBy = "";
		protected String where = "";

		protected AbstractQueryConverter(String query, String aggregateRoot) {
			this.query = query;
			this.aggregateRoot = aggregateRoot;
			extractSqlParts();
		}

		private void extractSqlParts() {
			select = extract("(?:select)(.*?)(?:(from|where|group by|order by|$))");
			from = extract("(?:from)(.*?)(?:(select|where|group by|order by|$))");
			where = extract("(?:where)(.*?)(?:(select|from|group by|order by|$))");
			groupBy = extract("(?:group by)(.*?)(?:(select|from|where|order by|$))");
			orderBy = extract("(?:order by)(.*?)(?:(select|from|where|group by|$))");
			if (!hasSqlParts()) {
				where = query; // query only contains conditions
			}
		}

		private String extract(String regex) {
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(query);
			if (matcher.find()) {
				return matcher.group(1).trim();
			}
			return "";
		}

		public abstract String toQueryDsl();

		@Override
		public String toString() {
			return String.format("select=%1$s from=%2$s where=%3$s group by=%4$s order by=%5$s", select, from, where, groupBy,
					orderBy);
		}

		private boolean hasSqlParts() {
			if (!(select + from + where + groupBy + orderBy).isEmpty()) {
				return true;
			}
			return false;
		}

	}

	static class ConditionalCriteriaStrategy extends AbstractQueryConverter {

		private String aggregateRootProperties = "";
		private Map<String, String> placeholders = new HashMap<String, String>();
		private int placeholdersCounter = 0;

		private static final List<Expression> expressions = new ArrayList<Expression>();
		static {
			expressions.add(new Expression("in", ".withProperty(%1$s).in(%2$s)"));
			expressions.add(new Expression("between", ".withProperty(%1$s).between(%2$s,%3$s)"));
			expressions.add(new Expression("not between", ".not().withProperty(%1$s).between(%2$s,%3$s)"));
			expressions.add(new Expression("=", ".withProperty(%1$s).eq(%2$s)"));
			expressions.add(new Expression("i=", ".withProperty(%1$s).ignoreCaseEq(%2$s)"));
			expressions.add(new Expression("!=", ".not().withProperty(%1$s).eq(%2$s)"));
			expressions.add(new Expression("<>", ".not().withProperty(%1$s).eq(%2$s)"));
			expressions.add(new Expression(">", ".withProperty(%1$s).greaterThan(%2$s)"));
			expressions.add(new Expression(">=", ".withProperty(%1$s).greaterThanOrEqual(%2$s)"));
			expressions.add(new Expression("<", ".withProperty(%1$s).lessThan(%2$s)"));
			expressions.add(new Expression("<=", ".withProperty(%1$s).lessThanOrEqual(%2$s)"));
			expressions.add(new Expression("like", ".withProperty(%1$s).like(%2$s)"));
			expressions.add(new Expression("ilike", ".withProperty(%1$s).ignoreCaseLike(%2$s)"));
			expressions.add(new Expression("not like", ".not().withProperty(%1$s).like(%2$s)"));
			expressions.add(new Expression("is null", ".withProperty(%1$s).isNull()"));
			expressions.add(new Expression("is not null", ".withProperty(%1$s).isNotNull()"));
			expressions.add(new Expression("is empty", ".withProperty(%1$s).isEmpty()"));
			expressions.add(new Expression("is not empty", ".withProperty(%1$s).isNotEmpty()"));
		}

		public ConditionalCriteriaStrategy(String query, String aggregateRoot) {
			super(query, aggregateRoot);
			this.aggregateRootProperties = aggregateRoot + "Properties";
		}

		@Override
		public String toQueryDsl() {
			prepareSelections();
			prepareWhere();
			prepareGroupBy();
			prepareOrderBy();
			return select + where + groupBy + orderBy;
		}

		private void prepareSelections() {
			if (!select.isEmpty())
				convertSelections();
		}

//		private void prepareFrom() {
//			if (!from.isEmpty())
//				convertSelections();
//		}

		private void prepareWhere() {
			if (!where.isEmpty()) {
				convertLiterals();
				convertExpressions();
				convertStaticText();
				insertExpressions();
				insertLiterals();
			}
		}

		private void prepareGroupBy() {
			if (!groupBy.isEmpty())
				convertGroupBy();
		}

		private void prepareOrderBy() {
			if (!orderBy.isEmpty())
				convertOrderBy();
		}

		private void convertSelections() {
			String[] selections = select.split(",");
			select = "";
			for (String selection : selections) {
				select += String.format(".select(%1$s)%2$s%3$s", convertAttribute(attribute(selection)),
						convertAlias(alias(selection)), convertAggregate(aggregate(selection)));
			}
		}

		private void convertGroupBy() {
			String[] groups = groupBy.split(",");
			groupBy = "";
			for (String group : groups) {
				groupBy += String.format(".groupBy(%1$s)", convertAttribute(attribute(group)));
			}
		}

		private void convertOrderBy() {
			String[] orders = orderBy.split(",");
			orderBy = "";
			for (String order : orders) {
				orderBy += String.format(".orderBy(%1$s)%2$s", convertAttribute(attribute(order)),
						convertOrderDirection(orderDirection(order)));
			}
		}

		private void convertLiterals() {
			addPlaceholders("'(.*?)'", "'", "\"");
		}

		private void convertExpressions() {
			for (Expression expression : expressions) {
				Pattern pattern = Pattern.compile(expression.getRegex());
				Matcher matcher = pattern.matcher(" " + where + " ");
				while (matcher.find()) {
					Object[] operants = new Object[expression.countOperants()];
					for (int i = 0; i < operants.length; i++) {
						operants[i] = convertOperant(matcher.group(i + 1).replaceAll(expression.getReplacement(), ""));
					}
					addPlaceholder(matcher.group(0).replaceAll(expression.getReplacement(), "").trim(),
							String.format(expression.getTransformation(), operants));
				}
			}
		}

		private String convertOperant(String operant) {
			if (operant.startsWith("$P")) {
				// ignore placeholders (literals) at this point
			} else if (operant.startsWith(":")) {
				operant = operant.replace(":", ""); // parameters
			} else {
				operant = convertAttribute(operant);
			}
			return operant;
		}

		private String convertAttribute(String attribute) {
			if (attribute.isEmpty())
				return "";
			String alias = alias(from) + ".";
			if (attribute.startsWith(alias))
				attribute = attribute.replace(alias, "");
			return aggregateRootProperties + "." + attribute.replace(".", "().") + "()";
		}

		private String convertAlias(String alias) {
			if (alias.isEmpty())
				return "";
			return ".alias(\"" + alias + "\")";
		}

		private String convertAggregate(String aggregate) {
			if (aggregate.isEmpty())
				return "";
			return "." + aggregate + "()";
		}

		private String convertOrderDirection(String order) {
			if (order.isEmpty())
				return "";
			return "." + order + "()";
		}

		private void convertStaticText() {
			where = where.replace("(", ".lbrace").replace(")", ".rbrace").replace("lbrace", "lbrace()")
					.replace("rbrace", "rbrace()").replace("and", ".and()").replace("or", ".or()").replace("!", ".not()");
		}

		private void insertExpressions() {
			where = insertPlaceholders(where).replaceAll("\\s+\\.", ".").trim();
		}

		private void insertLiterals() {
			where = insertPlaceholders(where);
		}

		private void addPlaceholder(String replace, String with) {
			String placeholder = "$P" + (++placeholdersCounter);
			where = where.replace(replace, placeholder);
			placeholders.put(placeholder, with);
		}

		private void addPlaceholder(String replace) {
			addPlaceholder(replace, replace);
		}

		@SuppressWarnings("unused")
		private void addPlaceholders(String regex) {
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(where);
			while (matcher.find()) {
				addPlaceholder(matcher.group(0));
			}
		}

		private void addPlaceholders(String regex, String replace, String with) {
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(where);
			while (matcher.find()) {
				addPlaceholder(matcher.group(0), matcher.group(0).replace(replace, with));
			}
		}

		private String insertPlaceholders(String expression) {
			for (String placeholder : placeholders.keySet()) {
				if (expression.contains(placeholder)) {
					expression = expression.replace(placeholder, placeholders.get(placeholder));
				}
			}
			return expression;
		}

		private String alias(String expression) {
			if (expression.contains(" as ")) {
				return expression.split(" as ")[1].trim();
			} else if (expression.trim().contains(" ")) {
				return expression.split(" ")[1].trim();
			}
			return "";
		}

		private String attribute(String expression) {
			String attribute = expression.trim();
			if (expression.contains(" as ")) {
				attribute = expression.split(" as ")[0].trim();
			}
			if (expression.contains(" desc")) {
				attribute = expression.split(" desc")[0].trim();
			}
			if (expression.contains(" asc")) {
				attribute = expression.split(" asc")[0].trim();
			}
			if (attribute.contains("(") && attribute.contains(")")) {
				attribute = attribute.split("\\(|\\)")[1].trim();
			}
			return attribute;
		}

		private String aggregate(String expression) {
			String expr = expression.trim();
			if (expr.contains("(")) {
				return expr.split("\\(")[0].trim();
			}
			return "";
		}

		private String orderDirection(String expression) {
			String expr = expression.trim();
			if (expr.contains(" desc")) {
				return "descending";
			}
			return "ascending";
		}

		private static class Expression {
			private String operator;
			private String transformation;
			private String regex;
			private String replacement = "\\(|\\)";

			public Expression(String operator, String transformation) {
				this.operator = operator;
				this.transformation = transformation;
				switch (countOperants()) {
				case 3:
					// (not) between expression
					regex = "(\\S+?)\\s+" + operator + "\\s+(\\S+?)\\sand\\s+(\\S+?)\\s+";
					break;
				case 2:
					regex = "(\\S+?)\\s+" + operator + "\\s+(\\S+?)(?=\\s+)";
					break;
				case 1:
					regex = "(\\S+?)\\s+" + operator + "\\s+";
					break;
				default:
					break;
				}
				if (this.operator.equals("in")) {
					replacement = "";
					regex = "(\\S+?)\\s+in\\s+\\(+(.*?)\\)+";
				}
			}

			@SuppressWarnings("unused")
			public String getOperator() {
				return operator;
			}

			public String getTransformation() {
				return transformation;
			}

			public String getRegex() {
				return regex;
			}

			public String getReplacement() {
				return replacement;
			}

			public int countOperants() {
				if (transformation.contains("%3"))
					return 3;
				else if (transformation.contains("%2"))
					return 2;
				else if (transformation.contains("%1"))
					return 1;
				return 0;
			}
		}
	}
}
