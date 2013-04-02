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

import java.util.ArrayList;
import java.util.Collection;
import java.util.Date;
import java.util.List;

import org.bson.types.ObjectId;
import org.sculptor.framework.accessapi.SaveAccess;
import org.sculptor.framework.domain.Auditable;
import org.sculptor.framework.domain.JodaAuditable;
import org.sculptor.framework.errorhandling.OptimisticLockingException;
import org.sculptor.framework.errorhandling.ServiceContextStore;
import org.joda.time.DateTime;

import com.mongodb.BasicDBObject;
import com.mongodb.DBCollection;
import com.mongodb.DBObject;

/**
 * <p>
 * Save an entity. Implementation of Access command for Update.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbSaveAccessImpl<T> extends MongoDbAccessBase<T> implements SaveAccess<T> {

    private T entity;
    private T result;
    private Collection<T> entities;

    public MongoDbSaveAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public T getEntity() {
        return entity;
    }

    @Override
    public void setEntity(T entity) {
        this.entity = entity;
    }

    public Collection<T> getEntities() {
        return entities;
    }

    @Override
    public void setEntities(Collection<T> entities) {
        this.entities = entities;
    }

    @Override
    public T getResult() {
        return result;
    }

    @Override
    public void performExecute() {
        if (entity != null) {
            result = performSave(entity);
        }
        if (entities != null) {
            List<T> newInstances = new ArrayList<T>();
            for (T each : getEntities()) {
                newInstances.add(performSave(each));
            }
            setEntities(newInstances);
        }
    }

    protected T performSave(T obj) {
        updateAuditInformation(obj);
        DBObject dbObj = getDataMapper().toData(obj);

        if (dbObj.containsField("_id")) {
            if (dbObj.containsField("version")) {
                updateWithOptimisticLocking(obj, dbObj);
            } else {
                update(dbObj);
            }
        } else {
            insert(obj, dbObj);
        }

        return obj;
    }

    protected void insert(T obj, DBObject dbObj) {
        ObjectId objectId = ObjectId.get();
        dbObj.put("_id", objectId);
        Long newVersion = null;
        if (dbObj.containsField("version") && dbObj.get("version") == null) {
            newVersion = 1L;
            dbObj.put("version", newVersion);
        }
        getDBCollection().insert(dbObj);
        checkLastError();
        IdReflectionUtil.internalSetId(obj, objectId.toStringMongod());
        if (newVersion != null) {
            IdReflectionUtil.internalSetVersion(obj, newVersion);
        }
    }

    protected void update(DBObject dbObj) {
        getDBCollection().save(dbObj);
        checkLastError();
    }

    protected void updateWithOptimisticLocking(T obj, DBObject dbObj) {
        Long version = (Long) dbObj.get("version");
        DBObject q = new BasicDBObject();
        q.put("_id", dbObj.get("_id"));
        // version in db must be same as old version
        q.put("version", version);
        Long newVersion;
        if (version == null) {
            newVersion = 1L;
        } else {
            newVersion = version + 1;
        }
        dbObj.put("version", newVersion);
        DBCollection dbCollection = getDBCollection();
        dbCollection.update(q, dbObj);
        DBObject lastError = dbCollection.getDB().getLastError();

        if (lastError.containsField("updatedExisting") && Boolean.FALSE.equals(lastError.get("updatedExisting"))) {
            throw new OptimisticLockingException("Optimistic locking violation. Object was updated by someone else.");
        }

        checkLastError();
        IdReflectionUtil.internalSetVersion(obj, newVersion);
    }

    protected void updateAuditInformation(T obj) {
        if (obj instanceof Auditable) {
            changeAuditInformation((Auditable) obj);
        } else if (obj instanceof JodaAuditable) {
            changeAuditInformation((JodaAuditable) obj);
        }

    }

    private void changeAuditInformation(Auditable auditableEntity) {
        auditableEntity.setLastUpdated(new Date());
        String lastUpdatedBy = ServiceContextStore.getCurrentUser();
        auditableEntity.setLastUpdatedBy(lastUpdatedBy);
        if (auditableEntity.getCreatedDate() == null)
            auditableEntity.setCreatedDate(auditableEntity.getLastUpdated());
        if (auditableEntity.getCreatedBy() == null)
            auditableEntity.setCreatedBy(auditableEntity.getLastUpdatedBy());
    }

    private void changeAuditInformation(JodaAuditable auditableEntity) {
        auditableEntity.setLastUpdated(new DateTime());
        String lastUpdatedBy = ServiceContextStore.getCurrentUser();
        auditableEntity.setLastUpdatedBy(lastUpdatedBy);
        if (auditableEntity.getCreatedDate() == null)
            auditableEntity.setCreatedDate(auditableEntity.getLastUpdated());
        if (auditableEntity.getCreatedBy() == null)
            auditableEntity.setCreatedBy(auditableEntity.getLastUpdatedBy());
    }

}