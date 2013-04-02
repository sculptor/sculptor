package org.sculptor.examples.library.media.domain;

import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

import org.sculptor.examples.library.media.domain.MediaCharacterBase;

/**
 * 
 * Value object representing MediaCharacter. This class is responsible for the
 * domain object related business logic for MediaCharacter. Properties and
 * associations are implemented in the generated base class
 * {@link org.sculptor.examples.library.media.domain.MediaCharacterBase}.
 */
@Entity
@Table(name = "MEDIACHARACTER")
@NamedQueries({ @NamedQuery(name = "MediaCharacter.findByCharacterName", query = "select c from MediaCharacter as c where c.name = :characterName") })
public class MediaCharacter extends MediaCharacterBase {
	private static final long serialVersionUID = 1L;

	protected MediaCharacter() {
	}

	public MediaCharacter(String name) {
		super(name);
	}
}
