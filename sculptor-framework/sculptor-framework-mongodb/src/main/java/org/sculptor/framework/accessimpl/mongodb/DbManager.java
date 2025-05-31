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
import com.mongodb.MongoClientSettings;
import com.mongodb.client.*;

public class DbManager implements Cloneable {
    private static final ThreadLocal<DbManager> threadInstance = new ThreadLocal<>();

    private MongoClient mongo;
    private MongoDatabase db;
    private boolean initialized = false;

    private String dbname;
    private String dbConnection;
    private MongoClientSettings options = null;

    public DbManager() {
    }

    public static DbManager getThreadInstance() {
        return threadInstance.get();
    }

    public static void setThreadInstance(DbManager dbManager) {
        threadInstance.set(dbManager);
    }

    private boolean isAnotherThreadInstance() {
        DbManager other = getThreadInstance();
        if (other == null) {
            return false;
        }
        return (other != this);
    }

    private synchronized void init() {
        if (initialized) {
            return;
        }
        if (dbname == null) {
            throw new IllegalStateException("MongoDB dbname not defined");
        }
        try {
            if (options != null) {
                mongo = MongoClients.create(options);
            } else {
                mongo = MongoClients.create(dbConnection);
            }
            db = mongo.getDatabase(dbname);
            initialized = true;
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    public ClientSession startSession() {
        return mongo.startSession();
    }

    public synchronized MongoDatabase getDB() {
        if (isAnotherThreadInstance()) {
            return getThreadInstance().getDB();
        }
        init();
        return db;
    }

    public MongoCollection<DBObject> getDBCollection(String name) {
        try {
			return getDB().getCollection(name, DBObject.class);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    public String getDbname() {
        return dbname;
    }

    public void setDbname(String dbname) {
        this.dbname = dbname;
        initialized = false;
    }

    public MongoClientSettings getOptions() {
        return options;
    }

    public synchronized void setOptions(MongoClientSettings options) {
        this.options = options;
        initialized = false;
    }

    public String getDbConnection() {
        return dbConnection;
    }

    public void setDbConnection(String dbConnection) {
        this.dbConnection = dbConnection;
        initialized = false;
    }

    @Override
    public Object clone() {
        try {
            return super.clone();
        } catch (CloneNotSupportedException e) {
            // this shouldn't happen, since we are Cloneable
            throw new InternalError();
        }
    }
}
