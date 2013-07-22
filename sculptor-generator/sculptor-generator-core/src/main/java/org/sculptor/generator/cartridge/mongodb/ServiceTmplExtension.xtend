package org.sculptor.generator.cartridge.mongodb

import com.google.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Properties
import org.sculptor.generator.template.service.ServiceTmpl
import org.slf4j.Logger
import org.slf4j.LoggerFactory
import sculptormetamodel.Service

@ChainOverride
class ServiceTmplExtension extends ServiceTmpl {

	private static final Logger LOG = LoggerFactory::getLogger(typeof(ServiceTmplExtension));

	@Inject private var MongoDbServiceTestTmpl mongoDbServiceTestTmpl

	@Inject extension Properties properties

	override String service(Service it) {
		LOG.debug("service()")
		if (isTestToBeGenerated() && mongoDb()) {
			mongoDbServiceTestTmpl.serviceJUnitSubclassMongoDb(it);
		}
		
		next_service(it)
		""
	}
}
