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

import javax.persistence.PersistenceException;
import javax.persistence.Query;

import org.sculptor.framework.accessapi.FindAllAccess;
import org.sculptor.framework.domain.Property;


/**
 * <p>
 * Find all entities of a specific type. Implementation of Access command
 * FindAllAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindAllAccessImpl<T> extends JpaAccessBase<T> implements FindAllAccess<T> {

	private String orderBy;
    private boolean orderByAsc = true;
    private int firstResult = -1;
    private int maxResult = 0;
    private List<T> result;
	private Property<?>[] fetchEager;

    public JpaFindAllAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
    }

    public boolean isOrderByAsc() {
        return orderByAsc;
    }

    public void setOrderByAsc(boolean orderByAsc) {
        this.orderByAsc = orderByAsc;
    }

    public void setFetchEager(Property<?>[] fetchEager) {
        this.fetchEager = fetchEager;
    }

    public Property<?>[] getFetchEager() {
        return fetchEager;
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
		StringBuilder queryStr = new StringBuilder();
		queryStr.append("select e from ").append(getPersistentClass().getSimpleName()).append(" as e");
		if (orderBy != null) {
			queryStr.append(" order by e.").append(orderBy);
			if (!isOrderByAsc()) {
				queryStr.append(" desc");
			}
		}
		if (fetchEager != null && fetchEager.length != 0) {
			for (Property<?> eagerProp : fetchEager) {
				queryStr.append(" left join fetch e.").append(eagerProp.getName());
			}
		}
		result = executeQuery(queryStr.toString());
	}

	@SuppressWarnings("unchecked")
	protected List<T> executeQuery(String queryStr) {
		Query query = getEntityManager().createQuery(queryStr.toString());
		prepareHints(query);

		if (firstResult >= 0) {
			query.setFirstResult(firstResult);
		}
		if (maxResult >= 1) {
			query.setMaxResults(maxResult);
		}
		return query.getResultList();
	}

	protected void prepareHints(Query query) {
    }

}