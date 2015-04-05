package org.sculptor.dddsample.routing.serviceimpl;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Random;
import java.util.UUID;

import org.sculptor.dddsample.routing.domain.TransitEdge;
import org.sculptor.dddsample.routing.domain.TransitPath;
import org.sculptor.framework.context.ServiceContext;
import org.springframework.stereotype.Service;

/**
 * Implementation of GraphTraversalService.
 */
@Service("graphTraversalService")
public class GraphTraversalServiceImpl extends GraphTraversalServiceImplBase {

    private final Random random;

    public GraphTraversalServiceImpl() {
        this.random = new Random();
    }

    public List<TransitPath> findShortestPath(ServiceContext ctx, String originUnLocode, String destinationUnLocode) {

        List<String> allVertices = getRtLocationRepository().listLocations();
        allVertices.remove(originUnLocode);
        allVertices.remove(destinationUnLocode);

        final int candidateCount = getRandomNumberOfCandidates();
        final List<TransitPath> candidates = new ArrayList<TransitPath>(candidateCount);

        for (int i = 0; i < candidateCount; i++) {
            allVertices = getRandomChunkOfLocations(allVertices);
            final List<TransitEdge> transitEdges = new ArrayList<TransitEdge>(allVertices.size() - 1);
            final String firstLegTo = allVertices.get(0);

            transitEdges.add(new TransitEdge(getRandomCarrierMovementId(originUnLocode, firstLegTo), originUnLocode,
                    firstLegTo));

            for (int j = 0; j < allVertices.size() - 1; j++) {
                final String curr = allVertices.get(j);
                final String next = allVertices.get(j + 1);
                transitEdges.add(new TransitEdge(getRandomCarrierMovementId(curr, next), curr, next));
            }

            final String lastLegFrom = allVertices.get(allVertices.size() - 1);
            transitEdges.add(new TransitEdge(getRandomCarrierMovementId(lastLegFrom, destinationUnLocode), lastLegFrom,
                    destinationUnLocode));

            candidates.add(new TransitPath(transitEdges));
        }

        return candidates;
    }

    private String getRandomCarrierMovementId(String from, String to) {
        final String random = UUID.randomUUID().toString().toUpperCase();
        final String cmId = random.substring(0, 4);
        getRtCarrierMovementRepository().storeCarrierMovementId(cmId, from, to);
        return cmId;
    }

    private int getRandomNumberOfCandidates() {
        return 1 + random.nextInt(4);
    }

    private List<String> getRandomChunkOfLocations(List<String> allLocations) {
        Collections.shuffle(allLocations);
        final int total = allLocations.size();
        final int chunk = total > 4 ? (total - 4) + random.nextInt(5) : total;
        return allLocations.subList(0, chunk);
    }
}
