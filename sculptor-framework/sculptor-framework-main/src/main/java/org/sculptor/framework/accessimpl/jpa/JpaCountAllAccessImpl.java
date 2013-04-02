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

import javax.persistence.PersistenceException;
import javax.persistence.Query;

import org.sculptor.framework.accessapi.CountAllAccess;

/**
 * <p>
 * Counts all entities of a specific type. Implementation of Access command
 * CountAllAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaCountAllAccessImpl<T> extends JpaAccessBase<T> implements CountAllAccess<T> {

    private long result;

    public JpaCountAllAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public long getResult() {
        return this.result;
    }

	@Override
    public void performExecute() throws PersistenceException {
		StringBuilder queryStr = new StringBuilder();
		queryStr.append("select count(e) from ").append(getPersistentClass().getSimpleName()).append(" e");
		result = executeQuery(queryStr.toString());
    }

	protected long executeQuery(String queryStr) {
		Query query = getEntityManager().createQuery(queryStr.toString());
		prepareHints(query);
		return ((Number) query.getSingleResult()).longValue();
	}

	protected void prepareHints(Query query) {
    }

}