package org.sculptor.generator.cartridge.mongodb

import com.google.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.service.ServiceTmpl
import sculptormetamodel.Service

// Re-enable once problem with ServiceTmpl constructor and injection is fixed:  @ChainOverride
class ServiceTmplExtension /*extends ServiceTmpl*/ {

	@Inject private var MongoDbServiceTestTmpl mongoDbServiceTestTmpl

	@Inject extension Properties properties

//	override String service(Service it) {
//		if (isTestToBeGenerated() && mongoDb()) {
//			mongoDbServiceTestTmpl.serviceJUnitSubclassMongoDb(it);
//		}
//		
//		super.service(it)
//		""
//	}
}
