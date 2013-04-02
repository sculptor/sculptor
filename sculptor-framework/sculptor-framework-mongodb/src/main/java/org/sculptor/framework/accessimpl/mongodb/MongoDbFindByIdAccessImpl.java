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

import org.bson.types.ObjectId;
import org.sculptor.framework.accessapi.FindByIdAccess;

import com.mongodb.DBObject;

/**
 * <p>
 * Find an entity by its id. Implementation of Access command FindByIdAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbFindByIdAccessImpl<T, ID extends Serializable> extends MongoDbAccessBase<T> implements
        FindByIdAccess<T, ID> {

    private ID id;
    private T result;

    public MongoDbFindByIdAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    protected ID getId() {
        return id;
    }

    @Override
    public void setId(ID id) {
        this.id = id;
    }

    @Override
    public T getResult() {
        return result;
    }

    protected void setResult(T result) {
        this.result = result;
    }

    @Override
    public void performExecute() {
        ObjectId objectId = ObjectId.massageToObjectId(getId());
        DBObject found = getDBCollection().findOne(objectId);
        result = getDataMapper().toDomain(found);
    }

    protected boolean isLock() {
        throw new UnsupportedOperationException("lock not supported by " + getClass().getName());
    }

    @Override
    public void setLock(boolean lock) {
        throw new UnsupportedOperationException("lock not supported by " + getClass().getName());
    }
}