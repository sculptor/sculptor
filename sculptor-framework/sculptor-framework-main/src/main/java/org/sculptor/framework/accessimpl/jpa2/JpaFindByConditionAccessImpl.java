/*
 * Copyright 2009 The Fornax Project Team, including the original
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

package org.sculptor.framework.accessimpl.jpa2;

import java.util.List;

import org.sculptor.framework.accessapi.FindByConditionAccess;


/**
 * <p>
 * Implementation of Access command FindByConditionAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByConditionAccessImpl<T>
    extends JpaFindByConditionAccessImplGeneric<T,T>
    implements FindByConditionAccess<T> {

    public JpaFindByConditionAccessImpl() {
        super();
    }

    public JpaFindByConditionAccessImpl(Class<T> type) {
        super(type);
    }

    public List<T> getResult() {
        return getListResult();
    }

	@Override
	public void executeCount() {
		executeResultCount();
	}
}