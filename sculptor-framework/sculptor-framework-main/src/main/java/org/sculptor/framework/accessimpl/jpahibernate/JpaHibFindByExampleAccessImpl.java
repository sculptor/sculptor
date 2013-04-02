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

package org.sculptor.framework.accessimpl.jpahibernate;

import java.util.List;

import javax.persistence.PersistenceException;

import org.hibernate.Criteria;
import org.hibernate.Session;
import org.hibernate.criterion.DetachedCriteria;
import org.hibernate.criterion.Example;
import org.hibernate.criterion.Order;
import org.sculptor.framework.accessapi.FindByExampleAccess;
import org.sculptor.framework.accessimpl.jpa.JpaAccessBase;


/**
 * <p>
 * Find all entities similar to another entity. Implementation of Access command
 * FindByExampleAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaHibFindByExampleAccessImpl<T> extends JpaAccessBase<T> implements FindByExampleAccess<T> {

    private T exampleInstance;
    private String orderBy;
    private boolean orderByAsc = true;
    private String[] excludeProperties;
    private List<T> result;

    public JpaHibFindByExampleAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public T getExample() {
        return exampleInstance;
    }

    public void setExample(T example) {
        this.exampleInstance = example;
    }

    public String getOrderBy() {
        return orderBy;
    }

    public void setOrderBy(String orderBy) {
        this.orderBy = orderBy;
    }

    public boolean isOrderByAsc() {
        return orderByAsc;
    }

    public void setOrderByAsc(boolean orderByAsc) {
        this.orderByAsc = orderByAsc;
    }

    public String[] getExcludeProperties() {
        return excludeProperties;
    }

    public void setExcludeProperties(String[] excludeProperties) {
        this.excludeProperties = excludeProperties;
    }

    public List<T> getResult() {
        return this.result;
    }

    @Override
    public void performExecute() throws PersistenceException {
        Example example = createExample();

        if (excludeProperties != null) {
            for (int i = 0; i < excludeProperties.length; i++) {
                example.excludeProperty(excludeProperties[i]);
            }
        }

        DetachedCriteria crit = createCriteria(example);

        if (orderBy != null) {
            if (orderByAsc) {
            	crit.addOrder(Order.asc(orderBy));
            } else {
            	crit.addOrder(Order.desc(orderBy));
            }
        }
        Session hibernateSession = HibernateSessionHelper.getHibernateSession(getEntityManager());
        final Criteria criteria = crit.getExecutableCriteria(hibernateSession);
        prepareCache(criteria);

        result = executeFind(criteria);
    }

    protected void prepareCache(Criteria criteria) {
        if (isCache()) {
            criteria.setCacheable(true);
            criteria.setCacheRegion(getCacheRegion());
        }
    }

    @SuppressWarnings("unchecked")
    protected List<T> executeFind(Criteria criteria) {
    	return criteria.list();
    }

    protected Example createExample() {
        return Example.create(exampleInstance).excludeZeroes().ignoreCase().enableLike();
    }

    protected DetachedCriteria createCriteria(Example example) {
        return DetachedCriteria.forClass(getPersistentClass()).add(example);
    }

}