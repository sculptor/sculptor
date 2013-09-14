package org.sculptor.dddsample.cargo.serviceimpl;

import org.apache.commons.lang.Validate;
import org.joda.time.DateTime;
import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.domain.HandlingEvent;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.cargo.domain.Type;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;
import org.sculptor.dddsample.carrier.exception.CarrierMovementNotFoundException;
import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.sculptor.framework.errorhandling.ServiceContext;
import org.springframework.stereotype.Service;

/**
 * Implementation of HandlingEventService.
 */
@Service("handlingEventService")
public class HandlingEventServiceImpl extends HandlingEventServiceImplBase {
    
    private DomainEventNotifier domainEventNotifier;

    public HandlingEventServiceImpl() {
    }

    public void register(ServiceContext ctx, DateTime completionTime, TrackingId trackingId,
            CarrierMovementId carrierMovementId, UnLocode unlocode, Type type) throws LocationNotFoundException,
            CarrierMovementNotFoundException, CargoNotFoundException {

        // Carrier movement may be null for certain event types
        Validate.noNullElements(new Object[] { trackingId, unlocode, type });

        Cargo cargo = getCargoRepository().find(trackingId);

        final CarrierMovement carrierMovement = findCarrierMovement(ctx, carrierMovementId);
        final Location location = findLocation(ctx, unlocode);
        final DateTime registrationTime = new DateTime();

        final HandlingEvent event = new HandlingEvent(cargo, completionTime, registrationTime, type, location,
                carrierMovement);

        /*
         * NOTE: The cargo instance that's loaded and associated with the
         * handling event is in an inconsitent state, because the cargo delivery
         * history's collection of events does not contain the event created
         * here. However, this is not a problem, because cargo is in a different
         * aggregate from handling event.
         * 
         * The rules of an aggregate dictate that all consistency rules within
         * the aggregate are enforced synchronously in the transaction, but
         * consistency rules of other aggregates are enforced by asynchronous
         * updates, after the commit of this transaction.
         */
        getHandlingEventRepository().save(event);

        if (domainEventNotifier != null) {
            domainEventNotifier.cargoWasHandled(event);
        }
    }


    /**
     * Dependency injection
     */
    public void setDomainEventNotifier(DomainEventNotifier domainEventNotifier) {
        this.domainEventNotifier = domainEventNotifier;
    }
    
    

}
