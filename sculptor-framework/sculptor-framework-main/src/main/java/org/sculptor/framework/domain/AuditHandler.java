/*
 * (C) Copyright Factory4Solutions a.s. 2009
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
package org.sculptor.framework.domain;

import java.io.Serializable;
import java.util.Set;

/**
 * Public interface of AuditHandlerImpl log
 * 
 * @author Ing. Pavel Tavoda
 */
public interface AuditHandler<T> {
    public boolean isChanged(Property<? super T> property);

    public Serializable getOldValue(Property<? super T> property);

    public Serializable getNewValue(Property<? super T> property);

    public Set<Property<? super T>> getOldValueList();
}
