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

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;

import org.junit.After;
import org.junit.Before;
import org.junit.runner.RunWith;
import org.sculptor.framework.context.ServiceContext;
import org.sculptor.framework.context.ServiceContextStore;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

import com.google.apphosting.api.ApiProxy.Environment;

/**
 * Base class for spring-based tests in a Google App Engine environment.
 * 
 * @author Patrik Nordwall
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public abstract class AbstractAppEngineJpaTests extends AbstractJUnit4SpringContextTests {
    private EntityManager entityManager;

    public AbstractAppEngineJpaTests() {
    }

    @Before
    public void setUpAppEngine() {
        AppEngineTestHelper.setUpAppEngine(createAppEngineTestEnvironment());
        ServiceContextStore.set(getServiceContext());
    }

    @After
    public void tearDownAppEngine() {
        AppEngineTestHelper.tearDownAppEngine();
    }

    protected ServiceContext getServiceContext() {
        return AppEngineTestHelper.getServiceContext();
    }

    @PersistenceContext
    protected void setEntityManager(EntityManager entityManager) {
        this.entityManager = entityManager;
    }

    protected EntityManager getEntityManager() {
        return entityManager;
    }

    /**
     * flushes the entity manager to get the correct result via jdbc
     */
    protected void flush() {
        getEntityManager().flush();
    }

    /**
     * Subclass may override to provide another environment
     */
    protected Environment createAppEngineTestEnvironment() {
        return new SimpleAppEngineTestEnvironment();
    }

    /**
     * Counts the number of stored instances of an object.
     */
    protected int countRowsInTable(Class<?> domainObjectClass) throws Exception {
        Query query = getEntityManager()
                .createQuery("select count(e) from " + domainObjectClass.getSimpleName() + " e");
        return (Integer) query.getSingleResult();
    }
}
