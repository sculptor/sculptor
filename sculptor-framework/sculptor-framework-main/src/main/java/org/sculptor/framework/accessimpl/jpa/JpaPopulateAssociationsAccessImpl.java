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

import java.io.Serializable;
import java.util.Collection;

import javax.persistence.PersistenceException;

import org.apache.commons.beanutils.PropertyUtils;
import org.sculptor.framework.accessapi.PopulateAssociationsAccess;
import org.sculptor.framework.domain.AssociationSpecification;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;


/**
 * <p>
 * Populate the specified associations of a persistent object.
 * Implementation of Access command FindByIdAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaPopulateAssociationsAccessImpl<T> extends JpaAccessBase<T> implements PopulateAssociationsAccess<T> {

    private static Logger log = LoggerFactory.getLogger(JpaPopulateAssociationsAccessImpl.class);

    private T entity;
    private AssociationSpecification associationSpecification;
    private T result;

    public JpaPopulateAssociationsAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
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

    public T getResult() {
        return result;
    }

    public void performExecute() throws PersistenceException {
        result = getEntityManager().find(getPersistentClass(), getId(entity));
        populateAssociations();
    }

    private Serializable getId(Object domainObject) {
        if (PropertyUtils.isReadable(domainObject, "id")) {
            try {
                return (Serializable) PropertyUtils.getProperty(domainObject, "id");
            } catch (Exception e) {
                throw new IllegalArgumentException("Can't get id property of domainObject: " + domainObject);
            }
        } else {
            // no id property, don't know if it is new
            throw new IllegalArgumentException("No id property in domainObject: " + domainObject);
        }
    }

    protected void populateAssociations() {
        if (result == null || associationSpecification == null) {
            return;
        }
        for (String each : associationSpecification.getAssociationNames()) {
            populateAssociation(result, each);
        }
    }

    protected void populateAssociation(Object object, String associationName) {
        try {
            Object association = PropertyUtils.getProperty(object, associationName);
            if (association instanceof Collection<?>) {
                ((Collection<?>) association).size();
            } else {
            	// TODO is there a more efficient way, something like Hibernate.initialize ?
                // try entityManger.getReference
            	String.valueOf(association);
            }
        } catch (Exception e) {
            log.warn("Could not populate association: " + associationName + " for " + object.getClass().getName());
        }
    }



}