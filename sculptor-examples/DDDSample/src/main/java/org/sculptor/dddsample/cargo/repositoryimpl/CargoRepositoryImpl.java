package org.sculptor.dddsample.cargo.repositoryimpl;

import java.util.UUID;

import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.domain.CargoProperties;
import org.sculptor.dddsample.cargo.domain.CargoRepository;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;
import org.sculptor.framework.domain.AssociationSpecification;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for Cargo
 */
@Repository("cargoRepository")
public class CargoRepositoryImpl extends CargoRepositoryBase implements CargoRepository {

    public CargoRepositoryImpl() {
    }

    @Override
    public TrackingId nextTrackingId() {
        final String random = UUID.randomUUID().toString().toUpperCase();
        return new TrackingId(random.substring(0, random.indexOf("-")));
    }

    @Override
    public Cargo find(TrackingId trackingId, boolean loadDeliveryHistory) throws CargoNotFoundException {
        Cargo result = find(trackingId);
        if (loadDeliveryHistory) {
            result = populateAssociations(result, new AssociationSpecification(CargoProperties.events().toString()));
        }
        return result;
    }

    @Override
    public Cargo save(Cargo entity) {
        Cargo result = super.save(entity);
        deleteOrphanItinerary();
        return result;
    }

    @Override
    public void detachItineray(Cargo cargo) {
        try {
            Long id = cargo.getId();
            Cargo storedCargo = findById(id);
            storedCargo.detachItinerary();
            save(storedCargo);
        } catch (CargoNotFoundException e) {
            throw new RuntimeException(e);
        }
    }
}
