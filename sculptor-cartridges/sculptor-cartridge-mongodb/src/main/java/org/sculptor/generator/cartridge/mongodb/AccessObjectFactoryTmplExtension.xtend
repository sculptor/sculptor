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
import org.sculptor.generator.template.repository.AccessObjectFactoryTmpl
import sculptormetamodel.RepositoryOperation

@ChainOverride
class AccessObjectFactoryTmplExtension extends AccessObjectFactoryTmpl {

	@Inject extension MongoDbHelper mongoDbHelper
	@Inject extension MongoDbProperties mongoDbProperties

	override String factoryMethodInit(RepositoryOperation it) {
		'''
			«next.factoryMethodInit(it)»
			«IF mongoDb»
				ao.setDbManager(dbManager);
				ao.setDataMapper(«repository.aggregateRoot.module.mapperPackage».«repository.aggregateRoot.name»Mapper.getInstance());
				ao.setAdditionalDataMappers(getAdditionalDataMappers());
			«ENDIF»
		'''
	}
}
