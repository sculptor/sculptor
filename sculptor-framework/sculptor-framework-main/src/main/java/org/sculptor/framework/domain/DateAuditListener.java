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

import org.sculptor.framework.context.ServiceContextStore;

import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;
import java.sql.Timestamp;


/**
 * This Listener will be invoked when objects are saved and it will
 * automatically update properties 'lastUpdated', 'lastUpdatedBy', 'created'
 * and 'createdBy' for objects implementing
 * {@link Auditable}.
 * <p>
 * It will grab the user from
 * {@link org.sculptor.framework.context.ServiceContext} provided by
 * {@link ServiceContextStore}.
 *
 */
public class DateAuditListener {

	/**
	 * set audit informations, doesn't modify createdDate and createdBy once set.
	 * Only works with DomainObjects that implement the Auditable interface. In other cases
	 * a IllegalArgumentException is thrown.
	 *
	 * @param entity
	 * @return
	 */
    @PreUpdate
    @PrePersist
    private void changeAuditInformation(DateAuditable auditableEntity) {
        Timestamp lastUpdated = new Timestamp(System.currentTimeMillis());
        auditableEntity.setLastUpdated(lastUpdated);
        String lastUpdatedBy = ServiceContextStore.getCurrentUser();
        auditableEntity.setLastUpdatedBy(lastUpdatedBy);
        if (auditableEntity.getCreatedDate() == null)
            auditableEntity.setCreatedDate(lastUpdated);
        if (auditableEntity.getCreatedBy() == null)
            auditableEntity.setCreatedBy(lastUpdatedBy);
    }
}
