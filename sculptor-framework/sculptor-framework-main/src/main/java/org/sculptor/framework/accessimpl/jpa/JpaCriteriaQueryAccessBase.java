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

import java.lang.reflect.Field;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.TypedQuery;
import javax.persistence.criteria.CriteriaBuilder;
import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Expression;
import javax.persistence.criteria.FetchParent;
import javax.persistence.criteria.From;
import javax.persistence.criteria.Join;
import javax.persistence.criteria.JoinType;
import javax.persistence.criteria.Path;
import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;
import javax.persistence.criteria.SetJoin;
import javax.persistence.metamodel.Attribute;
import javax.persistence.metamodel.Attribute.PersistentAttributeType;
import javax.persistence.metamodel.ManagedType;
import javax.persistence.metamodel.Metamodel;
import javax.persistence.metamodel.SingularAttribute;

import org.sculptor.framework.domain.AbstractDomainObject;
import org.sculptor.framework.domain.Property;

/**
 * <p>
 * Implementation of Access command FindByQueryAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public abstract class JpaCriteriaQueryAccessBase<T, R> extends JpaQueryAccessBase<T, R> {

	private CriteriaBuilder criteriaBuilder = null;
	private Metamodel metaModel = null;
	private CriteriaQuery<R> criteriaQuery = null;
	private Root<T> root = null;

	private QueryExpressions<T> expressions = new QueryExpressions<T>();

	private TypedQuery<Long> resultCountQuery = null;
	private Property<?>[] fetchEager;

	public JpaCriteriaQueryAccessBase() {
		super();
	}

	public JpaCriteriaQueryAccessBase(Class<T> type) {
		super(type);
	}

	public JpaCriteriaQueryAccessBase(Class<T> type, Class<R> resultType) {
		super(type, resultType);
	}

	protected CriteriaBuilder getCriteriaBuilder() {
		return criteriaBuilder;
	}

	protected void setCriteriaBuilder(CriteriaBuilder builder) {
		this.criteriaBuilder = builder;
	}

	protected CriteriaQuery<R> getCriteriaQuery() {
		return criteriaQuery;
	}

	protected void setCriteriaQuery(CriteriaQuery<R> query) {
		this.criteriaQuery = query;
	}

	protected Root<T> getRoot() {
		return root;
	}

	protected void setRoot(Root<T> root) {
		this.root = root;
	}

	protected Metamodel getMetaModel() {
		return metaModel;
	}

	protected void setMetaModel(Metamodel metaModel) {
		this.metaModel = metaModel;
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

	public void setFetchEager(Property<?>[] fetchEager) {
		this.fetchEager = fetchEager;
	}

	public Property<?>[] getFetchEager() {
		return fetchEager;
	}

	public void setSelections(String selections) {
		expressions.addSelections(selections);
	}

	public void setGroupBy(String groupBy) {
		expressions.addGroups(groupBy);
	}

	@Override
	protected void init() {
		criteriaBuilder = getEntityManager().getCriteriaBuilder();
		metaModel = getEntityManager().getMetamodel();
	}

	@Override
	final protected void prepareQuery(QueryConfig config) {
		if (criteriaQuery == null) {
			criteriaQuery = criteriaBuilder.createQuery(getResultType());
		}
		root = criteriaQuery.from(getType());
		prepareSelect(criteriaQuery, root, config);
		prepareGroupBy(criteriaQuery, root, config);
		prepareFetch(root, config);
		List<Predicate> predicates = preparePredicates();
		prepareDistinct(config);
		if (predicates != null && predicates.size() > 0) {
			criteriaQuery.where((config.isDisjunction()) ? orPredicates(predicates) : andPredicates(predicates));
		}
	}

	protected void prepareSelect(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
	}

	protected void prepareDistinct(QueryConfig config) {
		criteriaQuery.distinct(config.isDistinct());
	}

	protected void prepareGroupBy(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
	}

	@Override
	final protected void prepareOrderBy(QueryConfig config) {
		prepareOrderBy(criteriaQuery, root, config);
	}

	protected void prepareOrderBy(CriteriaQuery<R> criteriaQuery, Root<T> root, QueryConfig config) {
	}

	protected List<Predicate> preparePredicates() {
		return null;
	}

	protected void prepareFetch(Root<T> root, QueryConfig config) {
	}

	@Override
	protected TypedQuery<R> prepareTypedQuery(QueryConfig config) {
		return getEntityManager().createQuery(criteriaQuery);
	}

	@Override
	protected void prepareResultCount(QueryConfig config) {
	};

	@Override
	public void executeResultCount() {
		if (resultCountQuery == null) {
			CriteriaQuery<Long> resultCountCriteriaQuery = criteriaBuilder.createQuery(Long.class);
			// TODO: works only T = R
			Root<?> countRoot = resultCountCriteriaQuery.from(getType());
			if (getConfig().isDistinct()) {
				resultCountCriteriaQuery.select(criteriaBuilder.countDistinct(countRoot));
			} else {
				resultCountCriteriaQuery.select(criteriaBuilder.count(countRoot));
			}
			if (criteriaQuery.getRestriction() != null) {
				resultCountCriteriaQuery.where(criteriaQuery.getRestriction());
			}
			copyJoinRecursive(getRoot(), countRoot);
			// copy explicit joins
			resultCountQuery = getEntityManager().createQuery(resultCountCriteriaQuery);
		}
		setResultCount(resultCountQuery.getSingleResult());
	}

	private void copyJoinRecursive(From from, From to) {
		if (from.getJoins() != null && from.getJoins().size() > 0) {
			Set<Join<T, ?>> joins = from.getJoins();
			for (Join<T, ?> join : joins) {
				Join toJoin = to.join(join.getAttribute().getName(), join.getJoinType());
				toJoin.alias(join.getAlias());
				copyJoinRecursive(join, toJoin);
			}
		}
	}

	/**
	 * 
	 * @param path
	 * @param type
	 * @param entity
	 * @return
	 */
	protected List<Predicate> preparePredicates(Object entity) {
		return preparePredicates(root, metaModel.managedType(getType()), entity);
	}

	/**
	 * 
	 * @param path
	 * @param type
	 * @param entity
	 * @return
	 */
	@SuppressWarnings({ "rawtypes", "unchecked" })
	protected List<Predicate> preparePredicates(Path<?> path, ManagedType type, Object managedObject) {

		List<Predicate> predicates = new ArrayList<Predicate>();

		// TODO: this is a temporary workaround for datanucleus,
		// getSingularAttribute is not working correctly together with
		// MappedSuperclass
		Set<SingularAttribute> singularAttributes = new HashSet<SingularAttribute>();
		Set<Attribute> attributes = type.getAttributes();
		for (Attribute attribute : attributes) {
			if (attribute instanceof SingularAttribute) {
				singularAttributes.add((SingularAttribute) attribute);
			}
		}

		for (SingularAttribute attribute : singularAttributes) {

			// exclude properties
			if (getConfig().getExcludeProperties().contains(attribute.getName())) {
				continue;
			}

			Object value = JpaHelper.getValue(managedObject, attribute);
			if (value == null) {
				if (!getConfig().isExcludeZeroes()) {
					predicates.add(path.get(attribute).isNull());
				}
				continue;
			}

			if (isAttributeSingularManagedType(attribute)) {
				predicates.addAll(preparePredicates(path.get(attribute), (ManagedType) attribute.getType(), value));
			} else {
				predicates.add(preparePredicate(path.get(attribute), value));
			}
		}

		return predicates;
	}

	/**
	 * 
	 * @param restrictions
	 * @return
	 */
	protected List<Predicate> preparePredicates(Map<String, Object> restrictions) {
		return preparePredicates(root, restrictions);
	}

	/**
	 * Convenience method to get a single (conjunction) predicate for
	 * 
	 * @param restrictions
	 * @return
	 */
	protected Predicate preparePredicate(Map<String, Object> restrictions) {
		return preparePredicate(restrictions, true);
	}

	/**
	 * 
	 * @param restrictions
	 * @param disjunction
	 * @return
	 */
	protected Predicate preparePredicate(Map<String, Object> restrictions, boolean AND) {
		return (AND) ? andPredicates(preparePredicates(restrictions)) : orPredicates(preparePredicates(restrictions));
	}

	/**
	 * 
	 * @param path
	 * @param restrictions
	 * @return
	 */
	private List<Predicate> preparePredicates(Path<?> path, Map<String, Object> restrictions) {
		List<Predicate> predicates = new ArrayList<Predicate>();
		for (String property : restrictions.keySet()) {
			predicates.add(preparePredicate(path, property, restrictions.get(property)));
		}
		return predicates;
	}

	/**
	 * 
	 * @param path
	 * @param property
	 * @param value
	 * @return
	 */
	private Predicate preparePredicate(Path<?> path, String property, Object value) {
		path = getPath(path, property);

		if (value == null) {
			return path.isNull();
		}

		// openjpa and datanucleus do not support embeddables as restriction
		// directly
		// TODO: verify whether this is working now
		if (JpaHelper.isJpaProviderOpenJpa(getEntityManager())
				|| JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
			for (ManagedType<?> embeddableType : metaModel.getEmbeddables()) {
				if (embeddableType.getJavaType().equals(value.getClass())) {
					return andPredicates(preparePredicates(path, embeddableType, value));
				}
			}
		}

		return preparePredicate(path, value);
	}

	/**
	 * 
	 * @param path
	 * @param value
	 * @return
	 */
	protected Predicate preparePredicate(Path<?> path, Object value) {
		if (value instanceof String) {
			return preparePredicate(path, (String) value);
		}
		return criteriaBuilder.equal(path, value);
	}

	/**
	 * 
	 * @param path
	 * @param value
	 * @return
	 */
	@SuppressWarnings("unchecked")
	private Predicate preparePredicate(Path<?> path, String value) {
		// TODO: workaround for datanucleus
		// use unchecked cast, because datanucleus 2.x has not implemented
		// path.as
		// and 3.x has still problems
		if (path.getJavaType() != String.class) {
			throw new QueryConfigException("Path is not of type string.");
		}
		Expression<String> stringExpression = (getConfig().isIgnoreCase()) ? criteriaBuilder.upper((Path<String>) path)
				: (Path<String>) path;
		String stringValue = (getConfig().isIgnoreCase()) ? value.toString().toUpperCase() : value.toString();
		return (getConfig().isEnableLike()) ? criteriaBuilder.like(stringExpression, stringValue) : criteriaBuilder
				.equal(stringExpression, stringValue);
	}

	/**
	 * 
	 * @param predicates
	 * @return
	 */
	protected Predicate conjunctPredicates(List<Predicate> predicates) {
		if (predicates == null || predicates.size() == 0)
			return null;
		Predicate predicate = criteriaBuilder.conjunction();
		for (Predicate p : predicates) {
			predicate = criteriaBuilder.and(predicate, p);
		}
		return predicate;
	}

	/**
	 * 
	 * @param predicates
	 * @return
	 */
	protected Predicate disjunctPredicates(List<Predicate> predicates) {
		if (predicates == null || predicates.size() == 0)
			return null;
		Predicate predicate = criteriaBuilder.disjunction();
		for (Predicate p : predicates) {
			predicate = criteriaBuilder.or(predicate, p);
		}
		return predicate;
	}

	/**
	 * 
	 * @param predicates
	 * @return
	 */
	protected Predicate andPredicates(List<Predicate> predicates) {
		if (predicates == null || predicates.size() == 0)
			return null;
		Predicate predicate = null;
		for (Predicate p : predicates) {
			if (predicate == null)
				predicate = p;
			else
				predicate = criteriaBuilder.and(predicate, p);
		}
		return predicate;
	}

	/**
	 * 
	 * @param predicates
	 * @return
	 */
	protected Predicate orPredicates(List<Predicate> predicates) {
		if (predicates == null || predicates.size() == 0)
			return null;
		Predicate predicate = null;
		for (Predicate p : predicates) {
			if (predicate == null)
				predicate = p;
			else {
				predicate = criteriaBuilder.or(predicate, p);
			}
		}
		return predicate;
	}

	protected Path<?> getPath(Path<?> fromPath, String property) {
		return getPath(fromPath, property, true);
	}

	protected Path<?> getPath(Path<?> fromPath, String property, boolean enforceJoin) {
		if (property == null) {
			return null;
		}
		if (isNestedProperty(property)) {
			return getPathForNestedProperty(fromPath, property, enforceJoin);
		}
		return getPathForSimpleProperty(fromPath, property);
	}

	private boolean isNestedProperty(String property) {
		if (property.contains(".")) {
			return true;
		}
		return false;
	}

	private Path<?> getPathForSimpleProperty(Path<?> fromPath, String simpleProperty) {
		return fromPath.get(simpleProperty);
	}

	private Path<?> getPathForNestedProperty(Path<?> fromPath, String nestedProperties, boolean enforceExplicit) {
		Path<?> path = fromPath;
		List<String> properties = Arrays.asList(nestedProperties.split("\\."));
		List<String> investPath = new ArrayList<String>();
		for (Iterator<String> iterator = properties.iterator(); iterator.hasNext();) {
			String property = iterator.next();
			investPath.add(property);
			if ( (enforceExplicit || isExplicitJoinNeeded(path, property)) && iterator.hasNext()) {
				path = getExplicitJoinForPath(fromPath, investPath);
			} else {
				path = getPathForSimpleProperty(path, property);
			}
		}
		return path;
	}

	private boolean isExplicitJoinNeeded(Path<?> path, String property) {
		// eclipselink and openjpa do not need an explicit join
		if (!JpaHelper.isJpaProviderHibernate(getEntityManager())
				&& !JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
			return false;
		}

		for (Class<?> c = path.getJavaType(); !c.equals(Object.class); c = c.getSuperclass()) {
			try {
				Field declaredField = c.getDeclaredField(property);
				Class<?> type = declaredField.getType();
				if (Collection.class.isAssignableFrom(type) || Map.class.isAssignableFrom(type)) {
					return true;
				}
			} catch (NoSuchFieldException e) {
			}
		}
		return false;
	}

	private boolean isCollection(Path<?> path) {
		Class<?> type = path.getJavaType();
		if (Collection.class.isAssignableFrom(type)) {
			return true;
		}
		return false;
	}

	private boolean isMap(Path<?> path) {
		Class<?> type = path.getJavaType();
		if (Map.class.isAssignableFrom(type)) {
			return true;
		}
		return false;
	}

	protected <F> From<?, ?> getExplicitJoinForPath(Path<F> fromPath, List<String> pathElems) {
		if (From.class.isAssignableFrom(fromPath.getClass())) {
			From<?, F> curPath = (From<?, F>) fromPath;
			for (String pathElem : pathElems) {
				Set<Join<F,?>> joins = curPath.getJoins();
				boolean found=false;
				for (Join<F, ?> join : joins) {
					if (join.getAttribute().getName().equals(pathElem)) {
						curPath = (From) join;
						found=true;
						break;
					}
				}
				if (!found) {
					curPath = curPath.join(pathElem, JoinType.LEFT);
				}
			}
			return curPath;
		}

		// Concat path with dots
		StringBuilder dotPath=new StringBuilder();
		String delim="";
		for (String pathElem : pathElems) {
			dotPath.append(delim).append(pathElem);
			delim=".";
		}
		throw new QueryConfigException("Can't create a explicit join for property path " + dotPath + " from " + fromPath);
	}

	/**
	 * 
	 * @param type
	 * @return
	 */
	@SuppressWarnings("rawtypes")
	protected Attribute<?, ?> getAttribute(ManagedType<?> type, String property) {
		if (type == null || property == null) {
			return null;
		}

		if (!property.contains(".")) {
			return type.getAttribute(property);
		}

		Attribute<?, ?> attribute = type.getAttribute(property.substring(0, property.indexOf(".")));
		if (!attribute.isCollection() && isAttributeSingularManagedType(attribute)) {
			return getAttribute((ManagedType<?>) ((SingularAttribute) attribute).getType(),
					property.substring(property.indexOf(".") + 1));
		}

		return attribute;
	}

	@SuppressWarnings({ "unused" })
	private boolean isManagedType(Class<?> type) {
		for (ManagedType<?> managedType : metaModel.getManagedTypes()) {
			if (managedType.getJavaType().equals(type)) {
				return true;
			}
		}
		return false;
	}

	private boolean isAttributeSingularManagedType(Attribute<?, ?> attribute) {
		if (PersistentAttributeType.EMBEDDED.equals(attribute.getPersistentAttributeType())
				|| PersistentAttributeType.MANY_TO_ONE.equals(attribute.getPersistentAttributeType())
				|| PersistentAttributeType.ONE_TO_ONE.equals(attribute.getPersistentAttributeType())) {
			return true;
		}
		return false;
	}

}
