package org.sculptor.generator.ext

import com.google.inject.AbstractModule
import org.sculptor.generator.util.PropertiesBase
import org.sculptor.generator.util.HelperBase
import org.sculptor.generator.util.DbHelperBase
import org.sculptor.generator.util.SingularPluralConverter
import org.sculptor.generator.util.GenericAccessObjectManager

class ExtensionModule extends AbstractModule {
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
	}
}