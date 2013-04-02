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

package org.sculptor.framework.accessimpl.jpa2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.criteria.Predicate;

import org.sculptor.framework.accessapi.FindByKeysAccess2;


/**
 * <p>
 * Find all entities with matching keys. Implementation of Access command
 * FindByKeysAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByKeysAccessImplGeneric<T,R>
    extends JpaCriteriaQueryAccessBase<T,R>
    implements FindByKeysAccess2<R> {

    private String keyPropertyName;
    private String restrictionPropertyName;
    private Set<?> keys;
    private Map<Object, R> result;

    public JpaFindByKeysAccessImplGeneric() {
        super();
    }

    public JpaFindByKeysAccessImplGeneric(Class<T> type) {
        super(type);
    }

    public JpaFindByKeysAccessImplGeneric(Class<T> type, Class<R> resultType) {
        super(type, resultType);
    }

    protected String getKeyPropertyName() {
        return keyPropertyName;
    }

    public void setKeyPropertyName(String keyPropertyName) {
        this.keyPropertyName = keyPropertyName;
    }

    protected String getRestrictionPropertyName() {
        if (restrictionPropertyName == null) {
            return getKeyPropertyName();
        } else {
            return restrictionPropertyName;
        }
    }

    public void setRestrictionPropertyName(String restrictionPropertyName) {
        this.restrictionPropertyName = restrictionPropertyName;
    }

    public void setKeys(Set<?> keys) {
        this.keys = keys;
    }

    public Map<Object, R> getResult() {
        return result;
    }

    @Override
    protected void prepareConfig(QueryConfig config) {
        config.setDisjunction(true);
        config.setEnableLike(false);
        config.setIgnoreCase(false);
    }

    @Override
    protected List<Predicate> preparePredicates() {
        List<Predicate> list = new ArrayList<Predicate>();
        for (Object key : keys) {
            Map<String, Object> restrictions = new HashMap<String, Object>();
            restrictions.put(keyPropertyName, key);
            list.add(preparePredicate(restrictions));
        }
        return list;
    }

    @Override
    protected void prepareResult(List<R> resultList) {
        result = new HashMap<Object, R>();
        for (R entity : resultList) {
            // TODO: introduce new Interface for keyed entities?
            result.put(JpaHelper.getValue(entity, "key"), entity);
        }
    }
}