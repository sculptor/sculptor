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
package org.sculptor.generator.workflow

import com.google.inject.Injector
import java.lang.reflect.Method
import javax.inject.Inject
import org.eclipse.emf.common.util.Diagnostic
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.Diagnostician
import org.eclipse.xtext.resource.ClasspathUriResolutionException
import org.eclipse.xtext.resource.IResourceServiceProvider
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.EmfFormatter
import org.eclipse.xtext.validation.AbstractValidationDiagnostic
import org.eclipse.xtext.validation.CheckMode
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.generator.SculptorGeneratorException
import org.slf4j.LoggerFactory
import sculptormetamodel.Application

import static org.eclipse.xtext.diagnostics.Severity.*

/**
 * This class provides a strategy implementation of the Sculptor generators internal workflow:
 * <ol>
 * <li>read the Sculptor DSL model from a given URL
 * <li>validate the resources of the DSL model 
 * <li>validate the DSL model
 * <li>transform the DSL model into a generator model  
 * <li>generate the code from the generator model
 * </ol>
 * @see #run(String)
 */
class SculptorGeneratorWorkflow {

	val static LOG = LoggerFactory.getLogger(SculptorGeneratorWorkflow)

	@Inject
	var Injector injector

	@Inject
	var IResourceServiceProvider.Registry registry

	@Inject
	var Diagnostician diagnostitian

	var XtextResourceSet resourceSet

	@Inject
	protected def final void setResourceSet(XtextResourceSet resourceSet) {
		resourceSet.addLoadOption(XtextResource.OPTION_RESOLVE_ALL, Boolean.TRUE)
		this.resourceSet = resourceSet
	}

	def final boolean run(String modelURI) {
		if (readModel(modelURI)) {
			if (validateResources()) {
				val dslApp = getApplication()
				if (validateApplication(dslApp)) {
					val app = transformAndModifyApplication(dslApp)
					if (app != null) {
						if (generateCode(app) != null) {
							return true
						}
					}
				}
			}
		}
		false
	}

	protected def boolean readModel(String modelURI) {
		LOG.debug("Reading model from '{}'", modelURI)
		try {
			val resource = resourceSet.getResource(URI.createURI(modelURI), true)
			if (resource.contents.empty) {
				LOG.error("Model is empty")
			} else {
				val model = resource.contents.get(0) as DslModel
				val app = model.app

				// Read all imported models recursively
				return model.imports.forall [
					LOG.debug(
						"Application" + if (app.basePackage != null && !app.basePackage.empty)
							""
						else
							"Part" + " '{}' imports resource URI '{}'", app.name, it.importURI)
					readModel(it.importURI)
				]
			}
		} catch (ClasspathUriResolutionException e) {
			LOG.error(e.cause.message)
		}
		false
	}

	protected def boolean validateResources() {

		// Validate all resources in resource set
		resourceSet.resources.forall [
			LOG.debug("Validating resource '{}'", it.URI)
			val provider = registry.getResourceServiceProvider(it.URI)
			val issues = provider.resourceValidator.validate(it, CheckMode.ALL, null)
			issues.forall [
				val message = "Resource validation error \"" + it.message + "\" in line " + it.lineNumber +
					if(it.uriToProblem != null) " of " + it.uriToProblem.trimFragment else ""
				switch it.severity {
					case ERROR: {
						LOG.error(message)
						return false
					}
					case WARNING:
						LOG.warn(message)
					case INFO:
						LOG.info(message)
					default: {
					}
				}
				true
			]
		]
	}

	protected def DslApplication getApplication() {
		var DslApplication mainApp = null
		for (Resource resource : resourceSet.resources) {
			for (EObject obj : resource.contents) {
				if (obj instanceof DslModel) {
					val model = obj
					if (mainApp == null) {
						mainApp = model.app
					} else {
						mainApp.modules.addAll(model.app.modules)
					}
				}
			}
		}
		mainApp
	}

	protected def boolean validateApplication(DslApplication application) {
		LOG.debug("Validating application '{}'", application.name)
		val appDiagnostic = diagnostitian.validate(application)
		if (appDiagnostic.getSeverity() != Diagnostic.OK) {
			logDiagnostic(appDiagnostic)
			return false
		}
		true
	}

	protected def Application transformAndModifyApplication(DslApplication app) {
		val transformedApp = runAction("org.sculptor.generator.transform.DslTransformation.transform", app) as Application
		if (transformedApp != null) {
			return runAction("org.sculptor.generator.transform.Transformation.modify", transformedApp) as Application
		}
		transformedApp
	}

	protected def Object generateCode(Application app) {
		runAction("org.sculptor.generator.template.RootTmpl.root", app)
	}

	protected def Object runAction(String actionName, Object input) {
		LOG.debug("Running action '{}' on '{}'", actionName, input.class.name)
		try {
			val lastDot = actionName.lastIndexOf('.')
			val actionClass = Class.forName(actionName.substring(0, lastDot))
			var Method actionMethod
			try {
				actionMethod = actionClass.getMethod(actionName.substring(lastDot + 1), input.class)
			} catch (Throwable th) {
				actionMethod = actionClass.getMethod(actionName.substring(lastDot + 1), input.class.interfaces.get(0))
			}
			val actionObj = injector.getInstance(actionClass)
			return actionMethod.invoke(actionObj, input)
		} catch (Throwable t) {
			LOG.error("Error running action '{}': {}", actionName,
				if(t.cause instanceof SculptorGeneratorException) t.cause.message else t.message)
		}
		null
	}

	protected def void logDiagnostic(Diagnostic diagnostic) {
		val eObject = if (diagnostic instanceof AbstractValidationDiagnostic)
				(diagnostic).sourceEObject
			else
				null
		if (eObject != null) {
			val message = "Model validation error \"" + diagnostic.getMessage() + "\" at " +
				EmfFormatter.objPath(eObject)
			switch diagnostic.severity {
				case Diagnostic.ERROR:
					LOG.error(message)
				case Diagnostic.WARNING:
					LOG.warn(message)
				default:
					LOG.info(message)
			}
		}
		if (diagnostic.getChildren() != null) {
			for (Diagnostic childDiagnostic : diagnostic.getChildren()) {
				logDiagnostic(childDiagnostic)
			}
		}
	}

}
