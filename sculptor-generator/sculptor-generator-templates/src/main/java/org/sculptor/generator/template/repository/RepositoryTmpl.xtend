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

package org.sculptor.generator.template.repository

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.common.ExceptionTmpl
import org.sculptor.generator.template.common.PubSubTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Attribute
import sculptormetamodel.Parameter
import sculptormetamodel.Reference
import sculptormetamodel.Repository
import sculptormetamodel.RepositoryOperation

@ChainOverridable
class RepositoryTmpl {

	@Inject private var ExceptionTmpl exceptionTmpl
	@Inject private var PubSubTmpl pubSubTmpl
	@Inject private var AccessObjectFactoryTmpl accessObjectFactoryTmpl

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

def String repository(Repository it) {
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

def String repositoryInterface(Repository it) {
	val baseName  = it.getRepositoryBaseName()

	fileOutput(javaFileName(aggregateRoot.module.getRepositoryapiPackage() + "." + name), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryapiPackage()»;

/// Sculptor code formatter imports ///

	«IF it.formatJavaDoc() == "" »
		/**
		 * Generated interface for Repository for «baseName»
		 */
	«ELSE »
		«it.formatJavaDoc()»
	«ENDIF »
	«IF pureEjb3()»
	@javax.ejb.Local
	«ENDIF »
	public interface «name» «IF subscribe != null»extends «fw("event.EventSubscriber")» «ENDIF» {

		«IF isSpringToBeGenerated()»
			public final static String BEAN_ID = "«name.toFirstLower()»";
		«ENDIF»

		«it.operations.filter(op | op.isPublicVisibility()).map[interfaceRepositoryMethod(it)].join()»

		«repositoryInterfaceHook(it)»
	}
	'''
	)
}

def String repositoryBase(Repository it) {
	val baseName  = it.getRepositoryBaseName()

	fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + (if (gapClass) "Base" else getSuffix("Impl"))), OutputSlot::TO_GEN_SRC, '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryimplPackage()»;

/// Sculptor code formatter imports ///

	«IF gapClass»
		/**
		 * Generated base class for implementation of Repository for «baseName»
		«IF isSpringToBeGenerated()»
			«»
			 * <p>Make sure that subclass defines the following annotations:
			 * <pre>
			     @org.springframework.stereotype.Repository("«name.toFirstLower()»")
			 * </pre>
			 *
		 «ENDIF »
		«IF pureEjb3()»
			«»
			 * <p>Make sure that subclass defines the following annotations:
			 * <pre>
			    @javax.ejb.Stateless(name="«name.toFirstLower()»")
			 * </pre>
			 *
		«ENDIF»
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
	«IF subscribe != null»«pubSubTmpl.subscribeAnnotation(it.subscribe)»«ENDIF»
	public «IF gapClass»abstract «ENDIF»class «name»«if (gapClass) "Base" else getSuffix("Impl")» «it.extendsLitteral()»
		implements «aggregateRoot.module.getRepositoryapiPackage()».«name» {

		public «name»«if (gapClass) "Base" else getSuffix("Impl")»() {
		}

		«fetchEagerFields»
		«repositoryDependencies(it)»

		«it.operations.filter(op | op.delegateToAccessObject && !op.isGenericAccessObject()).map[op | baseRepositoryMethod(op)].join()»
		«it.operations.filter(op | op.isGenericAccessObject()).filter(e|!e.hasPagingParameter()).map[op | genericBaseRepositoryMethod(op)].join()»
		«it.operations.filter(op | op.isGenericAccessObject() && op.hasPagingParameter()).map[op | pagedGenericBaseRepositoryMethod(op)].join()»

		«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && !op.isGeneratedFinder()).map[op | abstractBaseRepositoryMethod(op)].join()»
		«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && op.isGeneratedFinder()).map[op | finderMethod(op)].join()»

		«IF jpa()»
			«entityManagerDependency(it) »
		«ENDIF»
	
		«extraRepositoryBaseDependencies»
		
		«accessObjectFactory(it)»
	
		«repositoryHook(it)»
	
	}
	'''
	)
}

/**
 * Any extra dependencies needed for specific types of repositories.  To be provided by cartridges.
 */
def String extraRepositoryBaseDependencies(Repository it) {
	""
}

def String accessObjectFactory(Repository it) {
	'''
	«it.distinctOperations.filter(op | op.isGenericAccessObject()).map[op | accessObjectFactoryTmpl.genericFactoryMethod(op)].join()»
	«it.distinctOperations.filter(op | op.delegateToAccessObject && !op.isGenericAccessObject()).map[op | accessObjectFactoryTmpl.factoryMethod(op)].join()»
	«accessObjectFactoryTmpl.getPersistentClass(it)»
	'''
}

def String entityManagerDependency(Repository it) {
	'''
		@javax.persistence.PersistenceContext«IF it.persistenceContextUnitName() != ""»(unitName = "«it.persistenceContextUnitName()»")«ENDIF»
		private javax.persistence.EntityManager entityManager;

		/**
		 * Dependency injection
		 */
		@javax.persistence.PersistenceContext«IF it.persistenceContextUnitName() != ""»(unitName = "«it.persistenceContextUnitName()»")«ENDIF»
		protected void setEntityManager(javax.persistence.EntityManager entityManager) {
			this.entityManager = entityManager;
		}

		protected javax.persistence.EntityManager getEntityManager() {
			return entityManager;
		}
	'''
}

def String fetchEagerFields(Repository it) {
	'''
	«IF operations.exists(e | e.hasHint("useFetchEager"))»
		«fw("domain.Property")»<?>[] eagerFields={
			«FOR e : aggregateRoot.references.filter[r | !r.many && !r.isBasicTypeReference() && !r.isEnumReference()] SEPARATOR ", "»«getDomainPackage(aggregateRoot)».«aggregateRoot.name»Properties.«e.name»()«ENDFOR»
		};
	«ENDIF»
	'''
}

def String repositoryDependencies(Repository it) {
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

def String repositorySubclass(Repository it) {
	val baseName  = it.getRepositoryBaseName()

	fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + getSuffix("Impl")), OutputSlot::TO_SRC, '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryimplPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * Repository implementation for «baseName»
	 */
	«IF isSpringToBeGenerated()»
	@org.springframework.stereotype.Repository("«name.toFirstLower()»")
	«ENDIF»
	«IF pureEjb3()»
	@javax.ejb.Stateless(name="«name.toFirstLower()»")
	«ENDIF»
	public class «name + getSuffix("Impl")» extends «name»Base {

		public «name + getSuffix("Impl")»() {
		}

		«otherDependencies(it)»

		«it.operations.filter(op | !op.delegateToAccessObject && !op.isGenericAccessObject() && !op.isGeneratedFinder()).map[subclassRepositoryMethod(it)].join()»

	}
	'''
	)
}

def String otherDependencies(Repository it) {
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

def String baseRepositoryMethod(RepositoryOperation it) {
	val pagingParameter  = it.getPagingParameter()

	'''
	/**
	 * Delegates to {@link «getAccessapiPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»}
	 */
	«repositoryMethodAnnotation(it)»
	«IF it.useGenericAccessStrategy()»
		«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[p | paramTypeAndName(p)].join(",")») «exceptionTmpl.throwsDecl(it)» {
			return «name»(«it.parameters.map[paramTypeAndName(it)].join(",")», getPersistentClass());
		}
		«it.getVisibilityLitteral()» <R> «it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")», Class<R> resultType) «exceptionTmpl.throwsDecl(it)» {
	«ELSE»
		«it.getVisibilityLitteral()»«it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)» {
	«ENDIF»
		«IF it.useGenericAccessStrategy()»
			«IF name != "findByExample"»
				«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»2«it.getGenericType()» ao = create«getAccessNormalizedName()»(resultType);
			«ELSE»
				«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»2<«it.getAggregateRootTypeName()», R> ao = create«getAccessNormalizedName()»(getPersistentClass(), resultType);
			«ENDIF»
		«ELSE»
			«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»«it.getGenericType()» ao = create«getAccessNormalizedName()»();
		«ENDIF»
		«setCache(it)»
		«setEagerColumns(it)»
		«setOrdered(it)»
		«FOR parameter : parameters.filter(e | e != pagingParameter)»
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

		«IF it.isPagedResult()»
			«it.getAccessObjectResultTypeName()» result = ao.getResult();

			«calculateMaxPages(it)»
	
			«it.getTypeName()» pagedResult = new «it.getTypeName()»(result
				, pagingParameter.getStartRow()
				, pagingParameter.getRowCount()
				, pagingParameter.getPageSize()
				, rowCount
				, additionalRows);
			return pagedResult;
		«ELSEIF it.getTypeName() != "void" »
			return ao.getResult();
		«ENDIF»
	}
	'''
}

def String setCache(RepositoryOperation it) {
	'''
		«IF it.hasHint("cache")»
			ao.setCache(true);
		«ENDIF»
	'''
}

def String setEagerColumns (RepositoryOperation it) {
	'''
		«IF it.hasHint("useFetchEager")»
			ao.setFetchEager(eagerFields);
		«ENDIF»
	'''
}

def String setOrdered(RepositoryOperation it) {
	'''
		«/* JPA2 supports multiple ordering columns, e.g. hint="orderBy=col1 asc, col2 desc" */»
		«IF jpa()»
			«IF it.hasHint("orderBy")»
				ao.setOrderBy("«it.getHint("orderBy",";")»");
			«ENDIF»
		«ELSE»
			«IF it.hasHint("orderBy")»
				ao.setOrderBy("«it.getHint("orderBy")»");
			«ENDIF»
		«ENDIF»
	'''
}

def String setQueryHint(RepositoryOperation it) {
	'''
		« /* TODO: complete queryHint */ »
		«IF it.hasHint("queryHint")»
			ao.setHint("«it.getHint("queryHint")»);
		«ENDIF»
	'''
}

def String genericBaseRepositoryMethod(RepositoryOperation it) {
	'''
		/**
		 * Delegates to {@link «genericAccessObjectInterface(name)»}
		 */
		«repositoryMethodAnnotation(it)»
		«IF it.useGenericAccessStrategy()»
			«it.getVisibilityLitteral()»«it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)» {
				return «name»(«FOR param : parameters SEPARATOR ","»«param.name»«ENDFOR»«IF it.hasParameters()»,«ENDIF»getPersistentClass());
			}

