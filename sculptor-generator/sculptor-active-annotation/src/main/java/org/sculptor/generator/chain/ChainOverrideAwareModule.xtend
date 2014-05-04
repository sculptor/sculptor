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
package org.sculptor.generator.chain

import com.google.inject.AbstractModule
import com.google.inject.Injector
import java.lang.reflect.Array
import java.util.HashSet
import java.util.List
import java.util.Stack
import javax.inject.Inject
import org.sculptor.generator.configuration.ConfigurationProvider
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Binds specified class(es) to instanc(es) with support for creating chains from override or extension classes.      
 */
class ChainOverrideAwareModule extends AbstractModule {

	private static final Logger LOG = LoggerFactory::getLogger(typeof(ChainOverrideAwareModule))

	private val List<? extends Class<?>> startClasses
	private Injector bootstrapInjector

	public new(Injector bootstrapInjector, Class<?> startClass) {
		this.bootstrapInjector = bootstrapInjector
		this.startClasses = #[startClass]
	}

	public new(Injector bootstrapInjector, Class<?>... startClasses) {
		this.bootstrapInjector = bootstrapInjector
		this.startClasses = startClasses
	}

	override protected configure() {
		if (LOG.debugEnabled) {
			LOG.debug("Enabled cartridges: {}", cartridgeNames.toList)
		}
		buildChainForClasses(<Class<?>>newHashSet(), startClasses)
	}

	def void buildChainForClasses(HashSet<Class<?>> mapped, List<? extends Class<?>> newClasses) {
		val onlyNew = newClasses.filter[c|!mapped.contains(c)].toList
		mapped.addAll(onlyNew)
		val HashSet<Class<?>> discovered = newHashSet()
		onlyNew.forEach[clazz|buildChainForClass(discovered, clazz)]
		if (discovered.size > 0) {
			buildChainForClasses(mapped, discovered.toList)
		}
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
		template.^class.discoverInjectedFields(discovered)

		// If template is overridable/chainable then try to prepare whole chain, with the overridable class being the last element in chain
		// chain ends up being the head of the chain or the template itself if not overridable/chainable.
		var T chain
		if (template instanceof ChainLink<?>) {
			val methodsDispatchHead = (template as ChainLink<?>)._getOverridesDispatchArray as T[]

			// Prepare list of class names to add to chain if they exist
			val needsToBeChained = new Stack<String>()
			needsToBeChained.push(clazz.overrideClassName)
			cartridgeNames.forEach[cartridgeName|needsToBeChained.push(clazz.getTemplateClassName(cartridgeName))]
			if (LOG.debugEnabled) {
				LOG.debug("Classes to check to add to chain: {}", needsToBeChained.join(", "))
			}

			// Create the override chain for needsToBeChained, removing elements off the stack as it goes
			chain = template.buildChainForInstance(template.^class, discovered, needsToBeChained, methodsDispatchHead)
			
			// Finally set methodsDispatchHead into each chain member
			chain.updateChainWithMethodsDispatchHead(methodsDispatchHead)
		} else {
			chain = template
		}

		// Bind loaded chain to class
		bind(clazz).toInstance(chain)
	}

	/**
	 * Returns list of cartridge names from Sculptor properties.
	 */
	private def getCartridgeNames() {
		val cartridgeNames = getConfigurationString("cartridges")
		if (cartridgeNames != null && cartridgeNames.length > 0) {
			cartridgeNames.split("[,; ]").map[it.trim].toList
		} else {
			<String>newArrayList()
		}
	}

	/**
	 * Returns the value for the given configuration key .  
	 */
	private def getConfigurationString(String key) {
		bootstrapInjector.getInstance(typeof(ConfigurationProvider)).getString(key)
	}

	/**
	 * Iterates through the whole chain and sets the methodsDispatchHead of each chain member.
	 */
	private def <T> updateChainWithMethodsDispatchHead(T chain, T[] methodsDispatchHead) {
		var chainLink = chain as ChainLink<?>
		while (chainLink != null) {
			chainLink.setMethodsDispatchHead(methodsDispatchHead)
			chainLink = chainLink.next
		}
	}

