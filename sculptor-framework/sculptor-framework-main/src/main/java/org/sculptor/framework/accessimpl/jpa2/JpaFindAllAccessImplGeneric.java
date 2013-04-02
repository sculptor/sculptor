/*
 * Copyright 2007 The Fornax Project Team, including the original
 * author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.framework.accessimpl.jpa2;

import java.util.Arrays;
import java.util.List;

import org.sculptor.framework.accessapi.FindAllAccess2;


/**
 * <p>
 * Find all entities of a specific type. Implementation of Access command
 * FindAllAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
// EclipseLink has problems with inheritance and criteria query, using jpql query works
// TODO: check reason and switch back to criteria query
public class JpaFindAllAccessImplGeneric<T,R>
//	extends JpaCriteriaQueryAccessBase<T,R>
	extends JpaJpqlQueryAccessBase<T,R>
    implements FindAllAccess2<R> {

    public JpaFindAllAccessImplGeneric() {
        super();
    }

    public JpaFindAllAccessImplGeneric(Class<T> type) {
        super(type);
    }

    public JpaFindAllAccessImplGeneric(Class<T> type, Class<R> resultType) {
        super(type, resultType);
    }

    public List<R> getResult() {
        return getListResult();
    }

    // TODO: remove all overrides if using criteria query

    String orderBy = null;

    @Override
    protected void prepareQuery(QueryConfig config) {
    	super.prepareQuery(config);
    	StringBuffer query = new StringBuffer();
    	query.append("select ");
    	if (config.isDistinct()) {
    		query.append("distinct ");
    	}
    	query.append("object(e) from ").append(getType().getSimpleName()).append(" e");
    	setNamedQuery(false);
		setQuery(query.toString());
    }

    @Override
    protected void prepareOrderBy(String query, QueryConfig config) {
        if (orderBy != null)
            query += " order by " + JpaHelper.toSeparatedString(Arrays.asList(orderBy.split(",")), ",", "e.");
    }

    @Override
    protected void prepareResultCount(QueryConfig config) {
    	StringBuffer query = new StringBuffer();
    	query.append("select ");
    	if (config.isDistinct()) {
    		query.append("distinct ");
    	}
    	query.append("count(e) from ").append(getType().getSimpleName()).append(" e");
        setResultCountQuery(getEntityManager().createQuery(query.toString(), Long.class));
    }

    @Override
    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
    }

    @Override
    @Deprecated
    public void setOrderByAsc(boolean orderByAsc) {
    }
}