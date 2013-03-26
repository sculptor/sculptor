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

package org.sculptor.dsl.scoping

import java.util.ArrayList
import org.eclipse.emf.ecore.EReference
import org.eclipse.xtext.naming.QualifiedName
import org.eclipse.xtext.resource.EObjectDescription
import org.eclipse.xtext.resource.IEObjectDescription
import org.eclipse.xtext.scoping.IScope
import org.eclipse.xtext.scoping.impl.AbstractDeclarativeScopeProvider
import org.sculptor.dsl.sculptordsl.DslDomainObject
import org.sculptor.dsl.sculptordsl.DslOppositeHolder
import org.sculptor.dsl.sculptordsl.DslReference
import org.sculptor.dsl.sculptordsl.DslRepository
import org.sculptor.dsl.sculptordsl.DslResourceOperationDelegate
import org.sculptor.dsl.sculptordsl.DslService
import org.sculptor.dsl.sculptordsl.DslServiceOperationDelegate

/**
 * This class contains custom scoping description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation/latest/xtext.html#scoping
 * on how and when to use it 
 *
 */
class SculptordslScopeProvider extends AbstractDeclarativeScopeProvider {

	def IScope scope_DslOppositeHolder_opposite(DslOppositeHolder ctx, EReference ref) {
		val Scope scope = new Scope()
		val elements = new ArrayList<IEObjectDescription>()
		val DslDomainObject domainObject = (ctx.eContainer as DslReference).domainObjectType as DslDomainObject
		domainObject.references.forEach[
			if (it.eContainer != null) {
				elements.add(new EObjectDescription(QualifiedName::create(it.name), it, null))
			}
		]
		scope.elements = elements
		return scope
	}

	def IScope scope_DslServiceOperationDelegate_delegateOperation(DslServiceOperationDelegate ctx, EReference ref) {
		val Scope scope = new Scope();
		val elements = new ArrayList<IEObjectDescription>()
		val option = ctx.delegate
		if (option != null) {
			if (option instanceof DslRepository) {
				(option as DslRepository).operations.forEach[
					elements.add(new EObjectDescription(QualifiedName::create(it.name), it, null))
				]
			} else {
				(option as DslService).operations.forEach[
					elements.add(new EObjectDescription(QualifiedName::create(it.name), it, null))
				]
			}
		}
		scope.elements = elements
		return scope
	}

	def IScope scope_DslResourceOperationDelegate_delegateOperation(DslResourceOperationDelegate ctx, EReference ref) {
		val Scope scope = new Scope()
		val elements = new ArrayList<IEObjectDescription>()
		val option = ctx.delegate
		if (option != null) {
			option.operations.forEach[
				elements.add(new EObjectDescription(QualifiedName::create(it.name), it, null))
			]
		}
		scope.elements = elements
		return scope;
	}

}
