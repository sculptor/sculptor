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

package org.sculptor.dsl.validation

import org.eclipse.xtext.validation.Check
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslSimpleDomainObject
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslModule
import org.sculptor.dsl.sculptordsl.DslAttribute
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslServiceOperation
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslParameter

import static org.sculptor.dsl.sculptordsl.SculptordslPackage$Literals.*

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.sculptor.dsl.SculptordslExtensions.*
import org.sculptor.dsl.sculptordsl.DslCollectionType

class SculptordslXtendValidator extends SculptordslJavaValidator {

	@Check
	def checkDomainObjectDuplicateName(DslSimpleDomainObject obj) {
		if (obj.name != null && obj.rootContainer.eAllOfClass(typeof(DslSimpleDomainObject)).filter [it.name == obj.name].size > 1) {
			error("Duplicate name.  There is already an existing Domain Object named '"
				+ obj.name + "'.", DSL_SIMPLE_DOMAIN_OBJECT__NAME, obj.name
			);  
		}
	}

	@Check
	def checkServiceDuplicateName(DslService service) {
		if (service.name != null && service.rootContainer.eAllOfType(typeof(DslService)).filter [it.name == service.name].size > 1) {
			error("Duplicate name.  There is already an existing Service named '"
				+ service.name + "'.", DSL_SERVICE_REPOSITORY_OPTION__NAME, service.name
			);  
		}
	}

	@Check
	def checkRepositoryDuplicateName(DslRepository repository) {
		if (repository.name != null && repository.rootContainer.eAllOfClass(typeof(DslRepository)).filter [it.name == repository.name].size > 1) {
			error("Duplicate name.  There is already an existing Repository named '"
				+ repository.name + "'.", DSL_SERVICE_REPOSITORY_OPTION__NAME, repository.name
			);  
		}
	}

	@Check
	def checkModuleDuplicateName(DslModule module) {
		if (module.name != null && module.rootContainer.eAllOfClass(typeof(DslModule)).filter [it.name == module.name].size > 1) {
			error("Duplicate name.  There is already an existing Module named '"
				+ module.name + "'.", DSL_MODULE__NAME, module.name
			);  
		}
	}
	
	@Check
	def checkApplicationDuplicateName(DslApplication app) {
		if (app.name != null && app.rootContainer.eAllOfClass(typeof(DslApplication)).filter [it.name == app.name].size > 1) {
			error("Duplicate name.  There is already an existing Application named '"
				+ app.name + "'.", DSL_APPLICATION__NAME, app.name
			);  
		}
	}

	/**
	 * Type matches a domain object, but due to missing '-', comes in as a DslAttribute rather than a DslReference
	 */
	@Check
	def checkMissingReferenceNotationWithNoCollection(DslAttribute attr) {
		if(attr.type != null && attr.collectionType == DslCollectionType::NONE &&
			attr.domainObjectsForAttributeType.empty == false) {
			warning("Use - " + attr.type, DSL_ATTRIBUTE__TYPE, attr.type)
		}
	}

	/**
	 * Type for collection matches a domain object, but due to missing '-', comes in as a DslAttribute rather than a DslReference
	 */
	@Check
	def checkMissingReferenceNotationWithCollection(DslAttribute attr) {
		if(attr.type != null && attr.collectionType != DslCollectionType::NONE &&
			attr.domainObjectsForAttributeType.empty == false) {
			warning("Use - " + attr.collectionType + "<" + attr.type + ">", DSL_ATTRIBUTE__TYPE, attr.type)
		}
	}

	@Check
	def checkMissingDomainObjectInServiceOperationReturnType(DslServiceOperation it) {
		if(returnType != null && returnType.domainObjectType == null && returnType.type != null &&
		   returnType.firstDomainObjectForType != null) {
			warning("Use @" + returnType.type, DSL_SERVICE_OPERATION__RETURN_TYPE, returnType.type)
		}
	}

	@Check
	def checkMissingDomainObjectInRepositoryOperationReturnType(DslRepositoryOperation it) {
		if(returnType != null && returnType.domainObjectType == null && returnType.type != null &&
		   returnType.firstDomainObjectForType != null) {
			warning("Use @" + returnType.type, DSL_REPOSITORY_OPERATION__RETURN_TYPE, returnType.type)
		}
	}

	@Check
	def checkMissingDomainObjectInParameter(DslParameter it) {
		if(parameterType != null && parameterType.domainObjectType == null && parameterType.type != null &&
		   parameterType.firstDomainObjectForType != null) {
			warning("Use @" + parameterType.type, DSL_PARAMETER__PARAMETER_TYPE, parameterType.type)
		}
	}

}
