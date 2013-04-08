package org.sculptor.generator

import com.google.common.collect.ImmutableList
import com.google.inject.AbstractModule
import java.util.List

/**
 * Base class for cartridges that extends Sculptor functionality.
 * 
 * A cartridge may extend any Sculptor template by supplying a class that extends the template base class (<template name>Base) and
 * placing it in the cartridge's extensions package ( see getExtensionPackage() ).  Sculptor will automatically bind any found extensions.
 * 
 * Additionally, any additional classes that the cartridge needs may be listed in getClassesToBind(), and they will be bound as well.
 */
abstract class Cartridge extends AbstractModule {
	
	/**
	 * @return package where all cartridge extensions can be found.  By default same package as concrete cartridge class.
	 */
	def String getExtensionsPackage() {
		this.class.package.name;
	}
	
	/**
	 * @return List of classes that are used in cartridge that must be bound via dependency injection.
	 * This should NOT include extensions of Sculptor classes, which are automatically bound.
	 */
	def List<Class<?>> getClassesToBind() {
		return ImmutableList::of()
	}
	
}