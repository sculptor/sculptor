package org.sculptor.examples.library.media.domain;

import static org.sculptor.examples.library.media.domain.MediaProperties.title;
import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.sculptor.examples.library.media.domain.Book;
import org.sculptor.examples.library.media.domain.MediaProperties;
import org.sculptor.examples.library.media.domain.MediaRepository;
import org.sculptor.examples.library.media.domain.MovieProperties;
import org.junit.Assume;
import org.junit.Test;
import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.examples.library.media.domain.Movie;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class MediaRepositoryTest extends AbstractDbUnitJpaTests {

    private MediaRepository mediaRepository;

    @Autowired
    public void setMediaRepository(MediaRepository mediaRepository) {
        this.mediaRepository = mediaRepository;
    }

    @Override
    protected String getDataSetFile() {
        if (JpaHelper.isJpaProviderEclipselink(getEntityManager())) {
            return "dbunit/LibraryServiceTest_eclipselink.xml";
        }
        // datanucleus bug. PrimaryKeyJoinColumn is not working correctly for entities inherited from mappedsuperclass
        // TODO: report to datanucleus issue tracker
        else if (JpaHelper.isJpaProviderDataNucleus(getEntityManager())) {
            return "dbunit/LibraryServiceTest_datanucleus.xml";
        }
        return "dbunit/LibraryServiceTest.xml";
    }

    @Override
    protected String getSequenceName() {
        if (JpaHelper.isJpaProviderHibernate(getEntityManager())) {
            return "hibernate_sequence";
        } else if (JpaHelper.isJpaProviderEclipselink(getEntityManager())) {
            return "SEQ_GEN";
        } else {
            return null;
        }
    }

    @Test
    public void testFindMovieByKeys() throws Exception {
        Set<String> keys = new HashSet<String>();
        keys.add("abc");
        keys.add("def");
        keys.add("xyz");
        Map<String, Movie> movies = mediaRepository.findMovieByUrlIMDB(keys);
        assertEquals(2, movies.size());
        assertNotNull(movies.get("abc"));
        assertNotNull(movies.get("def"));
    }

    @Test
    public void testGetNumberOfMovies() throws Exception {
        long count = mediaRepository.getNumberOfMovies(1L);
        assertEquals(2, count);
    }

    @Test
    public void testSave() throws Exception {
        int before = countRowsInTable(Book.class);
        Book ddd = new Book("Domain-Driven Design", "0-321-12521-5");
        mediaRepository.save(ddd);
        assertEquals(before + 1, countRowsInTable(Book.class));
    }

    @Test
    public void testFindMediaByCondition() throws Exception {
        List<ConditionalCriteria> conditionalCriteria =
        	criteriaFor(Media.class).withProperty(title()).ignoreCaseLike("pippi%").build();
        List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
        assertEquals(1, found.size());
        assertEquals("Pippi Långstrump i Söderhavet", found.get(0).getTitle());
    }

    @Test
    public void testFindMovieByCondition() throws Exception {
        List<ConditionalCriteria> conditionalCriteria = criteriaFor(Movie.class).withProperty(MovieProperties.title())
                .like("Pippi%").build();
        List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
        assertEquals(1, found.size());
        assertEquals("Pippi Långstrump i Söderhavet", found.get(0).getTitle());
    }

    @Test
    public void testFindByNestedCondition() throws Exception {
    	// hibernate seems not to support this nested condition
    	// TODO: watch hibernate issue HHH-5948
        Assume.assumeTrue(!JpaHelper.isJpaProviderHibernate(getEntityManager()));
    	// datanucleus seems not to support this nested condition
        Assume.assumeTrue(!JpaHelper.isJpaProviderDataNucleus(getEntityManager()));
        List<ConditionalCriteria> conditionalCriteria = criteriaFor(Media.class).withProperty(
                MediaProperties.physicalMedia().location()).eq("abc123").build();
        List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
        assertEquals(1, found.size());
        assertEquals("Pippi Långstrump i Söderhavet", found.get(0).getTitle());
    }
}
