package org.sculptor.dddsample.routing.repositoryimpl;

import java.util.Arrays;
import java.util.HashSet;
import java.util.Map;

import org.apache.commons.lang.Validate;
import org.sculptor.dddsample.routing.domain.RtCarrierMovement;
import org.sculptor.dddsample.routing.domain.RtCarrierMovementRepository;
import org.sculptor.dddsample.routing.domain.RtLocation;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for RtCarrierMovement
 */
@Repository("rtCarrierMovementRepository")
public class RtCarrierMovementRepositoryImpl extends RtCarrierMovementRepositoryBase implements
        RtCarrierMovementRepository {
    public RtCarrierMovementRepositoryImpl() {
    }

    public void storeCarrierMovementId(String cmId, String from, String to) {
        Map<Object, RtLocation> locations = getRtLocationRepository().findByKeys(
                new HashSet<String>(Arrays.asList(from, to)));
        RtLocation fromLocation = locations.get(from);
        Validate.notNull(fromLocation);
        RtLocation toLocation = locations.get(to);
        Validate.notNull(toLocation);
        RtCarrierMovement carrierMovement = new RtCarrierMovement(cmId, fromLocation, toLocation);
        save(carrierMovement);
    }
}
