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

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

/**
 * This advice injects the dbManager in the ThreadLocal storage of
 * {@link DbManager#getThreadInstance()}. The thread instance is typically used
 * from DomainObjects when lazy loading associations.
 * 
 * @author Patrik Nordwall
 * 
 */
public class DbManagerAdvice implements MethodInterceptor {

    private DbManager dbManager;

    public Object invoke(MethodInvocation invocation) throws Throwable {
        if (DbManager.getThreadInstance() != null || dbManager == null) {
            // this is not the first advice and it should therefore be ignored
            // it is the first advice that is responsible for setting/clearing
            // the service context
            return invocation.proceed();
        }
        try {
            DbManager.setThreadInstance(dbManager);
            dbManager.requestStart();
            return invocation.proceed();
        } finally {
            dbManager.requestDone();
            DbManager.setThreadInstance(null);
        }
    }

    public DbManager getDbManager() {
        return dbManager;
    }

    public void setDbManager(DbManager dbManager) {
        this.dbManager = dbManager;
    }

}
