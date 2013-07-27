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

import java.sql.Types;

import org.hibernate.dialect.HSQLDialect;

/**
 * Workaround for problem with native queries and boolean fields.
 * <p>
 * See blog post<a href=
 * "http://www.codesmell.org/blog/2008/12/hibernate-hsql-native-queries-and-booleans/"
 * >Hibernate, HSQL, Native Queries and Booleans</a>.
 */
public class CustomHSQLDialect extends HSQLDialect {
    public CustomHSQLDialect() {
        registerColumnType(Types.BOOLEAN, "boolean");
        registerHibernateType(Types.BOOLEAN, "boolean");
    }
}
