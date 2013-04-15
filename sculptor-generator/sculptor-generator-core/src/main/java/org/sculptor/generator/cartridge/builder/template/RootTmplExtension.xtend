package org.sculptor.generator.cartridge.builder.template

import com.google.inject.Inject
import org.sculptor.generator.cartridge.builder.BuilderTmpl
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import sculptormetamodel.Application
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.template.RootTmpl

@ChainOverride(
//	baseClass=typeof(RootTmpl)
)
class RootTmplExtension extends RootTmpl {

	@Inject public var BuilderTmpl builderTmpl

	@Inject extension Properties properties
	@Inject extension Helper helper

	override def Root(Application it) {
		if (isDomainObjectToBeGenerated()) {
			getAllDomainObjects(false).filter[e | e.needsBuilder()].forEach[e | builderTmpl.builder(e)]
		}
		super.Root(it) // or next.Root(it)
	}
}
