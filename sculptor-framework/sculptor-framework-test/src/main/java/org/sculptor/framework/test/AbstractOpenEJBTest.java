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
package org.sculptor.framework.test;

import java.io.IOException;
import java.io.InputStream;
import java.lang.reflect.Field;
import java.net.URL;
import java.util.Enumeration;
import java.util.Properties;

import javax.annotation.Resource;
import javax.ejb.EJB;
import javax.jms.Destination;
import javax.jms.Message;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;

import org.apache.log4j.PropertyConfigurator;
import org.junit.AfterClass;
import org.junit.Before;
import org.sculptor.framework.errorhandling.ServiceContext;
import org.sculptor.framework.errorhandling.ServiceContextFactory;
import org.sculptor.framework.test.ejbtestbean.messaging.MessagingTestLocal;
import org.sculptor.framework.util.FactoryConfiguration;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Base class tests in a OpenEJB environment.
 * <p>
 * Inject dependencies to EJBs with the ordinary @EJB annotation.
 * <p>
 * OpenEJB is initialized from properties loaded from classpath
 * 'openejb-test.properties'. In case you need to destroy the container after
 * each test (class) you should add property
 * openejb.embedded.initialcontext.close=destroy It is possible to override
 * persistent unit properties this way also.
 * <p>
 * More information: http://openejb.apache.org/3.0/index.html
 * 
 * @author Patrik Nordwall
 * 
 */
public abstract class AbstractOpenEJBTest {

    static {
        try {
            if (System.getProperty("openejb.logger.external") == null) {
                System.setProperty("openejb.logger.external", "true");
            }

            String log4jSysProp = System.getProperty("log4j.configuration");
            if (log4jSysProp == null
                    || Thread.currentThread().getContextClassLoader().getResource(log4jSysProp) == null) {
                URL logConfiguration = Thread.currentThread().getContextClassLoader()
                        .getResource("log4j-test.properties");
                if (logConfiguration != null) {
                    PropertyConfigurator.configure(logConfiguration);
                }
            }
        } catch (Throwable e) {
            System.err.println("Couldn't initialize logging, using default (maybe nothing will be logged)");
        }
    }

    static {
        ServiceContextFactory.setConfiguration(new FactoryConfiguration() {
            @Override
            public String getFactoryImplementationClassName() {
                return "org.sculptor.framework.errorhandling.JUnitServiceContextFactory";
            }
        });
    }

    private static InitialContext initialContext;
    private static Properties initalContextProperties;

    private final Logger log = LoggerFactory.getLogger(getClass());

    private final int messageReplyTimeout = 10000;

    private final ServiceContext serviceContext = ServiceContextFactory.createServiceContext("JUnit");

    private MessagingTestLocal messagingTestBean;

    public AbstractOpenEJBTest() {
    }

    @Before
    public void initialize() throws Exception {
        initOpenEjb();
        initAnnotatedDependencies();
    }

    @AfterClass
    public static void cleanup() {
        if ("destroy".equals(initalContextProperties.get("openejb.embedded.initialcontext.close"))) {
            closeOpenEjb();
        }
    }

    public static void closeOpenEjb() {
        System.clearProperty(Context.INITIAL_CONTEXT_FACTORY);
        if (initialContext != null) {
            try {
                initialContext.close();
                initialContext = null;
            } catch (NamingException ignore) {
            }
        }
    }

    protected void initOpenEjb() throws Exception {

        long t0 = System.currentTimeMillis();
        if (initialContext == null) {
            initalContextProperties = createInitialContextProperties();
            // Need to set this System property to be able to do new
            // InitialContext()
            System.setProperty(Context.INITIAL_CONTEXT_FACTORY,
                    initalContextProperties.getProperty(Context.INITIAL_CONTEXT_FACTORY));

            initialContext = new InitialContext(initalContextProperties);
        }

        messagingTestBean = lookup(getMessagingTestBeanJndiName());
        if (messagingTestBean == null) {
            throw new IllegalStateException("Couldn't find " + getMessagingTestBeanJndiName());
        }

        log.info("OpenEJB initialized in: " + (System.currentTimeMillis() - t0) + " ms");
    }

    protected String getMessagingTestBeanJndiName() {
        return "MessagingTestBeanLocal";
    }

