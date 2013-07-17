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
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import javax.persistence.PersistenceException;

import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.FindByConditionAccess;
import org.sculptor.framework.domain.Property;


/**
 * <p>
 * Implementation of Access command FindByConditionAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByConditionAccessImpl<T> extends JpaAccessBase<T> implements FindByConditionAccess<T> {

    private List<ConditionalCriteria> cndCriterias=new ArrayList<ConditionalCriteria>();
    private Set<String> fetchAssociations = new HashSet<String>();
    private int firstResult = -1;
    private int maxResult = 0;
    private List<T> result;
	private Property<?>[] fetchEager;

    public JpaFindByConditionAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public void setCondition(List<ConditionalCriteria> criteria) {
		cndCriterias=criteria;
	}

	public void addCondition(ConditionalCriteria criteria) {
		cndCriterias.add(criteria);
	}

    public void setFetchAssociations(Set<String> associationPaths) {
        this.fetchAssociations = associationPaths;
    }

    public void addFetchAssociation(String associationPath) {
        this.fetchAssociations.add(associationPath);
    }

    protected Set<String> getFetchAssociations() {
        return fetchAssociations;
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

	public void setFetchEager(Property<?>[] fetchEager) {
		this.fetchEager = fetchEager;
	}

	public Property<?>[] getFetchEager() {
		return fetchEager;
	}

    public List<T> getResult() {
        return this.result;
    }

    @Override
    public void performExecute() throws PersistenceException {
    	// JPA 2.0 will contain criteria API similar to Hibernate criteria API
    	// Till then we can't support this
        throw new UnsupportedOperationException("FindByCondition is not supported.");
    }

	public Long getResultCount() {
    	// JPA 2.0 will contain criteria API similar to Hibernate criteria API
    	// Till then we can't support this
        throw new UnsupportedOperationException("FindByCondition is not supported.");
	}

	@Override
	public void executeCount() {
    	// JPA 2.0 will contain criteria API similar to Hibernate criteria API
    	// Till then we can't support this
        throw new UnsupportedOperationException("FindByCondition is not supported.");
	}
}
