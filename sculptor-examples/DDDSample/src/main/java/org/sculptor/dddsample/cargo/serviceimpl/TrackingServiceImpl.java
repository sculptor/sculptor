package org.sculptor.dddsample.cargo.serviceimpl;

import org.apache.commons.lang3.Validate;
import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;
import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;
import org.sculptor.framework.context.ServiceContext;
import org.springframework.stereotype.Service;

/**
 * Implementation of TrackingService.
 */
@Service("trackingService")
public class TrackingServiceImpl extends TrackingServiceImplBase {
    private static final Log LOG = LogFactory.getLog(TrackingServiceImpl.class);

    public TrackingServiceImpl() {
    }

    public Cargo track(ServiceContext ctx, TrackingId trackingId) throws CargoNotFoundException {
        Validate.notNull(trackingId);

        return getCargoRepository().find(trackingId, true);
    }

    public void inspectCargo(ServiceContext ctx, TrackingId trackingId) throws CargoNotFoundException {
        Validate.notNull(trackingId);

        try {
            final Cargo cargo = getCargoRepository().find(trackingId);
    
            if (cargo.isMisdirected()) {
                handleMisdirectedCargo(cargo);
            }
            if (cargo.isUnloadedAtDestination()) {
                notifyCustomerOfAvailability(cargo);
            }
        } catch (CargoNotFoundException e) {
            LOG.warn("Can't inspect non-existing cargo " + trackingId);
            throw e;
        }
    }

    private void notifyCustomerOfAvailability(Cargo cargo) {
        LOG.info("Cargo " + cargo.getTrackingId() + " has been unloaded " + "at its final destination "
                + cargo.getDestination());
    }

    private void handleMisdirectedCargo(Cargo cargo) {
        LOG.info("Cargo " + cargo.getTrackingId() + " has been misdirected. " + "Last event was "
                + cargo.deliveryHistory().lastEvent());
    }

}
