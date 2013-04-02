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

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.persistence.criteria.Predicate;

import org.sculptor.framework.accessapi.FindByKeyAccess;

/**
 * <p>
 * Find domain object with specified natural key. Implementation of Access
 * command FindByKeyAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByKeyAccessImpl<T>
    extends JpaCriteriaQueryAccessBase<T,T>
    implements FindByKeyAccess<T> {

    private String[] keyPropertyNames;
    private Object[] keyValues;

    public JpaFindByKeyAccessImpl(Class<T> persistentClass) {
        super(persistentClass);
    }

    @Override
    public void setPersistentClass(Class<? extends T> persistentClass) {
        super.setPersistentClass(persistentClass);
    }

    public void setKeyPropertyNames(String... keyPropertyNames) {
        this.keyPropertyNames = keyPropertyNames;
    }

    public void setKeyPropertyValues(Object... keyValues) {
        this.keyValues = keyValues;
    }

    protected String[] getKeyPropertyNames() {
        return keyPropertyNames;
    }

    protected Object[] getKeyValues() {
        return keyValues;
    }

    public T getResult() {
        return (T) getSingleResult();
    }

    @Override
    protected void validate() {
        if (keyValues == null) {
            throw new IllegalArgumentException("keyPropertyValues not defined");
        }
        if (keyPropertyNames == null) {
            throw new IllegalArgumentException("keyPropertyNames not defined");
        }
        if (keyValues.length != keyPropertyNames.length) {
            throw new IllegalArgumentException("Number of keyPropertyValues must be the same "
                    + "as the number of keyPropertyNames. " + keyValues + " != " + keyPropertyNames);
        }
    }

    @Override
    protected void prepareConfig(QueryConfig config) {
    	// datanucleus bug. datanucleus is not handling enums correctly.
    	// user type mapping is not called
    	// TODO: report to datanucleus issue tracker
    	if (!JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
            config.setSingleResult(true);
    	}
        config.setEnableLike(false);
        config.setIgnoreCase(false);
    }

    @Override
    protected List<Predicate> preparePredicates() {
        // map key to restrictions
        Map<String, Object> restrictions = new HashMap<String, Object>();
        for (int i = 0; i < keyPropertyNames.length; i++) {
            restrictions.put(keyPropertyNames[i], keyValues[i]);
        }
        return preparePredicates(restrictions);
    }
}