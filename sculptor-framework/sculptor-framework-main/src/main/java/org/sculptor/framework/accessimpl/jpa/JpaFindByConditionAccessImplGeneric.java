/*
 * Copyright 2009 The Fornax Project Team, including the original
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

import org.hibernate.annotations.QueryHints;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;
import org.sculptor.framework.accessapi.FindByConditionAccess2;
import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.Property;

import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Expression;
import javax.persistence.criteria.Fetch;
import javax.persistence.criteria.FetchParent;
import javax.persistence.criteria.JoinType;
import javax.persistence.criteria.Order;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;
import javax.persistence.criteria.Selection;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;
import java.util.Set;


/**
 * <p>
 * Implementation of Access command FindByConditionAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByConditionAccessImplGeneric<T,R>
    extends JpaCriteriaQueryAccessBase<T,R> implements FindByConditionAccess2<R> {

    private List<ConditionalCriteria> conditionalCriterias = new ArrayList<ConditionalCriteria>();

    public JpaFindByConditionAccessImplGeneric() {
        super();
    }

    public JpaFindByConditionAccessImplGeneric(Class<T> type) {
        super(type);
    }

    public JpaFindByConditionAccessImplGeneric(Class<T> type, Class<R> resultType) {
        super(type, resultType);
    }

    public void setCondition(List<ConditionalCriteria> criteria) {
		conditionalCriterias=criteria;
	}

	public void addCondition(ConditionalCriteria criteria) {
		conditionalCriterias.add(criteria);
	}

	public List<R> getResult() {
		return getListResult();
	}

    @Override
    protected List<Predicate> preparePredicates() {
        List<Predicate> predicates = new ArrayList<Predicate>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
            Predicate predicate = preparePredicate(criteria, false);
            if (predicate != null) {
                predicates.add(predicate);
            }
        }
        return predicates;
    }

    @Override
    protected void prepareConfig(QueryConfig config) {
		config.setDistinct(false);
    }

    @SuppressWarnings("unchecked")
    protected void prepareSelect(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
		List<Selection<?>> selections = new ArrayList<Selection<?>>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
        	Selection<?> selection = null;
            if (Operator.Select.equals(criteria.getOperator())) {
            	selection = getExpression(criteria, root);
            } else if (Operator.Max.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().max(getExpression(criteria, root));
            } else if (Operator.Min.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().min(getExpression(criteria, root));
            } else if (Operator.Avg.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().avg(getExpression(criteria,root));
            } else if (Operator.Sum.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().sum(getExpression(criteria, root));
            } else if (Operator.SumAsLong.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().sumAsLong(getExpression(criteria, root).as(Integer.class));
            } else if (Operator.SumAsDouble.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().sumAsDouble(getExpression(criteria, root).as(Float.class));
            } else if (Operator.Count.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().count(getExpression(criteria, root)).as(Long.class);
            } else if (Operator.CountDistinct.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().countDistinct(getExpression(criteria, root)).as(Long.class);
            }
            if (selection != null) {
	            if (criteria.getPropertyAlias() != null) {
	            	selection.alias(criteria.getPropertyAlias());
	            }
                selections.add(selection);
            }
        }
        if (!selections.isEmpty()) {
        	setFetchEager(null);
            if (selections.size() == 1) {
                criteriaQuery.select((Selection<? extends R>) selections.get(0));
            } else {
                criteriaQuery.multiselect(selections);
            }
        }
    }

    private Expression<? extends Number> getExpression(ConditionalCriteria criteria, Root<T> root) {
        CriteriaBuilder criteriaBuilder = getCriteriaBuilder();
        Expression<? extends Number> result = (Expression<? extends Number>) getPath(root, criteria.getPropertyFullName());
        if (criteria.getFirstOperant() instanceof ConditionalCriteria.Function) {
            ConditionalCriteria.Function function = (ConditionalCriteria.Function) criteria.getFirstOperant();
            if (ConditionalCriteria.Function.hour.equals(function)) {
                result = criteriaBuilder.function("hour", Integer.class, result);
            } else if (ConditionalCriteria.Function.day.equals(function)) {
                result = criteriaBuilder.function("day", Integer.class, result);
            } else if (ConditionalCriteria.Function.month.equals(function)) {
                result = criteriaBuilder.function("month", Integer.class, result);
            } else if (ConditionalCriteria.Function.year.equals(function)) {
                result = criteriaBuilder.function("year", Integer.class, result);
            } else if (ConditionalCriteria.Function.week.equals(function)) {
                result = criteriaBuilder.function("week", Integer.class, result);
            } else if (ConditionalCriteria.Function.quarter.equals(function)) {
                result = criteriaBuilder.function("quarter", Integer.class, result);
            } else if (ConditionalCriteria.Function.dayOfWeek.equals(function)) {
                result = criteriaBuilder.function("dow", Integer.class, result);
            } else if (ConditionalCriteria.Function.dayOfYear.equals(function)) {
                result = criteriaBuilder.function("doy", Integer.class, result);
            }
        }
        return result;
    }

    @Override
    protected void prepareFetch(Root<T> root, QueryConfig config) {
        // Extract eager field names
        List<String> eagerProperties = new ArrayList<>();
        Property<?>[] fetchEager = getFetchEager();
        if (fetchEager != null) {
            for (Property p : getFetchEager()) {
                String propFullName = p instanceof LeafProperty<?> ? ((LeafProperty<?>) p).getEmbeddedName() : p.getName();
                eagerProperties.add(propFullName);
            }
        }

        // Apply eager from criteria
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (Operator.FetchEager.equals(criteria.getOperator())) {
                // TODO: this is not tested
                String[] split = criteria.getPropertyFullName().split("\\.");
                FetchParent parent = root;
                for (String s : split) {
                    parent = parent.fetch(s, JoinType.LEFT);
                }
                // Remove fields which are overridden in criteria
                eagerProperties.remove(criteria.getPropertyFullName());
            } else if (Operator.FetchLazy.equals(criteria.getOperator())) {
                // TODO: fetchLazy is not supported actually
            }
        }

        // Apply eager unspecified in criteria
        for (String eager : eagerProperties) {
            String[] split = eager.split("\\.");
            FetchParent parent = root;
            for (String s : split) {
                parent = parent.fetch(s, JoinType.LEFT);
            }
        }
    }

    @Override
    protected void prepareOrderBy(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
        List<Order> orderByList = new ArrayList<Order>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (Operator.OrderAsc.equals(criteria.getOperator())) {
                if (config.isDistinct()) {
                    // for distinct select, sort column have to be in fetch columns - otherwise DB error
                    orderByList.add(getCriteriaBuilder().asc(getFetchPath(root, criteria)));
                } else {
                    orderByList.add(getCriteriaBuilder().asc(getPath(root, criteria.getPropertyFullName())));
                }
            } else if (Operator.OrderDesc.equals(criteria.getOperator())) {
                if (config.isDistinct()) {
                    // for distinct select, sort column have to be in fetch columns - otherwise DB error
                    orderByList.add(getCriteriaBuilder().desc(getFetchPath(root, criteria)));
                } else {
                    orderByList.add(getCriteriaBuilder().desc(getPath(root, criteria.getPropertyFullName())));
                }
            }
        }
        if (!orderByList.isEmpty()) {
            criteriaQuery.orderBy(orderByList);
        }
    }

    private Path getFetchPath(Root<T> root, ConditionalCriteria criteria) {
        FetchParent from = root;
        for (int i = 0; i < criteria.getPropertyPath().length; i++) {
            String stringPath = criteria.getPropertyPath()[i];
            Set<Fetch<?, ?>> fetches = from.getFetches();
            boolean found = false;
            for (Fetch<?, ?> fetch : fetches) {
                if (fetch.getAttribute().getName().equals(stringPath)) {
                    from = (FetchParent) fetch;
                    found = true;
                    break;
                }
            }
            if (!found) {
                from = from.fetch(stringPath, JoinType.LEFT);
            }
        }
        return ((Path) from).get(criteria.getPropertyName());
    }

    @Override
    protected void prepareGroupBy(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
		List<Expression<?>> groups = new ArrayList<Expression<?>>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (Operator.GroupBy.equals(criteria.getOperator())) {
            	groups.add(getExpression(criteria, root));
            }
        }
        if (!groups.isEmpty()) {
            criteriaQuery.groupBy(groups);
        }
    }

    /**
     * Map conditional criteria to type safe predicates using unchecked casts.
     *
     * @param criteria
     * @return
     */
    @SuppressWarnings({ "unchecked", "rawtypes" })
    private Predicate preparePredicate(ConditionalCriteria criteria, boolean forceJoin) {
        CriteriaBuilder builder = getCriteriaBuilder();
        Root<T> root = getRoot();
        Path<?> path = getPath(root, criteria.getPropertyFullName(), forceJoin);

        ConditionalCriteria.Operator operator = criteria.getOperator();
        if (Operator.Equal.equals(operator)) {
            return builder.equal(path, criteria.getFirstOperant());
        } else if (Operator.IgnoreCaseEqual.equals(operator)) {
            return builder.equal(builder.upper(path.as(String.class)), ((String) criteria.getFirstOperant()).toUpperCase());
        } else if (Operator.LessThan.equals(operator)) {
            return builder.lessThan((Expression<Comparable>) path, (Comparable) criteria.getFirstOperant());
        } else if (Operator.LessThanOrEqual.equals(operator)) {
            return builder.lessThanOrEqualTo((Expression<Comparable>) path, (Comparable) criteria.getFirstOperant());
        } else if (Operator.GreatThan.equals(operator)) {
            return builder.greaterThan((Expression<Comparable>) path, (Comparable) criteria.getFirstOperant());
        } else if (Operator.GreatThanOrEqual.equals(operator)) {
            return builder.greaterThanOrEqualTo((Expression<Comparable>) path, (Comparable) criteria.getFirstOperant());
        } else if (Operator.Like.equals(operator)) {
            return builder.like((Expression<String>) path, (String) criteria.getFirstOperant());
        } else if (Operator.IgnoreCaseLike.equals(operator)) {
            return builder.like(builder.upper(path.as(String.class)), ((String) criteria.getFirstOperant()).toUpperCase());
        } else if (Operator.IsNull.equals(operator)) {
            return builder.isNull(path);
        } else if (Operator.IsNotNull.equals(operator)) {
            return builder.isNotNull(path);
        } else if (Operator.IsEmpty.equals(operator)) {
            // TODO: support additional types like Map,...
            if (getAttribute(root.getModel(), criteria.getPropertyFullName()).isCollection()) {
                return builder.isEmpty((Expression<Collection>)path);
            } else {
                return null;
            }
        } else if (Operator.IsNotEmpty.equals(operator)) {
            // TODO: support additional types like Map,...
            if (getAttribute(root.getModel(), criteria.getPropertyFullName()).isCollection()) {
                return builder.isNotEmpty((Expression<Collection>)path);
            } else {
                return null;
            }
        } else if (Operator.Between.equals(operator)) {
            return builder.between((Expression<Comparable>) path, (Comparable) criteria.getFirstOperant(), (Comparable) criteria.getSecondOperant());
        } else if (Operator.Not.equals(operator)) {
            return builder.not(preparePredicate((ConditionalCriteria) criteria.getFirstOperant(), false));
        } else if (Operator.Or.equals(operator) && criteria.getFirstOperant() instanceof List<?>) {
            List<ConditionalCriteria> list = (List<ConditionalCriteria>) criteria.getFirstOperant();
            List<Predicate> resultPredicates = new ArrayList<>();
            for (ConditionalCriteria condition : (List<ConditionalCriteria>) criteria.getFirstOperant()) {
                resultPredicates.add(preparePredicate(condition, true));
            }
			return builder.or(resultPredicates.toArray(new Predicate[resultPredicates.size()]));
        } else if (Operator.Or.equals(operator)) {
            return builder.or(
                    preparePredicate((ConditionalCriteria) criteria.getFirstOperant(), true),
                    preparePredicate((ConditionalCriteria) criteria.getSecondOperant(), true));
        } else if (Operator.And.equals(operator) && criteria.getFirstOperant() instanceof List<?>) {
            Predicate conjunction = builder.conjunction();
            List<ConditionalCriteria> list = (List<ConditionalCriteria>) criteria.getFirstOperant();
            for (ConditionalCriteria condition : list) {
                conjunction = builder.and(conjunction, preparePredicate(condition, false));
            }
            return conjunction;
        } else if (Operator.And.equals(operator)) {
            return builder.and(
                    preparePredicate((ConditionalCriteria) criteria.getFirstOperant(), false),
                    preparePredicate((ConditionalCriteria) criteria.getSecondOperant(), false));
        } else if (Operator.In.equals(operator)) {
            if (criteria.getFirstOperant() instanceof Collection<?>) {
                return path.in((Collection<?>) criteria.getFirstOperant());
            } else {
                return path.in((Object[])criteria.getFirstOperant());
            }
        } else if (Operator.EqualProperty.equals(operator)) {
            return builder.equal(path, getPath(root, (String) criteria.getFirstOperant()));
        } else if (Operator.LessThanProperty.equals(operator)) {
            return builder.lessThan((Expression<Comparable>) path, (Expression<Comparable>) getPath(root, (String) criteria.getFirstOperant()));
        } else if (Operator.LessThanOrEqualProperty.equals(operator)) {
            return builder.lessThanOrEqualTo((Expression<Comparable>) path, (Expression<Comparable>) getPath(root, (String) criteria.getFirstOperant()));
        } else if (Operator.GreatThanProperty.equals(operator)) {
            return builder.greaterThan((Expression<Comparable>) path, (Expression<Comparable>) getPath(root, (String) criteria.getFirstOperant()));
        } else if (Operator.GreatThanOrEqualProperty.equals(operator)) {
            return builder.greaterThanOrEqualTo((Expression<Comparable>) path, (Expression<Comparable>) getPath(getRoot(), (String) criteria.getFirstOperant()));
        } else if (Operator.ProjectionRoot.equals(operator)) {
            // TODO: support projectionRoot, if possible
            if (getConfig().throwExceptionOnConfigurationError()) {
                throw new QueryConfigException("Operator 'ProjectionRoot' is not supported");
            }
            return null;
        } else if (Operator.DistinctRoot.equals(operator)) {
            getConfig().setDistinct(true);
            return null;
        } else if (Operator.ReadOnly.equals(operator)) {
        	setHint(QueryHints.READ_ONLY, true);
            return null;
        } else if (Operator.Scroll.equals(operator)) {
        	getConfig().setScroll(true);
            return null;
        } else {
            return null;
        }
    }

	public void executeCount() {
		executeResultCount();
	}
}
