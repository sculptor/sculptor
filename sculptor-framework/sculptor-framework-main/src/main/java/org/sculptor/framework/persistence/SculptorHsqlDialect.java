package org.sculptor.framework.persistence;

import org.hibernate.boot.model.FunctionContributions;
import org.hibernate.dialect.HSQLDialect;
import org.hibernate.dialect.function.StandardSQLFunction;
import org.hibernate.query.sqm.function.SqmFunctionRegistry;
import org.hibernate.type.BasicType;
import org.hibernate.type.BasicTypeRegistry;
import org.hibernate.type.StandardBasicTypes;

/**
 * Created by tavoda on 22 Nov 2020
 */
public class SculptorHsqlDialect extends HSQLDialect {
	public void initializeFunctionRegistry(FunctionContributions functionContributions) {
		super.initializeFunctionRegistry(functionContributions);
		SqmFunctionRegistry functionRegistry = functionContributions.getFunctionRegistry();
		BasicTypeRegistry basicTypeRegistry = functionContributions.getTypeConfiguration().getBasicTypeRegistry();
		BasicType<Integer> intType = basicTypeRegistry.resolve(StandardBasicTypes.INTEGER);

//		registerColumnType(Types.BOOLEAN, "boolean");
//		registerHibernateType(Types.BOOLEAN, "boolean");

		functionRegistry.registerPattern("week", "extract(week_of_year from ?1)", intType);
		functionRegistry.registerPattern("quarter", "extract(quarter from ?1)", intType);
		functionRegistry.registerPattern("dow", "extract(day_of_week from ?1)", intType);
		functionRegistry.registerPattern("doy", "extract(day_of_year from ?1)", intType);
		functionRegistry.register("join", new StandardSQLFunction("concat_ws", StandardBasicTypes.STRING));
		functionRegistry.register("right", new StandardSQLFunction("right", StandardBasicTypes.STRING));
		functionRegistry.register("rpad", new StandardSQLFunction("rpad", StandardBasicTypes.STRING));
		functionRegistry.register("lpad", new StandardSQLFunction("lpad", StandardBasicTypes.STRING));
		functionRegistry.register("substr", new StandardSQLFunction("substr", StandardBasicTypes.STRING));
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
