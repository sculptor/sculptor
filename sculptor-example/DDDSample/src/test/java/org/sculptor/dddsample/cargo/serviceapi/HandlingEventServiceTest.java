package org.sculptor.dddsample.cargo.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;

import org.joda.time.DateTime;
import org.junit.Test;
import org.sculptor.dddsample.cargo.domain.HandlingEvent;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.cargo.domain.Type;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class HandlingEventServiceTest extends AbstractDbUnitJpaTests implements HandlingEventServiceTestBase {
    private HandlingEventService handlingEventService;

    @Autowired
    public void setHandlingEventService(HandlingEventService handlingEventService) {
        this.handlingEventService = handlingEventService;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testRegister() throws Exception {
        final DateTime date = new DateTime();
        final TrackingId trackingId = trackingId("ABC");
        final CarrierMovementId carrierMovementId = new CarrierMovementId("AAA_BBB");
        final UnLocode unLocode = new UnLocode("SESTO");

        int countBefore = countRowsInTable(HandlingEvent.class, "where cargo = 2");
        assertEquals(0, countBefore);

        handlingEventService.register(getServiceContext(), date, trackingId, carrierMovementId, unLocode, Type.LOAD);

        int countAfter = countRowsInTable(HandlingEvent.class, "where cargo = 2");
        assertEquals(1, countAfter);
    }
}
