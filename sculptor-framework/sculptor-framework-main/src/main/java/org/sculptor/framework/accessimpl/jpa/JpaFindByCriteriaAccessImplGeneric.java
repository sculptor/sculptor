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

import javax.persistence.criteria.Predicate;
import javax.persistence.criteria.Root;

import org.sculptor.framework.accessapi.FindByCriteriaAccess2;


/**
 * <p>
 * Implementation of Access command FindByCriteriaAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByCriteriaAccessImplGeneric<T,R>
    extends JpaCriteriaQueryAccessBase<T,R>
    implements FindByCriteriaAccess2<R> {

    private Set<String> fetchAssociations = new HashSet<String>();
    private Map<String, Object> restrictions = new HashMap<String, Object>();

    public JpaFindByCriteriaAccessImplGeneric() {
        super();
    }

    public JpaFindByCriteriaAccessImplGeneric(Class<T> type) {
        super(type);
    }

    public JpaFindByCriteriaAccessImplGeneric(Class<T> type, Class<R> resultType) {
        super(type, resultType);
    }

	public void setRestrictions(Map<String, Object> restrictions) {
	    if (restrictions == null)
	        return;
	    this.restrictions.putAll(restrictions);
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

	public List<R> getResult() {
        return getListResult();
    }

	@Override
    protected List<Predicate> preparePredicates() {
	    return preparePredicates(restrictions);
    }

    @Override
    protected void prepareFetch(Root<T> root, QueryConfig config) {
        for (String path : fetchAssociations) {
            root.fetch(path);
        }
    }
}