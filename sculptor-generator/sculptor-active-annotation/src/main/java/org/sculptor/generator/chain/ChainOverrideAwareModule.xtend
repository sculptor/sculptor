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
import java.lang.reflect.Array
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
	 * Add any injected classes found in clazz to discovered.  These will later be evaluated for chain processing as well.
	 * Instantiate clazz first, then work backwards looking for cartridges or app override class that override clazz
	 */
	def <T> buildChainForClass(HashSet<Class<?>> discovered, Class<T> clazz) {
		LOG.debug("Building chain for class '{}'", clazz)

		// Instantiate template - try overrideable version first
		val T template = try {
			
			clazz.getConstructor(clazz).newInstance(null as T)
		} catch (Throwable t) {
			// fall-back to non-overrideable class constructor
			clazz.newInstance
		}
		
		

		// Add all classes injected into template to discovered  
		discoverInjectedFields(discovered, template.^class)

		// If template is overridable/chainable then try to prepare whole chain, with the overridable class being the last element in chain
		// chain ends up being the head of the chain or the template itself if not overridable/chainable.
		var T chain
		if (template instanceof ChainLink<?>) {

			// TODO: Do this via casting
			val getOverridesDispatchArrayMethod = template.class.getMethod("_getOverridesDispatchArray")
			val methodsDispatchHead = getOverridesDispatchArrayMethod.invoke(template) as T[]
			
			// Prepare list of class names to add to chain if they exist
			val needsToBeChained = new Stack<String>()
			needsToBeChained.push(makeOverrideClassName(clazz))

			cartridgeNames.forEach[cartridgeName|needsToBeChained.push(makeTemplateClassName(clazz, cartridgeName))]

			if(LOG.debugEnabled) {
				LOG.debug("Classes to check to add to chain: " + needsToBeChained.join(","))
			}
			chain = buildChainForInstance(template, template.^class, discovered, needsToBeChained, methodsDispatchHead)
			
			// Now set methodsDispatchHead into each chain member
			chain.updateChainWithMethodsDispatchHead(methodsDispatchHead)


		} else {
			chain = template
		}

		// Bind loaded chain to class
		bind(clazz).toInstance(chain)
	}
	
	private def <T> updateChainWithMethodsDispatchHead(T chain, T[] methodsDispatchHead) {
			var chainLink = chain as ChainLink<?>
			while(chainLink != null) {
				chainLink.setMethodsDispatchHead(methodsDispatchHead)
				chainLink = chainLink.next as ChainLink<?>
			}
		
	}

	/**
	 * Build out the override chain for needsToBeChained, removing elements off the stack as it goes.
	 * @param object current head of chain.  New ChainLink instance will be made to point to object
	 * @param templateClass Original template class
	 * @param discovered Classes discovered so far that are to be injected into ChainLink classes
	 * @param needsToBeChained Classes that still need to be chained
	 */
	def <T> T buildChainForInstance(T object, Class<?> templateClass, HashSet<Class<?>> discovered, Stack<String> needsToBeChained,
		T[] methodsDispatchHead
	) {
		if (needsToBeChained.isEmpty)
			return object

		var result = object
		val className = needsToBeChained.pop
		try {
			val chainedClass = Class::forName(className)
			if (typeof(ChainLink).isAssignableFrom(chainedClass)) {
				LOG.debug("    chaining with class '{}'", chainedClass)
				val const = chainedClass.getConstructor(templateClass, methodsDispatchHead.class)
				
				val nextDispatchObj = createNextDispatchObjFromHead(methodsDispatchHead, templateClass, object)
				
				// Create chained instance
				result = (const.newInstance(nextDispatchObj, null) as T)
				
				methodsDispatchHead.updateFromObjDispatchArray(result)
				
				requestInjection(object)
				discoverInjectedFields(discovered, chainedClass)
			} else {
				LOG.debug("    found class {} but not assignable to ChainLink.  skipping.", className)
			}
		} catch (ClassNotFoundException ex) {
			if(LOG.traceEnabled) {
				LOG.trace("Could not find class extension or override class {}", className)
			}

			// No such class - continue with popping from stack using same base object
		}
		// Recursive
		buildChainForInstance(result, templateClass, discovered, needsToBeChained, methodsDispatchHead);
	}
	
	private def <T> createNextDispatchObjFromHead(T[] methodsDispatchHead, Class<?> templateClass, T object) {
		val methodsDispatchNextArr = methodsDispatchHead.copyMethodsDispatchHead(templateClass)

		val methodDispatchClass = Class::forName(templateClass.name + "MethodDispatch")
		val methodDispatchConst = methodDispatchClass.getConstructor(templateClass, methodsDispatchNextArr.class)
		val mdoRes = methodDispatchConst.newInstance(object, methodsDispatchNextArr as Object)
		mdoRes as T
	}
	
	private def <T> T[] copyMethodsDispatchHead(T[] methodsDispatchHead, Class<?> overrideableClass) {
		val T[] methodsDispatchNext = Array::newInstance(overrideableClass, methodsDispatchHead.size) as T[]
		System.arraycopy(methodsDispatchHead, 0, methodsDispatchNext, 0, methodsDispatchHead.length)
		methodsDispatchNext
	}
	
	/**
	 * Update methodsDispatchHead with dispatch array returned by chainLink.
	 */
	private def <T> updateFromObjDispatchArray(T[] methodsDispatchHead, T chainLink) {
		val cl = chainLink as ChainLink<?>
		
		val dispatchArray = cl._getOverridesDispatchArray()
		if(dispatchArray != null) {
			dispatchArray.forEach[dispatchObj, i|
				if(dispatchObj != null) {
					methodsDispatchHead.set(i, dispatchObj as T)
				}
				
			]
		}
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
