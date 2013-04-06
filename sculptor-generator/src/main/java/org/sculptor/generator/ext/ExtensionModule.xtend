package org.sculptor.generator.ext

import com.google.inject.AbstractModule
import java.util.List
import org.sculptor.generator.Cartridge
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
		bind(typeof(PropertiesBase))
		bind(typeof(SingularPluralConverter))
		bind(typeof(HelperBase))
		bind(typeof(DbHelperBase))

		// Extensioins
		bind(typeof(Properties))
		bind(typeof(Helper))
		bind(typeof(DbHelper))
		bind(typeof(UmlGraphHelper))
		bind(typeof(GenericAccessObjectManager))
		
		//initializeCartridges()
	}
	
	/**
	 * @return list of Sculptor generator classes (e.g. templates or other classes that get bound) that may be overridden or extended
	 */
	def List<Class<?>> getGeneratorClasses() {
		
	}
	
	def initializeCartridges() {
		cartridges = getCartridges()
		
		// Bind cartridge additional classes
		cartridges.forEach[bindCartridgeClasses]
		
		// Bind cartridge extensions to Sculptor generator classes
		generatorClasses.forEach[ generatorClass | 
			cartridges.forEach[ cartridge |
				val extensionClass = findExtensionClass(cartridge, generatorClass)
				if(extensionClass != null) {
					bind(extensionClass as Class<?>)
				}
			]
		]
	}
	
	
	/**
	 * @return Cartridge instances for every cartridge that has been configured and could be instantiated
	 */
	def Iterable<Cartridge> getCartridges() {
		val cartridgeNames = getCartridgeNames()
		cartridgeNames.map[getCartridge].filter[it != null]
	}

	
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
		#["org.sculptor.generator.template.domain.BuilderCartridge"];
	}

	/**
	 * Bind custom classes used in each cartridge implementation so they can access other Sculptor generator classes
	 */
	def bindCartridgeClasses(Cartridge cartridge) {
		cartridge.classesToBind.forEach[
			bind
		]
	}
	
	/**
	 * Find a cartridge extension class for the given Sculptor template class.
	 * The extension class is expected to be in the cartridge's extensions package, and named <template class name>Extension
	 */
	def <T> Class<?> findExtensionClass(Cartridge cartridge, Class<T> clazz) {
		val clsName = clazz.name
		
		// Generator base class must exist, and extension class must extend it
		val baseClassName = clazz.name + "Base"
		val baseClass = Class::forName(baseClassName)
		
		val extensionName = cartridge.extensionsPackage + "." + clazz.simpleName + "Extension"
		
		try {
			val extensionClass = Class::forName(extensionName)
			if (baseClass.isAssignableFrom(extensionClass)) {
				LOG.info("Binding extension class {} for {}", extensionName, clsName)
				return (extensionClass as Class<?>)				
			} else {
				LOG.error("Extension {} has to be inherited from {}", extensionName, clsName)
				throw new IllegalArgumentException("Extension " + extensionName + " has to be inherited from " + clsName)
			}
		} catch (ClassNotFoundException e) {
			// Ignore error
		}

		null
	}
}