	/**
	 * Build out the override chain for needsToBeChained recursively, removing elements off the stack as it goes.
	 * @param object current head of chain.  New ChainLink instance will be made to point to object
	 * @param templateClass Original template class
	 * @param discovered Classes discovered so far that are to be injected into ChainLink classes
	 * @param needsToBeChained Classes that still need to be chained
	 */
	def <T> T buildChainForInstance(T object, Class<?> templateClass, HashSet<Class<?>> discovered, Stack<String> needsToBeChained,
		T[] methodsDispatchHead
	) {
		if (needsToBeChained.isEmpty) {
			return object
		}

		var result = object
		val className = needsToBeChained.pop
		try {
			val chainedClass = Class::forName(className)
			if (typeof(ChainLink).isAssignableFrom(chainedClass)) {
				LOG.debug("    chaining with class '{}'", chainedClass)

				// Create an instance of MethodDispatch class for the given templateClass and the current head of chain object
				val nextDispatchObj = methodsDispatchHead.createNextDispatchObjFromHead(templateClass, object)

				// Create chain instance via chaining constructor added by ChainOverride annotation
				val constructor = chainedClass.getConstructor(templateClass, methodsDispatchHead.class)
				result = (constructor.newInstance(nextDispatchObj, null) as T)

				// Update methodsDispatchHead with dispatch array returned by chainLink of newly created chained instance
				methodsDispatchHead.updateFromObjDispatchArray(result)
				
				// Inject fields and methods into given object
				requestInjection(object)

				// Discover the classes of injected fields and add them to the given list
				chainedClass.discoverInjectedFields(discovered)
			} else {
				LOG.debug("    found class {} but not assignable to ChainLink.  skipping.", className)
			}
		} catch (ClassNotFoundException ex) {
			if (LOG.traceEnabled) {
				LOG.trace("Could not find class extension or override class {}", className)
			}

			// No such class - continue with popping from stack using same base object
		}
		// Recursive
		buildChainForInstance(result, templateClass, discovered, needsToBeChained, methodsDispatchHead);
	}

	/**
	 * Creates an instance of MethodDispatch class for the given templateClass and methodsDispatchHead.
	 */
	private def <T> createNextDispatchObjFromHead(T[] methodsDispatchHead, Class<?> templateClass, T object) {
		val methodsDispatchNext = methodsDispatchHead.copyMethodsDispatchHead(templateClass)

		val methodDispatchClass = Class::forName(templateClass.dispatchClassName)
		val methodDispatchConst = methodDispatchClass.getConstructor(templateClass, methodsDispatchNext.class)
		methodDispatchConst.newInstance(object, methodsDispatchNext as Object) as T
	}

	/**
	 * Returns a copy of the given methodsDispatchHead for the given overrideableClass.
	 */
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

		val dispatchArray = cl._getOverridesDispatchArray
		if (dispatchArray != null) {
			dispatchArray.forEach [ dispatchObj, i |
				if (dispatchObj != null) {
					methodsDispatchHead.set(i, dispatchObj as T)
				}
			]
		}
	}

	/**
	 * Discover any Inject annotated declared fields in newClass and add the classes to discovered.  Will process newClass base classes too.
	 */
	def void discoverInjectedFields(Class<?> newClass, HashSet<Class<?>> discovered) {
		var cls = newClass;
		do {
			discovered.addAll(
				cls.declaredFields.filter[f|
					(f.getAnnotation(typeof(Inject)) != null ||
						f.getAnnotation(typeof(com.google.inject.Inject)) != null) && !f.type.interface].map[f|f.type].toList)
			cls = cls.superclass
		} while (cls != typeof(Object))
	}

	//
	// Naming convention generators
	//

	/**
	 * @return Fully qualified name of override class
	 */
	def <T> String getOverrideClassName(Class<T> clazz) {
		getConfigurationString("defaultOverridesPackage") + "." + clazz.simpleName + "Override"
	}

	/**
	 * @return Fully qualified name of template class from given cartridge
	 */
	static def <T> String getTemplateClassName(Class<T> clazz, String cartridgeName) {
		"org.sculptor.generator.cartridge." + cartridgeName + "." + clazz.simpleName + "Extension"
	}

	/**
	 * @return Fully qualified name of method dispatch class
	 */
	static def <T> String getDispatchClassName(Class<T> clazz) {
		clazz.name + "MethodDispatch"
	}

}
