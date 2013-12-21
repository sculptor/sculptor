package org.sculptor.examples.library.media.repositoryimpl;

import static org.sculptor.examples.library.media.domain.LibraryProperties.name;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.List;

import org.sculptor.examples.library.media.domain.Library;
import org.sculptor.examples.library.media.exception.LibraryNotFoundException;
import org.sculptor.framework.errorhandling.ValidationException;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for Library
 */
@Repository("libraryRepository")
public class LibraryRepositoryImpl extends LibraryRepositoryBase {

	public LibraryRepositoryImpl() {
    }

    @Override
    public Library findLibraryByName(String name) throws LibraryNotFoundException {
        List<Library> result = findByCondition(criteriaFor(Library.class).withProperty(name()).eq(name).build());
        if (result.isEmpty()) {
            throw new LibraryNotFoundException("Library not found: " + name);
        } else {
            return result.get(0);
        }
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
}
