/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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
package org.sculptor.framework.test;

import java.sql.SQLException;

import javax.annotation.Resource;
import javax.persistence.Table;
import javax.sql.DataSource;

import org.dbunit.database.DatabaseConfig;
import org.dbunit.database.DatabaseConnection;
import org.dbunit.database.IDatabaseConnection;
import org.dbunit.dataset.IDataSet;
import org.junit.After;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.sculptor.framework.context.ServiceContext;
import org.sculptor.framework.context.ServiceContextFactory;
import org.sculptor.framework.util.FactoryConfiguration;
import org.sculptor.framework.util.db.DbUnitDataSourceUtils;
import org.sculptor.framework.util.db.HsqlDataTypeFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractTransactionalJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
import org.springframework.transaction.annotation.Transactional;

/**
 * Base class for transactional spring-based DBUnit tests.
 *
 * <p>
 * Override the method {@link #getDataSetFile} to specify XML file with DBUnit
 * test data.
 *
 * @author Patrik Nordwall
 * @author Oliver Ringel
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
@Transactional(transactionManager = "txManager")
public abstract class AbstractDbUnitAnnotationAwareTransactionalTests extends
        AbstractTransactionalJUnit4SpringContextTests {

    private final Logger log = LoggerFactory.getLogger(getClass());

    public AbstractDbUnitAnnotationAwareTransactionalTests() {
    }

    static {
        ServiceContextFactory.setConfiguration(new FactoryConfiguration() {
			public String getFactoryImplementationClassName() {
				return "org.sculptor.framework.context.JUnitServiceContextFactory";
            }
        });
    }

    private final ServiceContext serviceContext = ServiceContextFactory.createServiceContext("JUnit");

    protected ServiceContext getServiceContext() {
        return serviceContext;
    }

    /**
     * inject the datasource
     */
    @Override
    @Autowired
    @Qualifier("testDataSource")
    public void setDataSource(DataSource dataSource) {
    	super.setDataSource(dataSource);
    }

    /**
     * setup dbunit DatabaseTester/DataSet in transaction
     *
     * @throws Exception
     */
    @Before
    public void setUpDatabaseTester() throws Exception {
    	if (getJdbcTemplate().getDataSource() == null) {
    		throw new IllegalStateException("Missing @Resource 'testDataSource'");
    	}
    	buildSchema();
        
    	IDataSet dataSet = getDataSet();
    	String[] compositeDataSetFileNames = getCompositeDataSetFiles();
     	
    	if(dataSet != null) {
             DbUnitDataSourceUtils.setUpDatabaseTester(getClass(), getJdbcTemplate().getDataSource(), dataSet);    		
    	} else if (compositeDataSetFileNames != null) {
             DbUnitDataSourceUtils.setUpDatabaseTester(getClass(), getJdbcTemplate().getDataSource(), compositeDataSetFileNames);    		
     	} else {
             DbUnitDataSourceUtils.setUpDatabaseTester(getClass(), getJdbcTemplate().getDataSource(), getDataSetFile());
     	}
 
        restartSequence();
    }

    /**
     * Override this method to specify a DataSet to use for test data.
     * If dataSet is not set, getCompompositeDataSetFiles() and getDataSetFile() will be called.
     * 
     * @return Data set to use
     */
    protected IDataSet getDataSet() {
    	return null;
    }
    
    /**
     * Start the id sequence from a high value to avoid conflicts with test
     * data. You can define the sequence name with {@link #getSequenceName}.
     */
    protected void restartSequence() {
        String sequenceName = getSequenceName();
        if (sequenceName == null) {
            return;
        }
        try {
            DbUnitDataSourceUtils.restartSequence(getConnection(), sequenceName);
        } catch (Exception e) {
            log.debug("Couldn't restart sequence: " + sequenceName);
        }
    }

    /**
     * increase the version number to test optimistic locking
     *
     * @param domainObjectClass
     */
    protected void increaseVersion(Class<?> domainObjectClass, Long id) {
        increaseVersion(getTableName(domainObjectClass), id);
    }

    /**
     * increase the version number to test optimistic locking
     *
     * @param tableName
     * @return
     */
    protected void increaseVersion(String tableName, Long id) {
        getJdbcTemplate().update("update " + tableName + " set version = version + 1 where id = " + id);
    }

    /**
     * In case you don't need to start the id sequence from a high value to
     * avoid conflicts with test data you should override this method and return
     * null.
     */
    protected String getSequenceName() {
        return null;
    }

    /**
     * Execute some SQL scripts before setup the database to modify the schema
     * This is used for workarounds
     *
     * @throws Exception
     */
    protected void buildSchema() {
    }

    @After
    public void tearDownDatabaseTester() throws Exception {
        DbUnitDataSourceUtils.tearDownDatabaseTester();
    }

    /**
     * Override this method to specify the XML file with DBUnit test data. If
     * filename is not set, DbUnitDataSourceUtils will guess a filename.
     *
     * @return the filename with test data
     */
    protected String getDataSetFile() {
        return null;
    }
    

    /**
      * Override this method to specify multiple XML files with DBUnit test data to be processed as a CompositeDataSetFile.
      * If filename is not set, getDataSetFile() will be called.
      * 
      * @return Array of filenames with test data
      */
     protected String[] getCompositeDataSetFiles() {
     	return null;
     }

    protected int countRowsInTable(Class<?> domainObjectClass) throws Exception {
        return countRowsInTable(domainObjectClass, "");
    }

    /**
     * Counts the number of rows from a table via jdbc. Table name is picked for @Table
     * annotation of the domainObjectClass
     *
     * @param domainObjectClass
     *            persistent class defining the name of the table for counting
     *            rows
     * @param condition
     *            additional condition
     * @return number of rows
     */
    protected int countRowsInTable(Class<?> domainObjectClass, String condition) throws Exception {
        return countRowsInTable(getTableName(domainObjectClass), condition);
    }

    /**
     * counts the number of rows from a table via jdbc
     *
     * @param tableName
     *            name of the table for counting rows
     * @return number of rows
     */
    @Override
    protected int countRowsInTable(String tableName) {
        return countRowsInTable(tableName, "");
    }

    /**
     * counts the number of rows from a table via jdbc
     *
     * @param tableName
     *            name of the table for counting rows
     * @param condition
     *            additional condition
     * @return number of rows
     */
	protected int countRowsInTable(String tableName, String condition) {
		Number number = getJdbcTemplate().queryForObject("select count(*) from " + tableName + " " + condition,
				Integer.class);
		return (number != null ? number.intValue() : 0);
	}

    protected IDatabaseConnection getConnection() throws Exception {
        IDatabaseConnection connection = new DatabaseConnection(getJdbcTemplate().getDataSource().getConnection());
        DatabaseConfig config = connection.getConfig();
        config.setProperty(DatabaseConfig.PROPERTY_DATATYPE_FACTORY, new HsqlDataTypeFactory());
        return connection;
    }

    protected void logDb() {
        IDatabaseConnection connection = null;
        try {
            connection = getConnection();
            DbUnitDataSourceUtils.logDb(connection);
        } catch (Exception e) {
            throw new RuntimeException(e.getMessage(), e);
        } finally {
            if (connection != null) {
                try {
                    connection.close();
                } catch (SQLException ignore) {
                }
            }
        }
    }

    /**
     * Get the table name from a domainobject class
     *
     * @param domainObjectClass
     * @return the table name
     *
     */
    protected String getTableName(Class<?> domainObjectClass) {
        String table = null;
        if (domainObjectClass.isAnnotationPresent(Table.class)) {
            table = domainObjectClass.getAnnotation(Table.class).name();
        } else {
            table = domainObjectClass.getSimpleName();
        }
        return table;
    }


    protected ApplicationContext getApplicationContext() {
        return applicationContext;
    }

    /**
     * Return the JdbcTemplate that this base class manages.
     */
    public final JdbcTemplate getJdbcTemplate() {
        return this.jdbcTemplate;
    }
}
