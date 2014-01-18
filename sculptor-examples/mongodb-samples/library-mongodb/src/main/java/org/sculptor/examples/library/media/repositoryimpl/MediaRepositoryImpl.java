package org.sculptor.examples.library.media.repositoryimpl;

import static org.sculptor.examples.library.media.domain.MediaProperties.title;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.examples.library.media.domain.MediaCharacter;
import org.sculptor.examples.library.media.domain.MediaCharacterProperties;
import org.sculptor.examples.library.media.domain.Movie;
import org.sculptor.examples.library.media.domain.MovieProperties;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for Media
 */
@Repository("mediaRepository")
public class MediaRepositoryImpl extends MediaRepositoryBase {

	public MediaRepositoryImpl() {
    }

    @Override
    public Media save(Media entity) {
        if (entity.getId() == null && entity.isMediaCharactersLoaded()) {
            List<MediaCharacter> mediaCharacters = new ArrayList<MediaCharacter>(entity.getMediaCharacters());
            entity.removeAllMediaCharacters();
            Media saved = super.save(entity);
            for (MediaCharacter each : mediaCharacters) {
                saved.addMediaCharacter(each);
                getMediaCharacterRepository().save(each);
            }
            return super.save(entity);
        } else {
            if (entity.isMediaCharactersLoaded()) {
                for (MediaCharacter each : entity.getMediaCharacters()) {
                    getMediaCharacterRepository().save(each);
                }
            }

            return super.save(entity);
        }
    }

    @Override
    public java.util.List<Media> findMediaByName(String libraryId, String name) {

        List<Media> potentialResult = findByCondition(criteriaFor(Media.class).withProperty(title()).eq(name).build());
        List<Media> result = new ArrayList<Media>();
        for (Media each : potentialResult) {
            if (each.existsInLibrary(libraryId)) {
                result.add(each);
            }
        }

        return result;
    }

    @Override
    public Map<String, Movie> findMovieByUrlIMDB(Set<String> keys) {
        Map<Object, Media> media = findByKeys(keys, MovieProperties.urlIMDB().toString(), Movie.class);
        Map<String, Movie> movies = new HashMap<String, Movie>();
        for (Object k : media.keySet()) {
            movies.put((String) k, (Movie) media.get(k));
        }
        return movies;
    }

    @Override
    public List<Media> findMediaByCharacter(String libraryId, String characterName) {
        // Retrieve the MediaCharacter objects via another Repository

        List<MediaCharacter> foundCharacters = getMediaCharacterRepository().findByCondition(
                criteriaFor(MediaCharacter.class).withProperty(MediaCharacterProperties.name()).eq(characterName)
                        .build());

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

    @Override
    public int getNumberOfMovies(String libraryId) {
        int count = 0;
        List<Media> all = findAll();
        for (Media each : all) {
            if (each instanceof Movie && each.existsInLibrary(libraryId)) {
                count++;
            }
        }

        return count;
    }
}
