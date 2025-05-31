package org.sculptor.framework.persistence;

import org.hibernate.boot.model.FunctionContributions;
import org.hibernate.dialect.PostgreSQLDialect;
import org.hibernate.query.sqm.function.SqmFunctionRegistry;
import org.hibernate.type.BasicType;
import org.hibernate.type.BasicTypeRegistry;
import org.hibernate.type.StandardBasicTypes;

/**
 * Created by tavoda on 11/2/16.
 */
public class SculptorPostgreSQLDialect extends PostgreSQLDialect {
	public void initializeFunctionRegistry(FunctionContributions functionContributions) {
		super.initializeFunctionRegistry(functionContributions);
		SqmFunctionRegistry functionRegistry = functionContributions.getFunctionRegistry();
		BasicTypeRegistry basicTypeRegistry = functionContributions.getTypeConfiguration().getBasicTypeRegistry();
		BasicType<Integer> intType = basicTypeRegistry.resolve(StandardBasicTypes.INTEGER);

		functionRegistry.registerPattern("week", "extract(week from ?1)", intType);
		functionRegistry.registerPattern("quarter", "extract(quarter from ?1)", intType);
		functionRegistry.registerPattern("dow", "extract(isodow from ?1)", intType);
		functionRegistry.registerPattern("doy", "extract(doy from ?1)", intType);
	}
}
