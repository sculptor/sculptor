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

/**
 * Helper class that can be used to store & access the ServiceContext object in
 * the ThreadLocal memory, and in that way make the ServiceContext object
 * available for all objects taking part in handling a request in the EJB tier
 * without having to pass the context object to all participating methods.
 * <p>
 *
 * <em>Don't use this to pass ServiceContext in remote method calls.</em>
 *
 * @author Patrik Nordwall
 */
public class ServiceContextStore {

    // thread-local storage
    private static ThreadLocal<ServiceContext> threadLocal = new ThreadLocal<ServiceContext>();

    /**
     * Sets the service-context in the thread-local storage.
     */
    public static void set(ServiceContext ctx) {
        threadLocal.set(ctx);
    }

    /**
     * Gets the service-context in the thread-local storage.
     *
     * @return ServiceContext of this thread
     */
    public static ServiceContext get() {
        return threadLocal.get();
    }

    /**
     * Current user from ServiceContext. If ServiceContext is not set then
     * {@link ServiceContextFactory.SYSTEM_USER} is returned.
     */
    public static String getCurrentUser() {
        ServiceContext ctx = ServiceContextStore.get();
        String currentUser;
        if (ctx == null) {
            currentUser = ServiceContextFactory.SYSTEM_USER;
        } else {
            currentUser = ctx.getUserId();
        }

        if (currentUser == null) {
            currentUser = ServiceContextFactory.UNKNOWN_USER;
        }
        return currentUser;
    }

}
