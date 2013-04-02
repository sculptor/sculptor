/*
 * Copyright 2010 The Fornax Project Team, including the original
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

package org.sculptor.framework.accessimpl.mongodb;

import java.io.Serializable;

import org.apache.commons.beanutils.PropertyUtils;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.sculptor.framework.accessapi.PopulateAssociationsAccess;
import org.sculptor.framework.accessimpl.jpa.JpaPopulateAssociationsAccessImpl;
import org.sculptor.framework.domain.AssociationSpecification;

/**
 * <p>
 * Populate the specified associations of a persistent object. Implementation of
 * Access command PopulateAssociationsAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbPopulateAssociationsAccessImpl<T> extends MongoDbFindByIdAccessImpl<T, Serializable> implements
        PopulateAssociationsAccess<T> {

    private static Log log = LogFactory.getLog(JpaPopulateAssociationsAccessImpl.class);

    private T entity;
    private AssociationSpecification associationSpecification;

    public MongoDbPopulateAssociationsAccessImpl(Class<T> persistentClass) {
        super(persistentClass);
    }

    public T getEntity() {
        return entity;
    }

    public void setEntity(T entity) {
        this.entity = entity;
    }

    public AssociationSpecification getAssociationSpecification() {
        return associationSpecification;
    }

    public void setAssociationSpecification(AssociationSpecification associationSpecification) {
        this.associationSpecification = associationSpecification;
    }

    @Override
    public void performExecute() {
        // retrieve a fresh instance
        Serializable id = IdReflectionUtil.internalGetId(entity);
        setId(id);
        super.performExecute();

        populateAssociations();
    }

    protected void populateAssociations() {
        if (getResult() == null || associationSpecification == null) {
            return;
        }
        for (String each : associationSpecification.getAssociationNames()) {
            populateAssociation(getResult(), each);
        }
    }

    protected void populateAssociation(Object object, String associationName) {
        try {
            PropertyUtils.getProperty(object, associationName);
        } catch (Exception e) {
            log.warn("Could not populate association: " + associationName + " for " + object.getClass().getName());
        }
    }

}