			«it.getVisibilityLitteral()» <R> «it.getGenericResultTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")»«IF it.hasParameters()»,«ENDIF» Class<R> resultType) «exceptionTmpl.throwsDecl(it)» {
		«ELSE»
			«it.getVisibilityLitteral()»«it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)» {
		«ENDIF»

			«/* TODO:implement a better solution */»
			«IF it.useGenericAccessStrategy()»
				«IF name != "findByExample"»
					«genericAccessObjectInterface(name)»2<R> ao = create«getAccessNormalizedName()»(resultType);
				«ELSE»
					«genericAccessObjectInterface(name)»2<«it.getAggregateRootTypeName()»,R> ao = create«getAccessNormalizedName()»(«it.getAggregateRootTypeName()».class, resultType);
				«ENDIF»
			«ELSE»
				«genericAccessObjectInterface(name)»«it.getGenericType()» ao = create«getAccessNormalizedName()»();
			«ENDIF»
			«setCache(it)»
			«setEagerColumns(it)»
			«setOrdered(it)»
			«IF it.hasHint("useSingleResult")»
				ao.setUseSingleResult(true);
			«ENDIF»
			«IF name != "findByKey"»
				«/* TODO: why do you need to remove persistentClass from parameter list? */»
				«FOR parameter : parameters.filter[e | !(jpa() && e.name == "persistentClass")]»
					ao.set«parameter.name.toFirstUpper()»(«parameter.name»);
				«ENDFOR»
			«ENDIF»
			«findByKeysSpecialCase(it)»
			«findByKeySpecialCase(it)»
			ao.execute();
			«IF it.getTypeName() != "void" »
				«nullThrowsNotFoundExcpetion(it)»
				«IF (parameters.exists(e|e.name == "useSingleResult") || it.hasHint("useSingleResult")) && it.collectionType == null»
					return «IF !jpa() && it.getTypeName() != "Object"»(«it.getTypeName().getObjectTypeName()») «ENDIF»ao.getSingleResult();
				«ELSE»
					return ao.getResult();
				«ENDIF»
			«ENDIF»
		}
		«findByNaturalKeys(it) »
	'''
}

def String pagedGenericBaseRepositoryMethod(RepositoryOperation it) {
	val pagingParameter = it.getPagingParameter()

	'''
	«repositoryMethodAnnotation(it)»
	«it.getVisibilityLitteral()»«it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)» {
		«IF it.useGenericAccessStrategy()»
			«genericAccessObjectInterface(name)»2«it.getGenericType()» ao = create«getAccessNormalizedName()»();
		«ELSE»
			«genericAccessObjectInterface(name)»«it.getGenericType()» ao = create«getAccessNormalizedName()»();
		«ENDIF»
		«setCache(it)»
		«setEagerColumns(it)»
		«setOrdered(it)»
		«FOR parameter : parameters.filter(e | e != pagingParameter)»
		ao.set«parameter.name.toFirstUpper()»(«parameter.name»);
		«ENDFOR»

		if («pagingParameter.name».getStartRow() != «fw("domain.PagedResult")».UNKNOWN
				&& «pagingParameter.name».getRealFetchCount() != «fw("domain.PagedResult")».UNKNOWN) {
			ao.setFirstResult(«pagingParameter.name».getStartRow());
			ao.setMaxResult(«pagingParameter.name».getRealFetchCount());
		}

		ao.execute();
		«IF it.isPagedResult()»
			«it.getAccessObjectResultTypeName()» result = ao.getResult();
			«calculateMaxPages(it)»
	
			«it.getTypeName()» pagedResult = new «it.getTypeName()»(result
					, pagingParameter.getStartRow()
					, pagingParameter.getRowCount()
					, pagingParameter.getPageSize()
					, rowCount
					, additionalRows);
			return pagedResult;
		«ELSEIF it.getTypeName() != "void" »
			return ao.getResult();
		«ENDIF»
	}
	«findByNaturalKeys(it) »
	'''
}

def String calculateMaxPages(RepositoryOperation it) {
	val pagingParameter  = it.getPagingParameter()
	val countOperationHint = it.getHint("countOperation")
	val countQueryHint = it.getHint("countQuery")

	'''
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
					«val countOperation = it.repository.operations.findFirst(e | e != it && e.name == countOperationHint)»
						«IF countOperation == null»
							Long countNumber = «countOperationHint»«IF !countOperationHint.endsWith(")")»()«ENDIF»;
						«ELSE»
							Long countNumber = «countOperation.name»(«FOR param : countOperation.parameters SEPARATOR ", "»«IF parameters.exists(e|e.name == param.name)»«param.name»«ELSE»null«ENDIF»«ENDFOR»);
						«ENDIF»
				«ELSEIF countQueryHint != null»
					«val countOperation1 = it.repository.operations.findFirst(e | e != it && e.name == "findByQuery" && e.parameters.exists(p | p.name == "useSingleResult"))»
					«val countOperation2 = it.repository.operations.findFirst(e | e != it && e.name == "findByQuery")»
					«val countOperation = if (countOperation1 != null) countOperation1 else countOperation2»
					«IF countOperation == null»
						// TODO define findByQuery
						Long countNumber = null;
					«ELSE»
						«IF !parameters.exists(e|e.name == "parameters") && countOperation.parameters.exists(e|e.name == "parameters")»
						java.util.Map<String, Object> parameters = new java.util.HashMap<String, Object>();
						«FOR param  : parameters.filter(e | !e.isPagingParameter())»
							parameters.put("«param.name»", «param.name»);
						«ENDFOR»
						«ENDIF»
						Long countNumber = «IF countOperation.getTypeName() == "Object"»(Long) «ENDIF»
							«countOperation.name»(«FOR param : countOperation.parameters SEPARATOR ", "»«IF param.name == "query" || param.name == "namedQuery"»«IF countQueryHint == null»«param.name».replaceFirst("find", "count")«ELSE»"«countQueryHint»"«ENDIF»«
							ELSEIF param.name == "useSingleResult"»true« ELSEIF param.name == "parameters"»parameters«
							ELSEIF parameters.exists(e|e.name == param.name)»«param.name»« ELSE»null«ENDIF»«ENDFOR»)«IF countOperation1 == null».size()«ENDIF»;
					«ENDIF»
					«ELSEIF (it.useGenericAccessStrategy())»
						// If you need an alternative way to calculate max pages you could define hint="countOperation=..." or hint="countQuery=..."
						ao.executeResultCount();
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

