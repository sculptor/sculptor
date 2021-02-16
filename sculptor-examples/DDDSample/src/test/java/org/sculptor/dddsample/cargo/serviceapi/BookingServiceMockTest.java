package org.sculptor.dddsample.cargo.serviceapi;

import static org.easymock.EasyMock.createMock;
import static org.easymock.EasyMock.expect;
import static org.easymock.EasyMock.isA;
import static org.easymock.EasyMock.replay;
import static org.easymock.EasyMock.verify;
import static org.junit.jupiter.api.Assertions.*;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;
import static org.sculptor.dddsample.location.domain.SampleLocations.CHICAGO;
import static org.sculptor.dddsample.location.domain.SampleLocations.STOCKHOLM;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.domain.CargoRepository;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.cargo.serviceimpl.BookingServiceImpl;
import org.sculptor.dddsample.location.domain.LocationRepository;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.serviceimpl.LocationServiceImpl;
import org.sculptor.framework.context.JUnitServiceContextFactory;
import org.sculptor.framework.context.ServiceContext;
import org.springframework.test.util.ReflectionTestUtils;

public class BookingServiceMockTest {

    private final ServiceContext serviceContext = JUnitServiceContextFactory.createServiceContext();

    private BookingServiceImpl cargoService;
    private CargoRepository cargoRepository;
    private LocationRepository locationRepository;

    @BeforeEach
    protected void setUp() throws Exception {
        cargoService = new BookingServiceImpl();
        cargoRepository = createMock(CargoRepository.class);
        locationRepository = createMock(LocationRepository.class);
        ReflectionTestUtils.setField(cargoService, "cargoRepository", cargoRepository);
        LocationServiceImpl locationService = new LocationServiceImpl();
        ReflectionTestUtils.setField(locationService, "locationRepository", locationRepository);
        ReflectionTestUtils.setField(cargoService, "locationService", locationService);
    }

    @Test
    public void testRegisterNew() throws Exception {
        TrackingId expectedTrackingId = trackingId("TRK1");
        UnLocode fromUnlocode = new UnLocode("USCHI");
        UnLocode toUnlocode = new UnLocode("SESTO");

        expect(cargoRepository.nextTrackingId()).andReturn(expectedTrackingId);
        expect(locationRepository.find(fromUnlocode)).andReturn(CHICAGO);
        expect(locationRepository.find(toUnlocode)).andReturn(STOCKHOLM);
        expect(cargoRepository.save(isA(Cargo.class))).andReturn(null);

        replay(cargoRepository, locationRepository);

        TrackingId trackingId = cargoService.bookNewCargo(serviceContext, fromUnlocode, toUnlocode);
        assertEquals(expectedTrackingId, trackingId);
    }

    @Test
    public void testRegisterNewNullArguments() throws Exception {
        replay(cargoRepository, locationRepository);
        assertThrows(NullPointerException.class, () -> {
            cargoService.bookNewCargo(serviceContext, null, null);
            fail("Null arguments should not be allowed");
        });
    }

    @AfterEach
    protected void tearDown() throws Exception {
        verify(cargoRepository, locationRepository);
    }
}
