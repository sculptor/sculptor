package org.sculptor.dddsample.cargo.serviceapi;

import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertTrue;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;

import java.util.List;

import org.junit.Test;
import org.sculptor.dddsample.cargo.domain.Itinerary;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class BookingServiceTest extends AbstractDbUnitJpaTests implements BookingServiceTestBase {
    private BookingService bookingService;

    @Autowired
    public void setBookingService(BookingService bookingService) {
        this.bookingService = bookingService;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testBookNewCargo() throws Exception {
        UnLocode fromUnlocode = new UnLocode("USCHI");
        UnLocode toUnlocode = new UnLocode("SESTO");
        TrackingId trackingId = bookingService.bookNewCargo(getServiceContext(), fromUnlocode, toUnlocode);
        assertNotNull(trackingId);
    }

    @Test
    public void testRequestPossibleRoutesForCargo() throws Exception {
        TrackingId trackingId = trackingId("FGH");
        List<Itinerary> itinaries = bookingService.requestPossibleRoutesForCargo(getServiceContext(), trackingId);
        assertNotNull(itinaries);
        assertTrue(itinaries.size() > 0);
    }

    @Test
    public void testAssignCargoToRoute() throws Exception {
        TrackingId trackingId = trackingId("XYZ");
        List<Itinerary> itinaries = bookingService.requestPossibleRoutesForCargo(getServiceContext(), trackingId);
        assertNotNull(itinaries);
        assertTrue(itinaries.size() > 0);
        bookingService.assignCargoToRoute(getServiceContext(), trackingId, itinaries.get(0));
    }
}
