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

import com.google.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.service.ServiceTmpl
import sculptormetamodel.Service

@ChainOverride
class ServiceTmplExtension extends ServiceTmpl {

	@Inject private var MongoDbServiceTestTmpl mongoDbServiceTestTmpl

	@Inject extension MongoDbProperties mongoDbProperties
	@Inject extension Properties properties

	override String service(Service it) {
		if (isTestToBeGenerated && mongoDb) {
			mongoDbServiceTestTmpl.serviceJUnitSubclassMongoDb(it);
		}
		next.service(it)
	}
}
