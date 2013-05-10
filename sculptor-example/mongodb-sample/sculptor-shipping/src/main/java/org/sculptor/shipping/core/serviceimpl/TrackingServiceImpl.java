package org.sculptor.shipping.core.serviceimpl;

import org.joda.time.DateTime;
import org.sculptor.framework.errorhandling.ApplicationException;
import org.sculptor.shipping.core.domain.Cargo;
import org.sculptor.shipping.core.domain.Port;
import org.sculptor.shipping.core.domain.Ship;
import org.sculptor.shipping.core.domain.ShipId;
import org.sculptor.shipping.core.domain.UnLocode;
import org.springframework.stereotype.Service;

/**
 * Implementation of TrackingService.
 */
@Service("trackingService")
public class TrackingServiceImpl extends TrackingServiceImplBase {
    public TrackingServiceImpl() {
    }

    public void recordArrival(DateTime occurred, ShipId shipId, UnLocode portId) {
        try {
            Ship ship = getShipRepository().findByKey(shipId);
            Port port = getReferenceDataService().getPort(portId);
            ship.arrival(port);
            getShipRepository().save(ship);
        } catch (ApplicationException e) {
            throw new IllegalStateException(e.getMessage(), e);
        }
    }

    public void recordDeparture(DateTime occurred, ShipId shipId, UnLocode portId) {
        try {
            Ship ship = getShipRepository().findByKey(shipId);
            Port port = getReferenceDataService().getPort(portId);
            ship.departure(port);
            getShipRepository().save(ship);
        } catch (ApplicationException e) {
            throw new IllegalStateException(e.getMessage(), e);
        }
    }

    public void recordLoad(DateTime occurred, ShipId shipId, String cargoId) {
        try {
            Ship ship = getShipRepository().findByKey(shipId);
            Cargo cargo = getReferenceDataService().getCargo(cargoId);
            ship.load(cargo);
            getShipRepository().save(ship);
        } catch (ApplicationException e) {
            throw new IllegalStateException(e.getMessage(), e);
        }
    }

    public void recordUnload(DateTime occurred, ShipId shipId, String cargoId) {
        try {
            Ship ship = getShipRepository().findByKey(shipId);
            Cargo cargo = getReferenceDataService().getCargo(cargoId);
            ship.unload(cargo);
            getShipRepository().save(ship);
        } catch (ApplicationException e) {
            throw new IllegalStateException(e.getMessage(), e);
        }
    }
}
