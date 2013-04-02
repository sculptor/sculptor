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

import java.util.Enumeration;
import java.util.HashSet;
import java.util.Set;

import javax.security.auth.Subject;
import javax.security.jacc.PolicyContext;
import javax.security.jacc.PolicyContextException;

import org.jboss.security.SimpleGroup;
import org.jboss.security.SimplePrincipal;

/**
 * JBoss specific implementation of
 * {@link org.sculptor.framework.errorhandling.ServiceContextFactory}.
 * 
 * @author Patrik Nordwall
 * 
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
        Set<SimplePrincipal> jaasUserPrincipals = caller.getPrincipals(SimplePrincipal.class);
        if (jaasUserPrincipals.isEmpty()) {
            return null;
        } else {
            for (SimplePrincipal p : jaasUserPrincipals) {
                // Use the first SimplePrincipal, which is not a SimpleGroup
                // SimpleGroup is subclass of SimplePrincipal
                if (p instanceof SimpleGroup) {
                    continue;
                } else {
                    return p.getName();
                }
            }
            // userPrincipal not found
            return null;
        }
    }

    protected Set<String> rolesFromSubject(Subject caller) {
        Set<String> roles = new HashSet<String>();
        Set<SimpleGroup> jaasRolesPrincipals = caller.getPrincipals(SimpleGroup.class);
        for (SimpleGroup role : jaasRolesPrincipals) {
            for (Enumeration<?> membersEnum = role.members(); membersEnum.hasMoreElements();) {
                String member = String.valueOf(membersEnum.nextElement());
                roles.add(member);
            }
        }
        return roles;
    }

}
