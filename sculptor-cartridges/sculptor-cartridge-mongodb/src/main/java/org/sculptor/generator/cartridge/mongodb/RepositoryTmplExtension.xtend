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
package org.sculptor.generator.cartridge.mongodb

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.repository.RepositoryTmpl
import sculptormetamodel.Repository

@ChainOverride
class RepositoryTmplExtension extends RepositoryTmpl {

	@Inject var MongoDbAccessObjectFactoryTmpl mongoDbAccessObjectFactoryTmpl

	@Inject extension Properties properties

	override String extraRepositoryBaseDependencies(Repository it) {
		'''
			«dbManagerDependency(it)»
			«next.extraRepositoryBaseDependencies(it)»
		'''
	}

	override String accessObjectFactory(Repository it) {
		'''
			«next.accessObjectFactory(it)»
			«mongoDbAccessObjectFactoryTmpl.getAdditionalDataMappers(it)»
			«mongoDbAccessObjectFactoryTmpl.ensureIndex(it)»
		'''
	}

	private def String dbManagerDependency(Repository it) {
		'''
			@org.springframework.beans.factory.annotation.Autowired
			private «fw("accessimpl.mongodb.DbManager")» dbManager;

			protected «fw("accessimpl.mongodb.DbManager")» getDbManager() {
				return dbManager;
			}
		'''
	}

}
