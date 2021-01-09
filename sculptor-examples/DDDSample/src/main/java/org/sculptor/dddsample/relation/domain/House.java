package org.sculptor.dddsample.relation.domain;

import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * Entity representing House.
 * <p>
 * This class is responsible for the domain object related
 * business logic for House. Properties and associations are
 * implemented in the generated base class {@link org.sculptor.dddsample.relation.domain.HouseBase}.
 */

@Entity
@Table(name = "HOUSE")
public class House extends HouseBase {

	private static final long serialVersionUID = 1L;

	public House() {
	}

}
