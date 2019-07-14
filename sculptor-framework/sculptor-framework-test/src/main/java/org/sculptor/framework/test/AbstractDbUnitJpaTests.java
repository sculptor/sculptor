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

package org.sculptor.framework.test;

import javax.persistence.EntityManager;
import javax.persistence.EntityManagerFactory;
import javax.persistence.PersistenceUnit;
import javax.persistence.Query;

import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.springframework.orm.jpa.SharedEntityManagerCreator;

/**
 * Base class for transactional spring-based DBUnit tests in a JPA environment.
 *
 * <p>
 * Override the method {@link #getDataSetFile} to specify XML file with DBUnit
 * test data.
 *
 * @author Patrik Nordwall
 * @author Oliver Ringel
 *
 */
public abstract class AbstractDbUnitJpaTests extends AbstractDbUnitAnnotationAwareTransactionalTests {

    private EntityManager entityManager;
    private static boolean buildSchemaExecuted = false;

    public AbstractDbUnitJpaTests() {
    }

    @PersistenceUnit
    public void setEntityManagerFactory(EntityManagerFactory entityManagerFactory) {
        this.entityManager = SharedEntityManagerCreator.createSharedEntityManager(entityManagerFactory);
    }

    protected EntityManager getEntityManager() {
        return entityManager;
    }

    /**
     * In case you don't need to start the id sequence from a high value to
     * avoid conflicts with test data you should override this method and return
     * null.
     */
    @Override
    protected String getSequenceName() {
        if (JpaHelper.isJpaProviderHibernate(getEntityManager())) {
            return "hibernate_sequence";
        } else if (JpaHelper.isJpaProviderEclipselink(getEntityManager())) {
            return "SEQ_GEN";
        } else {
            return null;
        }
    }

    @Override
    public void tearDownDatabaseTester() throws Exception {
        // commented out because of locking problems with OrderedDeleteAllOperation
        // DbUnitDataSourceUtils.tearDownDatabaseTester();
    }

    /**
     * flushes the entity manager to get the correct result via jdbc
     */
    protected void flush() {
        entityManager.flush();
    }

    protected void clear() {
        entityManager.clear();
    }

    /**
     * Using a separate JDBC connection causes locking problems with different rdbms
     * (hsqldb 2.x introduced a new transaction, locking and isolation level handling)
     */
    @Override
    protected int countRowsInTable(String tableName, String additionalCondition) {
        flush();
        clear();
        Query query = entityManager.createNativeQuery("select count(*) from " + tableName + " " + additionalCondition);
        Number rowCount = (Number) query.getSingleResult();
        return rowCount.intValue();
    }

    @Override
    protected void buildSchema() {
    	if (!buildSchemaExecuted) {
            executeScript("file:src/test/generated/resources/dbunit/ddl.sql");
            executeScript("file:src/test/generated/resources/dbunit/ddl_additional.sql");
            buildSchemaExecuted = true;
        }
    };

    /**
     * Execute some SQL scripts before setup the database
     * (Workaround for DataNucleus and OpenJPA together with DBUnit).
     *
     * @throws Exception
     */
    protected boolean executeScript(String scriptFile) {
        if (getApplicationContext().getResource(scriptFile).exists()) {
            executeSqlScript(scriptFile, true);
            return true;
        }
        return false;
    }
}
