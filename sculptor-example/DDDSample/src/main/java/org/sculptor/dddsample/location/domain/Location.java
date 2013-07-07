package org.sculptor.dddsample.location.domain;

import javax.persistence.Entity;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;
import org.sculptor.dddsample.location.domain.UnLocode;

/**
 * A location is our model is stops on a journey, such as cargo origin or destination, or carrier movement endpoints.
 */

@Entity(name = "Location")
@Table(name = "LOCATION", uniqueConstraints = @UniqueConstraint(columnNames = { "UNLOCODE" }))
public class Location extends LocationBase {

    private static final long serialVersionUID = -6499417534696844828L;

    /**
     * Special Location object that marks an unknown location.
     */
    public static final Location UNKNOWN = new Location("Unknown location", new UnLocode("XXXXX"));

	protected Location() {
	}

	public Location(String name, UnLocode unLocode) {
		super(name, unLocode);
	}

}