def String findByNaturalKeys(RepositoryOperation it) {
	'''
		«IF (name == "findByKeys") && repository.aggregateRoot.hasNaturalKey() »
			«IF repository.aggregateRoot.getAllNaturalKeyAttributes().size == 1 && repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty»
				«val Attribute naturalAttr = repository.aggregateRoot.getAllNaturalKeyAttributes().head»
				«findByNaturalKeys(it, repository, naturalAttr.getTypeName(), naturalAttr.name)»
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyReferences().size == 1 && repository.aggregateRoot.getAllNaturalKeyAttributes().isEmpty»
				«val Reference naturalKey = repository.aggregateRoot.getAllNaturalKeyReferences().head»
				«findByNaturalKeys(it, repository, naturalKey.to.getDomainPackage() + "." + naturalKey.to.name, naturalKey.name)»
			«ELSE»
				«findByNaturalKeys(it, repository, repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name + (if (repository.aggregateRoot.gapClass) "Base" else "") + "." + repository.aggregateRoot.name + "Key", "key") »
			«ENDIF»
		«ENDIF»
	'''
}

def String findByNaturalKeys(RepositoryOperation it, Repository repository, String naturalKeyTypeName, String keyPropertyName) {
	val fullAggregateRootName  = it.repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name
	val naturalKeyObjectType  = naturalKeyTypeName.getObjectTypeName()
	'''
		/**
		 * Find by the natural keys.
		 * Delegates to {@link «genericAccessObjectInterface(name)»}
		 */
		«it.getVisibilityLitteral()»java.util.Map<«naturalKeyObjectType», «fullAggregateRootName»> findByNaturalKeys(java.util.Set<«naturalKeyObjectType»> naturalKeys) {
			java.util.Map<Object, «fullAggregateRootName»> result1 = findByKeys(naturalKeys«IF parameters.exists(p | p.name == "keyPropertyName")», "«keyPropertyName»"«ENDIF»«IF
			parameters.exists(p | p.name == "persistentClass")», «fullAggregateRootName».class«ENDIF»);
			// convert to Map with «naturalKeyObjectType» key type
			java.util.Map<«naturalKeyObjectType», «fullAggregateRootName»> result2 = new java.util.HashMap<«naturalKeyObjectType», «fullAggregateRootName»>();
			for (java.util.Map.Entry<Object, «fullAggregateRootName»> e : result1.entrySet()) {
				result2.put((«naturalKeyObjectType») e.getKey(), e.getValue());
			}
			return result2;
		}
	'''
}

