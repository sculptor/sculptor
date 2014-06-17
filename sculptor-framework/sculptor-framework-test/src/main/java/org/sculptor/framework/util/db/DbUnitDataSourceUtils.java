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

import java.io.StringWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

import org.dbunit.DataSourceDatabaseTester;
import org.dbunit.database.DatabaseConfig;
import org.dbunit.database.DatabaseSequenceFilter;
import org.dbunit.database.IDatabaseConnection;
import org.dbunit.dataset.CompositeDataSet;
import org.dbunit.dataset.FilteredDataSet;
import org.dbunit.dataset.IDataSet;
import org.dbunit.dataset.ReplacementDataSet;
import org.dbunit.dataset.filter.ITableFilter;
import org.dbunit.dataset.xml.FlatXmlDataSet;
import org.dbunit.ext.hsqldb.HsqldbDataTypeFactory;
import org.dbunit.operation.DatabaseOperation;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Utility Class for handling DbUnit DataSets
 * 
 * @author Oliver Ringel
 * 
 */
public class DbUnitDataSourceUtils {

    private static final Logger log = LoggerFactory.getLogger(DbUnitDataSourceUtils.class);

    public static final String DEFAULT_DBUNIT_TEST_PATH = "dbunit";

    public static DataSourceDatabaseTester databaseTester = null;

    // TODO: support configuration of DatabaseOperations
    public static DatabaseOperation setUpDatabaseOperation = DatabaseOperation.REFRESH;
    public static DatabaseOperation tearDownDatabaseOperation = new OrderedDeleteAllOperation();

    /**
     * creates the dataset executes the dbunit setup operation
     * 
     * @param clazz
     *            test class
     * @param dataSource
     * @param dataSetFileName
     * @throws Exception
     */
    public static void setUpDatabaseTester(Class<?> clazz, DataSource dataSource, String dataSetFileName)
            throws Exception {

        if (dataSetFileName == null) {
            dataSetFileName = defaultDataSetFileName(clazz);
        }
        
        setUpDatabaseTester(clazz, dataSource, new String[] {dataSetFileName});
    }

    /**
      * creates the dataset executes the dbunit setup operation from multiple files
      * 
      * @param clazz
      *            test class
      * @param dataSource
      * @param dataSetFileNames
      * @throws Exception
      */
    public static void setUpDatabaseTester(Class<?> clazz, DataSource dataSource, String[] dataSetFileNames)
            throws Exception {

        // create dataset
    	IDataSet dataSet;
    	if(dataSetFileNames.length == 1) {
            dataSet = new FlatXmlDataSet(clazz.getClassLoader().getResource(
                    dataSetFileNames[0]), false, true);
    	} else {
    		IDataSet[] dataSets = new IDataSet[dataSetFileNames.length];
    		for (int i = 0; i < dataSetFileNames.length; i++) {
				dataSets[i] = new FlatXmlDataSet(clazz.getClassLoader().getResource(
	                    dataSetFileNames[i]), false, true);
    		}
        	dataSet = new CompositeDataSet(dataSets);
    	}
    		
        ReplacementDataSet replacementDataSet = new ReplacementDataSet(dataSet);
        replacementDataSet.addReplacementObject("[NULL]", null);

        setUpDatabaseTester(clazz, dataSource, replacementDataSet);
    }
    
    /**
     * creates the dataset executes the dbunit setup operation from a DataSet
     * 
     * @param clazz
     *            test class
     * @param dataSource
     * @param dataSet
     * @throws Exception
     */
    public static void setUpDatabaseTester(Class<?> clazz, DataSource dataSource, IDataSet dataSet)
            throws Exception {


        // setup database tester
        if (databaseTester == null) {
            databaseTester = new HsqlDataSourceDatabaseTester(dataSource);
        }

        databaseTester.setSetUpOperation(getSetUpDatabaseOperation());
        databaseTester.setTearDownOperation(getTearDownDatabaseOperation());
        databaseTester.setDataSet(dataSet);
        databaseTester.onSetup();
    }

    /**
     * executes the dbunit teardown operation
     * 
     * @throws Exception
     */
    public static void tearDownDatabaseTester() throws Exception {
        if (databaseTester != null) {
            try {
                databaseTester.onTearDown();
            } catch (Exception e) {
                LoggerFactory.getLogger(DbUnitDataSourceUtils.class).warn("Failed to tear down database.", e);
            }
        }
    }

    /**
     * guess the dataset filename for test class name
     * 
     * @param clazz
     *            test class
     * @return dataset filename
     */
    private static String defaultDataSetFileName(Class<?> clazz) {
        return DEFAULT_DBUNIT_TEST_PATH + "/" + clazz.getSimpleName() + ".xml";
    }

    public static DatabaseOperation getSetUpDatabaseOperation() {
        return setUpDatabaseOperation;
    }

    public static void setSetUpDatabaseOperation(DatabaseOperation setUpDatabaseOperation) {
        DbUnitDataSourceUtils.setUpDatabaseOperation = setUpDatabaseOperation;
    }

    public static DatabaseOperation getTearDownDatabaseOperation() {
        return tearDownDatabaseOperation;
    }

    public static void setTearDownDatabaseOperation(DatabaseOperation tearDownDatabaseOperation) {
        DbUnitDataSourceUtils.tearDownDatabaseOperation = tearDownDatabaseOperation;
    }

    public static void logDb(IDatabaseConnection connection) {
        try {
            ITableFilter filter = new DatabaseSequenceFilter(connection);
            IDataSet dataset = new FilteredDataSet(filter, connection.createDataSet());

            StringWriter out = new StringWriter();

            FlatXmlDataSet.write(dataset, out);
            log.info(out.getBuffer().toString());
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    /**
     * Start the id sequence from a high value to avoid conflicts with test
     * data. You can define the sequence name with {@link #getSequenceName}.
     */
    public static void restartSequence(IDatabaseConnection dbConnection, String sequenceName) {
        if (sequenceName == null) {
            return;
        }
        Connection connection = null;
        Statement stmt = null;
        try {
            connection = dbConnection.getConnection();
            stmt = connection.createStatement();
            stmt.execute("ALTER SEQUENCE " + sequenceName + " RESTART WITH 10000");

        } catch (Exception e) {
            try {
                stmt.close();
            } catch (SQLException ignore) {
            }
            try {
                stmt = connection.createStatement();
                stmt.execute("UPDATE SEQUENCE SET SEQ_COUNT = 10000 WHERE SEQ_NAME = '" + sequenceName + "'");
            } catch (Exception e2) {
                throw new RuntimeException("Couldn't restart sequence: " + sequenceName + " : " + e.getMessage(), e);
            }
        } finally {
            if (stmt != null) {
                try {
                    stmt.close();
                } catch (SQLException ignore) {
                }
            }
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException ignore) {
                }
            }
        }
    }

    /**
     * DatasourceTester with support for HSQLDB data types.
     * 
     */
    private static class HsqlDataSourceDatabaseTester extends DataSourceDatabaseTester {
        public HsqlDataSourceDatabaseTester(DataSource dataSource) {
            super(dataSource);
        }

        @Override
        public IDatabaseConnection getConnection() throws Exception {
            IDatabaseConnection connection = super.getConnection();
            connection.getConfig().setProperty(DatabaseConfig.PROPERTY_DATATYPE_FACTORY, new HsqldbDataTypeFactory());
            return connection;
        }
    }
}
