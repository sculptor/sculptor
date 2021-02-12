package org.sculptor.framework.persistence;

import org.hibernate.dialect.PostgreSQL10Dialect;
import org.hibernate.dialect.function.SQLFunctionTemplate;
import org.hibernate.dialect.function.StandardSQLFunction;
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
		registerFunction("join", new StandardSQLFunction("concat_ws", StandardBasicTypes.STRING));
		registerFunction("right", new StandardSQLFunction("right", StandardBasicTypes.STRING));
		registerFunction("lpad", new StandardSQLFunction("lpad", StandardBasicTypes.STRING));
		registerFunction("rpad", new StandardSQLFunction("rpad", StandardBasicTypes.STRING));

		registerFunction("ftsEquals", new SQLFunctionTemplate(StandardBasicTypes.BOOLEAN, "(?1 @@ ?2)"));
		registerFunction("toFtsVector", new SQLFunctionTemplate(StandardBasicTypes.STRING, "to_tsvector(?1::regconfig, ?2)"));
		registerFunction("ftsLength", new StandardSQLFunction("length", StandardBasicTypes.INTEGER));
		registerFunction("ftsNumNode", new StandardSQLFunction("numnode", StandardBasicTypes.INTEGER));
		registerFunction("ftsSetWeight", new StandardSQLFunction("setweight", StandardBasicTypes.STRING));
		registerFunction("ftsConcat", new SQLFunctionTemplate(StandardBasicTypes.STRING, "(?1 || ?2)"));
		registerFunction("ftsAnd", new SQLFunctionTemplate(StandardBasicTypes.STRING, "(?1 && ?2)"));
		registerFunction("ftsOr", new SQLFunctionTemplate(StandardBasicTypes.STRING, "(?1 || ?2)"));
		registerFunction("ftsNot", new SQLFunctionTemplate(StandardBasicTypes.STRING, "!! ?1"));
		registerFunction("ftsStrip", new StandardSQLFunction("strip", StandardBasicTypes.STRING));

		registerFunction("ftsRank", new StandardSQLFunction("ts_rank", StandardBasicTypes.FLOAT));
		registerFunction("ftsRankCd", new StandardSQLFunction("ts_rank_cd", StandardBasicTypes.FLOAT));
		registerFunction("ftsHighlight", new SQLFunctionTemplate(StandardBasicTypes.STRING, "ts_headline(?1::regconfig, ?2, ?3, ?4)"));

		registerFunction("ftsQuery", new SQLFunctionTemplate(StandardBasicTypes.STRING, "to_tsquery(?1::regconfig, ?2)"));
		registerFunction("ftsPlainQuery", new SQLFunctionTemplate(StandardBasicTypes.STRING, "plainto_tsquery(?1::regconfig, ?2)"));
		registerFunction("ftsPhraseQuery", new SQLFunctionTemplate(StandardBasicTypes.STRING, "phraseto_tsquery(?1::regconfig, ?2)"));
		registerFunction("ftsWebQuery", new SQLFunctionTemplate(StandardBasicTypes.STRING, "websearch_to_tsquery(?1::regconfig, ?2)"));
	}
}