def String findByKeysSpecialCase(RepositoryOperation it) {
	'''
		«IF (name == "findByKeys") »
			«IF !parameters.exists(p | p.name == "keyPropertyName") »
			«IF repository.aggregateRoot.getAllNaturalKeyAttributes().size == 1 && repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty»
			ao.setKeyPropertyName("«repository.aggregateRoot.getAllNaturalKeyAttributes().head.name»");
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyReferences().size == 1 && repository.aggregateRoot.getAllNaturalKeyAttributes().isEmpty»
			ao.setKeyPropertyName("«repository.aggregateRoot.getAllNaturalKeyReferences().head.name»");
			«ELSE»
			ao.setKeyPropertyName("key");
			«ENDIF »
			«ENDIF »

			«IF !parameters.exists(p | p.name == "restrictionPropertyName") »
			«IF !repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty »
			ao.setRestrictionPropertyName("«repository.aggregateRoot.getAllNaturalKeyReferences().head.name».« repository.aggregateRoot.getAllNaturalKeyReferences().head.to.getAllNaturalKeyAttributes().head.name»");
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyAttributes().size > 1 »
			ao.setRestrictionPropertyName("«repository.aggregateRoot.getAllNaturalKeyAttributes().head.name»");
			«ENDIF»
			«ENDIF »
		«ENDIF »
	'''
}

