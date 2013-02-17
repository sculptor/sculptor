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

import static org.sculptor.dsl.sculptordsl.SculptordslPackage$Literals.*

import static extension org.eclipse.emf.ecore.util.EcoreUtil.*
import static extension org.eclipse.xtext.EcoreUtil2.*
import static extension org.sculptor.dsl.SculptordslExtensions.*

class SculptordslXtendValidator extends SculptordslJavaValidator {

	@Check
	def checkDomainObjectDuplicateName(DslSimpleDomainObject obj) {
		if (obj.name == null) {
			return
		}
		if (obj.rootContainer.eAllOfType(typeof(DslSimpleDomainObject)).filter [it.name == obj.name].size > 1) {
			error("Duplicate name.  There is already an existing Domain Object named '"
				+ obj.name + "'.", DSL_SIMPLE_DOMAIN_OBJECT__NAME, obj.name
			);  
		}
	}

	@Check
	def checkServiceDuplicateName(DslService service) {
		if (service.name == null) {
			return
		}
		if (service.rootContainer.eAllOfClass(typeof(DslService)).filter [it.name == service.name].size > 1) {
			error("Duplicate name.  There is already an existing Service named '"
				+ service.name + "'.", DSL_SERVICE_REPOSITORY_OPTION__NAME, service.name
			);  
		}
	}

}
