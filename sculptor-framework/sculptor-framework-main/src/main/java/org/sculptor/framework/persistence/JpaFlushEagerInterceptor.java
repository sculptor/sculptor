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
package org.sculptor.framework.persistence;

import javax.ejb.EJBTransactionRolledbackException;
import javax.interceptor.AroundInvoke;
import javax.interceptor.InvocationContext;
import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.TransactionRequiredException;

/**
 * This interceptor flushes the {@link EntityManager} after normal return.
 * <p>
 * We have to flush eagerly in order to detect OptimisticLockingException and do
 * proper rollback.
 * 
 * @author Patrik Nordwall
 */
public class JpaFlushEagerInterceptor  {

	@PersistenceContext
	private EntityManager entityManager;

	@AroundInvoke
    public Object invoke(InvocationContext context) throws Exception {
		Object result = context.proceed();
        if (entityManager != null) {
            try {
                entityManager.flush();
            } catch (EJBTransactionRolledbackException ignore) {
                // already marked for rollback
            } catch (TransactionRequiredException ignore) {
                // already marked for rollback
            }
        }
        return result;
    }

}
