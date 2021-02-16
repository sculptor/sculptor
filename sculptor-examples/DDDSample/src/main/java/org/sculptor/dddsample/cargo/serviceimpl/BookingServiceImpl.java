package org.sculptor.dddsample.cargo.serviceimpl;

import java.util.List;

import org.apache.commons.lang3.Validate;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.joda.time.DateTime;
import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.domain.Itinerary;
import org.sculptor.dddsample.cargo.domain.RouteSpecification;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;
import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.sculptor.framework.context.ServiceContext;
import org.springframework.stereotype.Service;

/**
 * Implementation of BookingService.
 */
@Service("bookingService")
public class BookingServiceImpl extends BookingServiceImplBase {
    private static final Log LOG = LogFactory.getLog(BookingServiceImpl.class);

    public BookingServiceImpl() {
    }

    public TrackingId bookNewCargo(ServiceContext ctx, UnLocode originCode,
        UnLocode destinationCode) throws LocationNotFoundException {

        Validate.notNull(originCode);
        Validate.notNull(destinationCode);

        final TrackingId trackingId = getCargoRepository().nextTrackingId();
        final Location origin = findLocation(ctx, originCode);
        final Location destination = findLocation(ctx, destinationCode);
        Cargo cargo = new Cargo(trackingId, origin, destination);

        getCargoRepository().save(cargo);
        LOG.info("Registered new cargo with tracking id " + cargo.getTrackingId().getIdentifier());

        return cargo.getTrackingId();

    }

    public List<Itinerary> requestPossibleRoutesForCargo(ServiceContext ctx,
        TrackingId trackingId) throws CargoNotFoundException, LocationNotFoundException {

        Validate.notNull(trackingId);
        
        final Cargo cargo = getCargoRepository().find(trackingId);
        final RouteSpecification routeSpecification = RouteSpecification.forCargo(cargo, new DateTime());

        return fetchRoutes(ctx, routeSpecification);

    }

    public void assignCargoToRoute(ServiceContext ctx, TrackingId trackingId,
        Itinerary itinerary) throws CargoNotFoundException {

        Validate.notNull(trackingId);
        Validate.notNull(itinerary);

        final Cargo cargo = getCargoRepository().find(trackingId);

        cargo.attachItinerary(itinerary);
        getCargoRepository().save(cargo);

        LOG.info("Assigned cargo " + trackingId + " to new route");

    }
}
