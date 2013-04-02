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
import java.util.List;

import org.sculptor.framework.accessapi.FindAllAccess;

import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;

/**
 * <p>
 * Find all entities of a specific type. Implementation of Access command
 * FindAllAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbFindAllAccessImpl<T> extends MongoDbAccessBase<T> implements FindAllAccess<T> {

    private String orderBy;
    private boolean orderByAsc = true;
    private int firstResult = -1;
    private int maxResult = 0;
    private List<T> result;

    public MongoDbFindAllAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
    }

    public boolean isOrderByAsc() {
        return orderByAsc;
    }

    public void setOrderByAsc(boolean orderByAsc) {
        this.orderByAsc = orderByAsc;
    }

    protected int getFirstResult() {
        return firstResult;
    }

    public void setFirstResult(int firstResult) {
        this.firstResult = firstResult;
    }

    protected int getMaxResult() {
        return maxResult;
    }

    public void setMaxResult(int maxResult) {
        this.maxResult = maxResult;
    }

    public List<T> getResult() {
        return this.result;
    }

    @Override
    public void performExecute() {
        List<T> foundResult = new ArrayList<T>();

        DBCursor cur = getDBCollection().find();

        if (orderBy != null) {
            cur.sort(new BasicDBObject(orderBy, orderByAsc ? 1 : -1));
        }

        if (firstResult >= 0) {
            cur.skip(firstResult);
        }
        if (maxResult >= 1) {
            cur.limit(maxResult);
        }

        for (DBObject each : cur) {
            T eachResult = getDataMapper().toDomain(each);
            foundResult.add(eachResult);
        }

        this.result = foundResult;
    }

}