def String findByKeySpecialCase(RepositoryOperation it) {
	'''
		«IF (name == "findByKey")»
			«IF repository.aggregateRoot.hasNaturalKey() »
				ao.setKeyPropertyNames(«FOR e : repository.aggregateRoot.getAllNaturalKeys() SEPARATOR ", "»"«e.name»"«ENDFOR»);
				ao.setKeyPropertyValues(«FOR e : repository.aggregateRoot.getAllNaturalKeys() SEPARATOR ", "»«e.name»«ENDFOR»);
			«ELSEIF repository.aggregateRoot.getUuid() != null »
				ao.setKeyPropertyNames("«repository.aggregateRoot.getUuid().name»");
				ao.setKeyPropertyValues(«repository.aggregateRoot.getUuid().name»);
			«ENDIF »
		«ENDIF »
	'''
}

def String nullThrowsNotFoundExcpetion(RepositoryOperation it) {
	'''
		«IF it.hasNotFoundException()»
		«val baseName  = it.repository.getRepositoryBaseName()»
		if (ao.getResult() == null) {
			throw new «getExceptionPackage(repository.aggregateRoot.module)».«repository.aggregateRoot.name»NotFoundException("No «baseName» found with «parameters.get(0).name»: " + «parameters.get(0).name»);
		}
		«ENDIF»
	'''
}

