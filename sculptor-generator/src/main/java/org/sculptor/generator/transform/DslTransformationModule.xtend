package org.sculptor.generator.transform

import org.sculptor.generator.ext.ExtensionModule

class DslTransformationModule extends ExtensionModule {
	override protected configure() {
		super.configure()
		bind(typeof(DslTransformation))
		bind(typeof(Transformation))
	}
}