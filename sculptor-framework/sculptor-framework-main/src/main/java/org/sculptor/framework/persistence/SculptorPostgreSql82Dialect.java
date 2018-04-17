package org.sculptor.framework.persistence;

import org.hibernate.dialect.PostgreSQL82Dialect;
import org.hibernate.dialect.function.SQLFunctionTemplate;
import org.hibernate.type.StandardBasicTypes;

/**
 * Created by tavoda on 11/2/16.
 */
public class SculptorPostgreSql82Dialect extends PostgreSQL82Dialect {
	public SculptorPostgreSql82Dialect() {
		registerFunction("week", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(week from ?1)"));
		registerFunction("quarter", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(quarter from ?1)"));
		registerFunction("dow", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(isodow from ?1)"));
		registerFunction("doy", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(doy from ?1)"));
	}
}
