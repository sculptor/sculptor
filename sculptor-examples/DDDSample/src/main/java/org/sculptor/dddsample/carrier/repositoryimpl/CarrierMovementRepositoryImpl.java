package org.sculptor.dddsample.carrier.repositoryimpl;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;
import org.sculptor.dddsample.carrier.domain.CarrierMovementRepository;
import org.sculptor.dddsample.carrier.exception.CarrierMovementNotFoundException;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for CarrierMovement
 */
@Repository("carrierMovementRepository")
public class CarrierMovementRepositoryImpl extends CarrierMovementRepositoryBase
    implements CarrierMovementRepository {
    public CarrierMovementRepositoryImpl() {
    }

    public CarrierMovement find(CarrierMovementId carrierMovementId) throws CarrierMovementNotFoundException {
        Set<CarrierMovementId> keys = new HashSet<CarrierMovementId>();
        keys.add(carrierMovementId);
        Map<CarrierMovementId, CarrierMovement> result = findByNaturalKeys(keys);
        if (result.get(carrierMovementId) == null) {
            throw new CarrierMovementNotFoundException("Unknown carrier movement: " + carrierMovementId);
        }
        return result.get(carrierMovementId);
    }
}
