package org.blog.core.serviceapi;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.sculptor.framework.context.SimpleJUnitServiceContextFactory.getServiceContext;

import java.util.List;
import java.util.Set;

import org.blog.core.domain.Author;
import org.blog.core.domain.Blog;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

/**
 * Spring based test with MongoDB.
 */
@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class BlogServiceTest implements BlogServiceTestBase {

	@Autowired
	private BlogService blogService;

	@Autowired
	private AuthorService authorService;

	@Autowired
	private DbManager dbManager;

	@AfterEach
	public void dropDatabase() {
		dbManager.getDB().dropDatabase();
	}

	@BeforeEach
	public void initDbManagerThreadInstance() throws Exception {
		// to be able to do lazy loading of associations inside test class
		DbManager.setThreadInstance(dbManager);
	}

	@AfterEach
	public void cleanupDbManagerThreadInstance() {
		DbManager.setThreadInstance(null);
	}

	@Override
	@Test
	public void testSave() throws Exception {
		Blog blog = new Blog("http://www.test.org/cool");
		blog.setIntro("This is cool");
		blog.setTitle("Testing");

		Blog saved = blogService.save(getServiceContext(), blog);
		assertNotNull(saved.getId());
		Blog found = blogService.findById(getServiceContext(), saved.getId());
		assertEquals(found.getId(), saved.getId());
		assertEquals(found, saved);
	}

	@Test
	public void testUpdate() throws Exception {
		Blog blog = new Blog("http://www.test.org/cool");
		blog.setIntro("This is cool");
		blog.setTitle("Testing");
		Blog saved = blogService.save(getServiceContext(), blog);
		saved.setIntro("This is cool!!!");
		Blog saved2 = blogService.save(getServiceContext(), saved);
		assertEquals(saved.getId(), saved2.getId());
		Blog found = blogService.findById(getServiceContext(), saved2.getId());
		assertEquals("This is cool!!!", found.getIntro());
	}

	@Test
	public void testWriters() throws Exception {
		Blog blog = new Blog("http://www.test.org/cool");
		blog.setIntro("This is cool");
		blog.setTitle("Testing");

		Author pn = new Author("Patrik");
		pn = authorService.save(getServiceContext(), pn);
		blog.addWriter(pn);
		Author ak = new Author("Andreas");
		ak = authorService.save(getServiceContext(), ak);
		blog.addWriter(ak);
		Blog saved = blogService.save(getServiceContext(), blog);
		Blog found = blogService.findById(getServiceContext(), saved.getId());
		Set<Author> writers = found.getWriters();
		assertEquals(2, writers.size());
	}

	@Override
	@Test
	public void testFindAll() throws Exception {
		for (int i = 0; i < 10; i++) {
			Blog blog = new Blog("http://www.test.org/" + i);
			blogService.save(getServiceContext(), blog);
		}

		List<Blog> all = blogService.findAll(getServiceContext());
		assertEquals(10, all.size());
	}

	@Override
	public void testFindById() throws Exception {
		// covered by testSave
	}

	@Override
	@Test
	public void testDelete() throws Exception {
		// TODO Auto-generated method stub

	}

}
