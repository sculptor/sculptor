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

class RepositoryTmpl {

def static String repository(Repository it) {
	'''
		«repositoryInterface(it)»
		«repositoryBase(it)»
		«IF gapClass»
			«repositorySubclass(it)»
		«ENDIF»
		«IF !otherDependencies.isEmpty»
			«repositoryDependencyInjectionJUnit(it)»
		«ENDIF»
	'''
}

def static String repositoryInterface(Repository it) {
	'''
		«val baseName  = it.getRepositoryBaseName()»
	'''
	fileOutput(javaFileName(aggregateRoot.module.getRepositoryapiPackage() + "." + name), '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryapiPackage()»;

	«IF formatJavaDoc() == "" »
/**
 * Generated interface for Repository for «baseName»
 */
	«ELSE »
	«formatJavaDoc()»
	«ENDIF »
	«IF pureEjb3()»
	@javax.ejb.Local
	«ENDIF »
	public interface «name» «IF subscribe != null»^extends «fw("event.EventSubscriber")» «ENDIF» {

	«IF isSpringToBeGenerated()»
		public final static String BEAN_ID = "«name.toFirstLower()»";
		«ENDIF»

		«it.operations.filter(op | op.isPublicVisibility()).forEach[interfaceRepositoryMethod(it)]»

	«repositoryInterfaceHook(it)»
	}
	'''
	)
	'''
	'''
}

def static String repositoryBase(Repository it) {
	'''
		«val baseName  = it.getRepositoryBaseName()»
	'''
	fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + (gapClass ? "Base" : getSuffix("Impl"))), '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryimplPackage()»;

	«IF gapClass»
/**
 * Generated base class for implementation of Repository for «baseName»
	«IF isSpringToBeGenerated() »
 * <p>Make sure that subclass defines the following annotations:
 * <pre>
		@org.springframework.stereotype.Repository("«name.toFirstLower()»")
 * </pre>
 *	«ENDIF »
	«IF pureEjb3()»
 * <p>Make sure that subclass defines the following annotations:
 * <pre>
		@javax.ejb.Stateless(name="«name.toFirstLower()»")
 * </pre>
 *	«ENDIF»
 */
	«ELSE»
/**
 * Repository implementation for «baseName»
 */
	«IF isSpringToBeGenerated()»
	@org.springframework.stereotype.Repository("«name.toFirstLower()»")
	«ENDIF»
	«IF pureEjb3()»
	@javax.ejb.Stateless(name="«name.toFirstLower()»")
	«ENDIF»
	«ENDIF»
	«IF subscribe != null»«PubSubTmpl::subscribeAnnotation(it) FOR subscribe»«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name»«gapClass ? "Base" : getSuffix("Impl")» «^extendsLitteral()»
		implements «aggregateRoot.module.getRepositoryapiPackage()».«name» {

		public «name»«gapClass ? "Base" : getSuffix("Impl")»() {
		}

		«repositoryDependencies(it)»

		«it.operations.filter(op | op.delegateToAccessObject && !op.isGenericAccessObject()).forEach[baseRepositoryMethod(it)]»
		«it.operations.filter(op | op.isGenericAccessObject()).reject(e|e.hasPagingParameter()).forEach[genericBaseRepositoryMethod(it)]»
		«it.operations.filter(op | op.isGenericAccessObject() && op.hasPagingParameter()).forEach[pagedGenericBaseRepositoryMethod(it)]»

		«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && !op.isGeneratedFinder()).forEach[(it)^abstractBaseRepositoryMethod]»
		«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && op.isGeneratedFinder()).forEach[finderMethod(it)]»

	«IF isJpa1() && isJpaProviderDataNucleus() && !pureEjb3()»
	    @javax.persistence.PersistenceContext«IF persistenceContextUnitName() != ""»(unitName = "«persistenceContextUnitName()»")«ENDIF»
	    private javax.persistence.EntityManager entityManager;
	«ENDIF»

	«IF pureEjb3() && jpa()»
		«entityManagerDependency(it) »
	«ELSEIF isSpringToBeGenerated() && jpa()»
		«daoSupportEntityManagerDependency(it) »
	«ELSEIF mongoDb()»
		«dbManagerDependency(it)»
	«ENDIF»

	«accessObjectFactory(it)»

	«repositoryHook(it)»

	}
	'''
	)
	'''
	'''
}

def static String accessObjectFactory(Repository it) {
	'''
	«it.getDistinctOperations().filter(op | op.isGenericAccessObject()).forEach[AccessObjectFactory::genericFactoryMethod(it)]»
		«it.getDistinctOperations().filter(op | op.delegateToAccessObject && !op.isGenericAccessObject()).forEach[AccessObjectFactory::factoryMethod(it)]»
	«AccessObjectFactory::getPersistentClass(it)»
	«IF mongoDb()»
		«AccessObjectFactory::getAdditionalDataMappers(it)»
		«AccessObjectFactory::ensureIndex(it)»
	«ENDIF»
	'''
}

def static String entityManagerDependency(Repository it) {
	'''
	@javax.persistence.PersistenceContext«IF persistenceContextUnitName() != ""»(unitName = "«persistenceContextUnitName()»")«ENDIF»
	private javax.persistence.EntityManager entityManager;

		/**
			* Dependency injection
			*/
		@javax.persistence.PersistenceContext«IF persistenceContextUnitName() != ""»(unitName = "«persistenceContextUnitName()»")«ENDIF»
		protected void setEntityManager(javax.persistence.EntityManager entityManager) {
			this.entityManager = entityManager;
		}

		protected javax.persistence.EntityManager getEntityManager() {
			return entityManager;
		}
	'''
}

def static String dbManagerDependency(Repository it) {
	'''
	@org.springframework.beans.factory.annotation.Autowired
	private «fw("accessimpl.mongodb.DbManager")» dbManager;

	protected «fw("accessimpl.mongodb.DbManager")» getDbManager() {
	    return dbManager;
	}
	'''
}

def static String daoSupportEntityManagerDependency(Repository it) {
	'''
		private javax.persistence.EntityManager entityManager;

		/**
			* Dependency injection
			*/
		@javax.persistence.PersistenceContext«IF persistenceContextUnitName() != ""»(unitName = "«persistenceContextUnitName()»")«ENDIF»
		protected void setEntityManagerDependency(javax.persistence.EntityManager entityManager) {
			this.entityManager = entityManager;
			// for JpaDaoSupport, JpaTemplate
			setEntityManager(entityManager);
		}

		protected javax.persistence.EntityManager getEntityManager() {
			return entityManager;
		}
	'''
}

def static String repositoryDependencies(Repository it) {
	'''
	«FOR dependency  : repositoryDependencies»
		«IF isSpringToBeGenerated()»
	    	@org.springframework.beans.factory.annotation.Autowired
		«ENDIF»
		«IF pureEjb3()»
	    	@javax.ejb.EJB
		«ENDIF»
		private «dependency.aggregateRoot.module.getRepositoryapiPackage()».«dependency.name» «dependency.name.toFirstLower()»;

	    protected «dependency.aggregateRoot.module.getRepositoryapiPackage()».«dependency.name» get«dependency.name»() {
	        return «dependency.name.toFirstLower()»;
	    }
		«ENDFOR»
	'''
}

def static String repositorySubclass(Repository it) {
	'''
		«val baseName  = it.getRepositoryBaseName()»
	'''
	fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + getSuffix("Impl")), 'TO_SRC', '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryimplPackage()»;

/**
 * Repository implementation for «baseName»
 */
	«IF isSpringToBeGenerated()»
	@org.springframework.stereotype.Repository("«name.toFirstLower()»")
	«ENDIF»
	«IF pureEjb3()»
	@javax.ejb.Stateless(name="«name.toFirstLower()»")
	«ENDIF»
	public class «name + getSuffix("Impl")» ^extends «name»Base {

