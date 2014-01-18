package org.blog.core.repositoryimpl;

import static org.blog.core.domain.BlogPostProperties.commentSet;
import static org.blog.core.domain.BlogPostProperties.inBlog;
import static org.blog.core.domain.BlogPostProperties.published;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.List;

import org.blog.core.domain.Blog;
import org.blog.core.domain.BlogPost;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.springframework.stereotype.Repository;

/**
 * Repository implementation for BlogPost
 */
@Repository("blogPostRepository")
public class BlogPostRepositoryImpl extends BlogPostRepositoryBase {

	public BlogPostRepositoryImpl() {
	}

	@Override
	public List<BlogPost> findPostsWithGreatComments() {
		List<ConditionalCriteria> condition = criteriaFor(BlogPost.class).withProperty(commentSet().title())
				.ignoreCaseLike(".*great.*").and().withProperty(published()).isNotNull().orderBy(published())
				.descending().build();
		return findByCondition(condition);
	}

	@Override
	public List<BlogPost> findPostsInBlog(Blog blog) {
		List<ConditionalCriteria> condition = criteriaFor(BlogPost.class).withProperty(inBlog()).eq(blog)
				.orderBy(published()).descending().build();
		return findByCondition(condition);
	}

}
