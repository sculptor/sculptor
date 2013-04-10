package org.sculptor.generator.cartridge.builder

import com.google.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import sculptormetamodel.Application
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.template.RootTmplBase

@ChainOverride(
//	baseClass=typeof(RootTmpl)
)
class RootTmplExtension extends RootTmplBase {

	@Inject private var BuilderTmpl builderTmpl

	@Inject extension Properties properties
	@Inject extension Helper helper

	override def Root(Application it) {
		if (isDomainObjectToBeGenerated() && isBuilderToBeGenerated()) {
			getAllDomainObjects(false).filter[e | e.needsBuilder()].map[builderTmpl.builder(it)]
		}
		super.Root(it) // or next.Root(it)
	}
}