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

package org.sculptor.framework.accessimpl.mongodb;

import java.io.IOException;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;
import org.springframework.web.filter.OncePerRequestFilter;

/**
 * This Servlet Filter should be placed in front of Servlets to facilitate lazy
 * loading of DomainObject associations in view.
 * 
 * @author Patrik Nordwall
 * 
 */
public class DbManagerFilter extends OncePerRequestFilter {

    public DbManagerFilter() {
    }

    @Override
    protected void doFilterInternal(HttpServletRequest request, HttpServletResponse response, FilterChain filterChain)
            throws ServletException, IOException {

        DbManager dbManager = null;
        try {
            dbManager = lookupDbManager();
            DbManager.setThreadInstance(dbManager);
            dbManager.requestStart();

            filterChain.doFilter(request, response);

        } finally {
            if (dbManager != null) {
                dbManager.requestDone();
                DbManager.setThreadInstance(null);
            }
        }

    }

    protected DbManager lookupDbManager() {
        WebApplicationContext wac = WebApplicationContextUtils.getRequiredWebApplicationContext(getServletContext());
        return (DbManager) wac.getBean("mongodbManager", DbManager.class);
    }

}
