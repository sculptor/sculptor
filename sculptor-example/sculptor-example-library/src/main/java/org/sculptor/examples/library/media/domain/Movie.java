package org.sculptor.examples.library.media.domain;

import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.PrePersist;
import javax.persistence.PreUpdate;
import javax.persistence.PrimaryKeyJoinColumn;
import javax.persistence.Table;

import org.sculptor.examples.library.media.domain.Genre;
import org.sculptor.examples.library.media.domain.MovieBase;
import org.sculptor.framework.errorhandling.ValidationException;

/**
 * 
 * Entity representing Movie. This class is responsible for the domain object
 * related business logic for Movie. Properties and associations are implemented
 * in the generated base class
 * {@link org.sculptor.examples.library.media.domain.MovieBase}.
 */
@Entity
@Table(name = "MOVIE")
@PrimaryKeyJoinColumn(name = "MEDIA")
// @org.hibernate.annotations.ForeignKey(name = "FK_MOVIE_MEDIA")
@NamedQueries({ @NamedQuery(name = "Movie.getNumberOfMovies", query = "select count(m) from Movie m join m.physicalMedia p where p.library.id = :libraryId") })
public class Movie extends MovieBase {
	private static final long serialVersionUID = 1L;

	protected Movie() {
	}

	public Movie(String title, String urlIMDB) {
		super(title, urlIMDB);
	}

	@PreUpdate
	@PrePersist
	public void validatePlayLength() {
		if (getPlayLength() != null && Genre.SHORT.equals(getCategory()) && getPlayLength() > 15) {
			throw new ValidationException("Short movies should be less than 15 minutes");
		}
	}
}
