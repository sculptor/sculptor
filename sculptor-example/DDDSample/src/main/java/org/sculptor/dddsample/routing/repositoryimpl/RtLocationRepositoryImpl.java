package org.sculptor.dddsample.routing.repositoryimpl;

import java.util.ArrayList;
import java.util.List;

import org.sculptor.dddsample.routing.domain.RtLocation;
import org.sculptor.dddsample.routing.domain.RtLocationRepository;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for RtLocation
 */
@Repository("rtLocationRepository")
public class RtLocationRepositoryImpl extends RtLocationRepositoryBase implements RtLocationRepository {
    public RtLocationRepositoryImpl() {
    }

    public List<String> listLocations() {
        List<RtLocation> all = findAll();
        List<String> result = new ArrayList<String>();
        for (RtLocation each : all) {
            result.add(each.getUnlocode());
        }
        return result;
    }
}
