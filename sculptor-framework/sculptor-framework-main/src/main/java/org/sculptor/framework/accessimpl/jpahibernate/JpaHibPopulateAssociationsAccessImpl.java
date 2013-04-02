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

import java.util.Collection;

import org.apache.commons.beanutils.PropertyUtils;
import org.hibernate.Hibernate;
import org.sculptor.framework.accessapi.PopulateAssociationsAccess;
import org.sculptor.framework.accessimpl.jpa.JpaPopulateAssociationsAccessImpl;
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
public class JpaHibPopulateAssociationsAccessImpl<T> extends JpaPopulateAssociationsAccessImpl<T> implements PopulateAssociationsAccess<T> {

	private static Logger log = LoggerFactory.getLogger(JpaHibPopulateAssociationsAccessImpl.class);
	
	public JpaHibPopulateAssociationsAccessImpl(Class<T> persistentClass) {
		super(persistentClass);
	}

    @Override
    protected void populateAssociation(Object object, String associationName) {
        try {
            Object association = PropertyUtils.getProperty(object, associationName);
            Hibernate.initialize(association);
            if (association instanceof Collection<?>) {
                ((Collection<?>) association).size();
            }
        } catch (Exception e) {
            log.warn("Could not populate association: " + associationName + " for " + object.getClass().getName());
        }
    }

}