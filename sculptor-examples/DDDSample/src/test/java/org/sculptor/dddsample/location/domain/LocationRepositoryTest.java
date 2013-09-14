package org.sculptor.dddsample.location.domain;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import java.util.List;

import org.junit.Test;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

public class LocationRepositoryTest extends AbstractDbUnitJpaTests {
    private LocationRepository locationRepository;

    @Autowired
    public void setLocationRepository(LocationRepository locationRepository) {
        this.locationRepository = locationRepository;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testFind() throws Exception {
        final UnLocode melbourne = new UnLocode("AUMEL");
        Location location = locationRepository.find(melbourne);
        assertNotNull(location);
        assertEquals(melbourne, location.getUnLocode());
    }

    @Test(expected=LocationNotFoundException.class)
    public void testFindThrowingLocationNotFoundException() throws LocationNotFoundException {
        locationRepository.find(new UnLocode("NOLOC"));
    }

    @Test
    public void testFindAll() throws Exception {
        List<Location> allLocations = locationRepository.findAll();
        assertNotNull(allLocations);
        assertEquals(7, allLocations.size());
    }

}
