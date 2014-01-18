package org.blog.core.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.sculptor.framework.errorhandling.SimpleJUnitServiceContextFactory.getServiceContext;

import java.util.Date;
import java.util.List;
import java.util.Set;

import org.blog.core.domain.Blog;
import org.blog.core.domain.BlogPost;
import org.blog.core.domain.Comment;
import org.blog.core.exception.BlogPostNotFoundException;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

/**
 * Spring based test with MongoDB.
 */
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class BlogPostServiceTest extends AbstractJUnit4SpringContextTests implements BlogPostServiceTestBase {

	@Autowired
	private DbManager dbManager;

	@Autowired
	private BlogPostService postService;

	@Autowired
    private BlogService blogService;

	private Blog blog;
    private BlogPost post;

	@Before
	public void initTestData() {
        Blog b = new Blog("http://www.test.org/cool");
        b.setIntro("This is cool");
        b.setTitle("Testing");
        blog = blogService.save(getServiceContext(), b);

        BlogPost p = new BlogPost("intro-post");
        p.setInBlogId(blog.getId());
        p.setPublished(new Date());
        Comment comment1 = new Comment("Great", "Great Stuff", new Date());
        p.getCommentSet().add(comment1);
        post = postService.save(getServiceContext(), p);

        BlogPost p2 = new BlogPost("other-post");
        p2.setInBlogId(blog.getId());
        postService.save(getServiceContext(), p2);
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

    @Override
    @Test
    public void testGetPostsInBlog() throws Exception {
        List<BlogPost> found = postService.getPostsInBlog(getServiceContext(), blog);
        assertEquals(2, found.size());
    }

    @Override
    @Test
    public void testGetPostsWithGreatComments() throws Exception {
        List<BlogPost> found = postService.getPostsWithGreatComments(getServiceContext());
        assertEquals(1, found.size());
    }

    @Override
    @Test
    public void testSave() throws Exception {
        BlogPost post = new BlogPost("my-first-post");
        post.setInBlogId(blog.getId());

        BlogPost savedPost = postService.save(getServiceContext(), post);
        assertNotNull(savedPost.getId());

        BlogPost foundPost = postService.findById(getServiceContext(), savedPost.getId());
        assertEquals(savedPost, foundPost);
        assertEquals(savedPost.getBody(), foundPost.getBody());
        assertEquals(savedPost.getInBlogId(), foundPost.getInBlogId());
        assertEquals(savedPost.getSlug(), foundPost.getSlug());
        assertEquals(savedPost.getTitle(), foundPost.getTitle());

        // lazy fetch
        assertEquals(blog.getId(), foundPost.getInBlogId());
        Blog inBlog = foundPost.getInBlog();
        assertEquals(blog, inBlog);
        assertEquals(blog.getId(), inBlog.getId());
    }

    @Test
    public void testComments() throws Exception {
        Blog blog = new Blog("http://www.test.org/cool");
        blog.setIntro("This is cool");
        blog.setTitle("Testing");
        Blog savedBlog = blogService.save(getServiceContext(), blog);

        BlogPost post = new BlogPost("my-first-post");
        post.setInBlogId(savedBlog.getId());
        long time = System.currentTimeMillis();
        Comment comment1 = new Comment("Comment 1", "I think you are right", new Date(time));
        post.getCommentSet().add(comment1);
        Comment comment2 = new Comment("Comment 2", "I don't agree with you", new Date(time + 10000));
        post.getCommentSet().add(comment2);

        BlogPost saved = postService.save(getServiceContext(), post);
        assertEquals(post.getComments().size(), saved.getComments().size());
        assertNotNull(saved.getId());

        BlogPost found = postService.findById(getServiceContext(), saved.getId());
        assertEquals(saved.getComments().size(), found.getComments().size());
        assertEquals(comment1.getTitle(), found.getComments().get(0).getTitle());
        assertEquals(comment1.getBody(), found.getComments().get(0).getBody());
        assertEquals(comment2.getTitle(), found.getComments().get(1).getTitle());
        assertEquals(comment2.getBody(), found.getComments().get(1).getBody());
    }

    @Override
    @Test
    public void testFindAll() throws Exception {
        List<BlogPost> found = postService.findAll(getServiceContext());
        assertEquals(2, found.size());
    }

    @Override
    @Test
    public void testFindById() throws Exception {
        BlogPost found = postService.findById(getServiceContext(), post.getId());
        assertEquals(post, found);
    }

    @Test(expected = BlogPostNotFoundException.class)
    public void testFindByIdNotFound() throws Exception {
        postService.findById(getServiceContext(), "jdfldfhiu");
    }

    @Override
    public void testDelete() throws Exception {
        int before = countRowsInDBCollection(BlogPost.class.getSimpleName());
        postService.delete(getServiceContext(), post);
        int after = countRowsInDBCollection(BlogPost.class.getSimpleName());
        assertEquals(before - 1, after);
    }
}
