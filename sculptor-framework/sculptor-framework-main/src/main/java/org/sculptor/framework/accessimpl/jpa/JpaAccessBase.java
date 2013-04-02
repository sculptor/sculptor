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

package org.sculptor.framework.accessimpl.jpa;

import javax.persistence.PersistenceException;

import org.sculptor.framework.errorhandling.ApplicationException;


/**
 * Base class for Access Objects that doesn't throw ApplicationException.
 * It is responsible for some common JPA stuff and error handling.
 * <p>
 * Subclasses must implement {@link #performExecute()}
 *
 */
public abstract class JpaAccessBase<T> extends JpaAccessBaseWithException<T> {

	public void execute() {
        try {
            super.execute();
        } catch (ApplicationException e) {
            throw new RuntimeException("Don't expect " + e.getClass().getName() +
                    " from execute of " + getClass().getName());
        }
    }

    public abstract void performExecute() throws PersistenceException;
}
