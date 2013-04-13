package org.sculptor.generator

import com.google.common.collect.ImmutableList
import java.util.List
import org.sculptor.generator.util.ChainLink
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/**
 * Base class for cartridges that extends Sculptor functionality.
 * 
 * A cartridge may extend any Sculptor template by supplying a class that extends the template base class (<template name>Base) and
 * placing it in the cartridge's extensions package ( see getExtensionPackage() ).  Sculptor will automatically bind any found extensions.
 * 
 * Additionally, any additional classes that the cartridge needs may be listed in getClassesToBind(), and they will be bound as well.
 */
class Cartridge {
	
	private static final val Logger LOG = LoggerFactory::getLogger(typeof(Cartridge))
	
	// Suffix to find extension clasess.  By default "Extension"
	private val String extensionSuffix
	
	// package where all cartridge extensions can be found.  By default same package as concrete cartridge class
	private val String basePackage
	
	new() {
		extensionSuffix = "Extension"
		basePackage = this.class.package.name
	}
	
	new(String extensionSuffix, String basePackage) {
		this.extensionSuffix = extensionSuffix
		this.basePackage = basePackage
	}
	
	
	/**
	 * @return List of classes that are used in cartridge that must be bound via dependency injection.
	 * This should NOT include extensions of Sculptor classes, which are automatically bound.
	 */
	def List<Class<?>> getClassesToBind() {
		return ImmutableList::of()
	}

	/**
	 * Find a cartridge extension class for the given Sculptor template class.
	 * The extension class is expected to be in the cartridge's extensions package, and named <template class name>Extension
	 */
	def <T> Class<? extends ChainLink<?>> findExtensionClass(Class<T> clazz) {
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

		val extensionName = basePackage + clsName.substring("org.sculptor.generator".length) + extensionSuffix
		
		if(LOG.debugEnabled) {
			LOG.debug('''Looking for extension class at «extensionName»''')	
		}
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
	
}