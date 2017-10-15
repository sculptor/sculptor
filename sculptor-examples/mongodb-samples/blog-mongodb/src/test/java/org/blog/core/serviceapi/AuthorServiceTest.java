package org.blog.core.serviceapi;

import static org.junit.Assert.assertEquals;

import org.blog.core.domain.Author;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.framework.context.SimpleJUnitServiceContextFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * Spring based test with MongoDB.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class AuthorServiceTest extends AbstractJUnit4SpringContextTests implements AuthorServiceTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private AuthorService authorService;

    private String authorId1;

	@Before
	public void initTestData() {
        Author author1 = new Author("Patrik");
        Author saved = authorService.save(SimpleJUnitServiceContextFactory.getServiceContext(), author1);
        authorId1 = saved.getId();
	}

	@Before
	public void initDbManagerThreadInstance() throws Exception {
		// to be able to do lazy loading of associations inside test class
		DbManager.setThreadInstance(dbManager);
	}

	@After
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
