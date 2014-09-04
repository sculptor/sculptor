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

package org.sculptor.framework.accessimpl.jpa;

import java.util.List;

import javax.persistence.criteria.CriteriaQuery;

import org.sculptor.framework.accessapi.FindByCriteriaQueryAccess;


/**
 * <p>
 * Implementation of Access command FindByCriteriaQueryAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByCriteriaQueryAccessImplGeneric<T,R>
    extends JpaCriteriaQueryAccessBase<T,R>
    implements FindByCriteriaQueryAccess<R> {

    public JpaFindByCriteriaQueryAccessImplGeneric() {
        super();
    }

    public JpaFindByCriteriaQueryAccessImplGeneric(Class<T> type) {
        super(type);
    }

    public JpaFindByCriteriaQueryAccessImplGeneric(Class<T> type, Class<R> resultType) {
        super(type,resultType);
    }

    public List<R> getResult() {
        return getListResult();
    }

    public void setQuery(CriteriaQuery<R> criteriaQuery) {
        setCriteriaQuery(criteriaQuery);
    }
}