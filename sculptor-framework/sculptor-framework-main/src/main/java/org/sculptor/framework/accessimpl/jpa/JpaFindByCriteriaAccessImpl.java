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

import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.PersistenceException;

import org.sculptor.framework.accessapi.FindByCriteriaAccess;


/**
 * <p>
 * Implementation of Access command FindByCriteriaAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByCriteriaAccessImpl<T> extends JpaAccessBase<T> implements FindByCriteriaAccess<T> {

    private Map<String, Object> restrictions = new HashMap<String, Object>();
    private Set<String> fetchAssociations = new HashSet<String>();
    private String orderBy;
    private boolean orderByAsc = true;
    private int firstResult = -1;
    private int maxResult = 0;
    private List<T> result;

    public JpaFindByCriteriaAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public void setRestrictions(Map<String, Object> parameters) {
        this.restrictions = parameters;
    }

    protected Map<String, Object> getRestrictions() {
        return restrictions;
    }

    public void addRestriction(String name, Object value) {
        restrictions.put(name, value);
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

    public String getOrderBy() {
        return orderBy;
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
        throw new UnsupportedOperationException("FindByCriteris is not supported.");
    }
}