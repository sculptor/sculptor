package generator

import com.google.inject.Inject
import org.sculptor.generator.chain.ChainOverride
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.ext.Properties
import sculptormetamodel.DomainEvent

@ChainOverride
class HelperOverride extends Helper {

	@Inject extension Properties properties
	
	override dispatch String getImplementsInterfaceNames(DomainEvent domainObject) {
		fw("event.Event") + ", java.io.Serializable, org.sculptor.shipping.ShippingEvent"
	}


}