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
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Application

@ChainOverridable
class EhCacheTmpl {

	@Inject extension Helper helper

	def void ehcacheConfig(Application it) {
		ehcacheXml
		ehcacheTestXml
	}

	def void ehcacheXml(Application it) {
		fileOutput("ehcache.xml", OutputSlot.TO_RESOURCES,   ehcacheTemplateXml())
	}

	def void ehcacheTestXml(Application it) {
		fileOutput("ehcache-test.xml", OutputSlot.TO_RESOURCES_TEST,  ehcacheTemplateXml())
	}

	def String ehcacheTemplateXml() {
		'''
		<config
				xmlns:xsi='http://www.w3.org/2001/XMLSchema-instance'
				xmlns='http://www.ehcache.org/v3'
				xmlns:jsr107='http://www.ehcache.org/v3/jsr107'
				xsi:schemaLocation="
					http://www.ehcache.org/v3 http://www.ehcache.org/schema/ehcache-core.xsd
					http://www.ehcache.org/v3/jsr107 http://www.ehcache.org/schema/ehcache-107-ext.xsd">

			<service>
				<jsr107:defaults default-template="defaultCache" enable-management="false" enable-statistics="false"/>
			</service>

			<!--
			According to documentation https://docs.jboss.org/hibernate/orm/5.4/userguide/html_single/Hibernate_User_Guide.html#caching-query-region
			this cache should be set ETERNAL if possible. Cache region for the default-update-timestamps-region have to be
			set to a higher value than the timeout setting of any of the QUERY caches.
			-->
			<cache alias="default-update-timestamps-region">
				<expiry>
					<none/>
				</expiry>
				<heap unit="entries">5000</heap>
			</cache>

			<cache alias="default-query-results-region">
				<expiry>
					<tti unit="minutes">5</tti>
				</expiry>
				<heap unit="entries">1000</heap>
			</cache>

			<!-- Override defaultCache per entity and avoid warning in console -->
			<!--
			<cache alias="com.package.domain.Entity" uses-template="defaultCache">
				<expiry>
					<ttl unit="minutes">1</ttl>
				</expiry>
				<heap unit="MB">5</heap>
			</cache>
			-->

			<!-- Override query cache -->
			<!--
			<cache alias="query.com.package.domain.Entity" uses-template="defaultCache">
				<expiry>
					<ttl unit="minutes">3</ttl>
				</expiry>
				<heap unit="MB">5</heap>
			</cache>
			-->

			<cache-template name="defaultCache">
				<expiry>
					<ttl unit="minutes">3</ttl>
				</expiry>
				<heap unit="entries">500</heap>
			</cache-template>

		</config>
		'''
	}
}
