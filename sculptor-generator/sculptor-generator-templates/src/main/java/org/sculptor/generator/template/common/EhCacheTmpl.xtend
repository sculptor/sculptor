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

	def String ehcacheConfig(Application it) {
		ehcacheXml
		ehcacheTestXml
	}

	def String ehcacheXml(Application it) {
		fileOutput("ehcache.xml", OutputSlot.TO_RESOURCES, '''
		<?xml version="1.0" encoding="UTF-8"?>
		<ehcache updateCheck="false">
			<diskStore path="java.io.tmpdir"/>
			<defaultCache
				maxElementsInMemory="100000"
				eternal="false"
				timeToIdleSeconds="120"
				timeToLiveSeconds="120"
				overflowToDisk="false"
				diskPersistent="false"
				/>
		</ehcache>
		'''
		)
	}

	def String ehcacheTestXml(Application it) {
		fileOutput("ehcache.xml", OutputSlot.TO_RESOURCES_TEST, '''
		<?xml version="1.0" encoding="UTF-8"?>
		<ehcache updateCheck="false">
			<diskStore path="java.io.tmpdir"/>
			<defaultCache
				maxElementsInMemory="10000"
				eternal="false"
				timeToIdleSeconds="120"
				timeToLiveSeconds="120"
				overflowToDisk="false"
				diskPersistent="false"
				/>
		</ehcache>
		'''
		)
	}

}
