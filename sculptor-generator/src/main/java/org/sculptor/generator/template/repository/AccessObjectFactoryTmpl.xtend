/*
 * Copyright 2007 The Fornax Project Team, including the original
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

package org.sculptor.generator.template.repository

import sculptormetamodel.*

import static extension org.sculptor.generator.ext.DbHelper.*
import static extension org.sculptor.generator.util.DbHelperBase.*
import static extension org.sculptor.generator.ext.Helper.*
import static extension org.sculptor.generator.util.HelperBase.*
import static extension org.sculptor.generator.ext.Properties.*
import static extension org.sculptor.generator.util.PropertiesBase.*

class AccessObjectFactoryTmpl {

def static String getPersistentClass(Repository it) {
	'''
		protected Class<«getDomainPackage(aggregateRoot)».«aggregateRoot.name»> getPersistentClass() {
			return «getDomainPackage(aggregateRoot)».«aggregateRoot.name».class;
		}
	'''
}

def static String genericFactoryMethod(RepositoryOperation it) {
	'''
	«IF useGenericAccessStrategy()»
		«IF name != "findByExample"»
		// convenience method
		protected «genericAccessObjectInterface(name)»2«getGenericType()» create«getAccessObjectName()»() {
			return create«getAccessObjectName()»(getPersistentClass(), getPersistentClass());
		}

		// convenience method
		protected <R> «genericAccessObjectInterface(name)»2<R> create«getAccessObjectName()»(Class<R> resultType) {
			return create«getAccessObjectName()»(getPersistentClass(), resultType);
		}

		protected <T,R> «genericAccessObjectInterface(name)»2<R> create«getAccessObjectName()»(Class<T> type, Class<R> resultType) {
			«genericAccessObjectImplementation(name)»Generic<T,R> ao = new «genericAccessObjectImplementation(name)»Generic<T,R>(type, resultType);
			«factoryMethodInit(it)»
			return ao;
		}
		«ELSE»
		protected <T,R> «genericAccessObjectInterface(name)»2<T,R> create«getAccessObjectName()»(Class<T> type, Class<R> resultType) {
			«genericAccessObjectImplementation(name)»Generic<T,R> ao = new «genericAccessObjectImplementation(name)»Generic<T,R>(type, resultType);
			«factoryMethodInit(it)»
			return ao;
		}
		«ENDIF»
		«ELSE»
		protected «genericAccessObjectInterface(name)»«getGenericType()» create«getAccessObjectName()»() {
			«genericAccessObjectImplementation(name)»«getGenericType()» ao = new «genericAccessObjectImplementation(name)»«getGenericType()»(« IF hasAccessObjectPersistentClassConstructor()»getPersistentClass()«ENDIF»);
			«factoryMethodInit(it)»
			return ao;
		}
	«ENDIF»
	'''
}

def static String factoryMethod(RepositoryOperation it) {
	'''
		protected «getAccessapiPackage(repository.aggregateRoot.module)».«getAccessObjectName()»«getGenericType()» create«getAccessObjectName()»() {
			«getAccessimplPackage(repository.aggregateRoot.module)».«getAccessObjectName()»«getGenericType()»Impl«getGenericType()» ao = new «getAccessimplPackage(repository.aggregateRoot.module)».«getAccessObjectName()»«getGenericType()»Impl«getGenericType()»();
			«factoryMethodInit(it)»
			return ao;
		}
	'''
}

def static String factoryMethodInit(RepositoryOperation it) {
	'''
	«IF jpa()»
		ao.setEntityManager(getEntityManager());
	«ELSEIF mongoDb() »
		ao.setDbManager(dbManager);
		ao.setDataMapper(«repository.aggregateRoot.module.getMapperPackage()».«repository.aggregateRoot.name»Mapper.getInstance());
		ao.setAdditionalDataMappers(getAdditionalDataMappers());
	«ENDIF »
	'''
}

def static String getAdditionalDataMappers(Repository it) {
	'''
	«val allUnownedReferences = it.aggregateRoot.getAggregate().getAllReferences().filter(e | e.isUnownedReference())»
	«val allNonEnumNaturalKeyReferences = it.aggregateRoot.getNaturalKeyReferences().reject(e | e.isEnumReference())»
		@SuppressWarnings("unchecked")
		private «fw("accessimpl.mongodb.DataMapper")»[] additionalDataMappers =
			new «fw("accessimpl.mongodb.DataMapper")»[] {
				«IF isJodaDateTimeLibrary() »
				«fw("accessimpl.mongodb.JodaLocalDateMapper")».getInstance(),
				«fw("accessimpl.mongodb.JodaDateTimeMapper")».getInstance(),
				«ENDIF »
				«fw("accessimpl.mongodb.EnumMapper")».getInstance()«IF !allUnownedReferences.isEmpty»,«ENDIF»
				«FOR ref SEPARATOR ", " : allUnownedReferences»
				«fw("accessimpl.mongodb.IdMapper")».getInstance(«ref.to.getDomainPackage()».«ref.to.name».class)
				«ENDFOR»«IF !allNonEnumNaturalKeyReferences.isEmpty»,«ENDIF»
				«FOR ref SEPARATOR ", " : allNonEnumNaturalKeyReferences»
					«getMapperPackage(ref.to.module)».«ref.to.name»Mapper.getInstance()
				«ENDFOR»
				};

		@SuppressWarnings("unchecked")
		protected «fw("accessimpl.mongodb.DataMapper")»<Object, com.mongodb.DBObject>[] getAdditionalDataMappers() {
			return additionalDataMappers;
		}
	'''
}

def static String ensureIndex(Repository it) {
	'''
		@javax.annotation.PostConstruct
		protected void ensureIndex() {
			com.mongodb.DBCollection dbCollection = dbManager.getDBCollection(«aggregateRoot.module.getMapperPackage()».«aggregateRoot.name»Mapper.getInstance().getDBCollectionName());
			for («fw("accessimpl.mongodb.IndexSpecification")» each : «aggregateRoot.module.getMapperPackage()».«aggregateRoot.name»Mapper.getInstance().indexes()) {
				dbCollection.ensureIndex(each.getKeys(), each.getName(), each.isUnique());
			}
		}
	'''
}
}
