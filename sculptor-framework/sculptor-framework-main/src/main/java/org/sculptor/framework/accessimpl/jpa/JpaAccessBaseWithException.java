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

import javax.persistence.EntityManager;
import javax.persistence.PersistenceException;

import org.sculptor.framework.errorhandling.ApplicationException;

/**
 * Base class for Access Objects for use in JPA environment.
 * <p>
 * Subclasses must implement {@link #performExecute()}
 * <p>
 * It is rare that AccessObjecs throws ApplicationException you
 * will normally use {@link JpaAccessBase}, which
 * does not declare ApplicationException in the method signatures.
 */
public abstract class JpaAccessBaseWithException<T> {

    private Class<? extends T> persistentClass;
    private String cacheRegion;

	private EntityManager entityManager;

    public void setEntityManager(EntityManager entityManager) {
    	this.entityManager = entityManager;
    }

    public EntityManager getEntityManager() {
        return entityManager;
    }

    public void execute() throws ApplicationException {
    	// subclass implementation in separate method to make it possible
    	// to add stuff around the call here
        performExecute();
    }

    public abstract void performExecute() throws ApplicationException, PersistenceException;

    protected Class<? extends T> getPersistentClass() {
        return persistentClass;
    }

    protected void setPersistentClass(Class<? extends T> persistentClass) {
        this.persistentClass = persistentClass;
    }

    public boolean isCache() {
        return (getCacheRegion() != null);
    }

    public void setCache(boolean cache) {
        if (cache) {
            String name;
            if (getPersistentClass() == null) {
                name = getClass().getName();
            } else {
                name = getPersistentClass().getName();
            }

            setCacheRegion(getQueryCacheRegionPrefix() + name);
        } else {
            // no cache
            setCacheRegion(null);
        }
    }

    public String getCacheRegion() {
        return cacheRegion;
    }

    public void setCacheRegion(String cacheRegion) {
        this.cacheRegion = cacheRegion;
    }

    protected String getQueryCacheRegionPrefix() {
        return "query.";
    }
}
