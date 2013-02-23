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

package org.sculptor.generator

import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModule
import org.sculptor.dsl.sculptordsl.DslService
import sculptormetamodel.SculptormetamodelFactory

import static extension org.sculptor.generator.HelperExtensions.*

import static extension org.eclipse.xtext.EcoreUtil2.*

class SculptorDslTransformation {

	private static val SculptormetamodelFactory FACTORY = SculptormetamodelFactory::eINSTANCE

	def create FACTORY.createApplication transform(DslApplication app) {
		val allDslModules = app.eAllOfType(typeof(DslModule))
		setName(app.name)
		setBasePackage(app.basePackage)
		setDoc(app.doc)
		modules.addAll(allDslModules.map [it.transform])

	    // have to transform the dependencies afterwards, otherwise strange errors
//TODO	    allDslModules.services.transformDependencies() ->
//TODO	    allDslModules.resources.transformDependencies() ->
//TODO	    allDslModules.consumers.transformDependencies() ->
//TODO	    allDslModules.domainObjects().transformDependencies() ->
//TODO	    allDslModules.domainObjects().select(d | d.scaffold).scaffold() ->
//TODO	    allDslModules.resources.select(e | e.scaffold).scaffold();
    }

	def create FACTORY.createModule transform(DslModule module) {
	    setApplication((module.eContainer as DslApplication).transform)
	    setDoc(module.doc)
	    setName(module.name)
	    setHint(module.hint)
//TODO	    setExternal(!isModuleToBeGenerated(module.name))
	    setBasePackage(module.basePackage)
//TODO	    domainObjects.addAll(module.domainObjects.map [it.transform])
	    services.addAll(module.services.map [it.transform])
//TODO	    resources.addAll(module.resources.map [it.transform])
//TODO	    consumers.addAll(module.consumers.map [.transform])
	}

	def create FACTORY.createService transform(DslService service) {
		setModule((service.eContainer as DslModule).transform) 
	    setDoc(service.doc)
	    setName(service.name)
//TODO	    setGapClass(service.isGapClassToBeGenerated)
	    setWebService(service.webService)
	    setHint(service.hint)
	
	    // TODO these hints will probably be replaced by real keywords in DSL
	    setRemoteInterface(!hasHint("notRemote"))
	    setLocalInterface(!hasHint("notLocal"))
	    if (service.subscribe != null) {
//TODO	    	setSubscribe(service.subscribe.transform)
	    }
//TODO	    operations.addAll(service.operations.map [it.transform])
    }

}