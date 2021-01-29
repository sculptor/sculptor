package org.sculptor.shipping.statistics.serviceapi;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.sculptor.shipping.core.domain.ShipId.shipId;
import static org.sculptor.shipping.core.domain.UnLocode.unLocode;

import java.util.Set;

import org.joda.time.DateTime;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
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
import org.springframework.test.context.junit.jupiter.SpringExtension;

/**
 * Spring based test with MongoDB.
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class StatisticsTest implements StatisticsTestBase {
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

    @BeforeEach
    public void initTestData() {
        kr = shipId("KR");
        referenceDataService.createShip(kr, "King Roy");

        sfo = new Port(unLocode("USSFO"));
        sfo.setCity("San Francisco");
        sfo.setCountry(Country.US);
        referenceDataService.savePort(sfo);

        statistics.reset();
    }

    @BeforeEach
    public void initDbManagerThreadInstance() throws Exception {
        // to be able to do lazy loading of associations inside test class
        DbManager.setThreadInstance(dbManager);
    }

    @AfterEach
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
