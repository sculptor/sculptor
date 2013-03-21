/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *		http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.generator.check

import javax.inject.Inject
import org.sculptor.dsl.sculptordsl.DslBasicType
import org.sculptor.dsl.sculptordsl.DslCommandEvent
import org.sculptor.dsl.sculptordsl.DslDataTransferObject
import org.sculptor.dsl.sculptordsl.DslDomainEvent
import org.sculptor.dsl.sculptordsl.DslDomainObject
import org.sculptor.dsl.sculptordsl.DslDtoReference
import org.sculptor.dsl.sculptordsl.DslEntity
import org.sculptor.dsl.sculptordsl.DslModule
import org.sculptor.dsl.sculptordsl.DslParameter
import org.sculptor.dsl.sculptordsl.DslReference
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslRepositoryOperation
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslServiceOperation
import org.sculptor.dsl.sculptordsl.DslSimpleDomainObject
import org.sculptor.dsl.sculptordsl.DslValueObject
import org.sculptor.generator.util.HelperBase

// These checks fixes CSC-650, i.e. the problem that cross references are not linked in 
// imported resources. It would have been better to force the linking and validation in 
// the ordinary model load, but I couldn't find a way to do that. Maybe this issue:
// http://www.eclipse.org/forums/index.php/mv/msg/136903/440479/#msg_440479

class CheckCrossLink {

	@Inject extension HelperBase helperBase

	def void checkCrossLink(DslModule module) {

		module.domainObjects.forEach[checkSimpleDomainObjectCrossLink()]
		
		module.domainObjects.filter(typeof(DslDomainObject)).filter([e | e.repository != null]).map(e|e.repository).
			map(r|r.operations).flatten().forEach[DslRepositoryOperation op| op.checkCrossLink()
		]
		
		module.services.map[operations].flatten().forEach[DslServiceOperation op|op.checkCrossLink()]
	}

	/**
	 * 'Abstract' method for dispatching
	 */
	def dispatch void checkSimpleDomainObjectCrossLink(DslSimpleDomainObject domainObject) {
		
	}
	
	def dispatch void checkSimpleDomainObjectCrossLink(DslEntity domainObject) {
		domainObject.references.forEach[checkReferenceCrossLink()]
	  	if (domainObject.getExtends() != null && domainObject.getExtends().eContainer == null) { 
    		error("Unresolved extends in " + domainObject.name);
	    }
	}
	
	def dispatch void checkSimpleDomainObjectCrossLink(DslValueObject domainObject) {
		domainObject.references.forEach[checkReferenceCrossLink()]
  		if (domainObject.getExtends() != null && domainObject.getExtends().eContainer == null) { 
    		error("Unresolved extends in " + domainObject.name);
    	}		
	}

	def dispatch void checkSimpleDomainObjectCrossLink(DslBasicType domainObject) {
		domainObject.references.forEach[checkReferenceCrossLink()]
	}

	def dispatch void checkSimpleDomainObjectCrossLink(DslDomainEvent domainObject) {
  		domainObject.references.forEach[checkReferenceCrossLink()]
  		if (domainObject.getExtends() != null && domainObject.getExtends().eContainer == null) { 
    		error("Unresolved extends in " + domainObject.name);
		}
	}

	def dispatch void checkSimpleDomainObjectCrossLink(DslCommandEvent domainObject) {
		domainObject.references.forEach[checkReferenceCrossLink()]
  		if (domainObject.getExtends() != null && domainObject.getExtends().eContainer == null) { 
    		error("Unresolved extends in " + domainObject.name);
		}
	
	}
		
	def checkReferenceCrossLink(DslReference ref)  {
    	if (ref.domainObjectType.eContainer == null) {
      		error("Unresolved reference " + ( ref.eContainer as DslSimpleDomainObject).name + "#" + ref.name);
      	}
    }

	def checkCrossLink(DslDataTransferObject domainObject) {
  		domainObject.references.forEach[checkDslDtoReferenceCrossLink()]
  		if (domainObject.getExtends() != null && domainObject.getExtends().eContainer == null) { 
    		error("Unresolved extends in " + domainObject.name);
    	}
	}
	
	def checkDslDtoReferenceCrossLink(DslDtoReference ref) {
    	if (ref.domainObjectType.eContainer == null) {
      		error("Unresolved reference " + (ref.eContainer as DslSimpleDomainObject).name + "#" + ref.name);
    	}

	}
	
	def checkCrossLink(DslServiceOperation op) {
		op.parameters.forEach[param| param.checkCrossLink(op)]
    	if (op.returnType != null && op.returnType.domainObjectType != null && op.returnType.domainObjectType.eContainer == null) {
      		error("Unresolved return type in operation " + (op.eContainer as DslService).name + "#" + op.name)
      	}
      }
      
    def checkCrossLink(DslParameter p, DslServiceOperation op) {
	    if (p.parameterType != null && p.parameterType.domainObjectType != null && p.parameterType.domainObjectType.eContainer == null) {
      		error("Unresolved parameter type in operation " + ( op.eContainer as DslService).name + "#" + op.name + " " + p.name)
     
	    }
     }
     
	def checkCrossLink(DslRepositoryOperation op) {
	    op.parameters.forEach(param| param.checkCrossLink(op))
    	if (op.returnType != null && op.returnType.domainObjectType != null && op.returnType.domainObjectType.eContainer == null) {
      		error("Unresolved return type in operation " + (op.eContainer as DslRepository).name + "#" + op.name)
     	}
     
     }
     
	def checkCrossLink(DslParameter p, DslRepositoryOperation op) {
    	if (p.parameterType != null && p.parameterType.domainObjectType != null && p.parameterType.domainObjectType.eContainer == null) {
      error("Unresolved parameter type in operation " + (op.eContainer as DslRepository).name + "#" + op.name + " " + p.name);
     
      }
     
    }
}