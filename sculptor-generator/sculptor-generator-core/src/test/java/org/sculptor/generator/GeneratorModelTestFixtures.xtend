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

import com.google.inject.Guice
import com.google.inject.Inject
import com.google.inject.Injector
import com.google.inject.Provider
import java.io.IOException
import java.util.ArrayList
import junit.framework.Assert
import org.eclipse.emf.common.util.URI
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.resource.ResourceSet
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.resource.IResourceServiceProvider$Registry
import org.eclipse.xtext.util.Pair
import org.eclipse.xtext.util.Tuples
import org.eclipse.xtext.validation.CheckMode
import org.eclipselabs.xtext.utils.unittesting.FluentIssueCollection
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.generator.chain.ChainOverrideAwareModule
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import org.slf4j.LoggerFactory
import sculptormetamodel.Application

/**
 * Test fixtures for tests that work on a loaded and transformed Sculptor model
 * This code is adapted from the XtextTest class which is part of the XText project
 */
class GeneratorModelTestFixtures {

	static val LOG = LoggerFactory::getLogger(typeof(GeneratorModelTestFixtures))

	@Inject
	protected var ResourceSet resourceSet;

	@Inject
	private var Registry serviceProviderRegistry;

	val String resourceRoot

	protected var FluentIssueCollection issues

	@Property
	var Class<? extends EObject> rootObjectType = typeof(DslModel)

	@Property
	var Boolean failOnParserWarnings = false

	@Property
	var Injector injector

	@Property
	var Application app

	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider

	@Property
	protected EObject rootElement;

	public new() {
		this("/");
	}

	/* Classpath resuolution is weird
	 * 
	 * For resources directly in the classpath, you need a starting slash after 'classpath:/':
     *   - classpath://bla.txt
     *   
     * But if you wan't to point to something in a subfolder, the subfolder must
     * occur directly after 'classpath:/':
     *   - classpath://subfolder
     *   
     * A trailing slash is optional.
    * */
	new(String resourceRoot) {
		if (!resourceRoot.contains(":/")) {
			this.resourceRoot = "classpath:/" + resourceRoot;
		} else {
			this.resourceRoot = resourceRoot;
		}
	}

	def Pair<String, FluentIssueCollection> loadAndSaveModule(String rootPath, String filename) {
		val uri = URI::createURI(resourceRoot + "/" + filename);
		rootElement = loadModel(resourceSet, uri, getRootObjectType);

		val r = resourceSet.getResource(uri, false);
		val provider = serviceProviderRegistry.getResourceServiceProvider(r.getURI());
		val result = provider.getResourceValidator().validate(r, CheckMode::ALL, null);

		return Tuples::create("-not serialized-", new FluentIssueCollection(r, result, new ArrayList<String>()));

	}

	@SuppressWarnings("unchecked")
	def <T extends EObject> T loadModel(ResourceSet rs, URI uri, Class<T> clazz) {
		val resource = rs.createResource(uri);
		try {
			resource.load(null);
		} catch (IOException e) {
			throw new RuntimeException(e);
		}

		val errors = new StringBuilder();
		if (!resource.getWarnings().isEmpty()) {
			LOG.error("Resource " + uri.toString() + " has warnings:");

			resource.warnings.forEach [ issue |
				LOG.error(issue.getLine() + ": " + issue.getMessage());
			]
		}

		if (failOnParserWarnings) {
			errors.append("Resource as warnings:");
			resource.warnings.forEach [ issue |
				errors.append("\n  - " + issue.getLine() + ": " + issue.getMessage());
			]
			errors.append("/n");
		}

		if (!resource.errors.empty) {
			LOG.error("Resource " + uri.toString() + " has errors:");
			errors.append("Resource has errors:");
			resource.errors.forEach [ issue |
				LOG.error("   " + issue.line + ": " + issue.message)
				errors.append("\n  - " + issue.getLine() + ": " + issue.getMessage());
			]

		}

		val o = resource.getContents().get(0);

		// assure that the root element is of the expected type
		if (clazz != null) {
			Assert::assertTrue(clazz.isInstance(o));
		}
		EcoreUtil::resolveAll(resource);
		return o as T;
	}

	def protected DslModel getDomainModel(String resource, String... referencedResources) {

		for (String referencedResource : referencedResources) {
			val uri = URI::createURI(resourceRoot + "/" + referencedResource);
			loadModel(resourceSet, uri, rootObjectType);
		}

		loadAndSaveModule(resourceRoot, resource);

		val dslModel = rootElement as DslModel
		dslModel
	}

	def void setupModel(String resource, String... referencedResources) {

		val uniLoadModule = new ChainOverrideAwareModule(#[typeof(DslTransformation), typeof(Transformation)])
		injector = Guice::createInjector(uniLoadModule)

		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel(resource, referencedResources).app

		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)

		val transformation = transformationProvider.get
		app = transformation.modify(app)

	}

	def <T> getProvidedObject(Class<T> clazz) {
		val provider = injector.getProvider(clazz)
		provider.get

	}

}
