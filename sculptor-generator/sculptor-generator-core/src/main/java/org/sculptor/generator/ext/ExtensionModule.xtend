package org.sculptor.generator.ext

import com.google.common.collect.ImmutableList
import com.google.inject.AbstractModule
import com.google.inject.Injector
import com.google.inject.Scopes
import java.util.List
import org.sculptor.generator.Cartridge
import org.sculptor.generator.util.ChainLink
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.GenericAccessObjectManager
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.PropertiesBase
import org.sculptor.generator.util.SingularPluralConverter
import org.slf4j.Logger
import org.slf4j.LoggerFactory

class ExtensionModule extends AbstractModule {
	
	private static final val Logger LOG = LoggerFactory::getLogger(typeof(ExtensionModule))

	// Cartridges configured for this module
	protected var Iterable<Cartridge> cartridges

	override protected configure() {
		// Util
		bind(typeof(PropertiesBase)).in(Scopes::SINGLETON)
		bind(typeof(SingularPluralConverter)).in(Scopes::SINGLETON)
		bind(typeof(HelperBase)).in(Scopes::SINGLETON)
		bind(typeof(DbHelperBase)).in(Scopes::SINGLETON)

		// Extensioins
		bind(typeof(Properties)).in(Scopes::SINGLETON)
		bind(typeof(Helper)).in(Scopes::SINGLETON)
		bind(typeof(DbHelper)).in(Scopes::SINGLETON)
		bind(typeof(UmlGraphHelper)).in(Scopes::SINGLETON)
		bind(typeof(GenericAccessObjectManager)).in(Scopes::SINGLETON)
		
		initializeCartridges()
	}
	
	/**
	 * @return list of Sculptor generator classes (e.g. templates or other classes that get bound) that may be overridden or extended
	 */
	def List<Class<?>> getGeneratorClasses() {
		ImmutableList::of()
	}
	
	/**
	 * Initialize cartridges that have been enabled, binding their extension classes and other classes that are part of the cartridge
	 */
	def initializeCartridges() {
		val cartridgeNames = getCartridgeNames()
		cartridges = cartridgeNames.map[getCartridge].filter[it != null].toList
		
		// Bind cartridge additional classes
		cartridges.forEach[bindCartridgeClasses]
		
		// Look for and bind cartridge generator extension classes
		generatorClasses.forEach[ generatorClass | 
			cartridges.forEach[ cartridge |
				val extensionClass = findExtensionClass(cartridge, generatorClass)
				if(extensionClass != null) {
					LOG.info("Binding extension class "+ extensionClass + " for " + generatorClass)
					bind(extensionClass as Class<?>).in(Scopes::SINGLETON)
				}
			]
		]
	}
	
	
//	/**
//	 * @return Cartridge instances for every cartridge that has been configured and could be instantiated
//	 */
//	def Iterable<Cartridge> getCartridges() {
//	}

	
	/**
	 * @return Cartridge instance corresponding to class name.  Null if not able to instantiate for any reason.
	 */
	def Cartridge getCartridge(String cartridgeClassName) {
		try {
			val cartridgeClass = Class::forName(cartridgeClassName)
			if (typeof(Cartridge).isAssignableFrom(cartridgeClass)) {
				LOG.info("Adding cartridge {}", cartridgeClassName);
				val clz = cartridgeClass as Class<? extends Cartridge>
				return clz.newInstance
			} else {
				LOG.error("Cartridge {} has to be inherited from org.sculptor.generator.Cartridge -> skipping cartridge",
					cartridgeClassName)
			}
		} catch (ClassNotFoundException e) {
			LOG.error("Could not find cartridge class {} -> skipping cartridge", cartridgeClassName);
		} catch (InstantiationException e) {
			LOG.error("Error instantiating cartridge " + cartridgeClassName + " -> skipping cartridge", e);
		} catch (IllegalAccessException e) {
			LOG.error("Error instantiating cartridge " + cartridgeClassName + " -> skipping cartridge", e);
		}

		null
	}
	
	/**
	 * Get the configured cartridge names, including both internal Sculptor cartridges, and cartridges configured by
	 * application.
	 * TODO: Implement by getting list of cartridge classes from properties
	 * 
	 * @return List of cartridge fully qualified class names
	 */
	def List<String> getCartridgeNames() {
		ImmutableList::of();
	}

	/**
	 * Bind custom classes used in each cartridge implementation so they can access other Sculptor generator classes
	 */
	def bindCartridgeClasses(Cartridge cartridge) {
		cartridge.classesToBind.forEach[
			bind(it as Class<?>).in(Scopes::SINGLETON)
		]
	}
	
	/**
	 * Find a cartridge extension class for the given Sculptor template class.
	 * The extension class is expected to be in the cartridge's extensions package, and named <template class name>Extension
	 */
	def <T> Class<? extends ChainLink<?>> findExtensionClass(Cartridge cartridge, Class<T> clazz) {
		val clsName = clazz.name
		
		// Generator base class must exist, and extension class must extend it
		val baseClassName = clazz.name + "Base"
		
		// TODO: Remove this check once all base classes are generated via active annotation
		try {
			Class::forName(baseClassName)
		} catch (ClassNotFoundException e) {
			return null
		}
		
		val baseClass = Class::forName(baseClassName)
		
		val extensionName = cartridge.extensionsPackage + "." + clazz.simpleName + "Extension"
		
		try {
			val extensionClass = Class::forName(extensionName)
			if (baseClass.isAssignableFrom(extensionClass)) {
				LOG.info("Found extension class {} for {}", extensionName, clsName)
				return (extensionClass as Class<? extends ChainLink<?>>)				
			} else {
				LOG.error("Extension {} has to be inherited from {}", extensionName, clsName)
				throw new IllegalArgumentException("Extension " + extensionName + " has to be inherited from " + clsName)
			}
		} catch (ClassNotFoundException e) {
			// Ignore error
		}

		null
	}
	
	def List<Class<? extends ChainLink<?>>> getExtensionsFor(Class<? extends ChainLink<?>> generatorClass) {
		val extensionClasses = cartridges.map[cartridge | findExtensionClass(cartridge, generatorClass)].filter[it != null].toList
		
		// Add generator class itself to the end
		extensionClasses.add(generatorClass)
		
		extensionClasses
	}
	
	/**
	 * Chain the extension classes that extend ChainLink together, including the Sculptor generator class, which gets added to the end of the chain.
	 */
	def void chainGeneratorExtensions(Injector injector) {
		generatorClasses.forEach[ generatorClass | 
			if(typeof(ChainLink).isAssignableFrom(generatorClass)) {				
				val extensionClasses = getExtensionsFor(generatorClass as Class<? extends ChainLink<?>>)
				if(extensionClasses.size > 1) {
					val extensionInstances = extensionClasses.map[getExtensionInstance(injector, it)]
				
					// The last instance, the Sculptor generator class, doesn't have a 'next'
					extensionInstances.subList(0, extensionInstances.size-1).forEach[extensionInstance, i|
						val nextExtensionInstance = extensionInstances.get(i+1)
						LOG.debug("Chaining extension " + extensionInstance + " to " + nextExtensionInstance)
						extensionInstance.setNext(nextExtensionInstance)
					]
				}
			}
			
		]

	}
	
	def protected ChainLink<?> getExtensionInstance(Injector injector, Class<? extends ChainLink<?>> extensionClass) {
		val Class<?> clz = extensionClass as Class<?>
		
		injector.getInstance(clz as Class<?>) as ChainLink<?>
	}
}