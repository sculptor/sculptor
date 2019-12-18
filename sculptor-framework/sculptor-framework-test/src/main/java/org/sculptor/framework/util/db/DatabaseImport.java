/*
 * Copyright 2007 The Fornax Project Team, including the original 
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

package org.sculptor.framework.util.db;

import org.dbunit.operation.DatabaseOperation;

/*
 * A development environment utility to import data from
 * DBUnit XML file to a database. Not intended to be used in
 * production.
 * <p>
 * Run this as JUnit test to import into database.
 * Override {@link #getDataSourceSpringBeanName} to
 * specify real database.
 */
public class DatabaseImport extends IsolatedDatabaseTestCase {

    /**
     * Override, because super will drop all tables.
     */
    protected DatabaseOperation getTearDownOperation() throws Exception {
        return DatabaseOperation.NONE;
    }

    /**
     * Override this method to specify the XML file to import into database. By
     * default "dbunit/full.xml" is used.
     */
    protected String getDataSetFile() {
        return "dbunit/full.xml";
    }

    /**
     * Override this to specify another datasource. By default testDataSource
     * is used.
     */
    protected String getDataSourceSpringBeanName() {
        return "testDataSource";
    }

    public void testDummy() {

    }

}