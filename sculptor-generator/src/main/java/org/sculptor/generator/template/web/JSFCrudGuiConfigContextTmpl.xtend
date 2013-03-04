/*
 * Copyright 2008 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.web

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class JSFCrudGuiConfigContextTmpl {

def static String contextXml(Application it) {
	'''
	«IF applicationServer() == "tomcat"»
	    «tomcatContextXml(it) »
	«ENDIF»
	«IF applicationServer() == "jetty"»
	    «jettyContextXml(it) »
	«ENDIF»
	'''
}

def static String tomcatContextXml(Application it) {
	'''
	'''
	fileOutput("META-INF/context.xml", 'TO_WEBROOT', '''
	<?xml version="1.0" encoding="UTF-8"?>
	<Context path="/«dataSourceName(this)»" docBase="«dataSourceName(this)»"
			debug="5" reloadable="true" crossContext="true">
		<Resource name="jdbc/«dataSourceName(this)»" auth="Container" type="javax.sql.DataSource"
				  maxActive="100" maxIdle="30" maxWait="10000"
		«IF dbProduct() == "hsqldb-inmemory" »
				  username="sa" password="" 
				  driverClassName="org.hsqldb.jdbcDriver"
				  url="jdbc:hsqldb:mem:applicationDB"
		«ELSEIF dbProduct() == "mysql" »
				  username="root" password="" 
				  driverClassName="com.mysql.jdbc.Driver"
				  url="jdbc:mysql://localhost/«name.toLowerCase()»?autoReconnect=true"
		«ELSEIF dbProduct() == "oracle" »
				  username="root" password="root" 
				  driverClassName="oracle.jdbc.driver.OracleDriver"
				  url="jdbc:oracle:thin:@localhost:1521:«name.toLowerCase()»"
		«ELSEIF dbProduct() == "postgresql" »
				  username="root" password="root" 
				  driverClassName="org.postgresql.Driver"
				  url="jdbc:postgresql://localhost/«name.toLowerCase()»"
		«ELSE »
				  username="root" password="root" 
				  driverClassName="other.jdbc.driver.OtherDriver"
				  url="jdbc:other:«name.toLowerCase()»"
		«ENDIF »
		/>
	</Context>
	'''
	)
	'''
	'''
}
def static String jettyContextXml(Application it) {
	'''
	'''
	fileOutput("WEB-INF/jetty-env.xml", 'TO_WEBROOT', '''
	<?xml version="1.0"?>
	<!DOCTYPE Configure PUBLIC "-//Mort Bay Consulting//DTD Configure//EN" "http://jetty.mortbay.org/configure.dtd">
	<Configure class="org.mortbay.jetty.webapp.WebAppContext">
	«IF !nosql()»
	<New id="«dataSourceName(this)»" class="org.mortbay.jetty.plus.naming.Resource">
		<Arg>jdbc/«dataSourceName(this)»</Arg>
		<Arg>
			<New class="org.springframework.jdbc.datasource.DriverManagerDataSource">
			«IF dbProduct() == "hsqldb-inmemory" »
				<Set name="DriverClassName">org.hsqldb.jdbcDriver</Set>
				<Set name="Url">jdbc:hsqldb:mem:applicationDB</Set>
				<Set name="Username">sa</Set>
				<Set name="Password"></Set>
			«ELSEIF dbProduct() == "mysql" »
				<Set name="DriverClassName">com.mysql.jdbc.Driver</Set>
				<Set name="Url">jdbc:mysql://localhost/«name.toLowerCase()»?autoReconnect=true</Set>
				<Set name="Username">root</Set>
				<Set name="Password"></Set>
			«ELSEIF dbProduct() == "oracle" »
				<Set name="DriverClassName">oracle.jdbc.driver.OracleDriver</Set>
				<Set name="Url">jdbc:oracle:thin:@localhost:1521:«name.toLowerCase()»</Set>
				<Set name="Username">root</Set>
				<Set name="Password">root</Set>
			«ELSEIF dbProduct() == "postgresql" »
				<Set name="DriverClassName">org.postgresql.Driver</Set>
				<Set name="Url">jdbc:postgresql://localhost/«name.toLowerCase()»</Set>
				<Set name="Username">root</Set>
				<Set name="Password">root</Set>
			«ELSE »
				<Set name="DriverClassName">other.jdbc.driver.OtherDriver</Set>
				<Set name="Url">jdbc:other:«name.toLowerCase()»</Set>
				<Set name="Username">root</Set>
				<Set name="Password">root</Set>
			«ENDIF»
			</New>
		</Arg>
	</New>
	«ENDIF»
	</Configure>
	'''
	)
	'''
	'''
}
}
