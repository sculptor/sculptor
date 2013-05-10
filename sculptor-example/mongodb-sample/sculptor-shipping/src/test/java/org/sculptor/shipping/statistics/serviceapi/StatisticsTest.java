package org.sculptor.shipping.statistics.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.sculptor.shipping.core.domain.ShipId.shipId;
import static org.sculptor.shipping.core.domain.UnLocode.unLocode;

import java.util.Set;

import org.joda.time.DateTime;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.framework.event.EventBus;
import org.sculptor.shipping.core.domain.Country;
import org.sculptor.shipping.core.domain.Port;
import org.sculptor.shipping.core.domain.ShipHasArrived;
import org.sculptor.shipping.core.domain.ShipId;
import org.sculptor.shipping.core.serviceapi.ReferenceDataService;
import org.sculptor.shipping.statistics.serviceapi.Statistics;
import org.sculptor.shipping.statistics.serviceapi.StatisticsTestBase;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;

/**
 * Spring based test with MongoDB.
 */
@RunWith(org.springframework.test.context.junit4.SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class StatisticsTest extends AbstractJUnit4SpringContextTests implements StatisticsTestBase {
    @Autowired
    private DbManager dbManager;
    @Autowired
    private Statistics statistics;

    @Autowired
    // @Qualifier("camelEventBusImpl")
    @Qualifier("eventBus")
    private EventBus eventBus;

    @Autowired
    private ReferenceDataService referenceDataService;

    private Port sfo;
    private ShipId kr;

    @Before
    public void initTestData() {
        kr = shipId("KR");
        referenceDataService.createShip(kr, "King Roy");

        sfo = new Port(unLocode("USSFO"));
        sfo.setCity("San Francisco");
        sfo.setCountry(Country.US);
        referenceDataService.savePort(sfo);

        statistics.reset();
    }

    @Before
    public void initDbManagerThreadInstance() throws Exception {
        // to be able to do lazy loading of associations inside test class
        DbManager.setThreadInstance(dbManager);
    }

    @After
    public void dropDatabase() {
        Set<String> names = dbManager.getDB().getCollectionNames();
        for (String each : names) {
            if (!each.startsWith("system")) {
                dbManager.getDB().getCollection(each).drop();
            }
        }

        // dbManager.getDB().dropDatabase();
    }

    @Override
    @Test
    public void testConsume() throws Exception {

        ShipHasArrived arrivalEvent = createShipArrivedEvent();
        eventBus.publish("shippingChannel", arrivalEvent);

        // TODO would like to use some kind of CountDownLatch mechanism,
        // but it is hard, since events might be serialized
        Thread.sleep(1500);

        assertEquals(1, statistics.getShipsInPort(sfo.getUnlocode()));
    }

    private ShipHasArrived createShipArrivedEvent() {
        DateTime date = dateTime(2000, 01, 01);
        ShipHasArrived arrivalEvent = new ShipHasArrived(date, date, kr, sfo);
        return arrivalEvent;
    }

    private DateTime dateTime(int year, int month, int day) {
        return new DateTime(year, month, day, 0, 0, 0, 0);
    }

    @Test
    @Override
    public void testGetShipsInPort() throws Exception {
        statistics.receive(createShipArrivedEvent());
        assertEquals(1, statistics.getShipsInPort(sfo.getUnlocode()));
    }

    @Override
    public void testReset() throws Exception {
    }

    @Override
    public void testReceive() throws Exception {
        // TODO Auto-generated method stub

    }

}
