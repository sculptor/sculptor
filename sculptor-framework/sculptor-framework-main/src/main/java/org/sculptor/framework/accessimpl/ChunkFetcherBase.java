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

package org.sculptor.framework.accessimpl;

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

/**
 *
 * @author Patrik Nordwall
 *
 */
public abstract class ChunkFetcherBase<T, KEY> {

    // max for Oracle is 1000
    private static final int CHUNK_SIZE = 990;

    private final String restrictionPropertyName;

    /**
     * @param restrictionPropertyName
     *            the name of the property to use for the 'in' criteria
     */
    public ChunkFetcherBase(String restrictionPropertyName) {
        this.restrictionPropertyName = restrictionPropertyName;
    }

    protected String getRestrictionPropertyName() {
		return restrictionPropertyName;
	}

	public Map<KEY, T> getDomainObjects(Set<? extends KEY> keys) {
        return filterResult(keys, getDomainObjectsAsList(keys));
    }

    public Map<KEY, Set<T>> getDomainObjectsNonUniqueKeys(Set<? extends KEY> keys) {
        return filterResultNonUniqueKeys(keys, getDomainObjectsAsList(keys));
    }

    /**
     * Fetch existing domain objects based on natural keys
     *
     * @param keys
     *            Set of natural keys for the domain objects to fetch
     * @param resultAsSet
     *            indicates if the keys are unique or not, eg. the resulting map
     *            must be a set of objects.
     * @return Map with keys and domain objects
     */
    public List<T> getDomainObjectsAsList(Set<? extends KEY> keys) {
        // it is not "possible" to use huge number of parameters in a
        // Restrictions.in criterion and therefore we chunk the query
        // into pieces
        List<T> all = new ArrayList<T>();
        Iterator<? extends KEY> iter = keys.iterator();
        List<KEY> chunkKeys = new ArrayList<KEY>();
        for (int i = 1; iter.hasNext(); i++) {
            KEY element = iter.next();
            chunkKeys.add(element);
            if ((i % CHUNK_SIZE) == 0) {
                all.addAll(getChunk(chunkKeys));
                chunkKeys = new ArrayList<KEY>();
            }
        }
        // and then the last part
        if (!chunkKeys.isEmpty()) {
            all.addAll(getChunk(chunkKeys));
        }

        return all;
    }

    protected Map<KEY, T> filterResult(Set<? extends KEY> keys, List<T> all) {
        Map<KEY, T> existingObjectsMap = new HashMap<KEY, T>();
        for (T obj : all) {
            KEY key = key(obj);
            if (keys.contains(key)) {
                 existingObjectsMap.put(key, obj);
            }
        }
        return existingObjectsMap;
    }

    protected Map<KEY, Set<T>> filterResultNonUniqueKeys(Set<? extends KEY> keys, List<T> all) {
       Map<KEY, Set<T>> existingObjectsMap = new HashMap<KEY, Set<T>>();
       for (T obj : all) {
           KEY key = key(obj);
           if (keys.contains(key)) {
               Set<T> keySet = existingObjectsMap.get(key);
               if (keySet == null) {
                   keySet = new LinkedHashSet<T>();
                   existingObjectsMap.put(key, keySet);
               }
               keySet.add(obj);
           }
       }
       return existingObjectsMap;
   }

    /**
     * @return the natural key for the domain object, normally this is the value
     *         of the property specified in the constructor, but for composite
     *         keys it is not
     */
    protected abstract KEY key(T obj);

    protected abstract List<T> getChunk(Collection<KEY> keys);

    /**
     * By default, the values to use in the restriction criteria are the same as
     * the key objects, but if it is composite keys, then the subclass must
     * override and extract the property values to use in the restriction
     * criteria.
     */
    protected Collection<KEY> restrictionPropertyValues(Collection<KEY> keys) {
        return keys;
    }

}
