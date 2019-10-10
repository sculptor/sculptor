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
package org.sculptor.generator.transform

import com.google.inject.Inject
import org.sculptor.generator.chain.ChainOverridable
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.PropertiesBase
import sculptormetamodel.DomainObject
import sculptormetamodel.HttpMethod
import sculptormetamodel.ResourceOperation
import sculptormetamodel.SculptormetamodelFactory

@ChainOverridable
class RestTransformation {

	static val SculptormetamodelFactory FACTORY = SculptormetamodelFactory.eINSTANCE

	@Inject extension HelperBase helperBase
	@Inject extension Helper helper
	@Inject extension PropertiesBase propertiesBase
	
	def addRestDefaults(ResourceOperation operation) {
		val defaultReturn = operation.defaultReturn
		if (operation.returnString === null && defaultReturn != "")
			operation.setReturnString(defaultReturn)
		if (operation.path === null)
			operation.setPath(operation.defaultPath())
		if (operation.httpMethod === null || operation.httpMethod == HttpMethod.UNDEFINED)
			operation.setHttpMethod(operation.defaultHttpMethod().mapHttpMethod())
		if (operation.httpMethod == HttpMethod.GET &&
				operation.name == "updateForm" && operation.parameters.isEmpty)
			operation.addIdParameter()
		if (operation.httpMethod == HttpMethod.GET && operation.returnString !== null &&
				(operation.delegate !== null || operation.name == "createForm" || operation.name == "updateForm") &&
				!operation.parameters.exists(e | e.type == "ModelMap" || e.type == "Model"))
			operation.addModelMapParameter()
		if ((operation.throws === null || operation.throws == "") && (operation.httpMethod == HttpMethod.DELETE || operation.name == "updateForm"))
			operation.addThrowsException()
		if (operation.domainObjectType !== null)
			operation.domainObjectType.addXmlRootHint()
		operation.parameters.filter(e | e.domainObjectType !== null).map[e | e.domainObjectType].forEach[addXmlRootHint()]
	}

	def String defaultReturn(ResourceOperation operation) {
		val propKey1 = "rest." + operation.name + ".return"
		val propKey2 = "rest." + (if (operation.delegate === null) "default" else operation.delegate.name) + ".return"
		val value = 
			(if (hasProperty(propKey1))
				getProperty(propKey1)
			else if (hasProperty(propKey2))
				getProperty(propKey2)
			else
				"")
			value.replacePlaceholders(operation)
	}

	def String defaultHttpMethod(ResourceOperation operation) {
		val propKey1 = "rest." + operation.name + ".httpMethod"
		val propKey2 = "rest." + (if (operation.delegate === null) "default" else operation.delegate.name) + ".httpMethod"
		if (hasProperty(propKey1))
			getProperty(propKey1)
		else if (hasProperty(propKey2))
			getProperty(propKey2)
		else
			"GET"
	}

	def String defaultPath(ResourceOperation operation) {
		val propKey1 = "rest." + operation.name + ".path"
		val propKey2 = "rest." + (if (operation.delegate === null) "default" else operation.delegate.name) + ".path"
		val value = 
			(if (hasProperty(propKey1))
				getProperty(propKey1)
			else if (hasProperty(propKey2))
				getProperty(propKey2)
			else
				"/${resourceName}")
		value.replacePlaceholders(operation)
	}

	def String replacePlaceholders(String str, ResourceOperation op) {
		str.replaceRecourceNamePlaceholder(op).replaceOperationNamePlaceholder(op).replaceParamNamePlaceholders(op)
	}

	def String replaceRecourceNamePlaceholder(String str, ResourceOperation op) {
		str.replaceAll("\\$\\{resourceName}", op.resource.getDomainResourceName().toFirstLower())
	}
	
	def String replaceOperationNamePlaceholder(String str, ResourceOperation op) { 
		str.replaceAll("\\$\\{operationName}", op.name)
	}
	
	def addModelMapParameter(ResourceOperation op) {
		op.parameters.add(op.createModelMapParameter())
	}
	
	def create FACTORY.createParameter createModelMapParameter(ResourceOperation op) {
		setName("modelMap")
		setType("ModelMap")
	}
	
	def addIdParameter(ResourceOperation op) {
		op.parameters.add(op.createIdParameter())
	}

	def create FACTORY.createParameter createIdParameter(ResourceOperation op) {
		setName("id")
		setType("IDTYPE")
	}

	def addThrowsException(ResourceOperation op) {
		op.setThrows("java.lang.Exception")
	}
	
	def addXmlRootHint(DomainObject domainObject) {
		domainObject.addHint("xmlRoot=true")
	}	

}