def String interfaceRepositoryMethod(RepositoryOperation it) {
	'''
		«it.formatJavaDoc()»
		public «it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)»;
		«findByNaturalKeysInterfaceRepositoryMethod(it) »
	'''
}

def String findByNaturalKeysInterfaceRepositoryMethod(RepositoryOperation it) {
	'''
		«IF (name == "findByKeys") && repository.aggregateRoot.hasNaturalKey()»
			«IF repository.aggregateRoot.getAllNaturalKeyAttributes().size == 1 && repository.aggregateRoot.getAllNaturalKeyReferences().isEmpty»
			«findByNaturalKeysInterfaceRepositoryMethod(it,  repository.aggregateRoot.getAllNaturalKeyAttributes().get(0).getTypeName())»
			«ELSEIF repository.aggregateRoot.getAllNaturalKeyReferences().size == 1 && repository.aggregateRoot.getAllNaturalKeyAttributes().isEmpty»
				«findByNaturalKeysInterfaceRepositoryMethod(it,  repository.aggregateRoot.getAllNaturalKeyReferences().head.to.getDomainPackage() + "." + repository.aggregateRoot.getAllNaturalKeyReferences().head.to.name)»
			«ELSE»
			«findByNaturalKeysInterfaceRepositoryMethod(it,  repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name + (if (repository.aggregateRoot.gapClass) "Base" else "") + "." + repository.aggregateRoot.name + "Key") »
			«ENDIF»
		«ENDIF»
	'''
}

