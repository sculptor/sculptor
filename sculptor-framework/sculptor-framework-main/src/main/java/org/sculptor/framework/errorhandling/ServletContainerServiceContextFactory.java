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

import java.util.HashSet;
import java.util.Set;

import javax.security.auth.Subject;

public class ServletContainerServiceContextFactory extends ServiceContextFactory {

    public ServletContainerServiceContextFactory() {
        super();
    }

    protected Subject activeSubject() {
        // JAAS Subject not used
        return null;
    }

    protected String userIdFromSubject(Subject caller) {
        // JAAS Subject not used
        return null;
    }

    protected Set<String> rolesFromSubject(Subject caller) {
        // JAAS Subject not used
        Set<String> roles = new HashSet<String>();
        return roles;
    }

}