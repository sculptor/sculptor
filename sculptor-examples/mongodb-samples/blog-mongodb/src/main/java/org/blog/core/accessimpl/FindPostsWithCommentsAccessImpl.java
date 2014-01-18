package org.blog.core.accessimpl;

import java.util.ArrayList;
import java.util.List;

import org.blog.core.domain.BlogPost;

import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;

/**
 * Implementation of Access object for BlogPostRepository.findPostsWithComments.
 */
public class FindPostsWithCommentsAccessImpl extends FindPostsWithCommentsAccessImplBase {

	@Override
	public void performExecute() {
		DBObject query = new BasicDBObject();
		query.put("comments", new BasicDBObject("$not", new BasicDBObject("$size", 0)));
		DBCursor cur = getDBCollection().find(query);

		List<BlogPost> mappedResult = new ArrayList<BlogPost>();
		for (DBObject each : cur) {
			BlogPost eachResult = (BlogPost) getDataMapper().toDomain(each);
			mappedResult.add(eachResult);
		}

		setResult(mappedResult);
	}

}
