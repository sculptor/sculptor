package org.sculptor.examples.library.media.repositoryimpl;

import org.sculptor.examples.library.media.domain.LibraryRepository;
import org.sculptor.examples.library.media.repositoryimpl.LibraryRepositoryBase;
import org.sculptor.examples.library.media.domain.Library;
import org.sculptor.examples.library.media.exception.LibraryNotFoundException;
import org.sculptor.framework.errorhandling.ValidationException;
import org.springframework.stereotype.Repository;

/**
 * Repository for Library
 */
@Repository("libraryRepository")
public class LibraryRepositoryImpl extends LibraryRepositoryBase implements LibraryRepository {
	public LibraryRepositoryImpl() {
	}

	@Override
	public Library save(Library entity) {
		if (entity.getName().equals("err")) {
			throw new RuntimeException("SimulatedRuntimeException");
		}
		if (entity.getName().equals("validation")) {
			throw new ValidationException("foo", "Simulated validation exception");
		}
		return super.save(entity);
	}

	@Override
	public Library findLibraryByName(String name) throws LibraryNotFoundException {
		// TODO Auto-generated method stub
		return null;
	}

}
