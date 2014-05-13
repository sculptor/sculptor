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
package org.sculptor.generator.cartridge.builder

import java.util.List
import javax.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Attribute
import sculptormetamodel.DomainObject
import sculptormetamodel.Module
import sculptormetamodel.NamedElement
import sculptormetamodel.Reference

class BuilderHelper {

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension BuilderProperties properties

	def getBuilderPackage(Module module) {
		concatPackage(getBasePackage(module), getBuilderPackage())
	}

	def getBuilderPackage(DomainObject it) {
		getBuilderPackage(module)
	}

	def List<Attribute> getBuilderAttributes(DomainObject domainObject) {
		domainObject.allAttributes.filter[a|!a.isUuid && a != domainObject.idAttribute && a.name != "version"].toList
	}

	def List<Reference> getBuilderReferences(DomainObject domainObject) {
		domainObject.allReferences.toList
	}

	def List<NamedElement> getBuilderConstructorParameters(DomainObject domainObject) {
		domainObject.constructorParameters
	}

	def List<NamedElement> getBuilderProperties(DomainObject domainObject) {
		val List<NamedElement> retVal = newArrayList
		retVal.addAll(domainObject.builderAttributes)
		retVal.addAll(domainObject.builderReferences)
		retVal
	}

	def String getBuilderClassName(DomainObject domainObject) {
		domainObject.name + "Builder"
	}

	def String getBuilderFqn(DomainObject domainObject) {
		domainObject.builderPackage + "." + domainObject.builderClassName
	}

	def dispatch boolean needsBuilder(DomainObject domainObject) {
		domainObject.^abstract == false
	}

	def dispatch boolean needsBuilder(sculptormetamodel.Enum domainObject) {
		false
	}

}
