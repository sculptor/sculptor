/*
 * Copyright 2009 The Fornax Project Team, including the original
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
package org.sculptor.framework.test.ejbtestbean.jpa;

import javax.annotation.Resource;
import javax.ejb.Stateless;
import javax.ejb.TransactionManagement;
import javax.ejb.TransactionManagementType;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.sql.DataSource;

/**
 * Used by AbstractOpenEJBDbUnitTest, but can be used directly from application
 * project (test.ejb-jar file) also. The 'openejb.deployments.classpath.include'
 * will cause this EJB to be automatically discovered and deployed when OpenEJB
 * boots up. When using multiple persistence units you have to skip auto deploy
 * by adding the following property to openejb-test.properties:
 * openejb.deployments.classpath.include=
 * <p>
 * Instead you should deploy it via test.ejb-jar file and define the persistence
 * unit to use.
 * 
 * <pre>
 *         &lt;session>
 *             &lt;ejb-name>TestBean&lt;/ejb-name>
 *             &lt;ejb-class>org.sculptor.framework.test.ejbtestbean.jpa.TestBean&lt;/ejb-class>
 *             &lt;session-type>Stateless&lt;/session-type>
 *             &lt;persistence-context-ref>
 *                 &lt;persistence-context-ref-name>
 *                     org.sculptor.framework.test.ejbtestbean.jpa.TestBean/entityManager&lt;/persistence-context-ref-name>
 *                 &lt;persistence-unit-name>MyAppEntityManagerFactory&lt;/persistence-unit-name>
 *                 &lt;persistence-context-type>Transaction&lt;/persistence-context-type>
 *             &lt;/persistence-context-ref>
 *         &lt;/session>
 *         &lt;session>
 *             &lt;ejb-name>TestBean2&lt;/ejb-name>
 *             &lt;ejb-class>org.sculptor.framework.test.ejbtestbean.jpa.TestBean&lt;/ejb-class>
 *             &lt;session-type>Stateless&lt;/session-type>
 *             &lt;persistence-context-ref>
 *                 &lt;persistence-context-ref-name>
 *                     org.sculptor.framework.test.ejbtestbean.jpa.TestBean/entityManager&lt;/persistence-context-ref-name>
 *                 &lt;persistence-unit-name>SecondaryEntityManagerFactory&lt;/persistence-unit-name>
 *                 &lt;persistence-context-type>Transaction&lt;/persistence-context-type>
 *             &lt;/persistence-context-ref>
 *         &lt;/session>
 * </pre>
 * 
 */
@Stateless(name = "JpaTestBean")
@TransactionManagement(TransactionManagementType.BEAN)
public class JpaTestBean implements JpaTestLocal {

    @Resource(name = "DefaultDS", mappedName = "DefaultDS", type = javax.sql.DataSource.class)
    private DataSource dataSource;

    private EntityManager entityManager;

    @Override
    public EntityManager getEntityManager() {
        return entityManager;
    }

    @PersistenceContext
    protected void setEntityManager(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    @Override
    public DataSource getDataSource() {
        return dataSource;
    }

}