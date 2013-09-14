package org.sculptor.dddsample.routing.domain;

import java.util.List;

import javax.persistence.Entity;
import javax.persistence.Table;


/**
 *
 * Value object representing TransitPath.
 * This class is responsible for the domain object related
 * business logic for TransitPath. Properties and associations are
 * implemented in the generated base class {@link org.sculptor.dddsample.routing.domain.TransitPathBase}.
 */
@Entity(name = "TransitPath")
@Table(name = "TRANSITPATH")
public class TransitPath extends TransitPathBase {
    private static final long serialVersionUID = 1L;

    protected TransitPath() {
    }

    public TransitPath(List<TransitEdge> transitEdges) {
        getTransitEdges().addAll(transitEdges);
    }
}
