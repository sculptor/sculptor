package org.sculptor.examples.library.media.domain;

/**
 * Entity representing Library. This class is responsible for the domain object
 * related business logic for Library. Properties and associations are
 * implemented in the generated base class {@link LibraryBase}.
 */
public class Library extends LibraryBase {
	private static final long serialVersionUID = 1L;

	protected Library() {
	}

	public Library(String name) {
		super(name);
	}

	// TODO this must be invoked on preRemove
	protected void preRemove() {
		removeAllMedia();
	}

}
