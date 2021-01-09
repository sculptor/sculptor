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
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.framework.accessimpl.jpa;

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Expression;
import javax.persistence.criteria.Order;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;
import javax.persistence.criteria.Selection;
import javax.persistence.metamodel.ManagedType;

import org.sculptor.framework.accessimpl.jpa.QueryPropertyRestriction.Operator;

/**
 * <p>
 * Implementation of Access command FindByQueryAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public abstract class JpaCriteriaQueryExpressionAccessBase<T,R>
	extends JpaCriteriaQueryAccessBase<T,R> {

    private QueryExpressions<T> expressions = new QueryExpressions<T>();

	public JpaCriteriaQueryExpressionAccessBase() {
		super();
	}

	public JpaCriteriaQueryExpressionAccessBase(Class<T> type) {
		super(type);
	}

	public JpaCriteriaQueryExpressionAccessBase(Class<T> type, Class<R> resultType) {
		super(type, resultType);
	}

	protected QueryExpressions<T> getExpressions() {
        return expressions;
    }

	protected void setExpressions(QueryExpressions<T> expressions) {
        this.expressions = expressions;
    }

    public String getOrderBy() {
        return expressions.getOrdersAsString();
    }

    public void setOrderBy(String orderBy) {
        expressions.addOrders(orderBy);
    }

    public void setSelections(String selections) {
        expressions.addSelections(selections);
    }

    public void setGroupBy(String groupBy) {
        expressions.addGroups(groupBy);
    }

    @SuppressWarnings("unchecked")
    protected void prepareSelect(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
        if (expressions.hasSelections()) {
            List<Selection<?>> selections = mapSelections(getCriteriaBuilder(), root, expressions.getSelections());
            if (selections.size() == 1) {
                criteriaQuery.select((Selection<? extends R>) selections.get(0));
            } else {
                criteriaQuery.multiselect(selections);
            }
        }
    }

	protected void prepareGroupBy(CriteriaQuery<R> criteriaQuery, Root<T> root,	QueryConfig config) {
		if (expressions.hasGroups()) {
			criteriaQuery.groupBy(mapExpressions(getCriteriaBuilder(), root, expressions.getGroups()));
		}
	}

	protected void prepareOrderBy(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
		if (config.isSingleResult() && expressions.hasOrders()) {
			if (config.throwExceptionOnConfigurationError()) {
				throw new QueryConfigException(
						"Query returns a single result, 'order by' not allowed.");
			}
			return;
		}
		if (expressions.hasOrders()) {
			criteriaQuery.orderBy(mapOrders(getCriteriaBuilder(), root, expressions.getOrders()));
		}
	}

	protected List<Predicate> prepareWhere() {
		return null;
	}

	protected void prepareFetch(Root<T> root, QueryConfig config) {
	}

	@Override
	protected TypedQuery<R> prepareTypedQuery(QueryConfig config) {
		return getEntityManager().createQuery(getCriteriaQuery());
	}

	/**
	 *
	 * @param path
	 * @param property
	 * @param operator
	 * @param value
	 * @return
	 */
	@SuppressWarnings({ "unchecked", "rawtypes", "unused" })
	private Predicate preparePredicate(Path<?> path, String property, Operator operator, Object value) {

		path = getPath(path, property);

		if (Operator.Equal.equals(operator)) {
			return getCriteriaBuilder().equal(path, value);
		} else if (Operator.NotEqual.equals(operator)) {
			return getCriteriaBuilder().notEqual(
					getCriteriaBuilder().upper(path.as(String.class)),
					((String) value).toUpperCase());
		} else if (Operator.IgnoreCaseEqual.equals(operator)) {
			return getCriteriaBuilder().equal(
					getCriteriaBuilder().upper(path.as(String.class)),
					((String) value).toUpperCase());
		} else if (Operator.LessThan.equals(operator)) {
			return getCriteriaBuilder().lessThan((Expression<Comparable>) path,
					(Comparable) value);
		} else if (Operator.LessThanOrEqual.equals(operator)) {
			return getCriteriaBuilder().lessThanOrEqualTo(
					(Expression<Comparable>) path, (Comparable) value);
		} else if (Operator.GreaterThan.equals(operator)) {
			return getCriteriaBuilder().greaterThan((Expression<Comparable>) path,
					(Comparable) value);
		} else if (Operator.GreaterThanOrEqual.equals(operator)) {
			return getCriteriaBuilder().greaterThanOrEqualTo(
					(Expression<Comparable>) path, (Comparable) value);
		} else if (Operator.NotLike.equals(operator)) {
			return getCriteriaBuilder().notLike(path.as(String.class),
					(String) value);
		} else if (Operator.Like.equals(operator)) {
			return getCriteriaBuilder().like(path.as(String.class), (String) value);
		} else if (Operator.IgnoreCaseLike.equals(operator)) {
			return getCriteriaBuilder().like(
					getCriteriaBuilder().upper(path.as(String.class)),
					((String) value).toUpperCase());
		} else if (Operator.IsNull.equals(operator)) {
			return getCriteriaBuilder().isNull(path);
		} else if (Operator.IsNotNull.equals(operator)) {
			return getCriteriaBuilder().isNotNull(path);
		} else if (Operator.IsEmpty.equals(operator)) {
			// TODO: support additional types like Map,...
			if (getAttribute(getRoot().getModel(), property).isCollection()) {
				return getCriteriaBuilder().isEmpty(path.as(Collection.class));
			} else {
				return null;
			}
		} else if (Operator.IsNotEmpty.equals(operator)) {
			// TODO: support additional types like Map,...
			if (getAttribute(getRoot().getModel(), property).isCollection()) {
				return getCriteriaBuilder().isNotEmpty(path.as(Collection.class));
			} else {
				return null;
			}
		} else if (Operator.In.equals(operator)) {
			if (value instanceof Collection<?>) {
				return path.in((Collection<?>) value);
			} else {
				return path.in((Object[]) value);
			}
		} else if (Operator.NotIn.equals(operator)) {
			if (value instanceof Collection<?>) {
				return getCriteriaBuilder().not(path.in((Collection<?>) value));
			} else {
				return getCriteriaBuilder().not(path.in((Object[]) value));
			}
		}

		// openjpa does not support embeddables as restriction directly
		// TODO: verify whether this is working now
		if (JpaHelper.isJpaProviderOpenJpa(getEntityManager())) {
			for (ManagedType<?> embeddableType : getMetaModel().getEmbeddables()) {
				if (embeddableType.getJavaType().equals(value.getClass())) {
					return andPredicates(prepareWhere(path, embeddableType, value));
				}
			}
		}

		return preparePredicate(path, value);
	}

	/**
	 *
	 * @param path
	 * @param builder
	 * @param selections
	 * @return
	 */
	private List<Selection<?>> mapSelections(CriteriaBuilder builder, Path<?> root, List<String> selections) {
		List<Selection<?>> list = new ArrayList<Selection<?>>();
		list.addAll(mapExpressions(builder, root, selections));
		return list;
	}

	/**
	 *
	 * @param path
	 * @param builder
	 * @param selections
	 * @return
	 */
	private List<Order> mapOrders(CriteriaBuilder builder, Path<?> root, List<String> orders) {
		if (orders == null) {
			return null;
		}
		List<Order> list = new ArrayList<Order>();
		for (String order : orders) {
			Path<?> path = getPath(root, getPropertyName(order));
			if ("desc".equalsIgnoreCase(getFunction(order))) {
				list.add(builder.desc(path));
			} else {
				list.add(builder.asc(path));
			}
		}
		return list;
	}

	/**
	 *
	 * @param path
	 * @param builder
	 * @param expressions
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private List<Expression<?>> mapExpressions(CriteriaBuilder builder,
			Path<?> root, List<String> expressions) {
		if (expressions == null) {
			return null;
		}
		List<Expression<?>> list = new ArrayList<Expression<?>>();
		for (String expression : expressions) {
			String propertyName = getPropertyName(expression);
			String alias = getPropertyAlias(expression);
			String function = getFunction(expression);
			Path<?> path = getPath(root, propertyName);
			if (alias != null) {
				path.alias(alias);
			}
			if ("max".equalsIgnoreCase(function)) {
				list.add(builder.max((Expression<? extends Number>) path));
			} else if ("min".equalsIgnoreCase(function)) {
				list.add(builder.min((Expression<? extends Number>) path));
			} else if ("avg".equalsIgnoreCase(function)) {
				list.add(builder.avg((Expression<? extends Number>) path));
			} else if ("sum".equalsIgnoreCase(function)) {
				list.add(builder.sum((Expression<? extends Number>) path));
			} else if ("sumAsLong".equalsIgnoreCase(function)) {
				list.add(builder.sumAsLong(path.as(Integer.class)));
			} else if ("sumAsDouble".equalsIgnoreCase(function)) {
				list.add(builder.sumAsDouble(path.as(Float.class)));
			} else if ("count".equalsIgnoreCase(function)) {
				list.add(builder.count(path.as(Long.class)));
			} else if ("countDistinct".equalsIgnoreCase(function)) {
				list.add(builder.countDistinct(path.as(Long.class)));
			} else {
				list.add(path);
			}
		}
		return list;
	}

	/**
	 *
	 * @param expression
	 * @return
	 */
	private String getPropertyAlias(String expression) {
		if (expression.contains(" as ")) {
			return expression.split(" as ")[1].trim();
		}
		return null;
	}

	/**
	 *
	 * @param expression
	 * @return
	 */
	private String getPropertyName(String expression) {
		String propertyName = expression.trim();
		if (expression.contains(" as ")) {
			propertyName = expression.split(" as ")[0].trim();
		}
		if (propertyName.contains("(") && propertyName.contains(")")) {
			propertyName = propertyName.split("\\(|\\)")[1].trim();
		}

		return propertyName;
	}

	/**
	 *
	 * @param expression
	 * @return
	 */
	private String getFunction(String expression) {
		String expr = expression.trim();
		if (expr.contains(" asc")) {
			return "asc";
		} else if (expr.contains(" desc")) {
			return "desc";
		} else if (expr.contains("(")) {
			return expr.split("\\(")[0].trim();
		}
		return null;
	}

}
