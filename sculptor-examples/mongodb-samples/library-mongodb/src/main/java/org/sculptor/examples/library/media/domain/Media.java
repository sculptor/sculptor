package org.sculptor.examples.library.media.domain;

/**
 * Entity representing Media. This class is responsible for the domain object
 * related business logic for Media. Properties and associations are implemented
 * in the generated base class {@link MediaBase}.
 */
public abstract class Media extends MediaBase {
	private static final long serialVersionUID = 1L;

	protected Media() {
	}

	public Media(String title) {
		super(title);
	}

	public boolean existsInLibrary(String libraryId) {
		for (PhysicalMedia p : getPhysicalMedia()) {
			if (p.getLibrary() != null && libraryId.equals(p.getLibrary().getId())) {
				return true;
			}
		}
		// none found
		return false;
	}

}
