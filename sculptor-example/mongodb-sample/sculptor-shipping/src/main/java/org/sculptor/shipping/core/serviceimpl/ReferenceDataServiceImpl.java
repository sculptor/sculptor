package org.sculptor.shipping.core.serviceimpl;

import org.sculptor.shipping.core.domain.Cargo;
import org.sculptor.shipping.core.domain.Port;
import org.sculptor.shipping.core.domain.Ship;
import org.sculptor.shipping.core.domain.ShipId;
import org.springframework.stereotype.Service;

/**
 * Implementation of ReferenceDataService.
 */
@Service("referenceDataService")
public class ReferenceDataServiceImpl extends ReferenceDataServiceImplBase {
    public ReferenceDataServiceImpl() {
    }

    @Override
    public void createShip(ShipId shipId, String name) {
        Ship ship = Ship.createNew(shipId, name);
        getShipRepository().save(ship);
    }

    @Override
    public void savePort(Port port) {
        getPortRepository().save(port);
    }

    @Override
    public void saveCargo(Cargo cargo) {
        getCargoRepository().save(cargo);
    }

}
