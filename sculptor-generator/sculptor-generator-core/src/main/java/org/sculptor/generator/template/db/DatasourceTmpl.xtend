/*
 * Copyright 2013 The Sculptor Project Team, including the original 
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

package org.sculptor.generator.template.db

import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application

class DatasourceTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	@Inject extension Properties properties

def String datasource(Application it) {
	'''
	«IF dbProduct == "mysql"»
		«mysqlDS(it) »
	«ELSEIF dbProduct == "oracle"»
		«oracleDS(it) »
	«ELSEIF dbProduct == "postgresql"»
		«postgresqlDS(it) »
	«ELSEIF dbProduct == "hsqldb-inmemory"»
		«hsqldbInmemoryDS(it) »
	«ENDIF»
	'''
}

def String mysqlDS(Application it) {
	fileOutput("dbschema/" + name + "-ds.xml", OutputSlot::TO_GEN_RESOURCES, '''
		«dataSourceHeader(it)»
		        <connection-url>«getProperty("db.connectionUrl", "jdbc:mysql://localhost/" + name.toLowerCase() + "?autoReconnect=true")»</connection-url> 
		        <!-- Add valid reference to an already deployed / defined MySQL driver --> 
		        <driver>mysql.jar</driver> 
				<security>
			        <user-name>«getProperty("db.username", "root")»</user-name> 
			        <password>«getProperty("db.password", "root")»</password> 
				</security>
		    </datasource> 
		</datasources> 
	'''
	)
}

def String oracleDS(Application it) {
	fileOutput("dbschema/" + name + "-ds.xml", OutputSlot::TO_GEN_RESOURCES, '''
		«dataSourceHeader(it)»
				<connection-url>«getProperty("db.connectionUrl", "jdbc:oracle:thin:@localhost:1521:" + name.toLowerCase())»</connection-url>
		        <!-- Add valid reference to an already deployed / defined Oracle driver --> 
				<driver>ojdbc.jar</driver>
				<min-pool-size>5</min-pool-size>
				<max-pool-size>50</max-pool-size>
				<idle-timeout-minutes>15</idle-timeout-minutes>
				<prepared-statement-cache-size>100</prepared-statement-cache-size>
				<query-timeout>300</query-timeout>
				<!-- Checks the Oracle error codes and messages for fatal errors -->
				<exception-sorter-class-name>org.jboss.resource.adapter.jdbc.vendor.OracleExceptionSorter</exception-sorter-class-name>
				<check-valid-connection-sql>select DUMMY from dual</check-valid-connection-sql>
				<metadata>
					<type-mapping>Oracle9i</type-mapping>
				</metadata>
				<security>
					<user-name>«getProperty("db.username", "root")»</user-name> 
			        <password>«getProperty("db.password", "root")»</password>
				</security>
			</datasource>
		</datasources>
	'''
	)
}

def String postgresqlDS(Application it) {
	fileOutput("dbschema/" + name + "-ds.xml", OutputSlot::TO_GEN_RESOURCES, '''
		«dataSourceHeader(it)»
		        <connection-url>«getProperty("db.connectionUrl", "jdbc:postgresql://localhost/" + name.toLowerCase())»</connection-url> 
		        <!-- Add valid reference to an already deployed / defined PostgresSQL driver --> 
		        <driver>postgresql.jar</driver> 
				<security>
			        <user-name>«getProperty("db.username", "root")»</user-name> 
			        <password>«getProperty("db.password", "root")»</password> 
				</security>
		    </datasource> 
		</datasources> 
	'''
	)
}

def String hsqldbInmemoryDS(Application it) {
	fileOutput("dbschema/" + name + "-ds.xml", OutputSlot::TO_GEN_RESOURCES, '''
		«dataSourceHeader(it)»
		        <connection-url>«getProperty("db.connectionUrl", "jdbc.url=jdbc:hsqldb:mem:" + name.toFirstLower())»</connection-url>
		        <!-- Add valid reference to an already deployed / defined HSQLDB driver --> 
		        <driver>hsqldb.jar</driver> 
				<security>
			        <user-name>«getProperty("db.username", "sa")»</user-name> 
		    	    <password>«getProperty("db.password", "sa")»</password> 
				</security>
		    </datasource> 
		</datasources> 
	'''
	)
}

def String dataSourceHeader(Application it) {
	'''
		<?xml version="1.0" encoding="UTF-8"?>
		<!-- See: https://docs.jboss.org/author/display/AS72/DataSource+configuration -->
		<datasources xmlns="http://www.jboss.org/ironjacamar/schema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
				xsi:schemaLocation="http://www.jboss.org/ironjacamar/schema http://docs.jboss.org/ironjacamar/schema/datasources_1_0.xsd">
		    <datasource jndi-name="java:/jdbc/«name»DS" pool-name="«name»DS" enabled="true" use-java-context="true">
	'''
}

}
