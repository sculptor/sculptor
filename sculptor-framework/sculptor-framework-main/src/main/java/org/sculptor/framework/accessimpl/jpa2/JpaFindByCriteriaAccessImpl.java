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

package org.sculptor.framework.accessimpl.jpa2;

import org.sculptor.framework.accessapi.FindByCriteriaAccess;


/**
 * <p>
 * Implementation of Access command FindByCriteriaAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaFindByCriteriaAccessImpl<T>
    extends JpaFindByCriteriaAccessImplGeneric<T,T>
    implements FindByCriteriaAccess<T> {

    public JpaFindByCriteriaAccessImpl() {
        super();
    }

    public JpaFindByCriteriaAccessImpl(Class<T> type) {
        super(type);
    }
}