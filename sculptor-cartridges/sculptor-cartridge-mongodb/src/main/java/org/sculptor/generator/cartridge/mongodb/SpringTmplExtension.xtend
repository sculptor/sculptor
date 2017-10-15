/*
 * Copyright 2014 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.cartridge.mongodb

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.spring.SpringTmpl
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

@ChainOverride
class SpringTmplExtension extends SpringTmpl {

	@Inject extension Helper helper
	@Inject extension MongoDbProperties mongoDbProperties
	@Inject extension Properties properties

	override String spring(Application it) {
		'''
			«next.spring(it)»
			«IF mongoDb»
				«mongodb(it)»
				«IF isTestToBeGenerated»
					«mongodbTest(it)»
				«ENDIF»
			«ENDIF»
		'''
	}

	private def String mongodb(Application it) {
		fileOutput(it.getResourceDir("spring") + "mongodb.xml", OutputSlot.TO_GEN_RESOURCES, '''
		«header(it)»
			«mongodbManager(it)»
			«mongodbOptions(it)»
		</beans>
		'''
		)
	}

	private def String mongodbManager(Application it) {
		'''
		<bean id="mongodbManager" class="«fw("accessimpl.mongodb.DbManager")»">
			<property name="dbname" value="${mongodb.dbname}" />
			<property name="dbUrl1" value="${mongodb.url1}" />
			<property name="dbUrl2" value="${mongodb.url2}" />
			<property name="options" ref="mongodbOptions" />
		</bean>
		'''
	}

	private def String mongodbOptions(Application it) {
		'''
		<bean id="mongodbOptions" class="«fw("accessimpl.mongodb.MongoOptionsWrapper")»">
			<property name="connectionsPerHost" value="${mongodbOptions.connectionsPerHost}" />
			<property name="threadsAllowedToBlockForConnectionMultiplier" value="${mongodbOptions.threadsAllowedToBlockForConnectionMultiplier}" />
			<property name="connectTimeout" value="${mongodbOptions.connectTimeout}" />
			<property name="socketTimeout" value="${mongodbOptions.socketTimeout}" />
			<property name="autoConnectRetry" value="${mongodbOptions.autoConnectRetry}" />
		</bean>
		'''
	}

	private def String mongodbTest(Application it) {
		fileOutput(it.getResourceDir("spring") + "mongodb-test.xml", OutputSlot.TO_GEN_RESOURCES_TEST, '''
		«header(it)»
			«mongodbManagerTest(it)»
			«mongodbOptions(it)»
		</beans>
		'''
		)
	}

	private def String mongodbManagerTest(Application it) {
		'''
		<bean id="mongodbManager" class="«fw("accessimpl.mongodb.DbManager")»">
			<property name="dbname" value="«name»-test" />
			<property name="dbUrl1" value="${mongodb.url1}" />
			<property name="dbUrl2" value="${mongodb.url2}" />
			<property name="options" ref="mongodbOptions" />
		</bean>
		'''
	}

	override String applicationContextAdditions(Application it) {
		'''
			«IF mongoDb»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("mongodb.xml")»"/>
			«ENDIF»
		'''
	}

	override String applicationContextTestAdditions(Application it) {
		'''
			«IF mongoDb»
				<import resource="classpath:/«it.getResourceDir("spring") + it.getApplicationContextFile("mongodb-test.xml")»"/>
			«ENDIF»
		'''
	}

	override String generatedSpringPropertiesAdditions(Application it) {
		'''
			«IF mongoDb»
				mongodb.dbname=«name»
				mongodb.url1=localhost:27017
				mongodb.url2=
				mongodbOptions.connectionsPerHost=10
				mongodbOptions.threadsAllowedToBlockForConnectionMultiplier=5
				mongodbOptions.connectTimeout=10000
				mongodbOptions.socketTimeout=0
				mongodbOptions.autoConnectRetry=false
			«ENDIF»
		'''
	}

	override String interceptorAdditions(Application it) {
		'''
			«IF mongoDb»
				<bean id="mongodbManagerAdvice" class="«fw("accessimpl.mongodb.DbManagerAdvice")»" >
					<property name="dbManager" ref="mongodbManager" />
				</bean>
			«ENDIF»
		'''
	}

	override String aopConfigAdditions(Application it, boolean test) {
		'''
			«IF mongoDb»
				«IF !test»
					<aop:advisor pointcut-ref="businessService" advice-ref="mongodbManagerAdvice" order="5" />
					«IF it.hasConsumers»
						<aop:advisor pointcut-ref="messageConsumer" advice-ref="mongodbManagerAdvice" order="5" />
					«ENDIF»
				«ENDIF»
			«ENDIF»
		'''
	}

}
