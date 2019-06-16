package org.sculptor.dddsample.cargo.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotNull;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.location.domain.SampleLocations.HELSINKI;
import static org.sculptor.dddsample.location.domain.SampleLocations.HONGKONG;

import java.util.List;

import org.joda.time.DateTime;
import org.junit.Test;
import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.domain.Itinerary;
import org.sculptor.dddsample.cargo.domain.Leg;
import org.sculptor.dddsample.cargo.domain.RouteSpecification;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class RoutingServiceTest extends AbstractDbUnitJpaTests implements RoutingServiceTestBase {
    private RoutingService routingService;

    @Autowired
    public void setRoutingService(RoutingService routingService) {
        this.routingService = routingService;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Override
    protected String getSequenceName() {
        if (JpaHelper.isJpaProviderHibernate(getEntityManager())) {
            return "hibernate_sequence";
        } else if (JpaHelper.isJpaProviderEclipselink(getEntityManager())) {
            return "SEQ_GEN";
        } else {
            return null;
        }
    }

    @Test
    public void testFetchRoutesForSpecification() throws Exception {
        TrackingId trackingId = trackingId("ABC");
        Cargo cargo = new Cargo(trackingId, HONGKONG, HELSINKI);
        RouteSpecification routeSpecification = RouteSpecification.forCargo(cargo, new DateTime());

        List<Itinerary> candidates = routingService
                .fetchRoutesForSpecification(getServiceContext(), routeSpecification);
        assertNotNull(candidates);

        for (Itinerary itinerary : candidates) {
            List<Leg> legs = itinerary.getLegs();
            assertNotNull(legs);
            assertFalse(legs.isEmpty());

            // Cargo origin and start of first leg should match
            assertEquals(cargo.getOrigin(), legs.get(0).getFrom());

            // Cargo final destination and last leg stop should match
            Location lastLegStop = legs.get(legs.size() - 1).getTo();
            assertEquals(cargo.getDestination(), lastLegStop);

            for (int i = 0; i < legs.size() - 1; i++) {
                // Assert that all legs are conencted
                assertEquals(legs.get(i).getTo(), legs.get(i + 1).getFrom());
            }
        }
    }
}
