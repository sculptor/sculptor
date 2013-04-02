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

import org.sculptor.framework.accessapi.DeleteAccess;
import org.sculptor.framework.accessapi.FindByExampleAccess;
import org.sculptor.framework.accessapi.FindByIdAccess;
import org.sculptor.framework.accessapi.FindByQueryAccess;
import org.sculptor.framework.accessapi.GenericAccessFactory;
import org.sculptor.framework.accessapi.PopulateAssociationsAccess;
import org.sculptor.framework.accessapi.SaveAccess;


/**
 * <p>
 * Concrete Factory that creates Generic Access objects.
 * </p>
 * <p>
 * Abstract factory design pattern.
 * </p>
 *
 */
public class JpaGenericAccessFactoryImpl<T> implements GenericAccessFactory<T> {

    private Class<T> persistentClass;

	private EntityManager entityManager;

    public JpaGenericAccessFactoryImpl(Class<T> persistentClass) {
        this.persistentClass = persistentClass;
    }

    public void setEntityManager(EntityManager entityManager) {
    	this.entityManager = entityManager;
    }

    public EntityManager getEntityManager() {
        return entityManager;
    }

    public FindByIdAccess<T, Long> createFindByIdAccess() {
        JpaFindByIdAccessImpl<T, Long> a = new JpaFindByIdAccessImpl<T, Long>(persistentClass);
        a.setEntityManager(entityManager);
        return a;
    }

    public SaveAccess<T> createSaveAccess() {
        JpaSaveAccessImpl<T> a = new JpaSaveAccessImpl<T>();
        a.setEntityManager(entityManager);
        return a;
    }

    public FindByQueryAccess<T> createFindByQueryAccess() {
    	JpaFindByQueryAccessImpl<T> a = new JpaFindByQueryAccessImpl<T>();
        a.setEntityManager(entityManager);
        return a;
    }

    public FindByExampleAccess<T> createFindByExampleAccess() {
    	throw new UnsupportedOperationException("FindByExample is not supported for pure JPA");
    }

    public DeleteAccess<T> createDeleteAccess() {
        JpaDeleteAccessImpl<T> a = new JpaDeleteAccessImpl<T>(persistentClass);
        a.setEntityManager(entityManager);
        return a;
    }

    public PopulateAssociationsAccess<T> createPopulateAssociationsAccess() {
    	JpaPopulateAssociationsAccessImpl<T> a = new JpaPopulateAssociationsAccessImpl<T>(persistentClass);
        a.setEntityManager(entityManager);
        return a;
    }
}