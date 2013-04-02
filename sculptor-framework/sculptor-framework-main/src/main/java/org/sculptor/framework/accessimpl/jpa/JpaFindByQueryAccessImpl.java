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

import java.util.List;
import java.util.Map;

import javax.persistence.PersistenceException;
import javax.persistence.Query;

import org.sculptor.framework.accessapi.FindByQueryAccess;

/**
 * <p>
 * Implementation of Access command FindByQueryAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByQueryAccessImpl<T> extends JpaAccessBase<T> implements FindByQueryAccess<T> {

    private String query;
    private Map<String, Object> parameters;
    private Boolean namedQuery;
    private int firstResult = -1;
    private int maxResult = 0;
    private List<T> result;
    private boolean useSingleResult;
    private Object singleResult;

    public JpaFindByQueryAccessImpl() {
    }

    public JpaFindByQueryAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    protected String getQuery() {
        return query;
    }

    @Override
    public void setQuery(String aQuery) {
        query = aQuery;
    }

    protected Map<String, Object> getParameters() {
        return parameters;
    }

    @Override
    public void setParameters(Map<String, Object> parameters) {
        this.parameters = parameters;
    }

    protected boolean isNamedQuery() {
        if (namedQuery != null) {
            return namedQuery;
        }
        if (query == null) {
            return false;
        }
        return !query.contains(" ");
    }

    @Override
    public void setNamedQuery(boolean namedQuery) {
        this.namedQuery = namedQuery;
    }

    protected int getFirstResult() {
        return firstResult;
    }

    @Override
    public void setFirstResult(int firstResult) {
        this.firstResult = firstResult;
    }

    protected int getMaxResult() {
        return maxResult;
    }

    @Override
    public void setMaxResult(int maxResult) {
        this.maxResult = maxResult;
    }

    protected boolean isUseSingleResult() {
        return useSingleResult;
    }

    @Override
    public void setUseSingleResult(boolean useSingleResult) {
        this.useSingleResult = useSingleResult;
    }

    @Override
    public Object getSingleResult() {
        if (singleResult != null) {
            return singleResult;
        }
        if (result != null && !result.isEmpty()) {
            return result.get(0);
        }
        return null;
    }

    protected void setSingleResult(Object singleResult) {
        this.singleResult = singleResult;
    }

    @Override
    public List<T> getResult() {
        return this.result;
    }

    protected void setResult(List<T> result) {
        this.result = result;
    }

    @Override
    @SuppressWarnings("unchecked")
    public void performExecute() throws PersistenceException {
        Query queryObject;
        if (isNamedQuery()) {
            queryObject = getEntityManager().createNamedQuery(query);
            // hints may be defined on the named query itself
        } else {
            queryObject = getEntityManager().createQuery(query);
            prepareHints(queryObject);
        }

        if (firstResult >= 0) {
            queryObject.setFirstResult(firstResult);
        }
        if (maxResult >= 1) {
            queryObject.setMaxResults(maxResult);
        }

        if (parameters != null) {
            for (Map.Entry<String, ?> entry : parameters.entrySet()) {
                queryObject.setParameter(entry.getKey(), entry.getValue());
            }
        }

        if (useSingleResult) {
            this.singleResult = queryObject.getSingleResult();
        } else {
            this.result = queryObject.getResultList();
        }
    }

    protected void prepareHints(Query query) {
    }

}