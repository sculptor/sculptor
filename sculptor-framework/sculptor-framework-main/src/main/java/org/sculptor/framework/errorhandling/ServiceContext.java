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

import java.io.Serializable;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Set;

/**
 * The ServiceContext class is needed to support logging and audit trail
 * functionality through the tiers of an application. A ServiceContext object
 * will typically be sent through all tiers, and represents the context in which
 * a business service is called.
 * <p>
 * 
 * Such a context includes information about:
 * <ul>
 * <li>which user (real, not technical) that calls a (business) service
 * <li>roles of the user
 * <li>which application/channel that is used by the user to access the service
 * <li>the identity of the user session in which the call is made
 * </ul>
 * In addition, other (application-/service specific) properties may be added to
 * the context.
 * <p>
 * 
 * @author Patrik Nordwall
 * 
 */
public class ServiceContext implements Serializable {

    private static final long serialVersionUID = 6953254895524422542L;

    private String userId = null;
    private String sessionId = null;
    private String applicationId = null;
    private Map<String, Serializable> properties = null;
    private Set<String> roles = Collections.emptySet();

    /**
     * Constructor for the ServiceContext object
     * 
     * @param userId
     *            the ID of the (real, not technical) user that calls the
     *            service
     * @param sessionId
     *            the ID of the user session within which the service call
     *            occurs
     * @param applicationId
     *            the ID of the application (channel) that is used
     */
    public ServiceContext(String userId, String sessionId, String applicationId) {
        this.userId = userId;
        this.sessionId = sessionId;
        this.applicationId = applicationId;
    }

    public ServiceContext(String userId, String sessionId, String applicationId, Set<String> roles) {
        this(userId, sessionId, applicationId);
        this.roles = roles;
    }

    public String getApplicationId() {
        return applicationId;
    }

    public String getSessionId() {
        return sessionId;
    }

    public String getUserId() {
        return userId;
    }

    /**
     * The user is member of these roles.
     * 
     * @return Set of String elements representing the roles of the user
     */
    public Set<String> getRoles() {
        return Collections.unmodifiableSet(roles);
    }

    /**
     * Check if user is in role specified as parameter (ignoring case)
     * 
     * @param name
     *            of role to look for (ignoring case)
     * @return true if user own specified role, otherwise false
     */
    public boolean isUserInRole(String role) {
        for (String assRole : getRoles()) {
            if (assRole.equalsIgnoreCase(role)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Gets the property attribute of the ServiceContext object
     * 
     * @param key
     *            the property key
     * @return the property value (null if key was not found)
     */
    public synchronized Serializable getProperty(String key) {
        if (properties == null) {
            return null;
        }
        return properties.get(key);
    }

    /**
     * Adds a property to the ServiceContext object
     * 
     * @param key
     *            the property key
     * @param value
     *            the property value
     */
    public synchronized void setProperty(String key, Serializable value) {
        if (properties == null) {
            properties = new HashMap<String, Serializable>();
        }
        properties.put(key, value);
    }

    /**
     * Gets all property keys for attributes of the ServiceContext object
     * 
     * @return property key values, String elements
     */
    public synchronized Iterator<String> getPropertyKeys() {
        if (properties == null) {
            properties = new HashMap<String, Serializable>();
        }
        return properties.keySet().iterator();
    }

    /**
     * @return String representation of this instance
     */
    @Override
    public synchronized String toString() {
        if (properties == null) {
            return "user-id=" + userId + ", session-id=" + sessionId + ", application-id=" + applicationId;
        } else {
            StringBuilder sb = new StringBuilder();
            sb.append("user-id=" + userId + ", session-id=" + sessionId + ", application-id=" + applicationId);
            for (String key : properties.keySet()) {
                sb.append(", " + key + "=" + properties.get(key));
            }
            return sb.toString();
        }
    }
}
