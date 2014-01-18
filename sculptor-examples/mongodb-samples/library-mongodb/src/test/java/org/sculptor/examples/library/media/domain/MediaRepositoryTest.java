package org.sculptor.examples.library.media.domain;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.sculptor.examples.library.media.domain.MediaProperties.title;
import static org.sculptor.examples.library.media.domain.MovieProperties.playLength;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.examples.library.media.mapper.BookMapper;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class MediaRepositoryTest extends AbstractJUnit4SpringContextTests {

	@Autowired
	private MediaRepository mediaRepository;

	@Autowired
	private LibraryTestData testData;

	@Autowired
	private DbManager dbManager;

	@Before
	public void initialData() throws Exception {
		testData.saveInitialData();
	}

	@Before
	public void initDbManagerThreadInstance() throws Exception {
		// to be able to do lazy loading of associations inside test class
		DbManager.setThreadInstance(dbManager);
	}

	@After
	public void dropDatabase() {
		Set<String> names = dbManager.getDB().getCollectionNames();
		for (String each : names) {
			if (!each.startsWith("system")) {
				dbManager.getDB().getCollection(each).drop();
			}
		}
		// dbManager.getDB().dropDatabase();
	}

	private int countRowsInDBCollection(String name) {
		return (int) dbManager.getDBCollection(name).getCount();
	}

	private int countRowsInBookCollection() {
		return countRowsInDBCollection(BookMapper.getInstance().getDBCollectionName());
	}

	@Test
	@Ignore
	// TODO something wrong with FindByKeys, the $in condtion only returns "abc"
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
		int count = mediaRepository.getNumberOfMovies(testData.getLibraryId());
		assertEquals(3, count);
	}

	@Test
	public void testSave() throws Exception {
		int before = countRowsInBookCollection();
		Book ddd = new Book("Domain-Driven Design", "0-321-12521-5");
		mediaRepository.save(ddd);
		assertEquals(before + 1, countRowsInBookCollection());
	}

	@Test
	public void testFindMediaByLikeCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Media.class).withProperty(title())
				.ignoreCaseLike("^pippi").build();
		List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
		assertEquals(1, found.size());
		assertEquals("Pippi Långstrump i Söderhavet", found.get(0).getTitle());
	}

	@Test
	public void testFindMovieByLikeCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Movie.class).withProperty(MovieProperties.title())
				.like("Pippi.*").build();
		List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
		assertEquals(1, found.size());
		assertEquals("Pippi Långstrump i Söderhavet", found.get(0).getTitle());
	}

	@Test
	public void testFindGreaterThanCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Movie.class).withProperty(playLength())
				.greaterThan(10).build();
		List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
		assertEquals(2, found.size());
	}

	@Test
	public void testFindBetweenCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Movie.class).withProperty(playLength()).between(70)
				.to(100).build();
		List<Media> found = mediaRepository.findByCondition(conditionalCriteria);
		assertEquals(2, found.size());
	}

}
