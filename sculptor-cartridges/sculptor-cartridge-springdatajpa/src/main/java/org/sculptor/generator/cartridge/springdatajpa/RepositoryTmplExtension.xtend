/*
 * Copyright 2015 The Sculptor Project Team, including the original 
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
package org.sculptor.generator.cartridge.springdatajpa

import javax.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.template.repository.RepositoryTmpl
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.OutputSlot
import sculptormetamodel.Repository
import org.sculptor.generator.ext.Properties

@ChainOverride
class RepositoryTmplExtension extends RepositoryTmpl {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension Properties properties

	override String repository(Repository it) {
		if (!jpa) {
			error("Spring Data JPA is not supported for 'jpa.provider=none'.")
		}
		if (pureEjb3) {
			error("Spring Data JPA is not supported for the project nature 'pure-ejb3'.")
		}
		if (it.gapClass) {
			error(
				"With Spring Data marking the whole repository '" + it.name + "' as gap class is not supported." +
					" Instead mark the corresponding repository methods as gap methods.")
		}
		it.operations.forEach[op|
			if (op.delegateToAccessObject) {
				error(
					"With Spring Data delegating to an access object in repository operation '" + op.name +
						"' in repository '" + op.repository.name + "' is not supported")
			} else if (!op.publicVisibility) {
				error(
					"With Spring Data non-public visibility for repository operation '" + op.name + "' in repository '" +
						op.repository.name + "' is not supported")
			}]

		// If repository methods marked as gap method then we need the custom interface and the implementation class
		val custom = it.operations.filter[hasHint("gap")].size > 0
		'''
			«it.repositoryInterface(custom)»
			«IF custom»
				«it.repositoryCustomInterface»
				«it.repositoryCustomImpl»
			«ENDIF»
		'''
	}

	private def String repositoryInterface(Repository it, boolean custom) {
		val baseName = it.getRepositoryBaseName

		fileOutput(
			javaFileName(aggregateRoot.module.getRepositoryapiPackage + "." + name),
			OutputSlot.TO_GEN_SRC,
			'''
				«javaHeader»
				package «aggregateRoot.module.getRepositoryapiPackage»;
				
				/// Sculptor code formatter imports ///
				
				«IF it.formatJavaDoc == ""»
					/**
					 * Generated interface for Repository of «baseName»
					 */
				«ELSE»
					«it.formatJavaDoc»
				«ENDIF»
				public interface «name» extends org.springframework.data.jpa.repository.JpaRepository<«baseName», «getJavaType("IDTYPE")»>«IF custom»,
					«aggregateRoot.module.getRepositoryapiPackage».«name»Custom«ENDIF»«IF subscribe !== null»,
					«fw("event.EventSubscriber")»«ENDIF» {
					
						«it.operations.filter[isPublicVisibility && !hasHint("gap")].map[interfaceRepositoryMethod(it)].join»
					}
				'''
		)
	}

	private def String repositoryCustomInterface(Repository it) {
		val baseName = it.getRepositoryBaseName
		val className = name + "Custom"

		fileOutput(
			javaFileName(aggregateRoot.module.getRepositoryapiPackage + "." + className),
			OutputSlot.TO_GEN_SRC,
			'''
				«javaHeader»
				package «aggregateRoot.module.getRepositoryapiPackage»;
				
				/// Sculptor code formatter imports ///
				
				«IF it.formatJavaDoc == ""»
					/**
					 * Generated custom interface for Repository of «baseName»
					 */
				«ELSE»
					«it.formatJavaDoc»
				«ENDIF»
				public interface «className» {
				
					«it.operations.filter[isPublicVisibility && hasHint("gap")].map[interfaceRepositoryMethod(it)].join»
				}
			'''
		)
	}

	private def String repositoryCustomImpl(Repository it) {
		val baseName = it.getRepositoryBaseName
		val className = name + getSuffix("Impl")

		fileOutput(
			javaFileName(aggregateRoot.module.getRepositoryimplPackage + "." + className),
			OutputSlot.TO_SRC,
			'''
				«javaHeader»
				package «aggregateRoot.module.getRepositoryimplPackage»;
				
				/// Sculptor code formatter imports ///
				
				/**
				 * Repository custom implementation for «baseName»
				 */
				public class «className» implements «aggregateRoot.module.getRepositoryapiPackage».«name»Custom {
				
					public «className»() {
					}
				
					«repositoryDependencies(it)»
					«otherDependencies(it)»
				
					«it.operations.filter[isPublicVisibility && hasHint("gap")].map[subclassRepositoryMethod(it)].join»
				
				}
			'''
		)
	}

}
