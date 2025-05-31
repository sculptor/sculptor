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

import com.mongodb.client.model.Filters;
import org.bson.conversions.Bson;
import org.sculptor.framework.accessimpl.ChunkFetcherBase;

import com.mongodb.client.MongoCollection;
import com.mongodb.DBObject;

/**
 * This class can be used when fetching objects with a Query IN expression when
 * there are many values in the 'in' criteria. It is not "possible" to use huge
 * number of parameters in a IN criterion and therefore we chunk the query into
 * pieces.
 * 
 * @author Patrik Nordwall
 * 
 */
public abstract class MongoDbChunkFetcher<T, KEY> extends ChunkFetcherBase<T, KEY> {

    private final MongoCollection<DBObject> dbCollection;
    private final DataMapper<T, DBObject> dataMapper;

    /**
     * @param restrictionPropertyName
     *            the name of the property to use for the 'in' criteria
     */
    public MongoDbChunkFetcher(MongoCollection<DBObject> dbCollection, DataMapper<T, DBObject> dataMapper,
            String restrictionPropertyName) {
        super(restrictionPropertyName);
        this.dbCollection = dbCollection;
        this.dataMapper = dataMapper;
    }

    @Override
    protected List<T> getChunk(Collection<KEY> keys) {
        List<T> result = new ArrayList<>();
        Bson filter = Filters.in(getRestrictionPropertyName(), restrictionPropertyValues(keys));
        dbCollection.find(filter)
                .map(dataMapper::toDomain)
                .into(result);

        return result;
    }

}
