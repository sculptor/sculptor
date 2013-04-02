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
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Set;

/**
 * Implementation of full audit log interface
 * 
 * @author Ing. Pavel Tavoda
 */
public class AuditHandlerImpl<T> implements AuditHandler<T>, Serializable {
    private static final long serialVersionUID = -5799264861822716653L;
    private final Map<Property<? super T>, Serializable> oldValues = new HashMap<Property<? super T>, Serializable>();
    private final Map<Property<? super T>, Serializable> newValues = new HashMap<Property<? super T>, Serializable>();
    private boolean auditingValues = false;

    public boolean isChanged(Property<? super T> property) {
        return oldValues.containsKey(property);
    }

    public Serializable getOldValue(Property<? super T> property) {
        return oldValues.get(property);
    }

    public Serializable getNewValue(Property<? super T> property) {
        return newValues.get(property);
    }

    public Set<Property<? super T>> getOldValueList() {
        return Collections.unmodifiableSet(oldValues.keySet());
    }

    public void startAuditing() {
        auditingValues = true;
    }

    public void recordChange(Property<? super T> valProp, Serializable oldVal,
            Serializable newVal) {
        if (auditingValues
                && ((oldVal != null && !oldVal.equals(newVal)) || (oldVal == null && newVal != null))) {
            if (!oldValues.containsKey(valProp)) {
                oldValues.put(valProp, oldVal);
            }
            newValues.put(valProp, newVal);
        }
    }
}
