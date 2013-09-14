package org.sculptor.examples.library.media.domain;

import javax.persistence.Entity;
import javax.persistence.Inheritance;
import javax.persistence.InheritanceType;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.Table;

import org.sculptor.examples.library.media.domain.MediaBase;
import org.sculptor.examples.library.media.domain.PhysicalMedia;

/**
 * 
 * Entity representing Media. This class is responsible for the domain object
 * related business logic for Media. Properties and associations are implemented
 * in the generated base class
 * {@link org.sculptor.examples.library.media.domain.MediaBase}.
 */
@Entity(name = "Media")
@Table(name = "MEDIA")
@Inheritance(strategy = InheritanceType.JOINED)
@NamedQueries({ @NamedQuery(name = "Media.findMediaByTitle", query = "select m from Media m, in(m.physicalMedia) pm where m.title = :title and pm.library.id = :libraryId") })
// removed abstract, because datanucleus has problems with abstract entities
public class Media extends MediaBase {
	private static final long serialVersionUID = 1L;

	protected Media() {
	}

	public Media(String title) {
		super(title);
	}

	public boolean existsInLibrary(Long libraryId) {
		for (PhysicalMedia p : getPhysicalMedia()) {
			if (libraryId.equals(p.getLibrary().getId())) {
				return true;
			}
		}
		// none found
		return false;
	}
}
