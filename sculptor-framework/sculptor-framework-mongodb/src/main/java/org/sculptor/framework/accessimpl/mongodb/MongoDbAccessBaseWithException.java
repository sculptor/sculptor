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
import java.util.List;

import org.sculptor.framework.errorhandling.ApplicationException;
import org.sculptor.framework.errorhandling.DatabaseAccessException;

import com.mongodb.DBCollection;
import com.mongodb.DBObject;

/**
 * Base class for Access Objects for use in MongoDB environment.
 * <p>
 * Subclasses must implement {@link #performExecute()}
 * <p>
 * It is rare that AccessObjecs throws ApplicationException you will normally
 * use {@link MongoDbAccessBase}, which does not declare ApplicationException in
 * the method signatures.
 */
public abstract class MongoDbAccessBaseWithException<T> {

    private DbManager dbManager;
    private DataMapper<T, DBObject> dataMapper;
    private DataMapper<Object, DBObject>[] additionalDataMappers;
    private Class<? extends T> persistentClass;
    private String cacheRegion;

    public void execute() throws ApplicationException {
        if (dbManager == null) {
            throw new IllegalStateException("dbManager not defined");
        }
        if (dataMapper == null) {
            throw new IllegalStateException("dataMapper not defined");
        }
        // subclass implementation in separate method to make it possible
        // to add stuff around the call here
        performExecute();
    }

    public abstract void performExecute() throws ApplicationException;

    protected Class<? extends T> getPersistentClass() {
        return persistentClass;
    }

    protected void setPersistentClass(Class<? extends T> persistentClass) {
        this.persistentClass = persistentClass;
    }

    /**
     * DataMapper for persistentClass
     */
    public DataMapper<T, DBObject> getDataMapper() {
        return dataMapper;
    }

    /**
     * Matching DataMapper, if any, otherwise null
     */
    @SuppressWarnings("unchecked")
    public DataMapper<Object, DBObject> getDataMapper(Class<?> domainObjectClass) {
        if (additionalDataMappers != null) {
            for (DataMapper<Object, DBObject> each : additionalDataMappers) {
                if (each.canMapToData(domainObjectClass)) {
                    return each;
                }
            }
        }
        if (dataMapper.canMapToData(domainObjectClass)) {
            return (DataMapper<Object, DBObject>) dataMapper;
        }
        // no matching
        return null;
    }

    @SuppressWarnings("unchecked")
    public void setDataMapper(DataMapper<? extends T, DBObject> dataMapper) {
        this.dataMapper = (DataMapper<T, DBObject>) dataMapper;
    }

    public void setAdditionalDataMappers(DataMapper<Object, DBObject>... dataMappers) {
        this.additionalDataMappers = dataMappers;
    }

    protected DbManager getDbManager() {
        return dbManager;
    }

    public void setDbManager(DbManager dbManager) {
        this.dbManager = dbManager;
    }

    protected DBCollection getDBCollection() {
        return dbManager.getDBCollection(getDataMapper().getDBCollectionName());
    }

    public boolean isCache() {
        return (getCacheRegion() != null);
    }

    public void setCache(boolean cache) {
        if (cache) {
            String name;
            if (getPersistentClass() == null) {
                name = getClass().getName();
            } else {
                name = getPersistentClass().getName();
            }

            setCacheRegion(getQueryCacheRegionPrefix() + name);
        } else {
            // no cache
            setCacheRegion(null);
        }
    }

    public String getCacheRegion() {
        return cacheRegion;
    }

    public void setCacheRegion(String cacheRegion) {
        this.cacheRegion = cacheRegion;
    }

    protected String getQueryCacheRegionPrefix() {
        return "query.";
    }

    protected Object toData(Object value) {
        if (value == null) {
            return value;
        }

        if (value instanceof Collection<?>) {
            List<Object> result = new ArrayList<Object>();
            for (Object each : (Collection<?>) value) {
                result.add(toData(each));
            }
            return result;
        }

        DataMapper<Object, DBObject> dataMapper = getDataMapper(value.getClass());
        if (dataMapper != null) {
            return dataMapper.toData(value);
        }

        return value;
    }

    protected void checkLastError() {
        DBObject lastError = getDBCollection().getDB().getLastError();
        if (lastError.containsField("err") && lastError.get("err") != null) {
            throw new DatabaseAccessException(lastError.get("err").toString());
        }
    }
}
