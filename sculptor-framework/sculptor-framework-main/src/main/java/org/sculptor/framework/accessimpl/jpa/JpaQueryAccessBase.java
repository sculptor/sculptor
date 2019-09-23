/*
String[] * Copyright 2007 The Fornax Project Team, including the original
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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.NoResultException;
import javax.persistence.PersistenceException;
import javax.persistence.Query;
import javax.persistence.TypedQuery;

/**
 * <p>
 * Implementation of Access command FindByQueryAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public abstract class JpaQueryAccessBase<T,R>
    extends JpaAccessBase<T> {

    private List<R> listResult = null;
    private R singleResult = null;
    private Class<T> type;
    private Class<R> resultType = null;
    private Long resultCount = null;
    private Map<String, Object> hints = new HashMap<String, Object>();
    private Map<String, Object> parameters = new HashMap<String, Object>();

    private QueryConfig config = new QueryConfig.Default();

    public JpaQueryAccessBase () {
        super();
    }

    @SuppressWarnings("unchecked")
    public JpaQueryAccessBase (Class<T> type) {
        super();
        setPersistentClass(type);
        setType(type);
        setResultType((Class<R>)type);
    }

    public JpaQueryAccessBase (Class<T> type, Class<R> resultType) {
        super();
        setPersistentClass(type);
        setType(type);
        setResultType(resultType);
    }

    protected int getFirstResult() {
        return config.getFirstResult();
    }

    public void setFirstResult(int firstResult) {
        config.setFirstResult(firstResult);
    }

    protected int getMaxResult() {
        return config.getMaxResults();
    }

    public void setMaxResult(int maxResult) {
        config.setMaxResults(maxResult);
    }

    protected QueryConfig getConfig() {
        return config;
    }

    protected Map<String, Object> getParameters() {
        return parameters;
    }

    public void setParameters(Map<String, Object> parameters) {
        this.parameters = parameters;
    }

    public void addParameter(String name, Object value) {
        parameters.put(name, value);
    }

    protected boolean isUseSingleResult() {
        return getConfig().isSingleResult();
    }

    public void setUseSingleResult(boolean useSingleResult) {
        getConfig().setSingleResult(useSingleResult);
    }

    public Class<R> getResultType() {
        return resultType;
    }

    public void setResultType(Class<R> resultType) {
        this.resultType = resultType;
    }

    public Class<T> getType() {
        return type;
    }

    public void setType(Class<T> type) {
        this.type = type;
    }

    public R getSingleResult() {
        if (singleResult != null) {
            return singleResult;
        }
        if (listResult != null && !listResult.isEmpty()) {
            return listResult.get(0);
        }
        return null;
    }

    protected void setSingleResult(R singleResult) {
        this.singleResult = singleResult;
    }

    public List<R> getListResult() {
        return this.listResult;
    }

    protected void setListResult(List<R> listResult) {
        this.listResult = listResult;
    }

    public Long getResultCount() {
        return resultCount;
    }

    protected void setResultCount(Long resultCount) {
        this.resultCount = resultCount;
    }

    public void setHint(String hint, Object value) {
    	hints.put(hint, value);
    }

    @SuppressWarnings("unchecked")
	@Override
    final public void performExecute() throws PersistenceException {
        init();
        validate();
        prepareConfig(config);
        prepareQuery(config);
        prepareOrderBy(config);
        // there is no support for Tuple in JPQL, need an untyped query for jpql queries with more than one result expression
        // TODO: refactoring
        Query query;
        if (resultType.isArray()) {
            query = prepareUntypedQuery(config);
        } else {
            query = prepareTypedQuery(config);
        }

		prepareParameters(query, getParameters(), config);
		preparePagination(query, config);
		prepareHints(query, config);
		if (config.isSingleResult()) {
			try {
				singleResult = (R) query.getSingleResult();
			} catch (NoResultException e) {
				singleResult = null;
			}
			prepareSingleResult(singleResult);
		} else if (config.isScroll()) {
			listResult = new StreamOnlyList<R>(query.getResultStream());
		} else {
			listResult = query.getResultList();
			prepareResult(listResult);
		}

        if (config.isResultCountNeeded()) {
//          TypedQuery<Long> typedResultCountQuery = prepareResultCount(config);
            prepareResultCount(config);
            // TODO: run executeResultCount automatically, create handling for that
            // executeResultCount();
        }
    }

    protected void init() { }

    protected void validate() { }

    protected void prepareConfig(QueryConfig config) { }

    protected void prepareQuery(QueryConfig config) { }

    protected void prepareOrderBy(QueryConfig config) { }

    abstract protected TypedQuery<R> prepareTypedQuery(QueryConfig config);

    protected Query prepareUntypedQuery(QueryConfig config) { return null; }

    protected void preparePagination(Query query, QueryConfig config) {
        if (config.getFirstResult() >= 0) {
            query.setFirstResult(config.getFirstResult());
        }
        if (config.getMaxResults() >= 1) {
            query.setMaxResults(config.getMaxResults());
        }
    }

    protected void prepareParameters(Query query, Map<String, Object> parameters, QueryConfig config) {
        if (parameters != null) {
            for (Map.Entry<String, Object> entry : parameters.entrySet()) {
                query.setParameter(entry.getKey(), entry.getValue());
            }
        }
    }

    protected void prepareHints(Query query, QueryConfig config) {
        if (isCache()) {
            // TODO: add support for other jpa provider or let the provider handle the caching (recommended)
            if (JpaHelper.isJpaProviderHibernate(getEntityManager())) {
                // TODO: hibernate has problems caching queries with embedded types as parameter
//                query.setHint("org.hibernate.cacheable", "true");
//                query.setHint("org.hibernate.cacheRegion", getCacheRegion());
            }
        }
        if (!hints.isEmpty()) {
        	for (Map.Entry<String, Object> entry : hints.entrySet()) {
            	query.setHint(entry.getKey(), entry.getValue());
			}
        }
    }

    protected void prepareSingleResult(R result) { }

    protected void prepareResult(List<R> result) { }

    protected void prepareResultCount(QueryConfig config) { }

    protected void executeResultCount() { }
}