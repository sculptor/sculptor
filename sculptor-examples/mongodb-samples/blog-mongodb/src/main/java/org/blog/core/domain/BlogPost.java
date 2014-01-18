package org.blog.core.domain;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * EntityImpl representing BlogPost.
 * <p>
 * This class is responsible for the domain object related business logic for
 * BlogPost. Properties and associations are implemented in the generated base
 * class {@link org.blog.core.domain.BlogPostBase}.
 */
public class BlogPost extends BlogPostBase {

	private static final long serialVersionUID = 1L;

	protected BlogPost() {
	}

	public BlogPost(String slug) {
		super(slug);
	}

	public List<Comment> getComments() {
		List<Comment> result = new ArrayList<Comment>(getCommentSet());
		Collections.sort(result, new Comparator<Comment>() {
			@Override
			public int compare(Comment c1, Comment c2) {
				return c1.getTimestamp().compareTo(c2.getTimestamp());
			}
		});
		return result;
	}

}
