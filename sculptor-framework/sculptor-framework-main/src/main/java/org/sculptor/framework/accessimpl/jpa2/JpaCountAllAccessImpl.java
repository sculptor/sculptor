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

package org.sculptor.framework.accessimpl.jpa2;

import javax.persistence.criteria.CriteriaQuery;
import javax.persistence.criteria.Root;

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
@Deprecated
public class JpaCountAllAccessImpl<T>
    extends JpaCriteriaQueryAccessBase<T,Long>
    implements CountAllAccess<T> {

    public JpaCountAllAccessImpl(Class<T> persistentClass) {
        super(persistentClass, Long.class);
    }

    public long getResult() {
        return getSingleResult();
    }

    @Override
    protected void prepareConfig(QueryConfig config) {
        config.setSingleResult(true);
    }

    @Override
    protected void prepareSelect(CriteriaQuery<Long> criteriaQuery, Root<T> root, QueryConfig config) {
    	if (config.isDistinct()) {
        	criteriaQuery.select(getCriteriaBuilder().countDistinct(root));
    	} else {
        	criteriaQuery.select(getCriteriaBuilder().count(root));
    	}
    }
}