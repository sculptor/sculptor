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
package org.sculptor.generator.template.common

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

@ChainOverridable
class LogConfigTmpl {

	@Inject extension Helper helper
	@Inject extension Properties properties

	def String logbackConfig(Application it) {
		logbackXml(it)
		if (isTestToBeGenerated()) {
			logbackTestXml(it)
		}
	}

	def String logbackXml(Application it) {
		fileOutput("logback.xml", OutputSlot.TO_RESOURCES, '''
		<?xml version="1.0" encoding="UTF-8"?>
		<configuration>
			<!--
			You can use following MDC expressions when org.sculptor.framework.util.MdcFilter is in web.xml, user is extracted from SpringSecurityContext
				%mdc{user}
				%mdc{remoteAddress}
				%mdc{sessionId}
				%mdc{requestId} - internal unique request identifier (nanoTime)
				%mdc{serverName}
				%mdc{url}
			You can specify different logback configuration on Java command line like:
				-Dlogback.configurationFile=logback-color-info.xml
			-->
			<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
				<encoder>
					<pattern>%d{yy-MM-dd HH:mm:ss.SSS} %highlight(%-5level) - [%-15.15thread] %cyan(%-40.40logger{39}) : %msg%n</pattern>
				</encoder>
				<withJansi>true</withJansi>
			</appender>

			<root level="INFO">
				<appender-ref ref="STDOUT" />
			</root>

			<logger name="«basePackage»" level="DEBUG" />

			<!-- Spring security framework -->
			<!--
			<logger name="org.springframework.security" level="DEBUG" />
			-->

			<!-- Spring framework -->
			<!--
			<logger name="org.springframework" level="DEBUG" />
			-->

			<!-- Hibernate SQL statements -->
			<logger name="org.hibernate.SQL" level="DEBUG" />

			<!-- Hibernate binding SQL parameters -->
			<!--
			<logger name="org.hibernate.type.descriptor.sql.BasicBinder" level="ALL" />
			<logger name="org.hibernate.type.EnumType" level="ALL" />
			-->

			<!-- Hibernate binding and extracting SQL parameters -->
			<!--
			<logger name="org.hibernate.type" level="ALL" />
			-->

			<!-- Hibernate 2nd level caching and caching generally -->
			<!--
			<logger name="org.ehcache" level="DEBUG" />
			<logger name="org.hibernate.cache" level="DEBUG" />
			-->

		</configuration>
		'''
		)
	}

	def String logbackTestXml(Application it) {
		fileOutput("logback-test.xml", OutputSlot.TO_RESOURCES_TEST, '''
		<?xml version="1.0" encoding="UTF-8" ?>
		<configuration>
			<!--
			You can use following MDC expressions when org.sculptor.framework.util.MdcFilter is in web.xml, user is extracted from SpringSecurityContext
				%mdc{user}
				%mdc{remoteAddress}
				%mdc{sessionId}
				%mdc{requestId} - internal unique request identifier (nanoTime)
				%mdc{serverName}
				%mdc{url}
			-->
			<appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
				<encoder>
					<pattern>%d{yy-MM-dd HH:mm:ss.SSS} %highlight(%-5level) - [%-15.15thread] %cyan(%-40.40logger{39}) : %msg%n</pattern>
				</encoder>
				<withJansi>true</withJansi>
			</appender>

			<root level="INFO">
				<appender-ref ref="STDOUT" />
			</root>

			<logger name="«basePackage»" level="DEBUG" />

			<!-- Spring security framework -->
			<!--
			<logger name="org.springframework.security" level="DEBUG" />
			-->

			<!-- Spring framework -->
			<!--
			<logger name="org.springframework" level="DEBUG" />
			 -->

			<!-- Hibernate SQL statements -->
			<logger name="org.hibernate.SQL" level="DEBUG" />

			<!-- Binding SQL parameters -->
			<!--
			<logger name="org.hibernate.type.descriptor.sql.BasicBinder" level="ALL" />
			<logger name="org.hibernate.type.EnumType" level="ALL" />
			-->

			<!-- Binding and extracting SQL parameters -->
			<!--
			<logger name="org.hibernate.type" level="ALL" />
			-->

		</configuration>
		'''
		)
	}
}
