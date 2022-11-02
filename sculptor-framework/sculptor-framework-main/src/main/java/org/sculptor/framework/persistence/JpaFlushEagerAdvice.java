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

import java.lang.reflect.Method;

import javax.persistence.EntityManager;
import javax.persistence.TransactionRequiredException;

import org.springframework.aop.AfterReturningAdvice;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * This advice flushes the {@link EntityManager} after normal return.
 * <p>
 * We have to flush eagerly in order to detect OptimisticLockingException and do
 * proper rollback.
 */
public class JpaFlushEagerAdvice implements AfterReturningAdvice {

	@Autowired
	private EntityManager[] entityManagers;

	@Override
	public void afterReturning(Object returnValue, Method method, Object[] args, Object target) throws Throwable {
		if (entityManagers != null && entityManagers.length > 0) {
			for (EntityManager e : entityManagers) {
				try {
					e.flush();
				} catch (TransactionRequiredException ignore) {
					// already marked for rollback
				}
			}
		}
	}

}
