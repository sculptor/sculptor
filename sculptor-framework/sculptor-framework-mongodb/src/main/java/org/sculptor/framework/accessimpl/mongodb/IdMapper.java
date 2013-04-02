/*
 * Copyright 2010 The Fornax Project Team, including the original
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

import java.util.Collections;
import java.util.List;

public class IdMapper implements DataMapper<Object, String> {
    private final Class<?> supportedDomainObjectClass;

    protected IdMapper(Class<?> domainObjectClass) {
        this.supportedDomainObjectClass = domainObjectClass;
    }

    public static IdMapper getInstance(Class<?> domainObjectClass) {
        return new IdMapper(domainObjectClass);
    }

    public boolean canMapToData(Class<?> domainObjectClass) {
        if (domainObjectClass == null) {
            return true;
        }
        return supportedDomainObjectClass.isAssignableFrom(domainObjectClass);
    }

    public String getDBCollectionName() {
        throw new IllegalStateException("Not a DBCollection");
    }

    public String toData(Object from) {
        if (from == null) {
            return null;
        }
        Object id = IdReflectionUtil.internalGetId(from);
        if (id == null) {
            return null;
        } else {
            // TODO should it be mongoId
            return String.valueOf(id);
        }
    }

    public Object toDomain(String from) {
        throw new UnsupportedOperationException(getClass().getSimpleName()
                + " cannot map toDomain, it can only map toData");
    }

    public List<IndexSpecification> indexes() {
        return Collections.emptyList();
    }
}
