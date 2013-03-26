package org.sculptor.generator.transform

import org.sculptor.generator.ext.ExtensionModule
import org.sculptor.generator.ext.ModelLoadExtensions

class DslTransformationModule extends ExtensionModule {
	override protected configure() {
		super.configure()
		bind(typeof(DslTransformation))
		bind(typeof(Transformation))
		bind(typeof(ModelLoadExtensions))
	}
}