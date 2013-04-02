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
import java.util.Date;
import java.util.List;

import org.joda.time.DateTime;

public class JodaDateTimeMapper implements DataMapper<DateTime, Date> {
    private static JodaDateTimeMapper instance = new JodaDateTimeMapper();

    protected JodaDateTimeMapper() {
    }

    public static JodaDateTimeMapper getInstance() {
        return instance;
    }

    public boolean canMapToData(Class<?> domainObjectClass) {
        if (domainObjectClass == null) {
            return true;
        }
        return DateTime.class.isAssignableFrom(domainObjectClass);
    }

    public String getDBCollectionName() {
        throw new IllegalStateException("Not a DBCollection");
    }

    public Date toData(DateTime from) {
        if (from == null) {
            return null;
        }
        return from.toDate();
    }

    public DateTime toDomain(Object from) {
        return toDomain((Date) from);
    }

    public DateTime toDomain(Date from) {
        if (from == null) {
            return null;
        }
        return new DateTime(from.getTime());
    }

    public List<IndexSpecification> indexes() {
        return Collections.emptyList();
    }
}
