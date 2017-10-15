package org.sculptor.examples.library.media.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.sculptor.framework.context.SimpleJUnitServiceContextFactory.getServiceContext;

import java.util.List;

import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.examples.library.media.domain.Book;
import org.sculptor.examples.library.media.domain.Library;
import org.sculptor.examples.library.media.domain.LibraryTestData;
import org.sculptor.examples.library.media.domain.PhysicalMedia;
import org.sculptor.examples.library.media.mapper.MediaMapper;
import org.sculptor.examples.library.media.mapper.PhysicalMediaMapper;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class PhysicalMediaServiceTest extends AbstractJUnit4SpringContextTests implements PhysicalMediaServiceTestBase {

	@Autowired
	private PhysicalMediaService physicalMediaService;
	@Autowired
	private LibraryService libraryService;

	@Autowired
	private LibraryTestData testData;
	@Autowired
	private DbManager dbManager;

	@Before
	public void initialData() throws Exception {
		testData.saveInitialData();
	}

	@After
	public void dropDatabase() {
		dbManager.getDB().dropDatabase();
	}

	@Before
	public void initDbManagerThreadInstance() throws Exception {
		// to be able to do lazy loading of associations inside test class
		DbManager.setThreadInstance(dbManager);
	}

	@After
	public void cleanupDbManagerThreadInstance() {
		DbManager.setThreadInstance(null);
	}

	private int countRowsInDBCollection(String name) {
		return (int) dbManager.getDBCollection(name).getCount();
	}

	private int countRowsInPhysicalMediaCollection() {
		return countRowsInDBCollection(MediaMapper.getInstance().getDBCollectionName());
	}

	@Override
	@Test
	public void testSave() throws Exception {
		Library library = libraryService.findById(getServiceContext(), testData.getLibraryId());
		PhysicalMedia media = new PhysicalMedia();
		media.setLibrary(library);
		media.setStatus("A");
		media.setLocation("abcdef");
		PhysicalMedia saved = physicalMediaService.save(getServiceContext(), media);

		PhysicalMedia found = physicalMediaService.findById(getServiceContext(), saved.getId());
		assertEquals(library.getId(), found.getLibraryId());
		assertEquals(library, found.getLibrary());
	}

	@Test
	public void testSaveWithBook() throws Exception {
		int before = countRowsInPhysicalMediaCollection();
		PhysicalMedia media = new PhysicalMedia();
		media.setStatus("A");
		media.setLocation("abcdef");
		media.addMedia(new Book("book1", "123456"));
		media.addMedia(new Book("book2", "654321"));
		media = physicalMediaService.save(getServiceContext(), media);
		assertEquals(before + 2, countRowsInPhysicalMediaCollection());
	}

	@Override
	@Test
	public void testDelete() throws Exception {
		int before = countRowsInDBCollection(PhysicalMediaMapper.getInstance().getDBCollectionName());
		PhysicalMedia media = physicalMediaService.findById(getServiceContext(), testData.getPhysicalMediaId1());
		physicalMediaService.delete(getServiceContext(), media);
		assertEquals(before - 1, countRowsInDBCollection(PhysicalMediaMapper.getInstance().getDBCollectionName()));
	}

	@Override
	@Test
	public void testFindAll() throws Exception {
		List<PhysicalMedia> all = physicalMediaService.findAll(getServiceContext());
		assertEquals(2, all.size());
	}

	@Override
	@Test
	public void testFindById() throws Exception {
		PhysicalMedia media = physicalMediaService.findById(getServiceContext(), testData.getPhysicalMediaId1());
		assertNotNull(media);
		assertEquals("abc123", media.getLocation());
	}
}
