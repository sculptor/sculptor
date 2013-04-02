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

import org.sculptor.framework.accessapi.FindByKeyAccess;

import com.mongodb.BasicDBObject;
import com.mongodb.DBObject;

/**
 * <p>
 * Find domain object with specified natural key. Implementation of Access
 * command FindByKeyAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbFindByKeyAccessImpl<T> extends MongoDbAccessBase<T> implements FindByKeyAccess<T> {

    private T result;
    private String[] keyPropertyNames;
    private Object[] keyValues;

    public MongoDbFindByKeyAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public T getResult() {
        return result;
    }

    public void setKeyPropertyNames(String... keyPropertyNames) {
        this.keyPropertyNames = keyPropertyNames;
    }

    public void setKeyPropertyValues(Object... keyValues) {
        this.keyValues = keyValues;
    }

    protected String[] getKeyPropertyNames() {
        return keyPropertyNames;
    }

    protected Object[] getKeyValues() {
        return keyValues;
    }

    @Override
    public void setPersistentClass(Class<? extends T> persistentClass) {
        super.setPersistentClass(persistentClass);
    }

    private void checkKeyPropertyNamesValues() {
        if (keyValues == null) {
            throw new IllegalArgumentException("keyPropertyValues not defined");
        }
        if (keyPropertyNames == null) {
            throw new IllegalArgumentException("keyPropertyNames not defined");
        }
        if (keyValues.length != keyPropertyNames.length) {
            throw new IllegalArgumentException("Number of keyPropertyValues must be the same "
                    + "as the number of keyPropertyNames. " + keyValues + " != " + keyPropertyNames);
        }
    }

    @Override
    public void performExecute() {
        checkKeyPropertyNamesValues();

        DBObject query = new BasicDBObject();
        for (int i = 0; i < keyPropertyNames.length; i++) {
            Object dbValue = toData(keyValues[i]);
            query.put(keyPropertyNames[i], dbValue);
        }

        DBObject found = getDBCollection().findOne(query);
        result = getDataMapper().toDomain(found);
    }

}