    protected Properties createInitialContextProperties() {
        Properties defaultProperties = new Properties();
        defaultProperties.put(Context.INITIAL_CONTEXT_FACTORY, "org.apache.openejb.client.LocalInitialContextFactory");
        // defaultProperties.setProperty("openejb.embedded.initialcontext.close",
        // "destroy");
        // alternative deployment descriptors prefixed with test
        defaultProperties.put("openejb.altdd.prefix", "test");

        defaultProperties.put("openejb.deployments.classpath.include", ".*sculptor.framework.test.*");

        additionalInitialContextProperties(defaultProperties);

        Properties fileProperties = loadInitialContextPropertiesFromFile(defaultProperties);
        return fileProperties;
    }

    /**
     * possible to override to include more, or change, InitialContext
     * Properties
     */
    protected void additionalInitialContextProperties(Properties defaultProperties) {
    }

    @SuppressWarnings("unchecked")
    protected Properties loadInitialContextPropertiesFromFile(Properties defaultProperties) {
        String resourceName = "/openejb-test.properties";
        InputStream resource = getClass().getResourceAsStream(resourceName);
        if (resource == null) {
            log.info("Didn't find properties file: " + resourceName);
            return defaultProperties;
        } else {
            Properties p = new Properties();
            try {
                p.load(resource);
            } catch (IOException ignore) {
                log.warn("Couldn't load properties file: " + resourceName);
            }

            // it doesn't work to use defaultProperties as defaults to p
            for (Enumeration<String> iter = (Enumeration<String>) defaultProperties.propertyNames(); iter
                    .hasMoreElements();) {
                String name = iter.nextElement();
                Object value = p.get(name);
                if (value == null) {
                    p.put(name, defaultProperties.get(name));
                } else if ("".equals(value)) {
                    p.remove(name);
                }
            }

            return p;
        }
    }

    @SuppressWarnings("unchecked")
    protected <T> T lookup(String name) throws NamingException {

        try {
            return (T) initialContext.lookup(name);
        } catch (NamingException e) {
            if (!name.endsWith("Local")) {
                try {
                    return (T) initialContext.lookup(name + "Local");
                } catch (NamingException ignore) {
                    // throw first e
                }
            }
            try {
                return (T) initialContext.lookup("openejb:Resource/" + name);
            } catch (NamingException ignore) {
                // throw first e
            }

            throw e;
        }
    }

    protected InitialContext getInitialContext() {
        return initialContext;
    }

    protected void initAnnotatedDependencies() throws NamingException {
        Field[] fields = getClass().getDeclaredFields();
        for (Field each : fields) {
            initEjbAnnotatedDependency(each);
            initResouceAnnotatedDependency(each);
        }
    }

    protected void initEjbAnnotatedDependency(Field field) throws NamingException {
        EJB annotation = field.getAnnotation(EJB.class);
        if (annotation == null) {
            return;
        }

        String name = annotation.beanName();
        if (name == null || name.equals("")) {
            name = field.getName();
        }

        inject(field, name);
    }

    protected void initResouceAnnotatedDependency(Field field) throws NamingException {
        Resource annotation = field.getAnnotation(Resource.class);
        if (annotation == null) {
            return;
        }

        String name = annotation.mappedName();
        if (name == null || name.equals("")) {
            name = field.getName();
        }
        inject(field, name);
    }

    private void inject(Field field, String lookupName) throws NamingException {
        Object ejb = lookup(lookupName);
        try {
            field.setAccessible(true);
            field.set(this, ejb);
        } catch (Exception e) {
            throw new RuntimeException("Could not inject dependency for " + lookupName + ": " + e.getMessage());
        }
    }

    protected ServiceContext getServiceContext() {
        return serviceContext;
    }

    /**
     * @return temporary queue for the reply
     */
    protected Destination sendMessage(Destination destination, String message) {
        return messagingTestBean.sendMessage(destination, message);
    }

    /**
     * @return queue for the reply, either as specified replyTo in message, or a
     *         temporary queue
     */
    protected Destination sendMessage(Destination destination, Message message) {
        return messagingTestBean.sendMessage(destination, message);
    }

    protected Message waitForReply(Destination replyDestination) {
        return waitForReply(replyDestination, messageReplyTimeout);
    }

    protected Message waitForReply(Destination replyDestination, int timeoutMillis) {
        Message result = messagingTestBean.waitForReply(replyDestination, timeoutMillis);
        if (result == null) {
            throw new RuntimeException("No reply within timeout: " + timeoutMillis + " ms");
        }
        // wait little bit longer for transaction to complete
        try {
            long waitTime = Math.max(timeoutMillis / 20, 1000);
            Thread.sleep(waitTime);
        } catch (InterruptedException e) {
        }
        return result;
    }
}
