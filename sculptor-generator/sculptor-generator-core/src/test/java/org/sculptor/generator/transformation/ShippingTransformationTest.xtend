/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

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
import sculptormetamodel.CommandEvent
import sculptormetamodel.DomainEvent
import sculptormetamodel.Module

import static org.junit.Assert.*

import static extension org.sculptor.generator.GeneratorTestExtensions.*

@RunWith(typeof(XtextRunner2))
@InjectWith(typeof(SculptordslInjectorProvider))
class ShippingTransformationTest extends XtextTest {

	static val BASE_PACKAGE = "org.sculptor.example.shipping"

	extension Helper helper

	extension HelperBase helperBase
	
	var DslApplication model
	var Provider<DslTransformation> dslTransformProvider
	var Provider<Transformation> transformationProvider
	var Application app
	
	@Before
	def void setupDslModel() {
		
		System::setProperty("sculptor.generatorPropertiesLocation", "generator-tests/shipping/sculptor-generator.properties");

		
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
		
		testFileNoSerializer("generator-tests/shipping/model.btdesign")
		val dslModel = modelRoot as DslModel
		
		dslModel
	}
	

    private def coreModule() {
        app.modules.namedElement("core")
    }

    private def Module curiousModule() {
        app.modules.namedElement("curious")
    }

    private def statisticsModule() {
        app.modules.namedElement("statistics")
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
        assertEquals(BASE_PACKAGE + ".core.domain", event.domainPackage)
        assertOneAndOnlyOne(event.attributes, "recorded", "occurred");
    }

    @Test
    def assertRecordArrivalCommandEvent() {
        val event = coreModule.domainObjects.namedElement("RecordArrival") as CommandEvent
        assertOneAndOnlyOne(event.getReferences(), "port", "ship");
        assertFalse(event.isPersistent());
        assertEquals(BASE_PACKAGE + ".core.domain", event.domainPackage)
        assertOneAndOnlyOne(event.getAttributes(), "recorded", "occurred");
    }

    @Test
    def assertInspectorConsumer() {
        val consumer = curiousModule.consumers.namedElement("Inspector") 
        assertEquals("shippingChannel", consumer.getSubscribe().getTopic());
        assertEquals("extraBus", consumer.getSubscribe().getEventBus());
        assertEquals("shippingChannel", consumer.getChannel());
    }

    @Test
    def assertStatisticsSubscriber() throws Exception {
        val service = statisticsModule.services.namedElement("Statistics");
        assertEquals("statisticsChannel", service.getSubscribe().getTopic());
        assertNull(service.getSubscribe().getEventBus());
        val op = service.operations.namedElement("receive")
        assertNotNull(op);
        assertOneAndOnlyOne(op.getParameters(), "event");
    }
    
    @Test
    def assertPublishInReferenceDataService() {
        val service = coreModule.services.namedElement("ReferenceDataService")
        val op = service.operations.namedElement("saveShip")
        assertNotNull(op.getPublish());
        assertEquals("shippingChannel", op.getPublish().getTopic());
        assertNotNull(op.getPublish().getEventType());
        assertEquals("SavedDomainObjectEvent", op.getPublish().getEventType().getName());
        assertNull(op.getPublish().getEventBus());
    }

    @Test
    def assertPublishToCommandBus() {
        val service = coreModule.services.namedElement("TrackingService")
        val op = service.operations.namedElement("recordArrival2")
        assertNotNull(op.getPublish());
        assertEquals("shippingProcessor", op.getPublish().getTopic());
        assertNotNull(op.getPublish().getEventType());
        assertEquals("RecordArrival", op.getPublish().getEventType().getName());
        assertEquals("commandBus", op.getPublish().getEventBus());
    }

}