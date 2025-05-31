package org.sculptor.framework.persistence;

import org.hibernate.boot.model.FunctionContributions;
import org.hibernate.dialect.OracleDialect;
import org.hibernate.dialect.function.StandardSQLFunction;
import org.hibernate.query.sqm.function.SqmFunctionRegistry;
import org.hibernate.type.BasicType;
import org.hibernate.type.BasicTypeRegistry;
import org.hibernate.type.StandardBasicTypes;

/**
 * Created by tavoda on 11/2/16.
 */
public class SculptorOracleDialect extends OracleDialect {
	public void initializeFunctionRegistry(FunctionContributions functionContributions) {
		super.initializeFunctionRegistry(functionContributions);
		SqmFunctionRegistry functionRegistry = functionContributions.getFunctionRegistry();
		BasicTypeRegistry basicTypeRegistry = functionContributions.getTypeConfiguration().getBasicTypeRegistry();
		BasicType<Integer> intType = basicTypeRegistry.resolve(StandardBasicTypes.INTEGER);
		BasicType<String> stringType = basicTypeRegistry.resolve(StandardBasicTypes.STRING);
		BasicType<Boolean> booleanType = basicTypeRegistry.resolve(StandardBasicTypes.BOOLEAN);

		functionRegistry.registerPattern("week", "extract(week from ?1)", intType);
		functionRegistry.registerPattern("quarter", "extract(quarter from ?1)", intType);
		functionRegistry.registerPattern("dow", "extract(day_of_week from ?1)", intType);
		functionRegistry.registerPattern("doy", "extract(day_of_year from ?1)", intType);
		functionRegistry.register("join", new StandardSQLFunction("concat_ws", StandardBasicTypes.STRING));
		functionRegistry.register("right", new StandardSQLFunction("right", StandardBasicTypes.STRING));
		functionRegistry.register("lpad", new StandardSQLFunction("lpad", StandardBasicTypes.STRING));
		functionRegistry.register("rpad", new StandardSQLFunction("rpad", StandardBasicTypes.STRING));
	}
}
