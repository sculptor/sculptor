package org.sculptor.dddsample.cargo.repositoryimpl;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.sculptor.dddsample.cargo.domain.HandlingEvent;
import org.sculptor.dddsample.cargo.domain.HandlingEventRepository;
import org.sculptor.dddsample.cargo.domain.TrackingId;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for HandlingEvent
 */
@Repository("handlingEventRepository")
public class HandlingEventRepositoryImpl extends HandlingEventRepositoryBase
    implements HandlingEventRepository {
    public HandlingEventRepositoryImpl() {
    }

    @Override
    public List<HandlingEvent> findEventsForCargo(TrackingId trackingId) {
        Map<String, Object> parameters = new HashMap<String, Object>();
        parameters.put("tid", trackingId);
        return findByQuery("HandlingEvent.findEventsForCargo", parameters);
    }

}
