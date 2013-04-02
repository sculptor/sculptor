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

import org.sculptor.framework.accessapi.CountAllAccess;

/**
 * <p>
 * Counts all entities of a specific type. Implementation of Access command
 * CountAllAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbCountAllAccessImpl<T> extends MongoDbAccessBase<T> implements CountAllAccess<T> {

    private long result;

    public MongoDbCountAllAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public long getResult() {
        return this.result;
    }

    @Override
    public void performExecute() {
        result = getDBCollection().getCount();
    }

}