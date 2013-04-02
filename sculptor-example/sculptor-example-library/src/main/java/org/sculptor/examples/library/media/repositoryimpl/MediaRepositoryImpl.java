package org.sculptor.examples.library.media.repositoryimpl;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.sculptor.examples.library.media.domain.MediaRepository;
import org.sculptor.examples.library.media.domain.MovieProperties;
import org.sculptor.examples.library.media.repositoryimpl.MediaRepositoryBase;
import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.examples.library.media.domain.MediaCharacter;
import org.sculptor.examples.library.media.domain.Movie;
import org.sculptor.framework.accessapi.FindByKeysAccess2;
import org.springframework.stereotype.Repository;

/**
 * Repository for Media
 */
@Repository("mediaRepository")
public class MediaRepositoryImpl extends MediaRepositoryBase implements MediaRepository {
	public MediaRepositoryImpl() {
	}

	@Override
	public Map<String, Movie> findMovieByUrlIMDB(Set<String> keys) {
		Map<Object, Movie> media = findMovieByKeys(keys, MovieProperties.urlIMDB().toString(), Movie.class);
		Map<String, Movie> movies = new HashMap<String, Movie>();
		for (Object k : media.keySet()) {
			movies.put((String) k, (Movie) media.get(k));
		}
		return movies;
	}

	/**
	 * Delegates to {@link org.sculptor.framework.accessapi.FindByKeysAccess}
	 */
	@SuppressWarnings("rawtypes")
	protected Map<Object, Movie> findMovieByKeys(Set<String> keys, String keyPropertyName, Class persistentClass) {
		FindByKeysAccess2<Movie> ao = createFindByKeysAccess(Movie.class, Movie.class);
		ao.setKeys(keys);
		ao.setKeyPropertyName(keyPropertyName);
		ao.execute();
		return ao.getResult();
	}

	@Override
	public List<Media> findMediaByCharacter(Long libraryId, String characterName) {
		// Retrieve the MediaCharacter objects via another Repository
		Map<String, Object> parameters = new HashMap<String, Object>();
		parameters.put("characterName", characterName);
		List<MediaCharacter> foundCharacters = getMediaCharacterRepository().findByQuery("MediaCharacter.findByCharacterName",
				parameters);

		// filter matching Media for the found characters and the specified
		// library
		List<Media> matchingMedia = new ArrayList<Media>();
		for (MediaCharacter c : foundCharacters) {
			for (Media m : c.getExistsInMedia()) {
				if (m.existsInLibrary(libraryId)) {
					matchingMedia.add(m);
				}
			}
		}

		return matchingMedia;
	}
}
