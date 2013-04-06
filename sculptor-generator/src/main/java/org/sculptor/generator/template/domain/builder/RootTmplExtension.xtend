package org.sculptor.generator.template.domain.builder

import com.google.inject.Inject
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.RootTmplBase
import sculptormetamodel.Application

class RootTmplExtension extends RootTmplBase {

	@Inject private var BuilderTmpl builderTmpl

	@Inject extension Properties properties
	@Inject extension Helper helper


	override def Root(Application it) {
		if (isDomainObjectToBeGenerated() && isBuilderToBeGenerated()) {
			getAllDomainObjects(false).filter[e | e.needsBuilder()].map[builderTmpl.builder(it)]
		}
		this.next.Root(it)
	}
	
}