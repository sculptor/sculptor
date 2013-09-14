package org.sculptor.dddsample.cargo.accessimpl;

import javax.persistence.NoResultException;

import org.sculptor.dddsample.cargo.domain.Cargo;
import org.sculptor.dddsample.cargo.exception.CargoNotFoundException;

/**
 * Implementation of Access object for CargoRepository.find.
 *
 */
public class FindCargoAccessObjectImpl extends FindCargoAccessObjectImplBase {
    public void performExecute() throws CargoNotFoundException {

    	try {
            // Query for id and then perform a standard load().
            // This way we use the metadata-defined way of loading the aggregate
            // in an efficient way (generally a complete aggregate at a time),
            // and we can benefi from the identifier-keyed second level cache
            // without havng to cache individual queries.
        	Long id = (Long) getEntityManager()
        		.createQuery("select id from Cargo where trackingId = :tid").setParameter("tid", getTrackingId())
        		.getSingleResult();

             setResult((Cargo) getEntityManager().find(Cargo.class, id));
		} catch (NoResultException e) {
            throw new CargoNotFoundException("No cargo for tracking id: " + getTrackingId());
		}
    }
}
