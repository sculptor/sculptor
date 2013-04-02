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

package org.sculptor.framework.errorhandling;

import java.io.IOException;
import java.io.Serializable;

import javax.servlet.Filter;
import javax.servlet.FilterChain;
import javax.servlet.FilterConfig;
import javax.servlet.ServletException;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpSession;

import org.sculptor.framework.util.FactoryConfiguration;

/**
 * This Servlet Filter should be placed in front of Servlets to create a new
 * {@link org.sculptor.framework.errorhandling.ServiceContext} instance for each
 * reqest. The ServiceContext instance is stored in the thread local
 * {@link org.sculptor.framework.errorhandling.ServiceContextStore}.
 * <p>
 * The ServiceContext is created by 
 * {@link org.sculptor.framework.errorhandling.ServiceContextFactory}
 * and the concrete factory implementation is configurable by init-param 
 * 'ServiceContextFactoryImplementationClassName'. 
 * <p>
 * The filter will also copy attributes from the HTTP Session to the
 * ServiceContext instance. The attribute names to copy is configurable by the
 * init-param 'copySessionAttributes', which is a comma separated String of
 * attribute names.
 * 
 * @author Patrik Nordwall
 * @see org.sculptor.framework.errorhandling.ServiceContextFactory#createServiceContext(HttpServletRequest)
 * 
 */
public class ServiceContextServletFilter implements Filter {

    private static final String SERVICE_CONTEXT_FACTORY_IMPLEMENTATION_INIT_PARAM = "ServiceContextFactoryImplementationClassName";
    private static final String COPY_SESSION_ATTRIBUTES_INIT_PARAM = "copySessionAttributes";

    private String[] copySessionAttributes;

    public ServiceContextServletFilter() {
        super();
    }

    public void destroy() {

    }

    public void init(FilterConfig filterConfig) throws ServletException {
        initServiceContextFactoryImplementationClassName(filterConfig);
        initCopySessionAttributes(filterConfig);
    }
    
    private void initServiceContextFactoryImplementationClassName(FilterConfig filterConfig) {
        final String serviceContextFactoryImplementationClassName = filterConfig.getInitParameter(SERVICE_CONTEXT_FACTORY_IMPLEMENTATION_INIT_PARAM);
        if (serviceContextFactoryImplementationClassName != null && !serviceContextFactoryImplementationClassName.equals("")) {
            ServiceContextFactory.setConfiguration(new FactoryConfiguration() {
                public String getFactoryImplementationClassName() {
                    return serviceContextFactoryImplementationClassName;
                }
                
            });
        }
    }

    private void initCopySessionAttributes(FilterConfig filterConfig) {
        String copySessionAttributesParam = filterConfig.getInitParameter(COPY_SESSION_ATTRIBUTES_INIT_PARAM);
        if (copySessionAttributesParam != null && !copySessionAttributesParam.equals("")) {
            copySessionAttributes = copySessionAttributesParam.split(",");
            for (int i = 0; i < copySessionAttributes.length; i++) {
                copySessionAttributes[i] = copySessionAttributes[i].trim();
            }
        }
    }

    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException,
            ServletException {
        try {
            ServiceContext ctx = ServiceContextFactory.createServiceContext(request);
            copySessionAttributes((HttpServletRequest) request, ctx);
            ServiceContextStore.set(ctx);

            chain.doFilter(request, response);

        } finally {
            ServiceContextStore.set(null);
        }

    }

    private void copySessionAttributes(HttpServletRequest request, ServiceContext ctx) {
        if (copySessionAttributes == null) {
            return; // nothing to copy
        }
        HttpSession session = request.getSession();
        for (int i = 0; i < copySessionAttributes.length; i++) {
            Object value = session.getAttribute(copySessionAttributes[i]);
            if (value instanceof Serializable) {
                ctx.setProperty(copySessionAttributes[i], (Serializable) value);
            }
        }
    }

}
