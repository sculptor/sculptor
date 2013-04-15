package org.sculptor.generator.mwe2

import com.google.inject.AbstractModule
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import java.util.List
import java.util.HashSet
import javax.inject.Inject
import org.sculptor.generator.util.ChainLink
import java.util.Properties
import java.io.InputStream
import java.util.MissingResourceException
import java.io.IOException
import java.util.Stack

class UniversalLoadModule extends AbstractModule {
	
	private static final val Logger LOG = LoggerFactory::getLogger(typeof(UniversalLoadModule))
	private val List<? extends Class<?>> startClasses

	public new(Class<?> startClassOn) {
		startClasses = #[startClassOn]
	}

	public new(List<? extends Class<?>> startClassesOn) {
		startClasses = startClassesOn
	}

	override protected configure() {
		buildChainForClasses(<Class<?>> newHashSet(), startClasses)
	}

	def void buildChainForClasses(HashSet<Class<?>> mapped, List<? extends Class<?>> newClasses) {
		val onlyNew = newClasses.filter[c | !mapped.contains(c)].toList
		mapped.addAll(onlyNew)
		val HashSet<Class<?>> discovered = newHashSet()
		onlyNew.forEach[c | buildChainForClass(discovered, c)]
		if (discovered.size > 0)
			buildChainForClasses(mapped, discovered.toList)
	}

	private def <T> buildChainForClass(HashSet<Class<?>> discovered, Class<T> clazz) {
		// Original template
		val T base = try
				Class::forName(clazz.name + "Extension").newInstance as T
			catch (Throwable t)
				clazz.newInstance
		discoverInjectedFields(discovered, base.^class)

		// Prepare stack of of chained cartridges
		LOG.info("Building chain for {}", clazz)
		val stack = new Stack()
		stack.push(makeOverrideClassName(clazz))

		// If is overridable/chainable try to prepare whole chain
		if (base instanceof ChainLink<?>) {
			loadCartridgeList.forEach[p | stack.push(makeTemplateClassName(clazz, p))]
		}

		// Load available classes
		bind(clazz).toInstance(loadChain(base, discovered, stack))
	}

	def <T> T loadChain(T object, HashSet<Class<?>> discovered, Stack<String> stack) {
		if (stack.isEmpty)
			return object

		var result = object;
		try {
			val overrideClass = Class::forName(stack.pop)
			val const = overrideClass.getConstructor(object.getClass.superclass)
			if (typeof(ChainLink).isAssignableFrom(overrideClass)) {
				result = (const.newInstance(object) as T)
				requestInjection(object)
				LOG.info("    chaining with {}", overrideClass)
				discoverInjectedFields(discovered, overrideClass)
			}
		} catch (Exception ex) {
			// No such class - continue with poping from stack using same base object
		}
		// Recursive
		loadChain(result, discovered, stack);
	}

	def void discoverInjectedFields(HashSet<Class<?>> discovered, Class<?> newClass) {
		discovered.addAll(newClass.declaredFields
			.filter[f | f.getAnnotation(typeof(Inject)) != null || f.getAnnotation(typeof(com.google.inject.Inject)) != null]
			.map[f | f.type]
			.toList)
	}

	//
	// Naming convention generators
	//
	def <T> String makeOverrideClassName(Class<T> clazz) {
		// val clsName = clazz.name
		// clsName.substring("org.sculptor.".length) + "Override"
		"generator." + clazz.simpleName + "Override"
	}

	def <T> String makeTemplateClassName(Class<T> clazz, String cartridge) {
		val simpleClsName = clazz.simpleName
		"org.sculptor.generator.cartridge." + cartridge + "." + simpleClsName + "Extension"
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
			throw new MissingResourceException("Properties resource not available: " + resource, "GeneratorProperties", "");
		}
		val properties = new Properties
		try {
			properties.load(resourceInputStream);
		} catch (IOException e) {
			throw new MissingResourceException("Can't load properties from: " + resource, "GeneratorProperties", "");
		}

		properties
	}

	var Properties props

	def loadCartridgeList() {
		if (props == null) {
			props = loadProperties(PROPERTIES_RESOURCE)
			val cartString=props.getProperty("cartridges")
			if (cartString != null && cartString.length > 0) {
				cartString.split("[,; ]")
			} else {
				<String> newArrayOfSize(0)
			}
		}
	}
}