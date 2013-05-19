package org.sculptor.generator.cartridge.mongodb

import com.google.inject.Inject
import org.sculptor.generator.cartridge.builder.BuilderTmpl
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.RootTmpl
import sculptormetamodel.Application
import sculptormetamodel.BasicType

@ChainOverride
class RootTmplExtension extends RootTmpl {

	@Inject private var MongoDbMapperTmpl mongoDbMapperTmpl

	@Inject extension Properties properties
	@Inject extension Helper helper

	override root(Application it) {
		
		if (!modules.isEmpty && isRepositoryToBeGenerated()) {
			if (mongoDb()) {
				// it.getAllDomainObjects(false).filter(e | e.isPersistent() || e instanceof BasicType).forEach[mongoDbMapperTmpl.mongoDbMapper(it)]»
				it.getAllDomainObjects(false).filter(e | e.isPersistent() || e instanceof BasicType).forEach[mongoDbMapperTmpl.mongoDbMapper(it)]
			}
		}

		super.root(it)
	}

}