def String findByNaturalKeysInterfaceRepositoryMethod(RepositoryOperation it, String naturalKeyTypeName) {
	'''
		«IF (name == "findByKeys") && repository.aggregateRoot.hasNaturalKey()»
		«val fullAggregateRootName  = it.repository.aggregateRoot.getDomainPackage() + "." + repository.aggregateRoot.name»
		«val naturalKeyObjectType  = naturalKeyTypeName.getObjectTypeName()»
		/**
		 * Find by the natural keys.
		 */
		public java.util.Map<«naturalKeyObjectType», «fullAggregateRootName»> findByNaturalKeys(java.util.Set<«naturalKeyObjectType»> naturalKeys);
		«ENDIF»
	'''
}

def String abstractBaseRepositoryMethod(RepositoryOperation it) {
	'''
		«it.getVisibilityLitteral()»abstract «it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")») «exceptionTmpl.throwsDecl(it)»;
	'''
}

def String finderMethod(RepositoryOperation it) {
	'''
		«IF it.isQueryBased()»
			«queryBasedFinderMethod(it)»
		«ELSE»
			«conditionBasedFinderMethod(it)»
		«ENDIF»
	'''
}

def String queryBasedFinderMethod(RepositoryOperation it) {
	'''
			«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")»)
			«exceptionTmpl.throwsDecl(it)» {
			«IF it.hasParameters()»
				java.util.Map<String, Object> parameters = new java.util.HashMap<String, Object>();
				«FOR param : parameters.filter(e|!e.isPagingParameter())»
				parameters.put("«param.name»", «param.name»);
				«ENDFOR»
			«ENDIF»
			«IF collectionType != null»
				java.util.List<«it.getResultTypeName()»> result =
			«ELSE »
				«it.getResultTypeName()» result =
			«ENDIF»
				findByQuery("«it.buildQuery()»",«IF it.hasParameters()»parameters«ELSE»null«ENDIF»«IF collectionType == null»,true«ENDIF»,«it.getResultTypeName()».class);
			«throwNotFoundException(it)»
			«IF collectionType == "Set"»
				java.util.Set<«it.getResultTypeName()»> set = new java.util.HashSet<«it.getResultTypeName()»>();
				set.addAll(result);
				return set;
			«ELSE»
				return result;
			«ENDIF»
		}
	'''
}

def String conditionBasedFinderMethod(RepositoryOperation it) {
	val pagingParameter  = it.getPagingParameter()
	'''
			«it.getVisibilityLitteral()» «it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(",")»)
			«exceptionTmpl.throwsDecl(it)» {
			java.util.List<«fw("accessapi.ConditionalCriteria")»> condition =
				«fw("accessapi.ConditionalCriteriaBuilder")».criteriaFor(«it.getAggregateRootTypeName()».class)
				    «toConditionalCriteria(it.buildConditionalCriteria(), it.getAggregateRootTypeName())»
				    .build();

			«IF collectionType != null»
				java.util.List<«it.getResultTypeName()»> result =
				«IF !it.useTupleToObjectMapping()»
					findByCondition(condition«
						IF properties.getBooleanProperty("findByCondition.paging") && pagingParameter == null
							», PagingParameter.noLimits()).getValues();«
						ELSEIF properties.getBooleanProperty("findByCondition.paging") && pagingParameter != null
							», «pagingParameter.name»).getValues();«
						ELSE»«
							IF jpa()», «it.getResultTypeName()».class«ENDIF»);«
						ENDIF»
				«ELSE»
					new java.util.ArrayList<«it.getResultTypeName()»>();
					for («it.getResultTypeNameForMapping()» tuple : findByCondition(condition, «it.getResultTypeNameForMapping()».class)) {
						result.add(«fw("accessimpl.jpa.JpaHelper")».mapTupleToObject(tuple, «it.getResultTypeName()».class));
					}
				«ENDIF»
			«ELSE»
				«it.getResultTypeName()» result =
				«IF !it.useTupleToObjectMapping()»
						findByCondition(condition, true«
						IF properties.getBooleanProperty("findByCondition.paging") && pagingParameter == null
							», new PagingParameter.rowAccess(0,1));«
						ELSEIF properties.getBooleanProperty("findByCondition.paging") && pagingParameter != null
							», «pagingParameter.name»);«
						ELSE»«
							IF jpa()», «it.getResultTypeName()».class«ENDIF»);
						«ENDIF»
				«ELSE»
					«fw("accessimpl.jpa.JpaHelper")».mapTupleToObject(
						findByCondition(condition, true, «it.getResultTypeNameForMapping()».class), «it.getResultTypeName()».class);
				«ENDIF»
			«ENDIF»
			«throwNotFoundException(it)»
			«IF collectionType == "Set"»
				java.util.Set<«it.getResultTypeName()»> set = new java.util.HashSet<«it.getResultTypeName()»>();
				set.addAll(result);
				return set;
			«ELSE»
				return result;
			«ENDIF»
		}
	'''
}

