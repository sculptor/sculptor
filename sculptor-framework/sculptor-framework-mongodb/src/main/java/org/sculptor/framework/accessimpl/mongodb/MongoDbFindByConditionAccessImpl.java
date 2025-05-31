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

import com.mongodb.client.FindIterable;
import com.mongodb.client.model.Filters;
import com.mongodb.client.model.Sorts;
import org.bson.conversions.Bson;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteria.Operator;
import org.sculptor.framework.accessapi.FindByConditionAccess;
import org.sculptor.framework.domain.Property;

import com.mongodb.DBObject;

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
	private Property<?>[] fetchEager;

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

    public void setFetchEager(Property<?>[] fetchEager) {
        this.fetchEager = fetchEager;
    }

    public Property<?>[] getFetchEager() {
        return fetchEager;
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
        Bson query = createQuery();
        FindIterable<DBObject> cur = getDBCollection().find(query);
        sort(cur);

        if (firstResult >= 0) {
            cur.skip(firstResult);
        }
        if (maxResult >= 1) {
            cur.limit(maxResult);
        }

        List<T> foundResult = new ArrayList<T>();
        cur.map(row -> getDataMapper().toDomain(row)).into(result);

        this.result = foundResult;
    }

    private Bson createQuery() {
        List<Bson> andCriteria = new ArrayList<>();
        for (ConditionalCriteria crit : cndCriterias) {
            andCriteria.add(makeCriterion(crit, false));
        }
        return Filters.and(andCriteria);
    }

    protected Bson makeCriterion(ConditionalCriteria crit, boolean not) {
        Bson bson = makeSimpleCriterion(crit);
        return not ? Filters.not(bson) : bson;
    }

    private Bson makeSimpleCriterion(ConditionalCriteria crit) {
        ConditionalCriteria.Operator operator = crit.getOperator();
        return switch (operator) {
            case Equal -> Filters.eq(crit.getPropertyFullName(), toData(crit.getFirstOperant()));
            case Like -> Filters.regex(crit.getPropertyFullName(), String.valueOf(crit.getFirstOperant()));
            case IgnoreCaseLike -> Filters.regex(crit.getPropertyFullName(), String.valueOf(crit.getFirstOperant()), "i");
            case In -> {
                if (crit.getFirstOperant() instanceof Iterable<?> fo) {
                    yield Filters.in(crit.getPropertyFullName(), fo);
                } else {
                    yield Filters.in(crit.getPropertyFullName(), toData(crit.getFirstOperant()));
                }
            }
            case LessThan -> Filters.lt(crit.getPropertyFullName(), toData(crit.getFirstOperant()));
            case LessThanOrEqual -> Filters.lte(crit.getPropertyFullName(), toData(crit.getFirstOperant()));
            case GreatThan -> Filters.gt(crit.getPropertyFullName(), toData(crit.getFirstOperant()));
            case GreatThanOrEqual -> Filters.gte(crit.getPropertyFullName(), toData(crit.getFirstOperant()));
            case IsNull -> Filters.exists(crit.getPropertyFullName(), false);
            case IsNotNull -> Filters.exists(crit.getPropertyFullName(), true);
            case IsEmpty -> Filters.eq(crit.getPropertyFullName(), "");
            case IsNotEmpty -> Filters.ne(crit.getPropertyFullName(), "");
            case Between -> {
                Object val = toData(crit.getFirstOperant());
                yield Filters.and(Filters.gte(crit.getPropertyFullName(), val)
                        , Filters.lte(crit.getPropertyFullName(), val));
            }
            case And -> {
                Bson left = makeSimpleCriterion((ConditionalCriteria) crit.getFirstOperant());
                Bson right = makeSimpleCriterion((ConditionalCriteria) crit.getSecondOperant());
                yield Filters.and(left, right);
            }
            case Or -> {
                Bson left = makeSimpleCriterion((ConditionalCriteria) crit.getFirstOperant());
                Bson right = makeSimpleCriterion((ConditionalCriteria) crit.getSecondOperant());
                yield Filters.or(left, right);
            }
            case Not -> {
                Bson left = makeSimpleCriterion((ConditionalCriteria) crit.getFirstOperant());
                yield Filters.not(left);
            }
            default -> throw new UnsupportedOperationException("Unsupported operator '" + operator.name() + "'");
        };
    }

    protected void sort(FindIterable<DBObject> cursor) {
        List<Bson> orders = new ArrayList<>();
        for (ConditionalCriteria crit : cndCriterias) {
            if (Operator.OrderAsc.equals(crit.getOperator())) {
                orders.add(Sorts.ascending(crit.getPropertyFullName()));
            } else if (Operator.OrderDesc.equals(crit.getOperator())) {
                orders.add(Sorts.descending(crit.getPropertyFullName()));
            }
        }
        if (!orders.isEmpty()) {
            cursor.sort(Sorts.orderBy(orders));
        }
    }

    public Long getResultCount() {
        return rowCount;
    }

    public void executeCount() {
        Bson query = createQuery();
        long count = getDBCollection().countDocuments(query);
        if (count > Integer.MAX_VALUE) {
            throw new IllegalStateException("Too many in count: " + count);
        }
        rowCount = count;
    }
}