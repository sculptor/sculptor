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

import com.mongodb.DBObject;

public class IndexSpecification {
    private final String name;
    private final DBObject keys;
    private final boolean unique;

    public IndexSpecification(String name, DBObject keys, boolean unique) {
        this.name = name;
        this.keys = keys;
        this.unique = unique;
    }

    public String getName() {
        return name;
    }

    public DBObject getKeys() {
        return keys;
    }

    public boolean isUnique() {
        return unique;
    }

}
