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

import javax.inject.Inject
import org.sculptor.generator.ext.DbHelper
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Repository
import sculptormetamodel.RepositoryOperation

class AccessObjectFactoryTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String getPersistentClass(Repository it) {
	'''
		protected Class<«getDomainPackage(aggregateRoot)».«aggregateRoot.name»> getPersistentClass() {
			return «getDomainPackage(aggregateRoot)».«aggregateRoot.name».class;
		}
	'''
}

def String genericFactoryMethod(RepositoryOperation it) {
	'''
	«IF useGenericAccessStrategy(it)»
		«IF name != "findByExample"»
			// convenience method
			protected «genericAccessObjectInterface(name)»2«it.getGenericType()» create«getAccessNormalizedName()»() {
				return create«getAccessNormalizedName()»(getPersistentClass(), getPersistentClass());
			}

			// convenience method
			protected <R> «genericAccessObjectInterface(name)»2<R> create«getAccessNormalizedName()»(Class<R> resultType) {
				return create«getAccessNormalizedName()»(getPersistentClass(), resultType);
			}

			protected <T,R> «genericAccessObjectInterface(name)»2<R> create«getAccessNormalizedName()»(Class<T> type, Class<R> resultType) {
				«genericAccessObjectImplementation(name)»Generic<T,R> ao = new «genericAccessObjectImplementation(name)»Generic<T,R>(type, resultType);
				«factoryMethodInit(it)»
				return ao;
			}
		«ELSE»
			protected <T,R> «genericAccessObjectInterface(name)»2<T,R> create«getAccessNormalizedName()»(Class<T> type, Class<R> resultType) {
				«genericAccessObjectImplementation(name)»Generic<T,R> ao = new «genericAccessObjectImplementation(name)»Generic<T,R>(type, resultType);
				«factoryMethodInit(it)»
				return ao;
			}
		«ENDIF»
	«ELSE»
		protected «genericAccessObjectInterface(name)»«it.getGenericType()» create«getAccessNormalizedName()»() {
			«genericAccessObjectImplementation(name)»«it.getGenericType()» ao = new «genericAccessObjectImplementation(name)»«it.getGenericType()»(« IF it.hasAccessObjectPersistentClassConstructor()»getPersistentClass()«ENDIF»);
			«factoryMethodInit(it)»
			return ao;
		}
	«ENDIF»
	'''
}

def String factoryMethod(RepositoryOperation it) {
	'''
		protected «getAccessapiPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»«it.getGenericType()» create«getAccessNormalizedName()»() {
			«getAccessimplPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»«it.getGenericType()»Impl«it.getGenericType()» ao = new «getAccessimplPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»«it.getGenericType()»Impl«it.getGenericType()»();
			«factoryMethodInit(it)»
			return ao;
		}
	'''
}

def String factoryMethodInit(RepositoryOperation it) {
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


}
