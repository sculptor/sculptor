/*
 * Copyright 2007 The Fornax Project Team, including the original
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

package org.sculptor.framework.util.db;

import java.io.BufferedOutputStream;
import java.io.FileOutputStream;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.sql.DataSource;

import org.dbunit.database.DatabaseConfig;
import org.dbunit.database.DatabaseConnection;
import org.dbunit.database.IDatabaseConnection;
import org.dbunit.database.QueryDataSet;
import org.dbunit.dataset.datatype.IDataTypeFactory;
import org.dbunit.dataset.xml.FlatXmlDataSet;
import org.sculptor.framework.util.ApplicationContextSingleton;
import org.sculptor.framework.util.FactoryHelper;
import org.springframework.context.ApplicationContext;

/**
 * A development environment utility to export data from a
 * database to DBUnit XML file. Not intended to be used in
 * production.
 *
 */
public class DatabaseExport {

    private final ApplicationContext context = ApplicationContextSingleton.getApplicationContext();

    private final DatabaseEnvironmentStrategy environmentStrategy;

    public DatabaseExport() {
        this(new HsqldbStrategy());
    }

    public DatabaseExport(DatabaseEnvironmentStrategy strategy) {
        this.environmentStrategy = strategy;
    }

    public static void main(String[] args) {
        System.out.println("Starting export from Database");
        DatabaseExport dbe;
        if (args.length == 1) {
            DatabaseEnvironmentStrategy strategy = (DatabaseEnvironmentStrategy) FactoryHelper
                    .newInstanceFromName(args[0]);
            dbe = new DatabaseExport(strategy);
        } else {
            // HSQLDB
            dbe = new DatabaseExport();
        }
        dbe.export();
        System.out.println("Ending export from Database. File full.xml is present in current directory.");

    }

    public Connection getConnection() throws SQLException {
        DataSource ds = (DataSource) context.getBean(environmentStrategy.getDatasourceName());

        return ds.getConnection();
    }

    public void export() {

        try {
            Connection dbCon = getConnection();
            IDatabaseConnection connection = new DatabaseConnection(dbCon);
            List<String> tables = getTables(dbCon);
            // partial database export
            QueryDataSet partialDataSet = new QueryDataSet(connection);

            for (String table : tables) {
                partialDataSet.addTable(table);
            }

            FlatXmlDataSet.write(partialDataSet, new BufferedOutputStream(new FileOutputStream("full.xml")));

        } catch (Exception e) {

            e.printStackTrace();
        }
    }

    public List<String> getTables(Connection connection) {
        List<String> tables = new ArrayList<String>();
        PreparedStatement pstmt = null;
        try {
            pstmt = connection.prepareStatement(environmentStrategy.getSqlAllTables());

            ResultSet rset = pstmt.executeQuery();
            while (rset.next()) {
                tables.add(rset.getString("table_name"));
            }
        } catch (SQLException e) {
            System.out.println("SQLException: " + e.getMessage());
            e.printStackTrace();
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException ignore) {
                }
            }
        }

        return tables;

    }

    public static String printDBUnitTables() {
        return printDBUnitTables(new HsqldbStrategy());
    }

    public static String printDBUnitTables(DatabaseEnvironmentStrategy strategy) {
        System.out.println("Starting export from database");
        DatabaseExport dbe = new DatabaseExport(strategy);
        String s = dbe.printTables();
        System.out.println(s);
        System.out.println("Ending export from database. ");
        return s;
    }

    public static void executeSQL(String sql) {
        executeSQL(new HsqldbStrategy(), sql);
    }

    public static void executeSQL(DatabaseEnvironmentStrategy strategy, String sql) {
        DatabaseExport dbe = new DatabaseExport(strategy);
        dbe.executeSQLImpl(sql);
    }

    private void executeSQLImpl(String sql) {
        PreparedStatement pstmt = null;
        try {
            Connection connection = getConnection();

            pstmt = connection.prepareStatement(sql);

            ResultSet rset = pstmt.executeQuery();
            while (rset.next()) {
                System.out.println(rset.getString(0));
            }

        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (pstmt != null) {
                try {
                    pstmt.close();
                } catch (SQLException ignore) {
                }
            }
        }

    }

    private String printTables() {

        try {
            StringWriter stringWriter = new StringWriter();
            PrintWriter out = new PrintWriter(stringWriter);
            Connection dbCon = getConnection();
            IDatabaseConnection connection = new DatabaseConnection(dbCon);

            IDataTypeFactory dataTypeFactory = environmentStrategy.getDataTypeFactory();
            if (dataTypeFactory != null) {
                DatabaseConfig config = connection.getConfig();
                config.setProperty(DatabaseConfig.PROPERTY_DATATYPE_FACTORY, new HsqlDataTypeFactory());
            }

            List<String> tables = getTables(dbCon);

            for (String table : tables) {
                out.println("------------ " + table + "------------ ");
                QueryDataSet partialDataSet = new QueryDataSet(connection);
                partialDataSet.addTable(table);
                FlatXmlDataSet.write(partialDataSet, out);
            }
            return stringWriter.toString();
        } catch (Exception e) {
            e.printStackTrace();
            return "";
        }
    }

    public static abstract class DatabaseEnvironmentStrategy {
        protected abstract String getSqlAllTables();

        protected abstract String getDatasourceName();

        protected IDataTypeFactory getDataTypeFactory() {
            return null;
        }
    }

    public static class HsqldbStrategy extends DatabaseEnvironmentStrategy {

        private final static String sqlAllTables_HSQLDB = "" + "select * from INFORMATION_SCHEMA.SYSTEM_tables "
                + "where table_name not like 'SYSTEM%' ";

        @Override
        protected String getDatasourceName() {
            return "hsqldbDataSource";
        }

        @Override
        protected String getSqlAllTables() {
            return sqlAllTables_HSQLDB;
        }

        @Override
        protected IDataTypeFactory getDataTypeFactory() {
            return new HsqlDataTypeFactory();
        }

    }

    public static class OracleStrategy extends DatabaseEnvironmentStrategy {
        private final String sqlAllTables_ORACLE;

        public OracleStrategy(String user) {
            sqlAllTables_ORACLE = "" + "select * from all_tables " + "where owner = '" + user + "' "
                    + "and table_name not in " + "('TOAD_PLAN_SQL','TOAD_PLAN_TABLE',"
                    + "'PLSQL_PROFILER_UNITS','PLSQL_PROFILER_RUNS','PLSQL_PROFILER_DATA')";
        }

        @Override
        protected String getDatasourceName() {
            return "oracleDataSource";
        }

        @Override
        protected String getSqlAllTables() {
            return sqlAllTables_ORACLE;
        }

    }

}
