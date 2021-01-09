package org.sculptor.dddsample.relation.domain;

import javax.persistence.Entity;
import javax.persistence.Table;

/**
 * Testing entity for different type of relations
 */

@Entity
@Table(name = "PERSON")
public class Person extends PersonBase {

	private static final long serialVersionUID = 1L;

	public Person() {
	}

}
