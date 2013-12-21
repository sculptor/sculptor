package org.sculptor.examples.library.media.domain;

import org.sculptor.framework.errorhandling.ValidationException;

/**
 * Entity representing Movie. This class is responsible for the domain object
 * related business logic for Movie. Properties and associations are implemented
 * in the generated base class {@link MovieBase}.
 */
public class Movie extends MovieBase {
	private static final long serialVersionUID = 1L;

	protected Movie() {
	}

	public Movie(String title, String urlIMDB) {
		super(title, urlIMDB);
	}

	// TODO this must be invoked on prePersist, preUpdate
	public void validatePlayLength() {
		if (getPlayLength() != null && Genre.SHORT.equals(getCategory()) && getPlayLength() > 15) {
			throw new ValidationException("Short movies should be less than 15 minutes");
		}
	}

}
