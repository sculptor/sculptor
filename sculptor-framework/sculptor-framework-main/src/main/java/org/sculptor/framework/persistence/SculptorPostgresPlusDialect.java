package org.sculptor.framework.persistence;

import org.hibernate.boot.model.FunctionContributions;
import org.hibernate.dialect.PostgresPlusDialect;
import org.hibernate.dialect.function.StandardSQLFunction;
import org.hibernate.query.sqm.function.SqmFunctionRegistry;
import org.hibernate.type.BasicType;
import org.hibernate.type.BasicTypeRegistry;
import org.hibernate.type.StandardBasicTypes;

/**
 * Created by tavoda on 18 Dec 2019
 */
public class SculptorPostgresPlusDialect extends PostgresPlusDialect {
	public void initializeFunctionRegistry(FunctionContributions functionContributions) {
		super.initializeFunctionRegistry(functionContributions);
		SqmFunctionRegistry functionRegistry = functionContributions.getFunctionRegistry();
		BasicTypeRegistry basicTypeRegistry = functionContributions.getTypeConfiguration().getBasicTypeRegistry();
		BasicType<Integer> intType = basicTypeRegistry.resolve(StandardBasicTypes.INTEGER);
		BasicType<String> stringType = basicTypeRegistry.resolve(StandardBasicTypes.STRING);
		BasicType<Boolean> booleanType = basicTypeRegistry.resolve(StandardBasicTypes.BOOLEAN);

		functionRegistry.registerPattern("week", "extract(week from ?1)", intType);
		functionRegistry.registerPattern("quarter", "extract(quarter from ?1)", intType);
		functionRegistry.registerPattern("dow", "extract(isodow from ?1)", intType);
		functionRegistry.registerPattern("doy", "extract(doy from ?1)", intType);

		functionRegistry.register("join", new StandardSQLFunction("concat_ws", StandardBasicTypes.STRING));
		functionRegistry.register("right", new StandardSQLFunction("right", StandardBasicTypes.STRING));
		functionRegistry.register("lpad", new StandardSQLFunction("lpad", StandardBasicTypes.STRING));
		functionRegistry.register("rpad", new StandardSQLFunction("rpad", StandardBasicTypes.STRING));
		functionRegistry.registerPattern("ftsEquals", "(?1 @@ ?2)", booleanType);
		functionRegistry.registerPattern("toFtsVector", "to_tsvector(?1::regconfig, ?2)", stringType);
		functionRegistry.register("ftsLength", new StandardSQLFunction("length", StandardBasicTypes.INTEGER));
		functionRegistry.register("ftsNumNode", new StandardSQLFunction("numnode", StandardBasicTypes.INTEGER));
		functionRegistry.register("ftsSetWeight", new StandardSQLFunction("setweight", StandardBasicTypes.STRING));
		functionRegistry.registerPattern("ftsConcat", "(?1 || ?2)", stringType);
		functionRegistry.registerPattern("ftsAnd", "(?1 && ?2)", stringType);
		functionRegistry.registerPattern("ftsOr", "(?1 || ?2)", stringType);
		functionRegistry.registerPattern("ftsNot", "!! ?1", stringType);
		functionRegistry.register("ftsStrip", new StandardSQLFunction("strip", StandardBasicTypes.STRING));
		functionRegistry.register("ftsRank", new StandardSQLFunction("ts_rank", StandardBasicTypes.FLOAT));
		functionRegistry.register("ftsRankCd", new StandardSQLFunction("ts_rank_cd", StandardBasicTypes.FLOAT));
		functionRegistry.registerPattern("ftsHighlight", "ts_headline(?1::regconfig, ?2, ?3, ?4)", stringType);
		functionRegistry.registerPattern("ftsQuery", "to_tsquery(?1::regconfig, ?2)", stringType);
		functionRegistry.registerPattern("ftsPlainQuery", "plainto_tsquery(?1::regconfig, ?2)", stringType);
		functionRegistry.registerPattern("ftsPhraseQuery", "phraseto_tsquery(?1::regconfig, ?2)", stringType);
		functionRegistry.registerPattern("ftsWebQuery", "websearch_to_tsquery(?1::regconfig, ?2)", stringType);
	}
}
