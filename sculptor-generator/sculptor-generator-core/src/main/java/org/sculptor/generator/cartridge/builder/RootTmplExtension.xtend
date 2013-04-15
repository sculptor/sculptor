package org.sculptor.generator.cartridge.builder

import com.google.inject.Inject
import org.sculptor.generator.cartridge.builder.BuilderTmpl
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.RootTmpl
import sculptormetamodel.Application

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
