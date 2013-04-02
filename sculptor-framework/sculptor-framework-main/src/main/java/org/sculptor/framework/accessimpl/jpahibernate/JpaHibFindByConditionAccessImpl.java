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

package org.sculptor.framework.accessimpl.jpahibernate;

import java.util.ArrayList;
import java.util.Collection;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.PersistenceException;

import org.hibernate.Criteria;
import org.hibernate.FetchMode;
import org.hibernate.criterion.Conjunction;
import org.hibernate.criterion.Criterion;
import org.hibernate.criterion.Disjunction;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.ProjectionList;
import org.hibernate.criterion.Projections;
import org.hibernate.criterion.Restrictions;
import org.hibernate.transform.ResultTransformer;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.FindByConditionAccess;
import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;
import org.sculptor.framework.accessimpl.jpa.JpaAccessBase;

/**
 * <p>
 * Implementation of Access command FindByCriteriaAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaHibFindByConditionAccessImpl<T> extends JpaAccessBase<T>
		implements FindByConditionAccess<T> {

	private List<ConditionalCriteria> cndCriterias = new ArrayList<ConditionalCriteria>();
//	private Set<String> fetchAssociations = new HashSet<String>();
	private int firstResult = -1;
	private int maxResult = 0;
	private boolean realDistinctRoot=false;
	private List<T> result;
	Long rowCount = null;
	private ResultTransformer resultTransformer=Criteria.DISTINCT_ROOT_ENTITY;

	public JpaHibFindByConditionAccessImpl(Class<T> persistentClass) {
		setPersistentClass(persistentClass);
	}

	public void setCondition(List<ConditionalCriteria> criteria) {
		cndCriterias = criteria;
	}

	public void addCondition(ConditionalCriteria criteria) {
		cndCriterias.add(criteria);
	}

	protected int getFirstResult() {
		return firstResult;
	}

	public void setFirstResult(int firstResult) {
		this.firstResult = firstResult;
	}

	protected int getMaxResult() {
		return maxResult;
	}

	public void setMaxResult(int maxResult) {
		this.maxResult = maxResult;
	}

	public List<T> getResult() {
		return this.result;
	}

	@Override
	public void performExecute() throws PersistenceException {
		realDistinctRoot=false;
		Criteria criteria = createCriteria();
		prepareCache(criteria);

		// Prepare where clause
		addSubCriterias(criteria);
		addConditionalCriteria(criteria);
		addFetchStrategy(criteria);

		// Prepare orderBy
		addOrderBy(criteria);

		boolean hasLimit=false;
		if (firstResult >= 0) {
			criteria.setFirstResult(firstResult);
			hasLimit=true;
		}
		if (maxResult >= 1) {
			criteria.setMaxResults(maxResult);
			hasLimit=true;
		}

		if (realDistinctRoot && hasLimit) {
			addProjection(criteria);
			List<?> idList = criteria.list();

			// Prepare ids
			ArrayList<Long> distinctIds=new ArrayList<Long>();
			for (Object idListItem : idList) {
				if (idListItem instanceof Long) {
					distinctIds.add((Long) idListItem);
				} else {
					Object[] row=(Object[]) idListItem;
					distinctIds.add((Long) row[0]);
				}
			}
			if (distinctIds.size() == 0) {
				distinctIds.add(-1l);
			}

			criteria=createCriteria();
			addOrderBy(criteria);
			addResultTransformer(criteria);
			criteria.add(Restrictions.in("id", distinctIds));
			addFetchStrategy(criteria);
		} else {
			addResultTransformer(criteria);
		}

		result = executeFind(criteria);
	}

	private void addFetchStrategy(Criteria criteria) {
		for (ConditionalCriteria crit : cndCriterias) {
			if (Operator.FetchEager.equals(crit.getOperator())) {
				criteria.setFetchMode(crit.getPropertyFullName(), FetchMode.JOIN);
			} else if (Operator.FetchLazy.equals(crit.getOperator())) {
				criteria.setFetchMode(crit.getPropertyFullName(), FetchMode.SELECT);
			}
		}
	}

	private void addProjection(Criteria criteria) throws PersistenceException {
		// Prepare projection
		// All orderBy fields has to be in result - SQL limitation
		ProjectionList proj=Projections.projectionList().add(Projections.id());
		for (ConditionalCriteria crit : cndCriterias) {
			if (Operator.OrderAsc.equals(crit.getOperator()) || Operator.OrderDesc.equals(crit.getOperator())) {
				if (crit.getPropertyPath() != null && crit.getPropertyPath().length > 0) {
					throw new PersistenceException("Can't create distinct condition order by foreign field '"+crit.getPropertyFullName()+"'");
				}
				proj.add(Projections.property(crit.getPropertyFullName()));
			}
		}
		criteria.setProjection(Projections.distinct(proj));
	}

	private void addOrderBy(Criteria criteria) {
		for (ConditionalCriteria crit : cndCriterias) {
			if (Operator.OrderAsc.equals(crit.getOperator())) {
				criteria.addOrder(Order.asc(crit.getPropertyFullName()));
			} else if (Operator.OrderDesc.equals(crit.getOperator())) {
				criteria.addOrder(Order.desc(crit.getPropertyFullName()));
			}
		}
	}

	protected void addConditionalCriteria(Criteria criteria) {
		resultTransformer=Criteria.DISTINCT_ROOT_ENTITY;
		for (ConditionalCriteria crit : cndCriterias) {
			Criterion criterion = makeCriterion(crit);
			if (criterion != null) {
				criteria.add(criterion);
			}
		}
	}

	private Criterion makeCriterion(ConditionalCriteria crit) {
		if (crit == null) {
			return null;
		}

		ConditionalCriteria.Operator operator = crit.getOperator();
		if (Operator.Equal.equals(operator)) {
			return Restrictions.eq(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant());
		} else if (Operator.IgnoreCaseEqual.equals(operator)) {
			return Restrictions.eq(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant()).ignoreCase();
		} else if (Operator.LessThan.equals(operator)) {
			return Restrictions.lt(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant());
		} else if (Operator.LessThanOrEqual.equals(operator)) {
			return Restrictions.le(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant());
		} else if (Operator.GreatThan.equals(operator)) {
			return Restrictions.gt(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant());
		} else if (Operator.GreatThanOrEqual.equals(operator)) {
			return Restrictions.ge(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant());
		} else if (Operator.Like.equals(operator)) {
			// Hibernate bug HHH-5339 + PostgreSQL missing 'number like string' conversion
			return new NumericLikeExpression(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant().toString(), false);
		} else if (Operator.IgnoreCaseLike.equals(operator)) {
			// Hibernate bug HHH-5339 + PostgreSQL missing 'number like string' conversion
			return new NumericLikeExpression(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant().toString(), true);
		} else if (Operator.IsNull.equals(operator)) {
			return Restrictions.isNull(makePathWithAlias(crit.getPropertyFullName()));
		} else if (Operator.IsNotNull.equals(operator)) {
			return Restrictions.isNotNull(makePathWithAlias(crit.getPropertyFullName()));
		} else if (Operator.IsEmpty.equals(operator)) {
			return Restrictions.isEmpty(makePathWithAlias(crit.getPropertyFullName()));
		} else if (Operator.IsNotEmpty.equals(operator)) {
			return Restrictions.isNotEmpty(makePathWithAlias(crit.getPropertyFullName()));
		} else if (Operator.Not.equals(operator)) {
			return Restrictions.not(makeCriterion((ConditionalCriteria) crit.getFirstOperant()));
		} else if (Operator.Or.equals(operator) && crit.getFirstOperant() instanceof List<?>) {
			Disjunction disj=Restrictions.disjunction();
			List<?> disjList=(List<?>) crit.getFirstOperant();
			for (Object disjPart : disjList) {
				disj.add(makeCriterion((ConditionalCriteria) disjPart));
			}
			return disj;
		} else if (Operator.Or.equals(operator)) {
			return Restrictions.or(makeCriterion((ConditionalCriteria) crit.getFirstOperant()),
					makeCriterion((ConditionalCriteria) crit.getSecondOperant()));
		} else if (Operator.And.equals(operator) && crit.getFirstOperant() instanceof List<?>) {
			Conjunction conj=Restrictions.conjunction();
			List<?> conjList=(List<?>) crit.getFirstOperant();
			for (Object conjPart : conjList) {
				conj.add(makeCriterion((ConditionalCriteria) conjPart));
			}
			return conj;
		} else if (Operator.And.equals(operator)) {
			return Restrictions.and(makeCriterion((ConditionalCriteria) crit.getFirstOperant()),
					makeCriterion((ConditionalCriteria) crit.getSecondOperant()));
		} else if (Operator.In.equals(operator)) {
			if (crit.getFirstOperant() instanceof Collection<?>) {
				return Restrictions.in(makePathWithAlias(crit.getPropertyFullName()), (Collection<?>) crit.getFirstOperant());
			} else {
				return Restrictions.in(makePathWithAlias(crit.getPropertyFullName()), (Object[]) crit.getFirstOperant());
			}
		} else if (Operator.Between.equals(operator)) {
			return Restrictions.between(makePathWithAlias(crit.getPropertyFullName()), crit.getFirstOperant(), crit.getSecondOperant());
		} else if (Operator.DistinctRoot.equals(operator)) {
			realDistinctRoot=true;
			return null;
		} else if (Operator.ProjectionRoot.equals(operator)) {
			resultTransformer=Criteria.PROJECTION;
			return null;
		} else if (Operator.EqualProperty.equals(operator)) {
			return Restrictions.eqProperty(makePathWithAlias(crit.getPropertyFullName()), (String) crit.getFirstOperant());
		} else if (Operator.LessThanProperty.equals(operator)) {
			return Restrictions.ltProperty(makePathWithAlias(crit.getPropertyFullName()), (String) crit.getFirstOperant());
		} else if (Operator.LessThanOrEqualProperty.equals(operator)) {
			return Restrictions.leProperty(makePathWithAlias(crit.getPropertyFullName()), (String) crit.getFirstOperant());
		} else if (Operator.GreatThanProperty.equals(operator)) {
			return Restrictions.gtProperty(makePathWithAlias(crit.getPropertyFullName()), (String) crit.getFirstOperant());
		} else if (Operator.GreatThanOrEqualProperty.equals(operator)) {
			return Restrictions.geProperty(makePathWithAlias(crit.getPropertyFullName()), (String) crit.getFirstOperant());
		} else {
			return null;
		}
	}

	private String makePathWithAlias(String propertyFullName) {
		StringBuilder result=new StringBuilder(propertyFullName);
		int lastDotIndex = result.lastIndexOf(".");
		int dotIndex=-1;
		while ( (dotIndex=result.indexOf(".", dotIndex+1)) != -1 && dotIndex < lastDotIndex) {
			result.setCharAt(dotIndex, '_');
		}

		return result.toString();
	}

	protected void prepareCache(Criteria criteria) {
		if (isCache()) {
			criteria.setCacheable(true);
			criteria.setCacheRegion(getCacheRegion());
		}
	}

	@SuppressWarnings("unchecked")
	protected List<T> executeFind(Criteria criteria) {
		return criteria.list();
	}

	public void executeCount() {
		final Criteria criteria = createCriteria();
		prepareCache(criteria);

		// Prepare where clause
		addSubCriterias(criteria);
		addConditionalCriteria(criteria);

		addResultTransformer(criteria);

		if (realDistinctRoot) {
			criteria.setProjection(Projections.countDistinct(Criteria.ROOT_ALIAS+".id"));
		} else {
			criteria.setProjection(Projections.count(Criteria.ROOT_ALIAS+".id"));
		}
		rowCount = (Long) criteria.uniqueResult();
	}

	public Long getResultCount() {
		return rowCount;
	}

	/**
	 * By default a DISTINCT_ROOT_ENTITY result transformer is set on the
	 * criteria. Can be overridden to define another transformer.
	 */
	protected void addResultTransformer(final Criteria criteria) {
		criteria.setResultTransformer(resultTransformer);
	}

	protected Criteria createCriteria() {
		return HibernateSessionHelper.getHibernateSession(getEntityManager()).createCriteria(getPersistentClass());
	}

	/**
	 * Default fetch mode is FetchMode.JOIN. Can be overridden.
	 */
	protected FetchMode getFetchMode(String associationPath) {
		return FetchMode.JOIN;
	}

	protected void addSubCriterias(Criteria criteria) {
		List<String> subCriteriaNames = getSubCriteriaNames();
		for (String criteriaPath : subCriteriaNames) {
			criteria.createAlias(criteriaPath, criteriaPath.replace('.', '_'), Criteria.LEFT_JOIN);
		}
	}

	protected List<String> getSubCriteriaNames() {
		// Add path from criteria
		Set<String> allNames = new HashSet<String>();
		for (ConditionalCriteria c : cndCriterias) {
			getRecursiveSubCriteriaNames(c, allNames);
		}

		// sort by name length to make sure the criterias are added in the right
		// order
		List<String> namesList = new ArrayList<String>(allNames);
		sortByStringLength(namesList);

		return namesList;
	}

	private void getRecursiveSubCriteriaNamesArray(List<?> objArr, Set<String> names) {
		for (Object elem : objArr) {
			if (elem instanceof ConditionalCriteria) {
				getRecursiveSubCriteriaNames((ConditionalCriteria) elem, names);
			}
		}
	}

	private void getRecursiveSubCriteriaNames(ConditionalCriteria crit, Set<String> names) {
		if (crit != null && crit.getPropertyPath() != null && crit.getPropertyPath().length > 0) {
			String currentName=null;
			for (String propElem: crit.getPropertyPath()) {
				currentName = (currentName == null ? "" : currentName + ".") + propElem;
				names.add(currentName);
			}
		}

		if (crit.getFirstOperant() instanceof ConditionalCriteria) {
			getRecursiveSubCriteriaNames((ConditionalCriteria) crit.getFirstOperant(), names);
		}
		if (crit.getSecondOperant() instanceof ConditionalCriteria) {
			getRecursiveSubCriteriaNames((ConditionalCriteria) crit.getSecondOperant(), names);
		}
		if (crit.getFirstOperant() instanceof List && (
				Operator.And.equals(crit.getOperator())
				|| Operator.Or.equals(crit.getOperator())
				|| Operator.Not.equals(crit.getOperator())
				)) {
			getRecursiveSubCriteriaNamesArray((List<?>) crit.getFirstOperant(), names);
		}

		// Compare with another property (parse also second property name)
		if (crit != null && crit.getFirstOperant() != null && (
				crit.getOperator().equals(Operator.EqualProperty)
				|| crit.getOperator().equals(Operator.LessThanProperty)
				|| crit.getOperator().equals(Operator.LessThanOrEqualProperty)
				|| crit.getOperator().equals(Operator.GreatThanProperty)
				|| crit.getOperator().equals(Operator.GreatThanOrEqualProperty))) {
			String secondProperty=(String) crit.getFirstOperant();
			int lastDotPos = secondProperty.lastIndexOf('.');
			if (lastDotPos != -1) {
				String currentName=null;
				String[] secSplit=secondProperty.substring(0, lastDotPos).split("\\.");
				for (String propElem: secSplit) {
					currentName = (currentName == null ? "" : currentName + ".") + propElem;
					names.add(currentName);
				}
			}
		}
	}

	private void sortByStringLength(List<String> list) {
		Collections.sort(list, new StringLengthComparator());
	}

	private static class StringLengthComparator implements Comparator<String> {
		public int compare(String s1, String s2) {
			return (s1.length() < s2.length() ? -1 : (s1.length() == s2.length() ? 0 : 1));
		}
	}
}
