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

import javax.persistence.PersistenceException;

import org.sculptor.framework.accessapi.DeleteAccess;


/**
 * <p>
 * Removes an entity.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaDeleteAccessImpl<T> extends JpaAccessBase<T> implements DeleteAccess<T> {

    private T entity;
    private Collection<T> entities;

    public JpaDeleteAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public T getEntity() {
        return entity;
    }

    public void setEntity(T entity) {
        this.entity = entity;
    }

    public Collection<T> getEntities() {
        return entities;
    }

    public void setEntities(Collection<T> entities) {
        this.entities = entities;
    }

    @Override
    public void performExecute() throws PersistenceException {
    	if (entity != null) {
            performRemove(entity);
        }
        if (entities != null) {
            for (T e : entities) {
                performRemove(e);
            }
        }
    }

    protected void performRemove(T obj) {
        if (getEntityManager().contains(obj)) {
            getEntityManager().remove(obj);
        } else {
            T merged = getEntityManager().merge(obj);
            getEntityManager().remove(merged);
        }
    }

}