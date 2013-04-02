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

import org.aopalliance.intercept.MethodInterceptor;
import org.aopalliance.intercept.MethodInvocation;

/**
 * This advice stores the ServiceContext, which is passed in one of the method
 * parameters, in {@link org.sculptor.framework.errorhandling.ServiceContextStore}.
 * After proceed, both when returning and when exception, the
 * ServiceContextStore will be cleared.
 * 
 * @author Patrik Nordwall
 * 
 */
public class ServiceContextStoreAdvice implements MethodInterceptor {

    public Object invoke(MethodInvocation invocation) throws Throwable {
        if (ServiceContextStore.get() != null) {
            // this is not the first advice and it should therefore be ignored
            // it is the first advice that is responsible for setting/clearing
            // the service context
            return invocation.proceed();
        }
        try {
            Object[] args = invocation.getArguments();
            if (args != null) {
                for (int i = 0; i < args.length; i++) {
                    if (args[i] instanceof ServiceContext) {
                        ServiceContextStore.set((ServiceContext) args[i]);
                        break;
                    }
                }
            }
            return invocation.proceed();
        } finally {
            ServiceContextStore.set(null);
        }
    }

}
