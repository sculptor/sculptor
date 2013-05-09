package org.sculptor.generator.transformation

import com.google.inject.Guice
import com.google.inject.Injector
import com.google.inject.Provider
import org.eclipse.xtext.junit4.InjectWith
import org.eclipselabs.xtext.utils.unittesting.XtextRunner2
import org.eclipselabs.xtext.utils.unittesting.XtextTest
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith
import org.sculptor.dsl.SculptordslInjectorProvider
import org.sculptor.dsl.sculptordsl.DslApplication
import org.sculptor.dsl.sculptordsl.DslModel
import org.sculptor.generator.chain.ChainOverrideAwareModule
import org.sculptor.generator.ext.Helper
import org.sculptor.generator.transform.DslTransformation
import org.sculptor.generator.transform.Transformation
import org.sculptor.generator.util.HelperBase
import sculptormetamodel.Application
import sculptormetamodel.DomainEvent
import sculptormetamodel.Module

import static org.junit.Assert.*

import static extension org.sculptor.generator.GeneratorTestExtensions.*
import sculptormetamodel.CommandEvent
import sculptormetamodel.Consumer
import sculptormetamodel.ServiceOperation
import sculptormetamodel.Service

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class ShippingTransformationTest extends XtextTest {
	
	extension Helper helper

	extension HelperBase helperBase
	
	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app
	
	@Before
	def void setupDslModel() {
		
		System::setProperty("sculptor.generatorPropertiesLocation", "org/sculptor/generator/cartridge/mongodb/shipping-generator.properties");

		
		val uniLoadModule = new ChainOverrideAwareModule(#[typeof(DslTransformation), typeof(Transformation)])
		val Injector injector = Guice::createInjector(uniLoadModule)
		helper = injector.getInstance(typeof(Helper))
		helperBase = injector.getInstance(typeof(HelperBase))
		dslTransformProvider = injector.getProvider(typeof(DslTransformation))
		transformationProvider = injector.getProvider(typeof(Transformation))

		model = getDomainModel().app
		
		val dslTransformation = dslTransformProvider.get
		app = dslTransformation.transform(model)
		
		val transformation = transformationProvider.get
		app = transformation.modify(app)

	}

	def  getDomainModel() {
		
		testFileNoSerializer("shipping.btdesign")
		val dslModel = modelRoot as DslModel
		
		dslModel
	}
	

    private def coreModule() {
        app.modules.namedElement("core") as Module
    }

    private def Module curiousModule() {
        app.modules.namedElement("curious") as Module
    }

    private def statisticsModule() {
        app.modules.namedElement("statistics") as Module
    }

	@Test
	def void testAppTransformation() {
		assertNotNull(app)
		assertEquals(3, app.modules.size)
	}
	
    @Test
    def assertShipHasArrivedDomainEvent() {
        val event = coreModule.domainObjects.namedElement("ShipHasArrived") as DomainEvent
        assertOneAndOnlyOne(event.getReferences(), "port", "ship");
        assertFalse(event.isPersistent());
        assertEquals("org.sculptor.shipping.core.domain", event.domainPackage)
        assertOneAndOnlyOne(event.attributes, "recorded", "occurred");
    }


    @Test
    def assertRecordArrivalCommandEvent() {
        val event = coreModule.domainObjects.namedElement("RecordArrival") as CommandEvent
        assertOneAndOnlyOne(event.getReferences(), "port", "ship");
        assertFalse(event.isPersistent());
        assertEquals("org.sculptor.shipping.core.domain", event.domainPackage)
        assertOneAndOnlyOne(event.getAttributes(), "recorded", "occurred");
    }

    @Test
    def assertInspectorConsumer() {
        val consumer = curiousModule.consumers.namedElement("Inspector") as Consumer;
        assertEquals("shippingChannel", consumer.getSubscribe().getTopic());
        assertEquals("extraBus", consumer.getSubscribe().getEventBus());
        assertEquals("shippingChannel", consumer.getChannel());
    }

    @Test
    def assertStatisticsSubscriber() throws Exception {
        val service = statisticsModule.services.namedElement("Statistics");
        assertEquals("statisticsChannel", service.getSubscribe().getTopic());
        assertNull(service.getSubscribe().getEventBus());
        val op = service.operations.namedElement("receive") as ServiceOperation;
        assertNotNull(op);
        assertOneAndOnlyOne(op.getParameters(), "event");
    }
    
    @Test
    def assertPublishInReferenceDataService() {
        val service = coreModule.services.namedElement("ReferenceDataService") as Service;
        val op = service.operations.namedElement("saveShip") as ServiceOperation;
        assertNotNull(op.getPublish());
        assertEquals("shippingChannel", op.getPublish().getTopic());
        assertNotNull(op.getPublish().getEventType());
        assertEquals("SavedDomainObjectEvent", op.getPublish().getEventType().getName());
        assertNull(op.getPublish().getEventBus());
    }

    @Test
    def assertPublishToCommandBus() {
        val service = coreModule.services.namedElement("TrackingService") as Service
        val op = service.operations.namedElement("recordArrival2") as ServiceOperation
        assertNotNull(op.getPublish());
        assertEquals("shippingProcessor", op.getPublish().getTopic());
        assertNotNull(op.getPublish().getEventType());
        assertEquals("RecordArrival", op.getPublish().getEventType().getName());
        assertEquals("commandBus", op.getPublish().getEventBus());
    }


}