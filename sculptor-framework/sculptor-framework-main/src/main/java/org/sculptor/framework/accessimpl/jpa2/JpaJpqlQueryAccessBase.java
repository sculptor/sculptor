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

import java.util.Map;

import javax.persistence.Query;
import javax.persistence.TypedQuery;


/**
 * <p>
 * Implementation of Access command FindByQueryAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public abstract class JpaJpqlQueryAccessBase<T,R>
    extends JpaQueryAccessBase<T,R> {

    private String query;
    private Boolean namedQuery;

    private TypedQuery<Long> resultCountQuery = null;

	public JpaJpqlQueryAccessBase() {
        super();
    }

    @SuppressWarnings("unchecked")
    public JpaJpqlQueryAccessBase(Class<T> type) {
        super(type, (Class<R>) type);
    }

    public JpaJpqlQueryAccessBase(Class<T> type, Class<R> resultType) {
        super(type, resultType);
    }

    protected String getQuery() {
        return query;
    }

    public void setQuery(String query) {
        this.query = query;
    }

    protected TypedQuery<Long> getResultCountQuery() {
		return resultCountQuery;
	}

    protected void setResultCountQuery(TypedQuery<Long> resultCountQuery) {
		this.resultCountQuery = resultCountQuery;
	}

    protected boolean isNamedQuery() {
        if (namedQuery != null) {
            return namedQuery;
        }
        if (query == null) {
            return false;
        }
        return !query.trim().contains(" ");
    }

    public void setNamedQuery(boolean namedQuery) {
        this.namedQuery = namedQuery;
    }

    @Override
    protected TypedQuery<R> prepareTypedQuery(QueryConfig config) {
        if (isNamedQuery()) {
            return getEntityManager().createNamedQuery(query, getResultType());
        } else {
            return getEntityManager().createQuery(query, getResultType());
        }
    }

    @Override
    protected Query prepareUntypedQuery(QueryConfig config) {
        if (isNamedQuery()) {
            return getEntityManager().createNamedQuery(query);
        } else {
            return getEntityManager().createQuery(query);
        }
    }

    @Override
    final protected void prepareOrderBy(QueryConfig config) {
//	    if (config.hasOrders()) {
	        if (config.isSingleResult() || isNamedQuery()) {
		    	if (config.throwExceptionOnConfigurationError()) {
		            throw new QueryConfigException("Query returns a single result or is a named query, 'order by' not allowed.");
		    	}
		    	return;
		    }
	       	if (query.contains("order by")) {
	        	if (config.throwExceptionOnConfigurationError()) {
	                throw new QueryConfigException("Query contains 'order by' already.");
	        	}
	        	return;
	       	}
//	    }
       	prepareOrderBy(query, config);
    }

    protected void prepareOrderBy(String query, QueryConfig config) {
//	   	query += " order by " + config.getOrderBy();
    }

    @Override
    protected void prepareHints(Query query, QueryConfig config) {
        if (!isNamedQuery()) {
            super.prepareHints(query, config);
        }
    }

    @Override
    protected void prepareResultCount(QueryConfig config) {
        if (isNamedQuery()) {
            // try find a named query for counting rows
            if (JpaHelper.findNamedQuery(getType(), query.replace("find", "count")) != null) {
            	resultCountQuery =
                    getEntityManager().createNamedQuery(query.replace("find", "count"), Long.class);
            } else {
                // guess a query for counting rows based on the named query
                resultCountQuery =
                    getEntityManager().createQuery(
                            JpaHelper.createResultCountQuery(
                                    JpaHelper.findNamedQuery(getType(), query).query()), Long.class);
            }
        } else {
            // guess a query for counting rows based on the query string
            resultCountQuery =
                getEntityManager().createQuery(
                        JpaHelper.createResultCountQuery(query), Long.class);
        }
    };

    @Override
    public void executeResultCount() {
        if (resultCountQuery != null) {
            if (getParameters() != null) {
                for (Map.Entry<String, ?> entry : getParameters().entrySet()) {
                    resultCountQuery.setParameter(entry.getKey(), entry.getValue());
                }
            }
            setResultCount(resultCountQuery.getSingleResult());
        }
    }
}