package org.sculptor.dddsample.location.serviceapi;

import org.junit.jupiter.api.Test;
import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.junit.jupiter.api.Assertions.assertThrows;

/**
 * Spring based transactional test with DbUnit support.
 */
public class LocationServiceTest extends AbstractDbUnitJpaTests implements LocationServiceTestBase {
    private LocationService locationService;

    @Autowired
    public void setLocationService(LocationService locationService) {
        this.locationService = locationService;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testFind() throws Exception {
        Location found = locationService.find(getServiceContext(), new UnLocode("USCHI"));
        assertNotNull(found);
    }

    @Test
    public void testNotFound() throws LocationNotFoundException {
        assertThrows(LocationNotFoundException.class, () -> {
            locationService.find(getServiceContext(), new UnLocode("ZZZZZ"));
        });
    }
}
