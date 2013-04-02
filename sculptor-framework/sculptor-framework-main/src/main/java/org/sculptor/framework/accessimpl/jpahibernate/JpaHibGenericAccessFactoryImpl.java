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

package org.sculptor.framework.accessimpl.jpahibernate;

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
public class JpaHibGenericAccessFactoryImpl<T> implements GenericAccessFactory<T> {

    private final Class<T> persistentClass;

	private EntityManager entityManager;

    public JpaHibGenericAccessFactoryImpl(Class<T> persistentClass) {
        this.persistentClass = persistentClass;
    }

    public void setEntityManager(EntityManager entityManager) {
    	this.entityManager = entityManager;
    }

    public EntityManager getEntityManager() {
        return entityManager;
    }

    public FindByIdAccess<T, Long> createFindByIdAccess() {
        JpaHibFindByIdAccessImpl<T, Long> a = new JpaHibFindByIdAccessImpl<T, Long>(persistentClass);
        a.setEntityManager(entityManager);
        return a;
    }

    public SaveAccess<T> createSaveAccess() {
        JpaHibSaveAccessImpl<T> a = new JpaHibSaveAccessImpl<T>();
        a.setEntityManager(entityManager);
        return a;
    }

    public FindByQueryAccess<T> createFindByQueryAccess() {
    	JpaHibFindByQueryAccessImpl<T> a = new JpaHibFindByQueryAccessImpl<T>();
        a.setEntityManager(entityManager);
        return a;
    }

    public FindByExampleAccess<T> createFindByExampleAccess() {
    	JpaHibFindByExampleAccessImpl<T> a = new JpaHibFindByExampleAccessImpl<T>(persistentClass);
        a.setEntityManager(entityManager);
        return a;
    }

    public DeleteAccess<T> createDeleteAccess() {
        JpaHibDeleteAccessImpl<T> a = new JpaHibDeleteAccessImpl<T>(persistentClass);
        a.setEntityManager(entityManager);
        return a;
    }

    public PopulateAssociationsAccess<T> createPopulateAssociationsAccess() {
    	JpaHibPopulateAssociationsAccessImpl<T> a = new JpaHibPopulateAssociationsAccessImpl<T>(persistentClass);
        a.setEntityManager(entityManager);
        return a;
    }
}