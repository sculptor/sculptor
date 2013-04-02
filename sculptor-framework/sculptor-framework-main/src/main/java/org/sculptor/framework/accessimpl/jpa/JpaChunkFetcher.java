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

import java.util.Collection;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.Query;

import org.sculptor.framework.accessimpl.ChunkFetcherBase;

/**
 * This class can be used when fetching objects with a Query IN expression
 * when there are many values in the 'in' criteria. It is not "possible" to use
 * huge number of parameters in a IN criterion and therefore we
 * chunk the query into pieces.
 *
 * @author Patrik Nordwall
 *
 */
public abstract class JpaChunkFetcher<T, KEY> extends ChunkFetcherBase<T, KEY> {

	private final EntityManager entityManager;

    /**
     * @param restrictionPropertyName
     *            the name of the property to use for the 'in' criteria
     */
    public JpaChunkFetcher(EntityManager entityManager, String restrictionPropertyName) {
        super(restrictionPropertyName);
        this.entityManager = entityManager;
    }


    /**
     *
     * @return This is our base query which we will add the desired
     *         restrictions to
     */
    protected abstract String createBaseQuery();


    @SuppressWarnings("unchecked")
    protected List<T> getChunk(Collection<KEY> keys) {
        String queryStr = createBaseQuery();

        // get all with matching property
        if (queryStr.toLowerCase().contains(" where ")) {
            queryStr += " and ";
        } else {
            queryStr += " where ";
        }

        // not all jpa provider can handle collections as parameter, will be available in jpa 2.0
        Collection<KEY> restrictionPropertyValues = restrictionPropertyValues(keys);
        queryStr += getRestrictionPropertyName() + " IN (" + JpaHelper.convertToString((Collection<Object>) restrictionPropertyValues) +")";
        Query query = entityManager.createQuery(queryStr);
//        query.setParameter("restrictionPropertyValues", );

        List<T> list = query.getResultList();
        return list;
    }

}
