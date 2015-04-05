package org.helloworld.milkyway.domain;

import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

/**
 * Entity representing Planet.
 * <p>
 * This class is responsible for the domain object related business logic for
 * Planet. Properties and associations are implemented in the generated base
 * class {@link org.helloworld.milkyway.domain.PlanetBase}.
 */

@Entity(name = "Planet")
@Table(name = "PLANET")
@NamedQueries({
		@NamedQuery(name = "Planet.findLargest", query = "select planet from Planet planet where planet.diameter = (select max(planet.diameter) from Planet planet)"),
		@NamedQuery(name = "Planet.findSmallest", query = "select planet from Planet planet where planet.diameter = (select min(planet.diameter) from Planet planet)") })
public class Planet extends PlanetBase {

	private static final long serialVersionUID = 1L;

	public Planet() {
	}

}
