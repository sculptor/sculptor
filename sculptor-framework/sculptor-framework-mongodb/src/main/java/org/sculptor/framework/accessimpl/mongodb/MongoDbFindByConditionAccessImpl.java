/*
 * Copyright 2009 The Fornax Project Team, including the original
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

package org.sculptor.framework.accessimpl.mongodb;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.regex.Pattern;

import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.FindByConditionAccess;
import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;

import com.mongodb.BasicDBObject;
import com.mongodb.DBCursor;
import com.mongodb.DBObject;
import com.mongodb.QueryOperators;

/**
 * <p>
 * Implementation of Access command FindByConditionAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class MongoDbFindByConditionAccessImpl<T> extends MongoDbAccessBase<T> implements FindByConditionAccess<T> {

    private List<ConditionalCriteria> cndCriterias = new ArrayList<ConditionalCriteria>();
    private Set<String> fetchAssociations = new HashSet<String>();
    private int firstResult = -1;
    private int maxResult = 0;
    private List<T> result;
    private Long rowCount = null;

    public MongoDbFindByConditionAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public void setCondition(List<ConditionalCriteria> criteria) {
        cndCriterias = criteria;
    }

    public void addCondition(ConditionalCriteria criteria) {
        cndCriterias.add(criteria);
    }

    public void setFetchAssociations(Set<String> associationPaths) {
        this.fetchAssociations = associationPaths;
    }

    public void addFetchAssociation(String associationPath) {
        this.fetchAssociations.add(associationPath);
    }

    protected Set<String> getFetchAssociations() {
        return fetchAssociations;
    }

    protected int getFirstResult() {
        return firstResult;
    }

    public void setFirstResult(int firstResult) {
        this.firstResult = firstResult;
    }

    protected int getMaxResult() {
        return maxResult;
    }

    public void setMaxResult(int maxResult) {
        this.maxResult = maxResult;
    }

    public List<T> getResult() {
        return this.result;
    }

    @Override
    public void performExecute() {

        DBObject query = createQuery();

        DBCursor cur = getDBCollection().find(query);
        sort(cur);

        if (firstResult >= 0) {
            cur.skip(firstResult);
        }
        if (maxResult >= 1) {
            cur.limit(maxResult);
        }

        List<T> foundResult = new ArrayList<T>();
        for (DBObject each : cur) {
            T eachResult = getDataMapper().toDomain(each);
            foundResult.add(eachResult);
        }

        this.result = foundResult;

    }

    private DBObject createQuery() {
        DBObject query = new BasicDBObject();
        for (ConditionalCriteria crit : cndCriterias) {
            makeCriterion(query, crit, false);
        }
        return query;
    }

    protected void makeCriterion(DBObject query, ConditionalCriteria crit, boolean not) {
        ConditionalCriteria.Operator operator = crit.getOperator();
        if (Operator.Equal.equals(operator)) {
            Object dbValue = toData(crit.getFirstOperant());
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.NE, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.Like.equals(operator)) {
            Pattern regex = regex(crit.getFirstOperant(), false);
            Object dbValue = wrapNot(not, regex);
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.IgnoreCaseLike.equals(operator)) {
            Pattern regex = regex(crit.getFirstOperant(), true);
            Object dbValue = wrapNot(not, regex);
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.In.equals(operator)) {
            Object dbValue = toData(crit.getFirstOperant());
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.NIN, dbValue);
            } else {
                dbValue = new BasicDBObject(QueryOperators.IN, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.LessThan.equals(operator)) {
            Object dbValue = toData(crit.getFirstOperant());
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.GTE, dbValue);
            } else {
                dbValue = new BasicDBObject(QueryOperators.LT, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.LessThanOrEqual.equals(operator)) {
            Object dbValue = toData(crit.getFirstOperant());
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.GT, dbValue);
            } else {
                dbValue = new BasicDBObject(QueryOperators.LTE, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.GreatThan.equals(operator)) {
            Object dbValue = toData(crit.getFirstOperant());
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.LTE, dbValue);
            } else {
                dbValue = new BasicDBObject(QueryOperators.GT, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.GreatThanOrEqual.equals(operator)) {
            Object dbValue = toData(crit.getFirstOperant());
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.LT, dbValue);
            } else {
                dbValue = new BasicDBObject(QueryOperators.GTE, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.IsNull.equals(operator)) {
            Object dbValue = null;
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.NE, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.IsNotNull.equals(operator)) {
            Object dbValue;
            if (not) {
                dbValue = null;
            } else {
                dbValue = new BasicDBObject(QueryOperators.NE, null);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.IsEmpty.equals(operator)) {
            Object dbValue = "";
            if (not) {
                dbValue = new BasicDBObject(QueryOperators.NE, dbValue);
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.IsNotEmpty.equals(operator)) {
            Object dbValue;
            if (not) {
                dbValue = "";
            } else {
                dbValue = new BasicDBObject(QueryOperators.NE, "");
            }
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (not && Operator.Between.equals(operator)) {
            throw new UnsupportedOperationException("Not between condition not supported");
        } else if (Operator.Between.equals(operator)) {
            Object first = toData(crit.getFirstOperant());
            Object second = toData(crit.getSecondOperant());
            DBObject dbValue = new BasicDBObject();
            dbValue.put(QueryOperators.GTE, first);
            dbValue.put(QueryOperators.LTE, second);
            query.put(crit.getPropertyFullName(), dbValue);
        } else if (Operator.And.equals(operator)) {
            makeCriterion(query, (ConditionalCriteria) crit.getFirstOperant(), not);
            makeCriterion(query, (ConditionalCriteria) crit.getSecondOperant(), not);
        } else if (Operator.Not.equals(operator)) {
            makeCriterion(query, (ConditionalCriteria) crit.getFirstOperant(), !not);
        } else if (Operator.Or.equals(operator)) {
            throw new UnsupportedOperationException("Or condition not supported");
        }
    }

    private Object wrapNot(boolean not, Object dbValue) {
        if (not) {
            dbValue = new BasicDBObject("$not", dbValue);
        }
        return dbValue;
    }

    protected Pattern regex(Object expression, boolean ignoreCase) {
        if (expression instanceof Pattern) {
            return (Pattern) expression;
        }
        String strExpression = String.valueOf(expression);
        if (ignoreCase) {
            return Pattern.compile(strExpression, Pattern.CASE_INSENSITIVE);
        } else {
            return Pattern.compile(strExpression);
        }
    }

    protected void sort(DBCursor cur) {
        BasicDBObject orderBy = new BasicDBObject();
        for (ConditionalCriteria crit : cndCriterias) {
            if (Operator.OrderAsc.equals(crit.getOperator())) {
                orderBy.put(crit.getPropertyFullName(), 1);
            } else if (Operator.OrderDesc.equals(crit.getOperator())) {
                orderBy.put(crit.getPropertyFullName(), -1);
            }
        }
        if (!orderBy.isEmpty()) {
            cur.sort(orderBy);
        }
    }

    public Long getResultCount() {
        return rowCount;
    }

    public void executeCount() {
        DBObject query = createQuery();
        long count = getDBCollection().getCount(query);
        if (count > Integer.MAX_VALUE) {
            throw new IllegalStateException("Too many in count: " + count);
        }
        rowCount = count;
    }
}