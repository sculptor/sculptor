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

import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;
import org.sculptor.framework.accessapi.FindByConditionAccess2;
import org.sculptor.framework.domain.JpaFunction;
import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.Property;
import org.sculptor.framework.domain.PropertyWithExpression;
import org.sculptor.framework.domain.expression.ExpressionConverter;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import javax.persistence.criteria.*;
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
    extends JpaCriteriaQueryAccessBase<T,R> implements FindByConditionAccess2<R>, ExpressionConverter {

    private static final Logger log = LoggerFactory.getLogger(JpaFindByConditionAccessImplGeneric.class);

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
    protected List<Predicate> prepareWhere() {
        List<Predicate> predicates = new ArrayList<Predicate>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (!criteria.isHaving()) {
                Predicate predicate = preparePredicate(criteria, false);
                if (predicate != null) {
                    predicates.add(predicate);
                }
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
                if (selection != null) {
                    if (criteria.getPropertyAlias() != null) {
                        selection.alias(criteria.getPropertyAlias());
                    }
                    selections.add(selection);
                }
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

    @Override
    public Expression convertObject(Object param) {
        Expression retVal;
        if (param instanceof Expression) {
            retVal = (Expression) param;
        } else if (param instanceof PropertyWithExpression) {
            retVal = processExpressions((PropertyWithExpression) param);
        } else if (param instanceof Property) {
            Property prop = (Property) param;
            retVal = (Expression) getPath(getRoot(), prop.getName());
        } else {
            retVal = getCriteriaBuilder().literal(param);
        }
        return retVal;
    }

    @Override
    public Expression[] convertObjectArray(Object... obj) {
        Expression<?>[] args = new Expression[obj.length];
        for (int i = 0; i < args.length; i++) {
        	args[i] = convertObject(obj[i]);
        }
        return args;
    }

    private Expression processExpressions(PropertyWithExpression propertyExpression) {
        Expression result;
        if (propertyExpression.getBase().getName().length() != 0) {
            result=getPath(getRoot(), propertyExpression.getBase().getName());
        } else {
            result = null;
        }

        List<JpaFunction> functions = propertyExpression.getFunctions();
        if (functions != null && functions.size() > 0) {
            for (JpaFunction jpaFunction : functions) {
                result = jpaFunction.prepareFunction(getCriteriaBuilder(), result, this);
//                ConditionalCriteria.NativeFunction nativeFunction = jpaFunction.makeNativeFunction(null);
//                if (nativeFunction.getName().equalsIgnoreCase("min")) {
//                    result = getCriteriaBuilder().min(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("max")) {
//                    result = getCriteriaBuilder().max(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("least")) {
//                    result = getCriteriaBuilder().least(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("greatest")) {
//                    result = getCriteriaBuilder().greatest(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("avg")) {
//                    result = getCriteriaBuilder().avg(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("sum")) {
//                    result = getCriteriaBuilder().sum(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("sumAsDouble")) {
//                    result = getCriteriaBuilder().sumAsDouble(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("sumAsLong")) {
//                    result = getCriteriaBuilder().sumAsLong(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("count")) {
//                    result = getCriteriaBuilder().count(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("countDistinct")) {
//                    result = getCriteriaBuilder().countDistinct(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("abs")) {
//                    result = getCriteriaBuilder().abs(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("neg")) {
//                    result = getCriteriaBuilder().neg(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("sqrt")) {
//                    result = getCriteriaBuilder().sqrt(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("coalesce") || nativeFunction.getName().equalsIgnoreCase("nvl")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().coalesce(args[0], args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("concat")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().concat((Expression<String>) args[0], (Expression<String>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("currentDate")) {
//                    result = getCriteriaBuilder().currentDate();
//                } else if (nativeFunction.getName().equalsIgnoreCase("currentTime")) {
//                    result = getCriteriaBuilder().currentTime();
//                } else if (nativeFunction.getName().equalsIgnoreCase("currentTimestamp")) {
//                    result = getCriteriaBuilder().currentTimestamp();
//                    result = getCriteriaBuilder().diff((Expression<? extends Number>) args[0], (Expression<? extends Number>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("add")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().sum((Expression<? extends Number>) args[0], (Expression<? extends Number>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("substract")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("multiply")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().prod((Expression<? extends Number>) args[0], (Expression<? extends Number>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("divide")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().quot((Expression<? extends Number>) args[0], (Expression<? extends Number>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("mod")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().mod((Expression<Integer>) args[0], (Expression<Integer>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("toInteger")) {
//                    result = getCriteriaBuilder().toInteger(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("toLong")) {
//                    result = getCriteriaBuilder().toLong(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("toFloat")) {
//                    result = getCriteriaBuilder().toFloat(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("toDouble")) {
//                    result = getCriteriaBuilder().toDouble(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("toBigInteger")) {
//                    result = getCriteriaBuilder().toBigInteger(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("toBigDecimal")) {
//                    result = getCriteriaBuilder().toBigDecimal(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("toString")) {
//                    result = getCriteriaBuilder().toString(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("append")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().concat((Expression<String>) args[0], (Expression<String>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("prefix")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().concat((Expression<String>) args[0], (Expression<String>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("length")) {
//                    result = getCriteriaBuilder().length(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("indexOf")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().locate((Expression<String>) args[0], (Expression<String>) args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("lower")) {
//                    result = getCriteriaBuilder().lower(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("upper")) {
//                    result = getCriteriaBuilder().upper(result);
//                } else if (nativeFunction.getName().equalsIgnoreCase("nullif")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().nullif(args[0], args[1]);
//                } else if (nativeFunction.getName().equalsIgnoreCase("substring")) {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    if (args.length == 2) {
//                        result = getCriteriaBuilder().substring((Expression<String>) args[0], (Expression<Integer>) args[1]);
//                    } else {
//                        result = getCriteriaBuilder().substring((Expression<String>) args[0], (Expression<Integer>) args[1], (Expression<Integer>) args[2]);
//                    }
//                } else if (nativeFunction.getName().equalsIgnoreCase("trim")) {
//                    result = getCriteriaBuilder().trim(result);
//                } else {
//                    Expression<?> args[] = makeNativeArgs(nativeFunction.getParameters(), result);
//                    result = getCriteriaBuilder().function(nativeFunction.getName(), nativeFunction.getResultType(), args);
//                }
            }
        }
        return result;
    }

    private Expression<? extends Number> getExpression(ConditionalCriteria criteria, Root<T> root) {
        Expression<? extends Number> result;
        if (criteria.getExpression() instanceof PropertyWithExpression) {
            result = processExpressions((PropertyWithExpression) criteria.getExpression());
        } else {
            result = (Expression<? extends Number>) getPath(root, criteria.getPropertyFullName());
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
                    // TODO: !!! CHECK THIS OUT with latest versions !!!
                    // for distinct select, sort column have to be in fetch columns - otherwise DB error
                    orderByList.add(getCriteriaBuilder().asc(getFetchPath(root, criteria)));
                } else {
                    orderByList.add(getCriteriaBuilder().asc(getExpression(criteria, root)));
                }
            } else if (Operator.OrderDesc.equals(criteria.getOperator())) {
                if (config.isDistinct()) {
                    // for distinct select, sort column have to be in fetch columns - otherwise DB error
                    orderByList.add(getCriteriaBuilder().desc(getFetchPath(root, criteria)));
                } else {
                    orderByList.add(getCriteriaBuilder().desc(getExpression(criteria, root)));
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

    @Override
    protected void prepareHaving(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
        List<Predicate> havings = new ArrayList<>();
        for (ConditionalCriteria criteria : conditionalCriterias) {
            if (criteria.isHaving()) {
                Predicate predicate = preparePredicate(criteria, false);
                if (predicate != null) {
                    havings.add(preparePredicate(criteria, false));
                }
            }
        }
        if (!havings.isEmpty()) {
//            criteriaQuery.having(getCriteriaBuilder().and(havings.toArray(new Predicate[havings.size()])));
            criteriaQuery.having(andPredicates(havings));
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
    	// Performance improvement
        if (Operator.Select.equals(criteria.getOperator())
                || Operator.GroupBy.equals(criteria.getOperator())
                || Operator.FetchEager.equals(criteria.getOperator())
                || Operator.FetchLazy.equals(criteria.getOperator())
        ) {
            return null;
        }

        CriteriaBuilder builder = getCriteriaBuilder();
        Root<T> root = getRoot();
        Expression<?> path = getPath(root, criteria.getPropertyFullName(), forceJoin);
        path = getExpression(criteria, root);

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
			if (JpaHelper.isJpaProviderHibernate(getEntityManager())) {
                // org.hibernate.annotations.QueryHints.READ_ONLY
                setHint("org.hibernate.readOnly", true);
            } else if (JpaHelper.isJpaProviderEclipselink(getEntityManager())) {
				// org.eclipse.persistence.config.QueryHints.READ_ONLY
                setHint("eclipselink.read-only", true);
            } else if (JpaHelper.isJpaProviderOpenJpa(getEntityManager())) {
				// Open JPA doesn't support READ-ONLY query
                log.warn("Read only query hint ignored - not supported by OpenJPA");
            } else if (JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
                log.warn("Read only query hint ignored - not supported by DataNucleus");
            } else {
			    String provider = getEntityManager().getDelegate().getClass().getSimpleName();
			    log.warn("Read only query hint ignored - unsupported provider " + provider);
            }
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
