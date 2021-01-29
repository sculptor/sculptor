package org.sculptor.examples.library.media.domain;

import static org.junit.jupiter.api.Assertions.*;
import static org.sculptor.examples.library.media.domain.MediaProperties.title;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.*;

import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.sculptor.examples.library.media.domain.Book;
import org.sculptor.examples.library.media.domain.MediaProperties;
import org.sculptor.examples.library.media.domain.MediaRepository;
import org.sculptor.examples.library.media.domain.MovieProperties;
import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.examples.library.media.domain.Movie;
import org.sculptor.framework.accessapi.*;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import javax.persistence.Tuple;

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
        Assumptions.assumeTrue(!JpaHelper.isJpaProviderHibernate(getEntityManager()));
    	// datanucleus seems not to support this nested condition
        Assumptions.assumeTrue(!JpaHelper.isJpaProviderDataNucleus(getEntityManager()));
        List<ConditionalCriteria> conditionalCriteria = criteriaFor(Media.class).withProperty(
                MediaProperties.physicalMedia().location()).eq("abc123").build();
        List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
        assertEquals(1, found.size());
        assertEquals("Pippi Långstrump i Söderhavet", found.get(0).getTitle());
    }

    @Test
    public void testFindByConditionTuple() throws Exception {
        List<ConditionalCriteria> condition = criteriaFor(Media.class)
                .select(MediaProperties.lastUpdated()).countDistinct()
				.select(MediaProperties.lastUpdatedBy()).countDistinct()
                .select(MediaProperties.id()).countDistinct()
                .build();
        List<Tuple> result = mediaRepository.findByConditionTuple(condition);
        assertEquals(1, result.size());
        Tuple tuple = result.get(0);
        long lastUpdatedCount = tuple.get(0, Long.class);
        long lastUpdatedByCount = tuple.get(1, Long.class);
        long idCount = tuple.get(2, Long.class);
        assertEquals(2, lastUpdatedCount);
        assertEquals(1, lastUpdatedByCount);
        assertEquals(3, idCount);
    }

    @Test
    public void testFindByConditionStat() throws Exception {
        List<ConditionalCriteria> condition = criteriaFor(Media.class)
                .withProperty(MediaProperties.id()).isNotNull()
                .build();
        List<ColumnStatRequest<Media>> stat = new ArrayList<>();
        ColumnStatRequest statA = new ColumnStatRequest(MediaProperties.title(), ColumnStatType.STRING_STAT);
        ColumnStatRequest statB = new ColumnStatRequest(MediaProperties.lastUpdated(), ColumnStatType.COUNT_DISTINCT);
        ColumnStatRequest statC = new ColumnStatRequest(MediaProperties.lastUpdatedBy(), ColumnStatType.STRING_STAT);
        stat.add(statA);
        stat.add(statB);
        stat.add(statC);
        List<List<ColumnStatResult>> result = mediaRepository.findByConditionStat(condition, stat);

        assertEquals(1, result.size());
        assertEquals(3, result.get(0).size());

        List<ColumnStatResult> statRow = result.get(0);
        ColumnStatResult titleStat = statRow.get(0);
        assertEquals("title", titleStat.getName());
        assertEquals(3l, titleStat.getCount().longValue());
        assertEquals(3l, titleStat.getCountDistinct().longValue());
        assertEquals("Die Another Day", titleStat.getMinString());
        assertNull(titleStat.getAverage());

        ColumnStatResult lastUpdatedStat = statRow.get(1);
        assertEquals("lastUpdated", lastUpdatedStat.getName());
        assertEquals(2l, lastUpdatedStat.getCountDistinct().longValue());

        ColumnStatResult lastUpdatedByStat = statRow.get(2);
        assertEquals("lastUpdatedBy", lastUpdatedByStat.getName());
        assertEquals(3l, lastUpdatedByStat.getCount().longValue());
        assertEquals(1l, lastUpdatedByStat.getCountDistinct().longValue());
        assertEquals("dbunit", lastUpdatedByStat.getMinString());
        assertEquals("dbunit", lastUpdatedByStat.getMaxString());
        assertNull(lastUpdatedByStat.getAverage());
	}
}
