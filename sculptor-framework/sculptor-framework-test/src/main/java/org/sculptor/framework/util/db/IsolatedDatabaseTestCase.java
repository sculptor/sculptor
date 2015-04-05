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
package org.sculptor.framework.util.db;

import org.dbunit.DatabaseTestCase;
import org.dbunit.database.IDatabaseConnection;
import org.dbunit.dataset.IDataSet;
import org.dbunit.dataset.ReplacementDataSet;
import org.dbunit.dataset.xml.FlatXmlDataSet;
import org.dbunit.dataset.xml.FlatXmlDataSetBuilder;
import org.dbunit.operation.DatabaseOperation;
import org.sculptor.framework.context.ServiceContext;
import org.sculptor.framework.context.ServiceContextFactory;
import org.sculptor.framework.context.ServiceContextStore;
import org.sculptor.framework.util.FactoryConfiguration;
import org.springframework.context.ApplicationContext;
import org.springframework.context.ConfigurableApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;


/**
 * Base class for DBUnit TestCase. It will create new Spring context in setUp,
 * i.e. create all tables, and drop all tables in tearDown.
 * <p>
 * Remember to invoke super.setUp and super.tearDown if you override those
 * methods.
 * 
 * <p>
 * The intention was to make this class abstract, but JUnit (Maven Surfire
 * plugin) tries to instantiate it anyway, and therefore it is not abstract.
 * Override the method {@link #getDataSetFile} to specify XML file with DBUnit
 * test data.
 * 
 * @author Patrik Nordwall
 */
public class IsolatedDatabaseTestCase extends DatabaseTestCase {

    private static String DEFAULT_SPRING_CONFIG_FILE_LOCATION = "/applicationContext-test.xml";

    static {
        ServiceContextFactory.setConfiguration(new FactoryConfiguration() {
            public String getFactoryImplementationClassName() {
                return "org.sculptor.framework.context.JUnitServiceContextFactory";
            }
        });
    }
    private ServiceContext serviceContext = ServiceContextFactory.createServiceContext("JUnit");
    
    private ApplicationContext context;

    public IsolatedDatabaseTestCase() {
    }

    protected void setUp() throws Exception {
        // Don't use singleton context, since we need to re-create the tables
        // each time
        context = new ClassPathXmlApplicationContext(getSpringConfig());
        if (ServiceContextStore.get() == null) {
            ServiceContextStore.set(getServiceContext());
        }
        super.setUp();
    }

    /**
     * Override this method to specify the main Spring configuration file to
     * use. By default applicationContext-test.xml will be used.
     */
    protected String getSpringConfig() {
        return DEFAULT_SPRING_CONFIG_FILE_LOCATION;
    }

    protected void tearDown() throws Exception {
        super.tearDown();
        ((ConfigurableApplicationContext) context).close();
        context = null;
    }

    protected DatabaseOperation getSetUpOperation() throws Exception {
        return DatabaseOperation.REFRESH;
    }

    protected DatabaseOperation getTearDownOperation() throws Exception {
        return new DropAllTablesOperation();
    }

    protected IDatabaseConnection getConnection() throws Exception {
        return getDbUnitConnection().getConnection();
    }

    protected DbUnitConnection getDbUnitConnection() {
        return new DbUnitConnection(getDataSourceSpringBeanName());
    }

    /**
     * Override this to specify another datasource. By default hsqldbDataSource
     * is used.
     */
    protected String getDataSourceSpringBeanName() {
        return "hsqldbDataSource";
    }

	protected IDataSet getDataSet() throws Exception {
		FlatXmlDataSet xmlDataSet = new FlatXmlDataSetBuilder().build(this.getClass().getClassLoader()
				.getResourceAsStream(getDataSetFile()));
		ReplacementDataSet dataSet = new ReplacementDataSet(xmlDataSet);
		dataSet.addReplacementObject("[NULL]", null);
		return dataSet;
	}

    /**
     * Override this method to specify the XML file with DBUnit test data.
     * <p>
     * The intention was to make this class abstract, but JUnit tries to
     * instantiate it anyway, and therefore it is not abstract.
     */
    protected String getDataSetFile() {
        throw new UnsupportedOperationException("Override getDataSetFile method in subclass");
    }

    protected ApplicationContext getContext() {
        return context;
    }

    protected ServiceContext getServiceContext() {
        return serviceContext;
    }

}
