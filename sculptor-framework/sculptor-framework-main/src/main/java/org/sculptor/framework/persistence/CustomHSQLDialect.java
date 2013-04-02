package org.sculptor.framework.persistence;

import java.sql.Types;

import org.hibernate.dialect.HSQLDialect;

/**
 * Workaround for problem with native queries and boolean fields. See:
 * http://www
 * .codesmell.org/blog/2008/12/hibernate-hsql-native-queries-and-booleans/
 *
 */
public class CustomHSQLDialect extends HSQLDialect {
    public CustomHSQLDialect() {
        registerColumnType(Types.BOOLEAN, "boolean");
        registerHibernateType(Types.BOOLEAN, "boolean");
    }
}
