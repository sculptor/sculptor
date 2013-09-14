package org.sculptor.dddsample.cargo.domain;


import org.apache.commons.lang.Validate;
import org.joda.time.DateTime;
import org.sculptor.dddsample.common.Specification;
import org.sculptor.dddsample.location.domain.Location;


/**
 *
 * Value object representing RouteSpecification.
 * This class is responsible for the domain object related
 * business logic for RouteSpecification. Properties and associations are
 * implemented in the generated base class {@link org.sculptor.dddsample.cargo.domain.RouteSpecificationBase}.
 */
public class RouteSpecification extends RouteSpecificationBase implements Specification<Itinerary>{
    private static final long serialVersionUID = 1L;

    /**
     * Factory for creatig a route specification for a cargo, from cargo
     * origin to cargo destination. Use for initial routing.
     *
     * @param cargo cargo
     * @param arrivalDeadline arrival deadline
     * @return A route specification for this cargo and arrival deadline
     */
    public static RouteSpecification forCargo(Cargo cargo, DateTime arrivalDeadline) {
      Validate.notNull(cargo);
      Validate.notNull(arrivalDeadline);

      return new RouteSpecification(arrivalDeadline, cargo.getOrigin(), cargo.getDestination());
    }

    protected RouteSpecification() {
    }

    RouteSpecification(DateTime arrivalDeadline, Location origin,
            Location destination) {
        super(arrivalDeadline, origin, destination);
    }

    public boolean isSatisfiedBy(Itinerary itinerary) {
        // Stub implementation for now
        return true;
    }
}
