package org.sculptor.dddsample.cargo.accessimpl;

import java.util.List;

import org.sculptor.dddsample.cargo.domain.Itinerary;

/**
 * Implementation of Access object for CargoRepository.deleteOrphanItinerary.
 *
 */
public class DeleteOrphanItineraryAccessImpl extends DeleteOrphanItineraryAccessImplBase {
    @SuppressWarnings("unchecked")
    public void performExecute() {
    	List<Itinerary> orphans = getEntityManager().createQuery("from Itinerary where cargo = null").getResultList();
        for (Itinerary orphan : orphans) {
        	getEntityManager().remove(orphan);
        }
    }
}
