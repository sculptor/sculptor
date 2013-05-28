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
package org.sculptor.generator.chain

import com.google.inject.AbstractModule
import java.io.IOException
import java.io.InputStream
import java.util.HashSet
import java.util.List
import java.util.MissingResourceException
import java.util.Properties
import java.util.Stack
import javax.inject.Inject
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Binds specified class(es) to instanc(es) with support for creating
 * chains from override or extension classes.      
 */
class ChainOverrideAwareModule extends AbstractModule {

	private static final Logger LOG = LoggerFactory::getLogger(typeof(ChainOverrideAwareModule))

	//
	// Properties support for reading 'cartridges' property
	// TODO: Move this and loadProperties into separate class shared with PropertiesBase?
	//
	private static final String PROPERTIES_RESOURCE = System::getProperty("sculptor.generatorPropertiesLocation",
		"generator/sculptor-generator.properties");

	private static final String DEFAULT_PROPERTIES_RESOURCE = System::getProperty(
			"sculptor.defaultGeneratorPropertiesLocation", "default-sculptor-generator.properties");

	// Package where override packages will be looked for
	var String defaultOverridesPackage = "generator";
	
	private val List<? extends Class<?>> startClasses

	public new(Class<?> startClassOn) {
		startClasses = #[startClassOn]
		setProperties()
	}

	public new(List<? extends Class<?>> startClassesOn) {
		startClasses = startClassesOn
		setProperties()
	}

	def protected setProperties() {
		val defaultOverridesPkgProp = System::getProperty("sculptor.defaultOverridesPackage")
		if(defaultOverridesPkgProp != null) {
			defaultOverridesPackage = defaultOverridesPkgProp 
		}
	}
	
	override protected configure() {
		buildChainForClasses(<Class<?>>newHashSet(), startClasses)
	}

	def void buildChainForClasses(HashSet<Class<?>> mapped, List<? extends Class<?>> newClasses) {
		val onlyNew = newClasses.filter[c|!mapped.contains(c)].toList
		mapped.addAll(onlyNew)
		val HashSet<Class<?>> discovered = newHashSet()
		onlyNew.forEach[clazz | buildChainForClass(discovered, clazz)]
		if (discovered.size > 0)
			buildChainForClasses(mapped, discovered.toList)
	}

	/**
	 * Instantiate and build chain for clazz if it supports overriding/chaining.
	 * In either case, bind the newly created instance.
	 * Add any injected classes found in clazz to discovered.
	 */
	def <T> buildChainForClass(HashSet<Class<?>> discovered, Class<T> clazz) {
		LOG.debug("Building chain for class '{}'", clazz)

		// Instantiate template - try extension first
		val T template = try {
			clazz.getConstructor(clazz).newInstance(null as T)
		} catch (Throwable t) {
			// fall-back to original template
			clazz.newInstance
		}

		// Add all classes injected into template to discovered  
		discoverInjectedFields(discovered, template.^class)

		// If template is overridable/chainable then try to prepare whole chain.
		// chain ends up being the head of the chain or the template itself if not overridable/chainable
		var T chain
		if (template instanceof ChainLink<?>) {

			// Prepare list of class names to add to chain if they exist
			val needsToBeChained = new Stack<String>()
			needsToBeChained.push(makeOverrideClassName(clazz))

			cartridgeNames.forEach[cartridgeName|needsToBeChained.push(makeTemplateClassName(clazz, cartridgeName))]

			if(LOG.debugEnabled) {
				LOG.debug("Classes to check to add to chain: " + needsToBeChained.join(","))
			}
			chain = buildChainForInstance(template, template.^class, discovered, needsToBeChained)
		} else {
			chain = template
		}

		// Bind loaded chain to class
		bind(clazz).toInstance(chain)
	}

	def <T> T buildChainForInstance(T object, Class<?> constructorParam, HashSet<Class<?>> discovered, Stack<String> needsToBeChained) {
		if (needsToBeChained.isEmpty)
			return object

		var result = object;
		try {
			val overrideClass = Class::forName(needsToBeChained.pop)
			val const = overrideClass.getConstructor(constructorParam)
			if (typeof(ChainLink).isAssignableFrom(overrideClass)) {
				LOG.debug("    chaining with class '{}'", overrideClass)
				result = (const.newInstance(object) as T)
				requestInjection(object)
				discoverInjectedFields(discovered, overrideClass)
			}
		} catch (ClassNotFoundException ex) {
			if(LOG.traceEnabled) {
				LOG.trace("Could not find class extension or override class", ex)
			}

			// No such class - continue with popping from stack using same base object
		}

		// Recursive
		buildChainForInstance(result, constructorParam, discovered, needsToBeChained);
	}

	/**
	 * Discover any Inject annotated declared fields in newClass and add the classes to discovered.  Will process newClass base classes too.
	 */
	def void discoverInjectedFields(HashSet<Class<?>> discovered, Class<?> newClass) {
		var cls = newClass;
		do {
			discovered.addAll(
				cls.declaredFields.filter[f|
					f.getAnnotation(typeof(Inject)) != null || f.getAnnotation(typeof(com.google.inject.Inject)) != null].
					map[f|f.type].toList)
			cls = cls.superclass
		} while (cls != typeof(Object))
	}

	//
	// Naming convention generators
	//
	def <T> String makeOverrideClassName(Class<T> clazz) {
		defaultOverridesPackage + "." + clazz.simpleName + "Override"
	}

	def <T> String makeTemplateClassName(Class<T> clazz, String cartridgeName) {
		"org.sculptor.generator.cartridge." + cartridgeName + "." + clazz.simpleName + "Extension"
	}

	/**
	 * Load properties from resource into properties
	 */
	def protected void loadProperties(Properties properties, String resource) {
		var ClassLoader classLoader = Thread::currentThread().getContextClassLoader();
		if (classLoader == null) {
			classLoader = this.getClass.getClassLoader();
		}
		val InputStream resourceInputStream = classLoader.getResourceAsStream(resource);
		if (resourceInputStream == null) {
			throw new MissingResourceException("Properties resource not available: " + resource, "GeneratorProperties",
				"");
		}
		try {
			properties.load(resourceInputStream);
		} catch (IOException e) {
			throw new MissingResourceException("Can't load properties from: " + resource, "GeneratorProperties", "");
		}

	}

	private var Properties props

	def getCartridgeNames() {
		if (props == null) {
			
			val defaultProperties = new Properties();
			loadProperties(defaultProperties, DEFAULT_PROPERTIES_RESOURCE);
	
			props = new Properties(defaultProperties);
			try {
				loadProperties(props, PROPERTIES_RESOURCE);
			} catch (MissingResourceException e) {
				// ignore, it is not mandatory
			}
		}

		val cartString = props.getProperty("cartridges")
		if (cartString != null && cartString.length > 0) {
			cartString.split("[,; ]")
		} else {
			<String>newArrayOfSize(0)
		}
	}

}
