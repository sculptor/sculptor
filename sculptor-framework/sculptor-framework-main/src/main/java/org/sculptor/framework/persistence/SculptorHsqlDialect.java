package org.sculptor.framework.persistence;

import org.hibernate.dialect.HSQLDialect;
import org.hibernate.dialect.PostgreSQL10Dialect;
import org.hibernate.dialect.function.SQLFunctionTemplate;
import org.hibernate.dialect.function.StandardSQLFunction;
import org.hibernate.type.StandardBasicTypes;

import java.sql.Types;

/**
 * Created by tavoda on 22 Nov 2020
 */
public class SculptorHsqlDialect extends HSQLDialect {
	public SculptorHsqlDialect() {
		registerColumnType(Types.BOOLEAN, "boolean");
		registerHibernateType(Types.BOOLEAN, "boolean");

		registerFunction("week", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(week_of_year from ?1)"));
		registerFunction("quarter", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(quarter from ?1)"));
		registerFunction("dow", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(day_of_week from ?1)"));
		registerFunction("doy", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "extract(day_of_year from ?1)"));
		registerFunction("join", new StandardSQLFunction("concat_ws", StandardBasicTypes.STRING));
		registerFunction("right", new StandardSQLFunction("right", StandardBasicTypes.STRING));
		registerFunction("rpad", new StandardSQLFunction("rpad", StandardBasicTypes.STRING));
		registerFunction("lpad", new StandardSQLFunction("lpad", StandardBasicTypes.STRING));
		registerFunction("substr", new StandardSQLFunction("substr", StandardBasicTypes.STRING));
//		registerFunction("strpos", new StandardSQLFunction("instr", StandardBasicTypes.STRING));
//		registerFunction("starts_with", new StandardSQLFunction("starts_with", StandardBasicTypes.STRING));
//		registerFunction("starts_with", new SQLFunctionTemplate(StandardBasicTypes.BOOLEAN, "?1 LIKE ?2"));
//		registerFunction("add", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "?1 + ?2"));
//		registerFunction("substract", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "?1 - ?2"));
//		registerFunction("mul", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "?1 * ?2"));
//		registerFunction("div", new SQLFunctionTemplate(StandardBasicTypes.INTEGER, "?1 / ?2"));
//		registerFunction("countDistinct", new SQLFunctionTemplate(StandardBasicTypes.LONG, "count(distinct ?1)"));
//		registerFunction("sum", new StandardSQLFunction("sum", StandardBasicTypes.BIG_DECIMAL));
//		registerFunction("sumLong", new StandardSQLFunction("sum", StandardBasicTypes.LONG));
//		registerFunction("minStr", new StandardSQLFunction("min", StandardBasicTypes.STRING));
//		registerFunction("maxStr", new StandardSQLFunction("max", StandardBasicTypes.STRING));
	}
}
