package org.sculptor.framework.persistence;

import org.hibernate.dialect.PostgreSQL10Dialect;
import org.hibernate.dialect.function.SQLFunctionTemplate;
import org.hibernate.type.StandardBasicTypes;

/**
 * Created by tavoda on 18 Dec 2019
 */
public class SculptorPostgreSql10Dialect extends PostgreSQL10Dialect {
	public SculptorPostgreSql10Dialect() {
		registerFunction("week", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(week from ?1)"));
		registerFunction("quarter", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(quarter from ?1)"));
		registerFunction("dow", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(isodow from ?1)"));
		registerFunction("doy", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(doy from ?1)"));
	}
}
