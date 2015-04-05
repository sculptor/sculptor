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
package org.sculptor.framework.context;

import java.security.Principal;
import java.util.Collections;
import java.util.Random;
import java.util.Set;

import javax.security.auth.Subject;
import javax.servlet.ServletRequest;
import javax.servlet.http.HttpServletRequest;

import org.sculptor.framework.util.FactoryConfiguration;
import org.sculptor.framework.util.FactoryHelper;


/**
 * Factory class to create ServiceContext.
 *
 * @author Patrik Nordwall
 */
public abstract class ServiceContextFactory {

    private static final int MAX_GENERATED_SESSION_ID = 1000000;

    public static final String SYSTEM_USER = "system";
    public static final String GUEST_USER = "guest";
    public static final String UNKNOWN_USER = "unknown";

    private static final Random RANDOM_GENERATOR = new Random(System.currentTimeMillis());

    private static ServiceContextFactory singletonInstance;

    private static FactoryConfiguration config = new FactoryConfiguration() {
        public String getFactoryImplementationClassName() {
            return "org.sculptor.framework.context.JBossServiceContextFactory";
        }
    };

    protected ServiceContextFactory() {
    }

    public static void setConfiguration(FactoryConfiguration aConfig) {
        config = aConfig;
    }

    private static ServiceContextFactory getInstance() {
        if (singletonInstance == null) {
            singletonInstance = createInstance();
        }

        return singletonInstance;
    }

    private static ServiceContextFactory createInstance() {
        return (ServiceContextFactory) FactoryHelper.newInstanceFromName(config.getFactoryImplementationClassName());
    }

    /**
     * Convenience method, it requires that the request is a HttpServletRequest.
     *
     * @see #createServiceContext(HttpServletRequest)
     */
    public static ServiceContext createServiceContext(ServletRequest request) {
        if (!(request instanceof HttpServletRequest)) {
            throw new IllegalArgumentException("Expected HttpServletRequest");
        }
        return createServiceContext((HttpServletRequest) request);
    }

    /**
     * Use this method to create a ServiceContext for a web application.
     * sessionId is the HttpSession id. applicationId is defined in
     * <display-name> in web.xml
     * <p>
     * The userId and roles are populated from current Subject, which was
     * created by some Login Module.
     * <p>
     * If a ServiceContext instance is already available in thread local
     * {@link ServiceContextStore} it will be used instead of creating a new
     * instance.
     */
    public static ServiceContext createServiceContext(HttpServletRequest request) {
        return getInstance().createServiceContextImpl(request);
    }

    protected ServiceContext createServiceContextImpl(HttpServletRequest request) {
        ServiceContext context = ServiceContextStore.get();
        if (context != null) {
            return context;
        }

        String sessionId = request.getSession().getId();
        // ServletContextName is defined in <display-name> in web.xml
        String applicationId = request.getSession().getServletContext().getServletContextName();

        String userId = null;
        Set<String> roles = Collections.emptySet();
        Subject caller = activeSubject();
        if (caller != null) {
            userId = userIdFromSubject(caller);
            roles = rolesFromSubject(caller);
        }

        if (userId == null) {
            // try with this then
            Principal userPrincipal = request.getUserPrincipal();
            if (userPrincipal != null) {
                userId = userPrincipal.getName();
            }
        }

        if (userId == null) {
            // still no user, no login, use guest
            userId = GUEST_USER;
        }

        context = new ServiceContext(userId, sessionId, applicationId, roles);

        return context;
    }

    protected abstract Subject activeSubject();

    protected abstract String userIdFromSubject(Subject caller);

    protected abstract Set<String> rolesFromSubject(Subject caller);

    /**
     * Use this method to create a ServiceContext for a system user, e.g. a MDB
     * for system integration or batch job.
     * <p>
     * If a ServiceContext instance is already available in thread local
     * {@link ServiceContextStore} it will be used instead of creating a new
     * instance.
     *
     * @param applicationId
     *            the id of the external system
     */
    public static ServiceContext createServiceContext(String applicationId) {
        return getInstance().createServiceContextImpl(applicationId);
    }

    protected ServiceContext createServiceContextImpl(String applicationId) {
        ServiceContext context = ServiceContextStore.get();
        if (context != null) {
            return context;
        }
        String sessionId = String.valueOf(RANDOM_GENERATOR.nextInt(MAX_GENERATED_SESSION_ID));
        Subject caller = activeSubject();
        String userId = null;
        Set<String> roles = Collections.emptySet();
        if (caller != null) {
            userId = userIdFromSubject(caller);
            roles = rolesFromSubject(caller);
        } else {
            userId = SYSTEM_USER;
        }

        context = new ServiceContext(userId, sessionId, applicationId, roles);
        return context;
    }

}
