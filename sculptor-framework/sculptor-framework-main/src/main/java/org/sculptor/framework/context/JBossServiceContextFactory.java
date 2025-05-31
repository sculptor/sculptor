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

import com.sun.security.auth.NTUserPrincipal;

import java.nio.file.attribute.GroupPrincipal;
import java.nio.file.attribute.UserPrincipal;
import java.util.Enumeration;
import java.util.HashSet;
import java.util.Set;

import javax.security.auth.Subject;
import javax.security.jacc.PolicyContext;
import javax.security.jacc.PolicyContextException;

/**
 * JBoss specific implementation of
 * {@link org.sculptor.framework.context.ServiceContextFactory}.
 * 
 * @author Patrik Nordwall
 */
public class JBossServiceContextFactory extends ServiceContextFactory {
    
    /** The JACC PolicyContext key for the current Subject */
    private static final String SUBJECT_CONTEXT_KEY = "javax.security.auth.Subject.container";

    protected Subject activeSubject() {
        try {
            Subject caller = (Subject) PolicyContext.getContext(SUBJECT_CONTEXT_KEY);
            return caller;
        } catch (PolicyContextException e) {
            return null;
        }
    }
    
    protected String userIdFromSubject(Subject caller) {
        Set<UserPrincipal> jaasUserPrincipals = caller.getPrincipals(UserPrincipal.class);
        if (jaasUserPrincipals.isEmpty()) {
            return null;
        } else {
            for (UserPrincipal p : jaasUserPrincipals) {
                // Use the first SimplePrincipal, which is not a SimpleGroup
                // SimpleGroup is subclass of SimplePrincipal
                if (!(p instanceof GroupPrincipal)) {
                    return p.getName();
                }
            }
            // userPrincipal not found
            return null;
        }
    }

    protected Set<String> rolesFromSubject(Subject caller) {
        Set<String> roles = new HashSet<String>();
        Set<GroupPrincipal> jaasRolesPrincipals = caller.getPrincipals(GroupPrincipal.class);
        for (GroupPrincipal p : jaasRolesPrincipals) {
            roles.add(p.getName());
        }
        return roles;
    }

}
