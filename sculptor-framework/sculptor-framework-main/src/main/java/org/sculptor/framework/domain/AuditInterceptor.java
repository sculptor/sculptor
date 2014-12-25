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

package org.sculptor.framework.domain;

import java.io.Serializable;
import java.util.Date;

import org.hibernate.EmptyInterceptor;
import org.hibernate.type.Type;
import org.sculptor.framework.context.ServiceContextStore;


/**
 * This Hibernate interceptor will be invoked when objects are saved and it will
 * automatically update properties 'lastUpdated', 'lastUpdatedBy', 'createdDate'
 * and 'createdBy' for objects implementing
 * {@link org.sculptor.framework.domain.Auditable}.
 * <p>
 * It will grab the user from
 * {@link org.sculptor.framework.context.ServiceContext} provided by
 * {@link org.sculptor.framework.context.ServiceContextStore}.
 *
 */
public class AuditInterceptor extends EmptyInterceptor {

    private static final long serialVersionUID = -4898120478874862611L;

    @Override
    public void onDelete(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
        // do nothing
    }

    @Override
    public boolean onFlushDirty(Object entity, Serializable id, Object[] currentState, Object[] previousState,
            String[] propertyNames, Type[] types) {

        return changeLastUpdatedInformation(entity, currentState, propertyNames);
    }

    @Override
    public boolean onSave(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
        return changeLastUpdatedInformation(entity, state, propertyNames);
    }

    private boolean changeLastUpdatedInformation(Object entity, Object[] currentState, String[] propertyNames) {
        boolean result = false;
        if (entity instanceof Auditable) {
            String lastUpdatedBy = ServiceContextStore.getCurrentUser();
            Date lastUpdatedDate = new Date();
            for (int i = 0; i < propertyNames.length; i++) {
                if ("lastUpdated".equals(propertyNames[i])) {
                    currentState[i] = lastUpdatedDate;
                    result = true;
                } else if ("lastUpdatedBy".equals(propertyNames[i])) {
                    currentState[i] = lastUpdatedBy;
                    result = true;
                } else if ("createdDate".equals(propertyNames[i]) && (currentState[i] == null)) {
                    currentState[i] = lastUpdatedDate;
                    result = true;
                } else if ("createdBy".equals(propertyNames[i]) && (currentState[i] == null)) {
                    currentState[i] = lastUpdatedBy;
                    result = true;
                }
            }
        }

        return result;
    }

    @Override
    public boolean onLoad(Object entity, Serializable id, Object[] state, String[] propertyNames, Type[] types) {
        // Do nothing

        return false;
    }

}