		public «name + getSuffix("Impl")»() {
		}

	«otherDependencies(it)»

		«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && !op.isGeneratedFinder()).forEach[subclassRepositoryMethod(it)]»

	}
	'''
	)
	'''
	'''
}

def static String otherDependencies(Repository it) {
	'''
		«FOR dependency  : otherDependencies»
		/**
			* Dependency injection
			*/
		«IF isSpringToBeGenerated()»
	@org.springframework.beans.factory.annotation.Autowired
	«ENDIF»
		«IF pureEjb3()»
	@javax.ejb.EJB
	«ENDIF»
		public void set«dependency.toFirstUpper()»(Object «dependency») {
			// TODO implement setter for dependency injection of «dependency»
			throw new UnsupportedOperationException("Implement setter for dependency injection of «dependency» in «name + getSuffix("Impl")»");
		}
		«ENDFOR»

	'''
}

def static String baseRepositoryMethod(RepositoryOperation it) {
	'''
		«val baseName  = it.repository.getRepositoryBaseName()»
		«val pagingParameter  = it.getPagingParameter()»
	/**
	 * Delegates to {@link «getAccessapiPackage(repository.aggregateRoot.module)».«getAccessObjectName()»}
	 */
		«repositoryMethodAnnotation(it)»
		«IF useGenericAccessStrategy()»
		«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
				return «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]», getPersistentClass());
		}
		«getVisibilityLitteral()» <R> «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]», Class<R> resultType) « EXPAND ExceptionTmpl::throws» {
		«ELSE»
		«getVisibilityLitteral()»«getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
		«ENDIF»
		«IF useGenericAccessStrategy()»
			«IF name != "findByExample"»
			«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessObjectName()»2«getGenericType()» ao = create«getAccessObjectName()»(resultType);
			«ELSE»
			«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessObjectName()»2<«getAggregateRootTypeName()», R> ao = create«getAccessObjectName()»(getPersistentClass(), resultType);
			«ENDIF»
		«ELSE»
			«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessObjectName()»«getGenericType()» ao = create«getAccessObjectName()»();
		«ENDIF»
		«setCache(it)»
		«setOrdered(it)»
		«FOR parameter : parameters.reject(e | e == pagingParameter)»
		ao.set«parameter.name.toFirstUpper()»(«parameter.name»);
		«ENDFOR»
		«IF pagingParameter != null»
		if («pagingParameter.name».getStartRow() != «fw("domain.PagedResult")».UNKNOWN
				&& «pagingParameter.name».getRealFetchCount() != «fw("domain.PagedResult")».UNKNOWN) {
			ao.setFirstResult(«pagingParameter.name».getStartRow());
			ao.setMaxResult(«pagingParameter.name».getRealFetchCount());
		}
		«ENDIF»
		ao.execute();
		«IF isPagedResult()»
	        «IF isJpa1() && isJpaProviderDataNucleus()»
	    // workaround for datanucleus serialization issue
			java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»> result = new java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»>();
			result.addAll(ao.getResult());
	        «ELSE»
		«getAccessObjectResultTypeName()» result = ao.getResult();
	        «ENDIF»

		«calculateMaxPages(it)»

		«getTypeName()» pagedResult = new «getTypeName()»(result
				, pagingParameter.getStartRow()
				, pagingParameter.getRowCount()
				, pagingParameter.getPageSize()
				, rowCount
				, additionalRows);
		return pagedResult;
		«ELSEIF getTypeName() != "void" »
	        «IF isJpa1() && isJpaProviderDataNucleus() && getTypeName().startsWith("java.util.List")»
	    // workaround for datanucleus serialization issue
			java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»> result = new java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»>();
			result.addAll(ao.getResult());
			return result;
	        «ELSE»
		return ao.getResult();
	        «ENDIF»
		«ENDIF»
	}
	'''
}

def static String setCache(RepositoryOperation it) {
	'''
		«IF hasHint("cache")»
			ao.setCache(true);
		«ENDIF»
	'''
}

def static String setOrdered(RepositoryOperation it) {
	'''
		/*JPA2 supports multiple ordering columns, e.g. hint="orderBy=col1 asc, col2 desc" */
		«IF isJpa2()»
	    «IF hasHint("orderBy")»
	        ao.setOrderBy("«getHint("orderBy",";")»");
	    «ENDIF»
		«ELSE»
	    «IF hasHint("orderBy")»
	        ao.setOrderBy("«getHint("orderBy")»");
	    «ENDIF»
	    «IF hasHint("orderByAsc") && getHint("orderByAsc") != "true"»
	        ao.setOrderByAsc(false);
	    «ENDIF»
		«ENDIF»
	'''
}

def static String setQueryHint(RepositoryOperation it) {
	'''
		/*TODO: complete queryHint */
		«IF hasHint("queryHint")»
			ao.setHint("«getHint("queryHint")»);
		«ENDIF»
	'''
}

def static String genericBaseRepositoryMethod(RepositoryOperation it) {
	'''
		«val baseName  = it.repository.getRepositoryBaseName()»
		/**
			* Delegates to {@link «genericAccessObjectInterface(name)»}
			*/
		«repositoryMethodAnnotation(it)»
		«IF useGenericAccessStrategy()»
	    «getVisibilityLitteral()»«getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
	        return «name»(«FOR param SEPARATOR "," : parameters»«param.name»«ENDFOR»«IF hasParameters()»,«ENDIF»getPersistentClass());
	    }
	    «getVisibilityLitteral()» <R> «getGenericResultTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]»«IF hasParameters()»,«ENDIF» Class<R> resultType) « EXPAND ExceptionTmpl::throws» {
		«ELSE»
	    «getVisibilityLitteral()»«getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
		«ENDIF»
		/*TODO:implement a better solution */
			«IF useGenericAccessStrategy()»
	        «IF name != "findByExample"»
				«genericAccessObjectInterface(name)»2<R> ao = create«getAccessObjectName()»(resultType);
	        «ELSE»
				«genericAccessObjectInterface(name)»2<«getAggregateRootTypeName()»,R> ao = create«getAccessObjectName()»(«getAggregateRootTypeName()».class, resultType);
	        «ENDIF»
			«ELSE»
				«genericAccessObjectInterface(name)»«getGenericType()» ao = create«getAccessObjectName()»();
			«ENDIF»
			«setCache(it)»
			«setOrdered(it)»
		«IF hasHint("useSingleResult")»
			ao.setUseSingleResult(true);
		«ENDIF»
		«IF name != "findByKey" »
			/*TODO: why do you need to remove persistentClass from parameter list? */
			«FOR parameter : parameters.reject(e | isJpa2() && e.name == "persistentClass")»
			ao.set«parameter.name.toFirstUpper()»(«parameter.name»);
			«ENDFOR»
		«ENDIF»
		«findByKeysSpecialCase(it)»
		«findByKeySpecialCase(it)»
			ao.execute();
		«IF getTypeName() != "void" »
			«nullThrowsNotFoundExcpetion(it)»
			«findByKeySpecialCase2(it)»
			«IF (parameters.exists(e|e.name == "useSingleResult") || hasHint("useSingleResult")) && this.collectionType == null»
			return «IF !isJpa2() && getTypeName() != "Object"»(«getTypeName().getObjectTypeName()») «ENDIF»ao.getSingleResult();
			«ELSE»
	        «IF isJpa1() && isJpaProviderDataNucleus() && getTypeName().startsWith("java.util.List")»
	    // workaround for datanucleus serialization issue
			java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»> result = new java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»>();
			result.addAll(ao.getResult());
			return result;
	        «ELSE»
			return ao.getResult();
				«ENDIF»
			«ENDIF»
		«ENDIF»
		}
		«findByNaturalKeys(it) »
	'''
}

def static String pagedGenericBaseRepositoryMethod(RepositoryOperation it) {
	'''
		«val baseName  = it.repository.getRepositoryBaseName()»
		«val pagingParameter  = it.getPagingParameter()»
	«repositoryMethodAnnotation(it)»
	«getVisibilityLitteral()»«getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws» {
		«IF useGenericAccessStrategy()»
			«genericAccessObjectInterface(name)»2«getGenericType()» ao = create«getAccessObjectName()»();
		«ELSE»
			«genericAccessObjectInterface(name)»«getGenericType()» ao = create«getAccessObjectName()»();
		«ENDIF»
		«setCache(it)»
		«setOrdered(it)»
		«FOR parameter : parameters.reject(e | e == pagingParameter)»
		ao.set«parameter.name.toFirstUpper()»(«parameter.name»);
		«ENDFOR»

		if («pagingParameter.name».getStartRow() != «fw("domain.PagedResult")».UNKNOWN
				&& «pagingParameter.name».getRealFetchCount() != «fw("domain.PagedResult")».UNKNOWN) {
			ao.setFirstResult(«pagingParameter.name».getStartRow());
			ao.setMaxResult(«pagingParameter.name».getRealFetchCount());
		}

		ao.execute();
	«IF isPagedResult()»
	        «IF isJpa1() && isJpaProviderDataNucleus()»
	    // workaround for datanucleus serialization issue
			java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»> result = new java.util.ArrayList<«domainObjectType.getDomainPackage() + "." + domainObjectType.name»>();
			result.addAll(ao.getResult());
	        «ELSE»
		«getAccessObjectResultTypeName()» result = ao.getResult();
	        «ENDIF»
		«calculateMaxPages(it)»

		«getTypeName()» pagedResult = new «getTypeName()»(result
				, pagingParameter.getStartRow()
				, pagingParameter.getRowCount()
				, pagingParameter.getPageSize()
				, rowCount
				, additionalRows);
		return pagedResult;
	«ELSEIF getTypeName() != "void" »
		return ao.getResult();
	«ENDIF»
	}
	«findByNaturalKeys(it) »
	'''
}

def static String calculateMaxPages(RepositoryOperation it) {
	'''
	«val pagingParameter  = it.getPagingParameter()»
	«val countOperationHint = it.getHint("countOperation")»
	«val countQueryHint = it.getHint("countQuery")»
		int rowCount = «fw("domain.PagedResult")».UNKNOWN;
		int additionalRows=«fw("domain.PagedResult")».UNKNOWN;
		if («pagingParameter.name».getStartRow() != «fw("domain.PagedResult")».UNKNOWN && «pagingParameter.name».getRealFetchCount() != 0) {
			int resultSize=result.size();
			if (resultSize > 0 && resultSize < pagingParameter.getRealFetchCount()) {
				// Not enough rows fetched - end of result reached, we should fill row
				// count and also additional pages without real counting.
				// Fill it even when nobody  ask (isCountTotal), don't cost nothing and can be used on client side
				rowCount=pagingParameter.getStartRow()+resultSize;
				additionalRows=resultSize - pagingParameter.getRowCount();
				additionalRows=additionalRows < 0 ? 0 : additionalRows;
			} else {
				if («pagingParameter.name».isCountTotal()) {
				«IF countOperationHint != null»
					«val countOperation = it.repository.operations.selectFirst(e | e != this && e.name == countOperationHint)»
						«IF countOperation == null»
							Long countNumber = «countOperationHint»«IF !countOperationHint.endsWith(")")»()«ENDIF»;
						«ELSE»
							Long countNumber = «countOperation.name»(«FOR param SEPARATOR ", "  : countOperation.parameters»«IF parameters.exists(e|e.name == param.name)»«param.name»«ELSE»null«ENDIF»«ENDFOR»);
						«ENDIF»
				«ELSEIF  countQueryHint != null || (isJpa1() && name == "findByQuery")»
					«val countOperation1 = it.repository.operations.selectFirst(e | e != this && e.name == "findByQuery" && e.parameters.exists(p | p.name == "useSingleResult"))»
					«val countOperation2 = it.repository.operations.selectFirst(e | e != this && e.name == "findByQuery")»
					«val countOperation = it.countOperation1 != null ? countOperation1 : countOperation2»
						«IF countOperation == null»
							// TODO define findByQuery
							Long countNumber = null;
						«ELSE»
							«IF parameters.notExists(e|e.name == "parameters") && countOperation.parameters.exists(e|e.name == "parameters")»
							java.util.Map<String, Object> parameters = new java.util.HashMap<String, Object>();
							«FOR param  : parameters.reject(e | e.isPagingParameter())»
							parameters.put("«param.name»", «param.name»);
							«ENDFOR»
							«ENDIF»
							Long countNumber = «IF countOperation.getTypeName() == "Object"»(Long) «ENDIF»
								«countOperation.name»(«FOR param SEPARATOR ", "  : countOperation.parameters»«IF param.name == "query" || param.name == "namedQuery"»«IF countQueryHint == null»«param.name».replaceFirst("find", "count")«ELSE»"«countQueryHint»"«ENDIF»«
								ELSEIF param.name == "useSingleResult"»true« ELSEIF param.name == "parameters"»parameters«
								ELSEIF parameters.exists(e|e.name == param.name)»«param.name»« ELSE»null«ENDIF»«ENDFOR»)«IF countOperation1 == null».size()«ENDIF»;
						«ENDIF»
				    «ELSEIF (useGenericAccessStrategy())»
				        // If you need an alternative way to calculate max pages you could define hint="countOperation=..." or hint="countQuery=..."
				        ao.executeResultCount();
				        Long countNumber = ao.getResultCount();
				    «ELSEIF (isJpa1() && name == "findByCondition")»
				        // If you need an alternative way to calculate max pages you could define hint="countOperation=..." or hint="countQuery=..."
				        ao.executeCount();
				        Long countNumber = ao.getResultCount();
				    «ELSE»
					// If you need to calculate max pages you should define hint="countOperation=..." or hint="countQuery=..."
					Long countNumber = null;
				«ENDIF»
					rowCount = countNumber == null ? «fw("domain.PagedResult")».UNKNOWN : countNumber.intValue();
				}
				if (rowCount != «fw("domain.PagedResult")».UNKNOWN) {
					additionalRows = rowCount - pagingParameter.getEndRow();
					additionalRows = additionalRows < 0 ? 0 : additionalRows;
				} else {
					additionalRows = resultSize - pagingParameter.getRowCount();
					additionalRows = additionalRows < 0 ? 0 : additionalRows;
				}

				additionalRows = additionalRows > pagingParameter.getAdditionalResultRows()
					? pagingParameter.getAdditionalResultRows()
					: additionalRows;
			}
		}
	'''
}

def static String findByNaturalKeys(RepositoryOperation it) {
	'''
		«IF (name == "findByKeys") && repository.aggregateRoot.hasNaturalKey() »
			«IF repository.aggregateRoot.getAllNaturalKeyAttributes().size == 1 && repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty»
			«findByNaturalKeys(it)(repository, repository.aggregateRoot.getAllNaturalKeyAttributes().first().getTypeName(),
				repository.aggregateRoot.getAllNaturalKeyAttributes().first().name)»
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyReferences().size == 1 && repository.aggregateRoot.getAllNaturalKeyAttributes().isEmpty»
			«findByNaturalKeys(it)(repository, repository.aggregateRoot.getAllNaturalKeyReferences().first().to.getDomainPackage() + "." + repository.aggregateRoot.getAllNaturalKeyReferences().first().to.name,
				repository.aggregateRoot.getAllNaturalKeyAttributes().first().name)»
			«ELSE»
			«findByNaturalKeys(it)(repository, repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name + (repository.aggregateRoot.gapClass ? "Base" : "") + "." + repository.aggregateRoot.name + "Key",
				"key") »
			«ENDIF»
		«ENDIF»
	'''
}

def static String findByNaturalKeys(RepositoryOperation it, Repository repository, String naturalKeyTypeName, String keyPropertyName) {
	'''
		«val fullAggregateRootName  = it.repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name»
		«val naturalKeyObjectType  = it.naturalKeyTypeName.getObjectTypeName()»
			/**
			* Find by the natural keys.
			* Delegates to {@link «genericAccessObjectInterface(name)»}
			*/
			«getVisibilityLitteral()»java.util.Map<«naturalKeyObjectType», «fullAggregateRootName»> findByNaturalKeys(java.util.Set<«naturalKeyObjectType»> naturalKeys) {
				java.util.Map<Object, «fullAggregateRootName»> result1 = findByKeys(naturalKeys«IF parameters.exists(p | p.name == "keyPropertyName")», "«keyPropertyName»"«ENDIF»«IF
				parameters.exists(p | p.name == "persistentClass")», «fullAggregateRootName».class«ENDIF»);
				// convert to Map with «naturalKeyObjectType» key type
				java.util.Map<«naturalKeyObjectType», «fullAggregateRootName»> result2 = new java.util.HashMap<«naturalKeyObjectType», «fullAggregateRootName»>();
				for (java.util.Map.Entry<Object, «fullAggregateRootName»> e : result1.entrySet()) {
			«IF isJpa1() && isJpaProviderDataNucleus()»
	        // Workaround for datanucleus, bug with @Version
			    if (entityManager != null)
					entityManager.refresh(e.getValue());
			«ENDIF»
				result2.put((«naturalKeyObjectType») e.getKey(), e.getValue());
				}
				return result2;
			}
	'''
}

def static String findByKeysSpecialCase(RepositoryOperation it) {
	'''
		«IF (name == "findByKeys") »
			«IF !parameters.exists(p | p.name == "keyPropertyName") »
			«IF repository.aggregateRoot.getAllNaturalKeyAttributes().size == 1 && repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty»
			ao.setKeyPropertyName("«repository.aggregateRoot.getAllNaturalKeyAttributes().first().name»");
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyReferences().size == 1 && repository.aggregateRoot.getAllNaturalKeyAttributes().isEmpty»
			ao.setKeyPropertyName("«repository.aggregateRoot.getAllNaturalKeyReferences().first().name»");
			«ELSE»
			ao.setKeyPropertyName("key");
			«ENDIF »
			«ENDIF »

			«IF !parameters.exists(p | p.name == "restrictionPropertyName") »
			«IF !repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty »
			ao.setRestrictionPropertyName("«repository.aggregateRoot.getAllNaturalKeyReferences().first().name».« repository.aggregateRoot.getAllNaturalKeyReferences().first().to.getAllNaturalKeyAttributes().first().name»");
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyAttributes().size > 1 »
			ao.setRestrictionPropertyName("«repository.aggregateRoot.getAllNaturalKeyAttributes().first().name»");
			«ENDIF»
			«ENDIF »
		«ENDIF »
	'''
}

def static String findByKeySpecialCase(RepositoryOperation it) {
	'''
		«IF (name == "findByKey")»
			«IF repository.aggregateRoot.hasNaturalKey() »
				ao.setKeyPropertyNames(«FOR e SEPARATOR ", " : repository.aggregateRoot.getAllNaturalKeys()»"«e.name»"«ENDFOR»);
				ao.setKeyPropertyValues(«FOR e SEPARATOR ", " : repository.aggregateRoot.getAllNaturalKeys()»«e.name»«ENDFOR»);
			«ELSEIF repository.aggregateRoot.getUuid() != null »
				ao.setKeyPropertyNames("«repository.aggregateRoot.getUuid().name»");
				ao.setKeyPropertyValues(«repository.aggregateRoot.getUuid().name»);
			«ENDIF »
		«ENDIF »
	'''
}

def static String findByKeySpecialCase2(RepositoryOperation it) {
	'''
		«val baseName  = it.repository.getRepositoryBaseName()»
		«IF (name == "findByKey") && repository.aggregateRoot.hasNaturalKey() »
	    «IF isJpa1() && isJpaProviderDataNucleus()»
	    // Workaround for datanucleus, bug with @Version
	    if (entityManager != null)
	    	entityManager.refresh(ao.getResult());
	    «ENDIF»
		«ENDIF»
	'''
}

def static String nullThrowsNotFoundExcpetion(RepositoryOperation it) {
	'''
		«IF hasNotFoundException()»
		«val baseName  = it.repository.getRepositoryBaseName()»
		if (ao.getResult() == null) {
			throw new «getExceptionPackage(repository.aggregateRoot.module)».«repository.aggregateRoot.name»NotFoundException("No «baseName» found with «parameters.get(0).name»: " + «parameters.get(0).name»);
		}
		«ENDIF»
	'''
}

def static String interfaceRepositoryMethod(RepositoryOperation it) {
	'''
		«val baseName  = it.repository.getRepositoryBaseName()»
			«formatJavaDoc()»
			public «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws»;
			«findByNaturalKeysInterfaceRepositoryMethod(it) »
	'''
}

def static String findByNaturalKeysInterfaceRepositoryMethod(RepositoryOperation it) {
	'''
		«IF (name == "findByKeys") && repository.aggregateRoot.hasNaturalKey()»
			«IF repository.aggregateRoot.getAllNaturalKeyAttributes().size == 1 && repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty»
			«findByNaturalKeysInterfaceRepositoryMethod(it)( repository.aggregateRoot.getAllNaturalKeyAttributes().get(0).getTypeName())»
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyReferences().size == 1 && repository.aggregateRoot.getAllNaturalKeyAttributes().isEmpty»
				«findByNaturalKeysInterfaceRepositoryMethod(it)( repository.aggregateRoot.getAllNaturalKeyReferences().first().to.getDomainPackage() + "." + repository.aggregateRoot.getAllNaturalKeyReferences().first().to.name)»
			«ELSE»
			«findByNaturalKeysInterfaceRepositoryMethod(it)( repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name + (repository.aggregateRoot.gapClass ? "Base" : "") + "." + repository.aggregateRoot.name + "Key") »
			«ENDIF»
		«ENDIF»
	'''
}

def static String findByNaturalKeysInterfaceRepositoryMethod(RepositoryOperation it, String naturalKeyTypeName) {
	'''
			«IF (name == "findByKeys") && repository.aggregateRoot.hasNaturalKey()»
			«val fullAggregateRootName  = it.repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name»
			«val naturalKeyObjectType  = it.naturalKeyTypeName.getObjectTypeName()»
			/**
			* Find by the natural keys.
			*/
			public java.util.Map<«naturalKeyObjectType», «fullAggregateRootName»> findByNaturalKeys(java.util.Set<«naturalKeyObjectType»> naturalKeys);
			«ENDIF»
	'''
}

def static String abstractBaseRepositoryMethod(RepositoryOperation it) {
	'''
		«val baseName  = it.repository.getRepositoryBaseName()»
			«getVisibilityLitteral()»abstract «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») « EXPAND ExceptionTmpl::throws»;
	'''
}

def static String finderMethod(RepositoryOperation it) {
	'''
		«IF isQueryBased()»
			«queryBasedFinderMethod(it)»
		«ELSE»
			«conditionBasedFinderMethod(it)»
		«ENDIF»
	'''
}

def static String queryBasedFinderMethod(RepositoryOperation it) {
	'''
			«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]»)
			«ExceptionTmpl::throws(it)» {
			«IF hasParameters()»
				java.util.Map<String, Object> parameters = new java.util.HashMap<String, Object>();
				«FOR param : parameters.reject(e|e.isPagingParameter())»
				parameters.put("«param.name»", «param.name»);
				«ENDFOR»
			«ENDIF»
			«IF collectionType != null»
				java.util.List<«getResultTypeName()»> result =
			«ELSE »
				«getResultTypeName()» result =
			«ENDIF»
				findByQuery("«buildQuery()»",«IF hasParameters()»parameters«ELSE»null«ENDIF»«IF collectionType == null»,true«ENDIF»,«getResultTypeName()».class);
			«throwNotFoundException(it)»
			«IF collectionType == "Set"»
				java.util.Set<«getResultTypeName()»> set = new java.util.HashSet<«getResultTypeName()»>();
				set.addAll(result);
				return set;
			«ELSE»
				return result;
			«ENDIF»
		}
	'''
}

def static String conditionBasedFinderMethod(RepositoryOperation it) {
	'''
			«getVisibilityLitteral()» «getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]»)
			«ExceptionTmpl::throws(it)» {
			java.util.List<«fw("accessapi.ConditionalCriteria")»> condition =
				«fw("accessapi.ConditionalCriteriaBuilder")».criteriaFor(«getAggregateRootTypeName()».class)
				    «toConditionalCriteria(buildConditionalCriteria(), getAggregateRootTypeName())»
				    .build();

			«IF collectionType != null»
				java.util.List<«getResultTypeName()»> result =
				«IF !useTupleToObjectMapping()»
				findByCondition(condition«IF isJpa2()», «getResultTypeName()».class«ENDIF»);
				«ELSE»
				new java.util.ArrayList<«getResultTypeName()»>();
				for («getResultTypeNameForMapping()» tuple : findByCondition(condition, «getResultTypeNameForMapping()».class)) {
				    result.add(«fw("accessimpl.jpa2.JpaHelper")».mapTupleToObject(tuple, «getResultTypeName()».class));
				}
				«ENDIF»
			«ELSE»
				«getResultTypeName()» result =
				«IF !useTupleToObjectMapping()»
				    findByCondition(condition, true«IF isJpa2()», «getResultTypeName()».class«ENDIF»);
				«ELSE»
				    «fw("accessimpl.jpa2.JpaHelper")».mapTupleToObject(
				        findByCondition(condition, true, «getResultTypeNameForMapping()».class), «getResultTypeName()».class);
				«ENDIF»
			«ENDIF»
			«throwNotFoundException(it)»
			«IF collectionType == "Set"»
				java.util.Set<«getResultTypeName()»> set = new java.util.HashSet<«getResultTypeName()»>();
				set.addAll(result);
				return set;
			«ELSE»
				return result;
			«ENDIF»
		}
	'''
}

def static String throwNotFoundException(RepositoryOperation it) {
	'''
		«IF throwsNotFoundException()»
			if (result == null «IF collectionType != null» || result.isEmpty()«ENDIF») {
				throw new «getNotFoundExceptionName()»("");
			}
		«ENDIF»
	'''
}

def static String subclassRepositoryMethod(RepositoryOperation it) {
	'''
		«val baseName  = it.repository.getRepositoryBaseName()»
		«repositoryMethodAnnotation(it)»
		«getVisibilityLitteral()»«getTypeName()» «name»(«it.parameters SEPARATOR ",".forEach[paramTypeAndName(it)]») {
		«IF !delegateToAccessObject»
			// TODO Auto-generated method stub
			throw new UnsupportedOperationException("«name» not implemented");
		«ELSE»
			«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessObjectName()»«getGenericType()» ao = create«getAccessObjectName()»();
		«FOR parameter : parameters»
			ao.set«parameter.name.toFirstUpper()»(«parameter.name»);
		«ENDFOR»
			ao.execute();
		«IF getTypeName() != "void" »
			return ao.getResult();
		«ENDIF»
		«ENDIF»
			}
	'''
}

def static String paramTypeAndName(Parameter it) {
	'''
	«getTypeName()» «name»
	'''
}


def static String repositoryDependencyInjectionJUnit(Repository it) {
	'''
	'''
	fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + "DependencyInjectionTest"), 'TO_GEN_SRC_TEST', '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryimplPackage()»;

/**
 * JUnit test to verify that dependency injection setter methods
 * of other Spring beans have been implemented.
 */
	public class «name»DependencyInjectionTest ^extends junit.framework.TestCase {

		«it.otherDependencies.forEach[repositoryDependencyInjectionTestMethod(it)(this)]»

	}
	'''
	)
	'''
	'''
}