def String throwNotFoundException(RepositoryOperation it) {
	'''
		«IF it.throwsNotFoundException()»
			if (result == null «IF collectionType != null» || result.isEmpty()«ENDIF») {
				throw new «it.getNotFoundExceptionName(true)»("");
			}
		«ENDIF»
	'''
}

def String subclassRepositoryMethod(RepositoryOperation it) {
	'''
		«repositoryMethodAnnotation(it)»
		«it.getVisibilityLitteral()»«it.getTypeName()» «name»(«it.parameters.map[paramTypeAndName(it)].join(", ")») {
			«IF !delegateToAccessObject»
				// TODO Auto-generated method stub
				throw new UnsupportedOperationException("«name» not implemented");
			«ELSE»
				«getAccessapiPackage(repository.aggregateRoot.module)».«getAccessNormalizedName()»«getGenericType()» ao = create«getAccessNormalizedName»();
				«FOR parameter : parameters»
					ao.set«parameter.name.toFirstUpper()»(«parameter.name»);
				«ENDFOR»
				ao.execute();
				«IF it.getTypeName() != "void" »
					return ao.getResult();
				«ENDIF»
			«ENDIF»
		}
	'''
}

def String repositoryMethodAnnotation(RepositoryOperation it) {
	'''
		«IF publish != null»«pubSubTmpl.publishAnnotation(it.publish)»«ENDIF»
		«repositoryMethodAnnotationHook(it)»
	'''
}

def String repositoryDependencyInjectionJUnit(Repository it) {
	fileOutput(javaFileName(aggregateRoot.module.getRepositoryimplPackage() + "." + name + "DependencyInjectionTest"), OutputSlot::TO_GEN_SRC_TEST, '''
	«javaHeader()»
	package «aggregateRoot.module.getRepositoryimplPackage()»;

/// Sculptor code formatter imports ///

	/**
	 * JUnit test to verify that dependency injection setter methods
	 * of other Spring beans have been implemented.
	 */
	public class «name»DependencyInjectionTest extends junit.framework.TestCase {

		«it.otherDependencies.map[d | repositoryDependencyInjectionTestMethod(d, it)].join()»

	}
	'''
	)
}

/*
 * This (String) is the name of the dependency
 */
def String repositoryDependencyInjectionTestMethod(String it, Repository repository) {
	'''
		public void test«it.toFirstUpper()»Setter() throws Exception {
			Class clazz = «repository.aggregateRoot.module.getRepositoryimplPackage()».«repository.name + getSuffix("Impl")».class;
			java.lang.reflect.Method[] methods = clazz.getMethods();
			String setterMethodName = "set«it.toFirstUpper()»";
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
					"«it» must be defined in «repository.name».",
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

def String paramTypeAndName(Parameter it) {
	'''«it.getTypeName()» «name»'''
}

/*
 * Extension point to generate more stuff in repository interface.
 */
def String repositoryInterfaceHook(Repository it) {
	""
}

/*
 * Extension point to generate more stuff in repository implementation.
 */
def String repositoryHook(Repository it) {
	""
}

/*
 * Extension point to generate more annotations for repository methods.
 */
def String repositoryMethodAnnotationHook(RepositoryOperation it) {
	""
}

}
