package org.sculptor.dddsample.cargo.serviceimpl;

import java.util.ArrayList;
import java.util.List;

import org.apache.commons.lang.Validate;
import org.sculptor.dddsample.cargo.domain.Itinerary;
import org.sculptor.dddsample.cargo.domain.Leg;
import org.sculptor.dddsample.cargo.domain.RouteSpecification;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;
import org.sculptor.dddsample.carrier.exception.CarrierMovementNotFoundException;
import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.sculptor.dddsample.routing.domain.TransitEdge;
import org.sculptor.dddsample.routing.domain.TransitPath;
import org.sculptor.framework.errorhandling.ServiceContext;
import org.sculptor.framework.errorhandling.ServiceContextStore;
import org.springframework.stereotype.Service;

/**
 * Implementation of RoutingService.
 */
@Service("routingService")
public class RoutingServiceImpl extends RoutingServiceImplBase {

    public RoutingServiceImpl() {
    }

    public List<Itinerary> fetchRoutesForSpecification(ServiceContext ctx,
        RouteSpecification routeSpecification) throws LocationNotFoundException {

        final Location origin = routeSpecification.getOrigin();
        final Location destination = routeSpecification.getDestination();

        final List<TransitPath> transitPaths = findShortestPath(ctx, 
          origin.getUnLocode().getUnlocode(),
          destination.getUnLocode().getUnlocode()
        );
        
        saveUnknownCarrierMovements(transitPaths);
        
        final List<Itinerary> itineraries = new ArrayList<Itinerary>(transitPaths.size());

        for (TransitPath transitPath : transitPaths) {
          final Itinerary itinerary = toItinerary(transitPath);
          itineraries.add(itinerary);
        }

        return itineraries;

    }
    
    private void saveUnknownCarrierMovements(List<TransitPath> paths) throws LocationNotFoundException {
        for (TransitPath each : paths) {
            saveUnknownCarrierMovements(each);
        }
    }
    
    private void saveUnknownCarrierMovements(TransitPath path) throws LocationNotFoundException {
        for (TransitEdge each : path.getTransitEdges()) {
            saveUnknownCarrierMovements(each);
        }
    }

    private void saveUnknownCarrierMovements(TransitEdge edge) throws LocationNotFoundException {
        ServiceContext ctx = ServiceContextStore.get();
        try {
            getCarrierService().find(ctx, new CarrierMovementId(edge.getCarrierMovementId()));
        } catch (CarrierMovementNotFoundException e) {
            Location fromLocation = findLocation(ctx, new UnLocode(edge.getFromUnLocode()));
            Validate.notNull(fromLocation);
            Location toLocation = findLocation(ctx, new UnLocode(edge.getToUnLocode()));
            Validate.notNull(toLocation);
            getCarrierService().save(ctx, 
                    new CarrierMovement(new CarrierMovementId(edge.getCarrierMovementId()),
                            fromLocation, toLocation));
        }
        
    }

    private Itinerary toItinerary(TransitPath transitPath) throws LocationNotFoundException {
        List<Leg> legs = new ArrayList<Leg>(transitPath.getTransitEdges().size());
        for (TransitEdge edge : transitPath.getTransitEdges()) {
          legs.add(toLeg(edge));
        }
        return new Itinerary(legs);
      }

      private Leg toLeg(TransitEdge edge) throws LocationNotFoundException {
          try {
            return new Leg(
              findCarrierMovement(ServiceContextStore.get(), new CarrierMovementId(edge.getCarrierMovementId())),
              findLocation(ServiceContextStore.get(), new UnLocode(edge.getFromUnLocode())),
              findLocation(ServiceContextStore.get(), new UnLocode(edge.getToUnLocode()))
            );
          } catch (CarrierMovementNotFoundException e) {
              throw new IllegalStateException("Inconsistent CarrierMovement: " + e.getMessage(), e);
          }
      }
}
