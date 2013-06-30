/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.examples.library.media.repositoryimpl;

import org.sculptor.examples.library.media.domain.Library;
import org.sculptor.examples.library.media.domain.LibraryRepository;
import org.sculptor.framework.errorhandling.ValidationException;
import org.springframework.stereotype.Repository;

/**
 * Repository for Library
 */
@Repository("libraryRepository")
public class LibraryRepositoryImpl extends LibraryRepositoryBase implements LibraryRepository {

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
