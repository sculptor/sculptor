package org.blog.core.serviceapi;

import org.blog.core.domain.Author;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.framework.context.SimpleJUnitServiceContextFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

import static org.junit.jupiter.api.Assertions.assertEquals;

/**
 * Spring based test with MongoDB.
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class AuthorServiceTest implements AuthorServiceTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private AuthorService authorService;

    private String authorId1;

	@BeforeEach
	public void initTestData() {
        Author author1 = new Author("Patrik");
        Author saved = authorService.save(SimpleJUnitServiceContextFactory.getServiceContext(), author1);
        authorId1 = saved.getId();
	}

	@BeforeEach
	public void initDbManagerThreadInstance() throws Exception {
		// to be able to do lazy loading of associations inside test class
		DbManager.setThreadInstance(dbManager);
	}

	@AfterEach
	public void dropDatabase() {
		dbManager.getDB().dropDatabase();
	}

	@Test
	public void testFindById() throws Exception {
        Author found = authorService.findById(SimpleJUnitServiceContextFactory.getServiceContext(), authorId1);
        assertEquals("Patrik", found.getName());
	}

	@Test
	public void testFindAll() throws Exception {
		// TODO Auto-generated method stub
	}

	@Test
	public void testSave() throws Exception {
		// TODO Auto-generated method stub
	}

	@Test
	public void testDelete() throws Exception {
		// TODO Auto-generated method stub
	}
}
