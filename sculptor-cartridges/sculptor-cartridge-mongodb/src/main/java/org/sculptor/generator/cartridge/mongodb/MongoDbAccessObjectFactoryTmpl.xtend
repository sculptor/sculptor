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
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Repository

class MongoDbAccessObjectFactoryTmpl {

	@Inject extension MongoDbHelper mongoDbHelper
	@Inject extension DbHelper dbHelper
	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

	def String getAdditionalDataMappers(Repository it) {
		val allUnownedReferences = it.aggregateRoot.getAggregate().map[ag|ag.getAllReferences()].flatten.filter[e|
			e.isUnownedReference()]
		val allNonEnumNaturalKeyReferences = it.aggregateRoot.getNaturalKeyReferences().filter[e|!e.isEnumReference()]

		'''
			@SuppressWarnings("rawtypes")
			private «fw("accessimpl.mongodb.DataMapper")»[] additionalDataMappers =
				new «fw("accessimpl.mongodb.DataMapper")»[] {
					«IF isJodaDateTimeLibrary()»
						«fw("accessimpl.mongodb.JodaLocalDateMapper")».getInstance(),
						«fw("accessimpl.mongodb.JodaDateTimeMapper")».getInstance(),
					«ENDIF»
					«fw("accessimpl.mongodb.EnumMapper")».getInstance()«IF !allUnownedReferences.isEmpty»,«ENDIF»
					«FOR ref : allUnownedReferences SEPARATOR ", "»
						«fw("accessimpl.mongodb.IdMapper")».getInstance(«ref.to.getDomainPackage()».«ref.to.name».class)
					«ENDFOR»«IF !allNonEnumNaturalKeyReferences.isEmpty»,«ENDIF»
					«FOR ref : allNonEnumNaturalKeyReferences SEPARATOR ", "»
						«getMapperPackage(ref.to.module)».«ref.to.name»Mapper.getInstance()
					«ENDFOR»
					};
			
			@SuppressWarnings("unchecked")
			protected «fw("accessimpl.mongodb.DataMapper")»<Object, com.mongodb.DBObject>[] getAdditionalDataMappers() {
				return additionalDataMappers;
			}
		'''
	}

	def String ensureIndex(Repository it) {
		'''
			@javax.annotation.PostConstruct
			protected void ensureIndex() {
				com.mongodb.DBCollection dbCollection = dbManager.getDBCollection(«aggregateRoot.module.getMapperPackage()».«aggregateRoot.
				name»Mapper.getInstance().getDBCollectionName());
				for («fw("accessimpl.mongodb.IndexSpecification")» each : «aggregateRoot.module.getMapperPackage()».«aggregateRoot.
				name»Mapper.getInstance().indexes()) {
					dbCollection.ensureIndex(each.getKeys(), each.getName(), each.isUnique());
				}
			}
		'''
	}
}
