package org.sculptor.example.helloworld.milkyway.domain;

import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * EntityImpl representing Planet.
 * <p>
 * This class is responsible for the domain object related business logic for Planet. Properties and associations are implemented in
 * the generated base class {@link PlanetBase}.
 */

@Entity
@Table(name = "PLANET")
public class Planet extends PlanetBase {

    private static final long serialVersionUID = -5098471604527709435L;

    /**
     * Don't use this constructor.
     * This constructor is public due to DataNucleus.
     */
    // DataNucleus need a public no args constructor
    public Planet() {
    }

    public Planet(String name) {
        super(name);
    }

    public Moon getMoon(String moonName) {
        for (Moon moon : getMoons()) {
            if (moon.getName().equals(moonName)) {
                return moon;
            }
        }
        // not found
        return null;
    }

}
