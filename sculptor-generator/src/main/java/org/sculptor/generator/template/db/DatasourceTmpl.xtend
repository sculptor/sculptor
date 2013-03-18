package org.sculptor.generator.template.db

import org.sculptor.generator.ext.GeneratorFactory
import org.sculptor.generator.ext.GeneratorFactoryImpl
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.Application

class DatasourceTmpl {
	private static val GeneratorFactory GEN_FACTORY = GeneratorFactoryImpl::getInstance()


	extension HelperBase helperBase = GEN_FACTORY.helperBase
	extension Helper helper = GEN_FACTORY.helper
	extension PropertiesBase propertiesBase = GEN_FACTORY.propertiesBase
	extension Properties properties = GEN_FACTORY.properties


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
		<datasources> 
		    <local-tx-datasource> 
		        <jndi-name>jdbc/«name»DS</jndi-name> 
		        <connection-url>«getProperty("db.connectionUrl", "jdbc:mysql://localhost/" + name.toLowerCase() + "?autoReconnect=true")»</connection-url> 
		        <driver-class>com.mysql.jdbc.Driver</driver-class> 
		        <user-name>«getProperty("db.username", "root")»</user-name> 
		        <password>«getProperty("db.password", "")»</password> 
		    </local-tx-datasource> 
		</datasources> 
	'''
	)
}

def String oracleDS(Application it) {
	fileOutput("dbschema/" + name + "-ds.xml", OutputSlot::TO_GEN_RESOURCES, '''
		<?xml version="1.0" encoding="UTF-8"?>
		<!-- See: http://www.jboss.org/community/wiki/ConfigDataSources -->
		<datasources>
			<local-tx-datasource>
				<jndi-name>jdbc/«name»DS</jndi-name>
				<connection-url>«getProperty("db.connectionUrl", "jdbc:oracle:thin:@localhost:1521:" + name.toLowerCase())»</connection-url>
				<driver-class>oracle.jdbc.driver.OracleDriver</driver-class>
				<user-name>«getProperty("db.username", "root")»</user-name> 
		        <password>«getProperty("db.password", "root")»</password>
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
			</local-tx-datasource>
		</datasources>
	'''
	)
	'''
	'''
}

def String postgresqlDS(Application it) {
	fileOutput("dbschema/" + name + "-ds.xml", OutputSlot::TO_GEN_RESOURCES, '''
		<datasources> 
		    <local-tx-datasource> 
		        <jndi-name>jdbc/«name»DS</jndi-name> 
		        <connection-url>«getProperty("db.connectionUrl", "jdbc:postgresql://localhost/" + name.toLowerCase())»</connection-url> 
		        <driver-class>org.postgresql.Driver</driver-class> 
		        <user-name>«getProperty("db.username", "root")»</user-name> 
		        <password>«getProperty("db.password", "root")»</password> 
		    </local-tx-datasource> 
		</datasources> 
	'''
	)
}

def String hsqldbInmemoryDS(Application it) {
	fileOutput("dbschema/" + name + "-ds.xml", OutputSlot::TO_GEN_RESOURCES, '''
		<datasources> 
		    <local-tx-datasource> 
		        <jndi-name>jdbc/«name»DS</jndi-name> 
		        <connection-url>«getProperty("db.connectionUrl", "jdbc.url=jdbc:hsqldb:mem:" + name.toFirstLower())»</connection-url> 
		        <driver-class>org.hsqldb.jdbcDriver</driver-class> 
		        <user-name>«getProperty("db.username", "sa")»</user-name> 
		        <password>«getProperty("db.password", "")»</password> 
		    </local-tx-datasource> 
		</datasources> 
	'''
	)
}
}
