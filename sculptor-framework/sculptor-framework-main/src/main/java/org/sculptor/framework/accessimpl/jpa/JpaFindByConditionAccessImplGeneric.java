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

import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Expression;
import javax.persistence.criteria.Order;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;
import javax.persistence.criteria.Selection;

import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.FindByConditionAccess2;
import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;


/**
 * <p>
 * Implementation of Access command FindByConditionAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByConditionAccessImplGeneric<T,R>
    extends JpaCriteriaQueryAccessBase<T,R>
    implements FindByConditionAccess2<R> {

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
            Predicate predicate = preparePredicate(criteria);
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
               	selection = getPath(root, criteria.getPropertyFullName());
            } else if (Operator.Max.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().max((Expression<? extends Number>)getPath(root, criteria.getPropertyFullName()));
            } else if (Operator.Min.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().min((Expression<? extends Number>)getPath(root, criteria.getPropertyFullName()));
            } else if (Operator.Avg.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().avg((Expression<? extends Number>)getPath(root, criteria.getPropertyFullName()));
            } else if (Operator.Sum.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().sum((Expression<? extends Number>)getPath(root, criteria.getPropertyFullName()));
            } else if (Operator.SumAsLong.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().sumAsLong(getPath(root, criteria.getPropertyFullName()).as(Integer.class));
            } else if (Operator.SumAsDouble.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().sumAsDouble(getPath(root, criteria.getPropertyFullName()).as(Float.class));
            } else if (Operator.Count.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().count(getPath(root, criteria.getPropertyFullName()).as(Long.class));
            } else if (Operator.CountDistinct.equals(criteria.getOperator())) {
            	selection = getCriteriaBuilder().countDistinct(getPath(root, criteria.getPropertyFullName()).as(Long.class));
            }
            if (selection != null) {
	            if (criteria.getPropertyAlias() != null) {
	            	selection.alias(criteria.getPropertyAlias());
	            }
                selections.add(selection);
            }
        }
        if (!selections.isEmpty()) {
        	if (selections.size() == 1)
        		criteriaQuery.select((Selection<? extends R>) selections.get(0));
        	else
        		criteriaQuery.multiselect(selections);
        }
    }

    @Override
    protected void prepareFetch(Root<T> root, QueryConfig config) {
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (Operator.FetchEager.equals(criteria.getOperator())) {
                // TODO: this is not tested
                root.fetch(criteria.getPropertyFullName());
            } else if (Operator.FetchLazy.equals(criteria.getOperator())) {
                // TODO: fetchLazy is not supported actually
            }
        }
    }

    @Override
    protected void prepareOrderBy(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
        List<Order> orderByList = new ArrayList<Order>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (Operator.OrderAsc.equals(criteria.getOperator())) {
                orderByList.add(getCriteriaBuilder().asc(getPath(root, criteria.getPropertyFullName())));
            } else if (Operator.OrderDesc.equals(criteria.getOperator())) {
                orderByList.add(getCriteriaBuilder().desc(getPath(root, criteria.getPropertyFullName())));
            }
        }
        if (!orderByList.isEmpty()) {
            criteriaQuery.orderBy(orderByList);
        }
    }

    @Override
    protected void prepareGroupBy(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
		List<Expression<?>> groups = new ArrayList<Expression<?>>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (Operator.GroupBy.equals(criteria.getOperator())) {
            	groups.add(getPath(root, criteria.getPropertyFullName()));
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
    private Predicate preparePredicate(ConditionalCriteria criteria) {

        CriteriaBuilder builder = getCriteriaBuilder();
        Root<T> root = getRoot();
        Path<?> path = getPath(root, criteria.getPropertyFullName());

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
            return builder.like(builder.upper((Expression<String>) path), ((String) criteria.getFirstOperant()).toUpperCase());
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
            return builder.not(preparePredicate((ConditionalCriteria) criteria.getFirstOperant()));
        } else if (Operator.Or.equals(operator) && criteria.getFirstOperant() instanceof List<?>) {
        	Predicate disjunction = builder.disjunction();
            List<ConditionalCriteria> list = (List<ConditionalCriteria>) criteria.getFirstOperant();
            for (ConditionalCriteria condition : list) {
                disjunction = builder.or(disjunction, preparePredicate(condition));
            }
            return disjunction;
        } else if (Operator.Or.equals(operator)) {
            return builder.or(
                    preparePredicate((ConditionalCriteria) criteria.getFirstOperant()),
                    preparePredicate((ConditionalCriteria) criteria.getSecondOperant()));
        } else if (Operator.And.equals(operator) && criteria.getFirstOperant() instanceof List<?>) {
            Predicate conjunction = builder.conjunction();
            List<ConditionalCriteria> list = (List<ConditionalCriteria>) criteria.getFirstOperant();
            for (ConditionalCriteria condition : list) {
                conjunction = builder.and(conjunction, preparePredicate(condition));
            }
            return conjunction;
        } else if (Operator.And.equals(operator)) {
            return builder.and(
                    preparePredicate((ConditionalCriteria) criteria.getFirstOperant()),
                    preparePredicate((ConditionalCriteria) criteria.getSecondOperant()));
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
        } else {
            return null;
        }
    }

	@Override
	public void executeCount() {
		executeResultCount();
	}
}