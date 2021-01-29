package org.sculptor.examples.library.media.serviceapi;

import static org.junit.jupiter.api.Assertions.*;
import static org.sculptor.framework.context.SimpleJUnitServiceContextFactory.getServiceContext;

import java.util.Date;
import java.util.List;

import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.examples.library.media.domain.Library;
import org.sculptor.examples.library.media.domain.LibraryTestData;
import org.sculptor.examples.library.media.domain.Media;
import org.sculptor.examples.library.media.domain.Movie;
import org.sculptor.examples.library.media.exception.LibraryNotFoundException;
import org.sculptor.examples.library.media.mapper.LibraryMapper;
import org.sculptor.examples.library.media.mapper.PhysicalMediaMapper;
import org.sculptor.examples.library.person.domain.Person;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.framework.errorhandling.OptimisticLockingException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class LibraryServiceTest implements LibraryServiceTestBase {

	@Autowired
	private LibraryService libraryService;

	@Autowired
	private LibraryTestData testData;
	@Autowired
	private DbManager dbManager;

	@BeforeEach
	public void initialData() throws Exception {
		testData.saveInitialData();
	}

	@AfterEach
	public void dropDatabase() {
		dbManager.getDB().dropDatabase();
	}

	private int countRowsInDBCollection(String name) {
		return (int) dbManager.getDBCollection(name).getCount();
	}

	private int countRowsInLibraryCollection() {
		return countRowsInDBCollection(LibraryMapper.getInstance().getDBCollectionName());
	}

	private int countRowsInPhysicalMediaCollection() {
		return countRowsInDBCollection(PhysicalMediaMapper.getInstance().getDBCollectionName());
	}

	@Override
	@Test
	public void testFindLibraryByName() throws Exception {
		String libraryName = "LibraryServiceTest";
		Library library = libraryService.findLibraryByName(getServiceContext(), libraryName);
		assertNotNull(library);
		assertEquals(libraryName, library.getName());
		assertNotNull(library.getId());
	}

	@Test
	public void testFindLibraryByNameNotFound() throws Exception {
		assertThrows(LibraryNotFoundException.class, () -> {
			libraryService.findLibraryByName(getServiceContext(), "not a library");
		});
	}

	@Override
	@Test
	public void testSave() throws Exception {
		Date now = new Date();
		String name = "TestCreateLibrary " + now;
		Library library = new Library(name);
		libraryService.save(getServiceContext(), library);
		Library foundLibrary = libraryService.findLibraryByName(getServiceContext(), name);
		assertNotNull(foundLibrary);
		assertNotNull(foundLibrary.getLastUpdated());
		assertEquals("JUnit", foundLibrary.getLastUpdatedBy());
		assertTrue(foundLibrary.getLastUpdated().compareTo(now) >= 0
				, "Expected " + foundLibrary.getLastUpdated() + " > " + now);
	}

	@Test
	public void testOptimisticLocking() throws Exception {
		assertThrows(OptimisticLockingException.class, () -> {
			Library foundLibrary = libraryService.findById(getServiceContext(), testData.getLibraryId());
			foundLibrary.setVersion(0L);
			libraryService.save(getServiceContext(), foundLibrary);
		});
	}

	@Override
	@Test
	public void testFindMediaByName() throws Exception {
		String title = "Pippi Långstrump i Söderhavet";
		List<Media> movieList = libraryService.findMediaByName(getServiceContext(), testData.getLibraryId(), title);
		assertNotNull(movieList);
		assertEquals(1, movieList.size());
		assertEquals(Movie.class, movieList.get(0).getClass());

		Movie movie = (Movie) movieList.get(0);
		assertEquals(title, movie.getTitle());

	}

	@Override
	@Test
	public void testFindMediaByCharacter() throws Exception {
		String characterName = "James Bond";
		List<Media> movieList = libraryService.findMediaByCharacter(getServiceContext(), testData.getLibraryId(),
				characterName);
		assertNotNull(movieList);
		assertEquals(1, movieList.size());
		assertEquals(Movie.class, movieList.get(0).getClass());

		Movie movie = (Movie) movieList.get(0);
		assertEquals("Die Another Day", movie.getTitle());

	}

	@Override
	@Test
	public void testFindPersonByName() throws Exception {
		String name = "Pierce Brosnan";
		List<Person> persons = libraryService.findPersonByName(getServiceContext(), name);
		assertNotNull(persons);
		assertEquals(1, persons.size());
		Person p = persons.get(0);
		assertEquals("Pierce", p.getName().getFirst());
		assertEquals("Brosnan", p.getName().getLast());
		String s = p.toString();
		assertTrue(s.indexOf("ssn") != -1);
		assertTrue(s.indexOf("first") != -1);
		assertTrue(s.indexOf("last") != -1);
	}

	@Override
	@Test
	public void testDelete() throws Exception {
		int before = countRowsInLibraryCollection();
		int physicalMediaBefore = countRowsInPhysicalMediaCollection();
		Library library = libraryService.findById(getServiceContext(), testData.getLibraryId());
		libraryService.delete(getServiceContext(), library);
		assertEquals(before - 1, countRowsInLibraryCollection());
		// we remove PhysicalMedia associations before remove to avoid cascade
		// delete
		assertEquals(physicalMediaBefore, countRowsInPhysicalMediaCollection());
	}

	@Override
	@Test
	public void testFindAll() throws Exception {
		List<Library> all = libraryService.findAll(getServiceContext());
		assertEquals(1, all.size());
	}

	@Override
	@Test
	public void testFindById() throws Exception {
		Library library = libraryService.findById(getServiceContext(), testData.getLibraryId());
		assertNotNull(library);
		assertEquals("LibraryServiceTest", library.getName());
	}
}
