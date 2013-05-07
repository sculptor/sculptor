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

	private val List<? extends Class<?>> startClasses

	public new(Class<?> startClassOn) {
		startClasses = #[startClassOn]
	}

	public new(List<? extends Class<?>> startClassesOn) {
		startClasses = startClassesOn
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

	def <T> buildChainForClass(HashSet<Class<?>> discovered, Class<T> clazz) {
		LOG.debug("Building chain for class '{}'", clazz)
		var T chain

		// Instantiate template - try extension first
		val T template = try {
			clazz.getConstructor(clazz).newInstance(null as T)
		} catch (Throwable t) {
			// fall-back to original template
			clazz.newInstance
		}

		// Add all classes injected into template  
		discoverInjectedFields(discovered, template.^class)

		// If template is overridable/chainable then try to prepare whole chain
		if (template instanceof ChainLink<?>) {

			// Prepare list of class name to add to chain
			val needsToBeChained = new Stack()
			needsToBeChained.push(makeOverrideClassName(clazz))

			cartridgeNames.forEach[cartridgeName|needsToBeChained.push(makeTemplateClassName(clazz, cartridgeName))]

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
		} catch (Exception ex) {
			// No such class - continue with poping from stack using same base object
		}

		// Recursive
		buildChainForInstance(result, constructorParam, discovered, needsToBeChained);
	}

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
		"generator." + clazz.simpleName + "Override"
	}

	def <T> String makeTemplateClassName(Class<T> clazz, String cartridgeName) {
		"org.sculptor.generator.cartridge." + cartridgeName + "." + clazz.simpleName + "Extension"
	}

	//
	// Properties support for reading 'cartridges' property
	//
	private static final String PROPERTIES_RESOURCE = System::getProperty("sculptor.generatorPropertiesLocation",
		"generator/sculptor-generator.properties");

	def loadProperties(String resource) {
		var ClassLoader classLoader = Thread::currentThread().getContextClassLoader();
		if (classLoader == null) {
			classLoader = this.getClass.getClassLoader();
		}
		val InputStream resourceInputStream = classLoader.getResourceAsStream(resource);
		if (resourceInputStream == null) {
			throw new MissingResourceException("Properties resource not available: " + resource, "GeneratorProperties",
				"");
		}
		val properties = new Properties
		try {
			properties.load(resourceInputStream);
		} catch (IOException e) {
			throw new MissingResourceException("Can't load properties from: " + resource, "GeneratorProperties", "");
		}

		properties
	}

	private var Properties props

	def getCartridgeNames() {
		if (props == null) {
			props = loadProperties(PROPERTIES_RESOURCE)
			val cartString = props.getProperty("cartridges")
			if (cartString != null && cartString.length > 0) {
				cartString.split("[,; ]")
			} else {
				<String>newArrayOfSize(0)
			}
		}
	}

}
