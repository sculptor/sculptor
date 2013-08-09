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

import java.io.IOException;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.Properties;
import java.util.Set;

import javax.persistence.EntityManager;
import javax.persistence.Table;
import javax.sql.DataSource;

import org.dbunit.database.DatabaseConfig;
import org.dbunit.database.DatabaseConnection;
import org.dbunit.database.IDatabaseConnection;
import org.junit.After;
import org.junit.Before;
import org.sculptor.framework.test.ejbtestbean.jpa.JpaTestLocal;
import org.sculptor.framework.util.db.DbUnitDataSourceUtils;
import org.sculptor.framework.util.db.HsqlDataTypeFactory;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Base class for <a href=
 * "http://www.oracle.com/technetwork/java/javaee/tech/persistence-jsp-140049.html"
 * >JPA</a> and <a href="http://www.dbunit.org">DBUnit</a> tests in a <a
 * href="http://openejb.apache.org/">OpenEJB</a> environment.
 * <p>
 * Inject dependencies to EJBs with the ordinary <code>@EJB</code> annotation.
 * <p>
 * Override the method {@link #getDataSetFile} to specify XML file with DBUnit
 * test data.
 * 
 * @author Patrik Nordwall
 * 
 */
public abstract class AbstractOpenEJBDbUnitTest extends AbstractOpenEJBTest {

    private final Logger log = LoggerFactory.getLogger(getClass());

    private EntityManager entityManager;
    private DataSource dataSource;
    private JpaTestLocal jpaTestBean;

    public AbstractOpenEJBDbUnitTest() {
    }

    @Before
    @Override
    public void initialize() throws Exception {
        super.initialize();
        setUpDatabaseTester();
    }

    protected Set<String> getPersistentUnitNames() {
        try {
            PersistenceXmlParser persistenceXmlParser = new PersistenceXmlParser();
            String persistenceXml = DataHelper.content("/META-INF/persistence.xml");
            persistenceXmlParser.parse(persistenceXml);
            return persistenceXmlParser.getPersictenceUnitNames();
        } catch (IOException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

    @Override
    protected void initOpenEjb() throws Exception {
        super.initOpenEjb();
        jpaTestBean = lookup(getTestBeanJndiName());
        if (jpaTestBean == null) {
            throw new IllegalStateException("Couldn't find " + getMessagingTestBeanJndiName());
        }
        entityManager = jpaTestBean.getEntityManager();
        dataSource = jpaTestBean.getDataSource();
    }

    protected String getTestBeanJndiName() {
        return "JpaTestBeanLocal";
    }

    @Override
    protected void additionalInitialContextProperties(Properties defaultProperties) {
        for (String unitName : getPersistentUnitNames()) {
            initPersistenceUnitProperties(unitName, defaultProperties);
        }
    }

    /**
     * Overrides some properties defined for persistent units in "persistence.xml".
     */
    protected void initPersistenceUnitProperties(String unitName, Properties properties) {
        properties.put(unitName + ".hibernate.dialect", "org.sculptor.framework.persistence.CustomHSQLDialect");
        properties.put(unitName + ".hibernate.show_sql", "true");
        properties.put(unitName + ".hibernate.hbm2ddl.auto", "create-drop");
        properties.put(unitName + ".hibernate.cache.use_query_cache", "false");
        properties.put(unitName + ".hibernate.cache.use_second_level_cache", "false");
    }

    protected EntityManager getEntityManager() {
        return entityManager;
    }

    protected DataSource getDataSource() {
        return dataSource;
    }

    /**
     * setup dbunit DatabaseTester/DataSet in transaction
     * 
     * @throws Exception
     */
    protected void setUpDatabaseTester() throws Exception {
        DbUnitDataSourceUtils.setUpDatabaseTester(getClass(), getDataSource(), getDataSetFile());
        restartSequence();
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
     * In case you don't need to start the id sequence from a high value to
     * avoid conflicts with test data you should override this method and return
     * null.
     */
    protected String getSequenceName() {
        return null;
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

    protected IDatabaseConnection getConnection() throws Exception {
        IDatabaseConnection connection = new DatabaseConnection(getDataSource().getConnection());
        DatabaseConfig config = connection.getConfig();
        config.setProperty(DatabaseConfig.PROPERTY_DATATYPE_FACTORY, new HsqlDataTypeFactory());

        return connection;
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
        String table;
        if (domainObjectClass.isAnnotationPresent(Table.class)) {
            table = domainObjectClass.getAnnotation(Table.class).name();
        } else {
            table = domainObjectClass.getSimpleName();
        }
        return countRowsInTable(table, condition);
    }

    protected int countRowsInTable(String table) throws Exception {
        return countRowsInTable(table, "");
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
    protected int countRowsInTable(String table, String condition) throws Exception {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = getConnection().getConnection();
            stmt = con.createStatement();
            rs = stmt.executeQuery("select count(*) as rowcount from " + table + " " + condition);
            rs.next();
            int count = rs.getInt("rowcount");
            return count;
        } catch (SQLException e) {
            throw e;
        } finally {
            close(con, stmt, rs);
        }
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

    protected static void close(Connection con, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ignore) {
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException ignore) {
            }
        }
        if (con != null) {
            try {
                con.close();
            } catch (SQLException ignore) {
            }
        }
    }

}