/*This (String) is the name of the dependency */
def static String repositoryDependencyInjectionTestMethod(String it, Repository repository) {
	'''
		public void test«this.toFirstUpper()»Setter() throws Exception {
			Class clazz = «repository.aggregateRoot.module.getRepositoryimplPackage()».«repository.name + getSuffix("Impl")».class;
			java.lang.reflect.Method[] methods = clazz.getMethods();
			String setterMethodName = "set«this.toFirstUpper()»";
			java.lang.reflect.Method setter = null;
			for (int i = 0; i < methods.length; i++) {
				if (methods[i].getName().equals(setterMethodName) &&
				        void.class.equals(methods[i].getReturnType()) &&
				        methods[i].getParameterTypes().length == 1) {
				    setter = methods[i];
				    break;
				}
			}

			assertNotNull("Setter method for dependency injection of " +
				        "«this» must be defined in «repository.name».",
				        setter);

			«repository.aggregateRoot.module.getRepositoryimplPackage()».«repository.name + getSuffix("Impl")» «repository.name.toFirstLower()» = new «repository.aggregateRoot.module.getRepositoryimplPackage()».«repository.name + getSuffix("Impl")»();
			try {
				setter.invoke(«repository.name.toFirstLower()», new Object[] {null});
			} catch (java.lang.reflect.InvocationTargetException e) {
				if (e.getCause().getClass().equals(UnsupportedOperationException.class)) {
				    assertTrue(e.getCause().getMessage(), false);
				} else {
				    // exception due to something else, but the method was not forgotten
				}
			}

		}
	'''
}

/*Extension point to generate more stuff in repository interface.
	Use AROUND RepositoryTmpl::repositoryInterfaceHook FOR Repository
	in SpecialCases.xpt */
def static String repositoryInterfaceHook(Repository it) {
	'''
	'''
}

/*Extension point to generate more stuff in repository implementation.
	Use AROUND RepositoryTmpl::repositoryHook FOR Repository
	in SpecialCases.xpt */
def static String repositoryHook(Repository it) {
	'''
	'''
}

/*Extension point to generate annotations for repository methods.
	Use AROUND RepositoryTmpl::repositoryMethodAnnotation FOR RepositoryOperation
	in SpecialCases.xpt */
def static String repositoryMethodAnnotation(RepositoryOperation it) {
	'''
	«IF publish != null»«PubSubTmpl::publishAnnotation(it) FOR publish»«ENDIF»
	'''
}
}
