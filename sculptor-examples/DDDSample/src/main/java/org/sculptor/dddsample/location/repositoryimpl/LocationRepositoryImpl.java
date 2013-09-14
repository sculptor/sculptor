package org.sculptor.dddsample.location.repositoryimpl;

import java.util.HashSet;
import java.util.Map;
import java.util.Set;

import org.sculptor.dddsample.location.domain.Location;
import org.sculptor.dddsample.location.domain.LocationRepository;
import org.sculptor.dddsample.location.domain.UnLocode;
import org.sculptor.dddsample.location.exception.LocationNotFoundException;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for Location
 */
@Repository("locationRepository")
public class LocationRepositoryImpl extends LocationRepositoryBase
    implements LocationRepository {
    public LocationRepositoryImpl() {
    }

    public Location find(UnLocode unLocode) throws LocationNotFoundException {
        Set<UnLocode> keys = new HashSet<UnLocode>();
        keys.add(unLocode);
        Map<UnLocode, Location> result = findByNaturalKeys(keys);
        if (result.get(unLocode) == null) {
            throw new LocationNotFoundException("Unknown carrier movement: " + unLocode);
        }
        return result.get(unLocode);
    }
}
