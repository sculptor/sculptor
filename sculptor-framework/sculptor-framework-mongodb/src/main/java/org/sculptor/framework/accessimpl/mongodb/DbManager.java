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

import com.mongodb.DB;
import com.mongodb.DBAddress;
import com.mongodb.DBCollection;
import com.mongodb.Mongo;
import com.mongodb.MongoOptions;
import com.mongodb.ServerAddress;

public class DbManager implements Cloneable {

    private static ThreadLocal<DbManager> threadInstance = new ThreadLocal<DbManager>();
    private Mongo mongo;
    private DB db;
    private boolean initialized = false;

    private String dbname;
    private String dbUrl1;
    private String dbUrl2;
    private MongoOptions options = new MongoOptions();

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

    // lazy init
    @SuppressWarnings("deprecation")	
	private synchronized void init() {
        if (initialized) {
            return;
        }
        if (dbname == null) {
            throw new IllegalStateException("MongoDB dbname not defined");
        }
        try {
            if (dbUrl1 == null || dbUrl1.equals("")) {
                // default host/port, but with options
                mongo = new Mongo(new ServerAddress(), options);
            } else if (dbUrl2 != null && !dbUrl2.equals("")) {
                DBAddress left = new DBAddress(urlWithDbname(dbUrl1));
                DBAddress right = new DBAddress(urlWithDbname(dbUrl2));
                mongo = new Mongo(left, right, options);
            } else {
                DBAddress left = new DBAddress(urlWithDbname(dbUrl1));
                mongo = new Mongo(left, options);
            }
            db = mongo.getDB(dbname);
            initialized = true;
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    private String urlWithDbname(String dbUrl) {
        if (dbUrl == null) {
            return null;
        }
        if (!dbUrl.endsWith(dbname)) {
            return dbUrl + "/" + dbname;
        }
        return dbUrl;
    }

    public void requestStart() {
        getDB().requestStart();
    }

    public void requestDone() {
        getDB().requestDone();
    }

    public synchronized DB getDB() {
        if (isAnotherThreadInstance()) {
            return getThreadInstance().getDB();
        }
        init();
        return db;
    }

    public DBCollection getDBCollection(String name) {
        try {
            DBCollection coll = getDB().getCollection(name);
            return coll;
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    public String getDbname() {
        return dbname;
    }

    public synchronized void setDbname(String dbname) {
        this.dbname = dbname;
        initialized = false;
    }

    public String getDbUrl1() {
        return dbUrl1;
    }

    public synchronized void setDbUrl1(String dbUrl1) {
        this.dbUrl1 = dbUrl1;
        initialized = false;
    }

    public String getDbUrl2() {
        return dbUrl2;
    }

    public synchronized void setDbUrl2(String dbUrl2) {
        this.dbUrl2 = dbUrl2;
        initialized = false;
    }

    public MongoOptions getOptions() {
        return options;
    }

    public synchronized void setOptions(MongoOptions options) {
        this.options = options;
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
