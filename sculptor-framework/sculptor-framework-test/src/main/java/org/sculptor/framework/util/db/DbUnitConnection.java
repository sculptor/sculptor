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

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

import javax.sql.DataSource;

import org.dbunit.DatabaseUnitException;
import org.dbunit.database.DatabaseConfig;
import org.dbunit.database.DatabaseConnection;
import org.dbunit.database.IDatabaseConnection;
import org.sculptor.framework.util.ApplicationContextSingleton;
import org.springframework.context.ApplicationContext;


public class DbUnitConnection {

    private final String dataSourceSpringBeanName;

    public DbUnitConnection(String dataSourceSpringBeanName) {
        this.dataSourceSpringBeanName = dataSourceSpringBeanName;
    }

    public IDatabaseConnection getConnection() throws SQLException, DatabaseUnitException {

        ApplicationContext context = ApplicationContextSingleton.getApplicationContext();

        DataSource ds = (DataSource) context.getBean(dataSourceSpringBeanName);

        IDatabaseConnection connection = new DatabaseConnection(ds.getConnection());
        DatabaseConfig config = connection.getConfig();
        config.setProperty(DatabaseConfig.PROPERTY_DATATYPE_FACTORY, new HsqlDataTypeFactory());

        return connection;
    }

    public int countRows(String table) throws Exception {
        Connection con = null;
        Statement stmt = null;
        ResultSet rs = null;
        try {
            con = getConnection().getConnection();
            stmt = con.createStatement();
            rs = stmt.executeQuery("select count(*) as rowcount from " + table);
            rs.next();
            int count = rs.getInt("rowcount");
            return count;
        } catch (SQLException e) {
            e.printStackTrace();
            throw e;
        } finally {
            close(con, stmt, rs);
        }
    }

    private static void close(Connection con, Statement stmt, ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException ignore) {
            }
        }
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException ignore) {
            }
        }
        if (con != null) {
            try {
                con.close();
            } catch (SQLException ignore) {
            }
        }
    }
}
