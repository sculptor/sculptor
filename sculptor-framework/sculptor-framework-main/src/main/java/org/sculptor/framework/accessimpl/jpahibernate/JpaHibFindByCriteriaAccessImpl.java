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

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import javax.persistence.PersistenceException;

import org.hibernate.Criteria;
import org.hibernate.FetchMode;
import org.hibernate.criterion.Order;
import org.hibernate.criterion.Restrictions;
import org.sculptor.framework.accessapi.FindByCriteriaAccess;
import org.sculptor.framework.accessimpl.jpa.JpaAccessBase;


/**
 * <p>
 * Implementation of Access command FindByCriteriaAccess.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 */
public class JpaHibFindByCriteriaAccessImpl<T> extends JpaAccessBase<T> implements FindByCriteriaAccess<T> {

    private Map<String, Object> restrictions = new HashMap<String, Object>();
    private Set<String> fetchAssociations = new HashSet<String>();
    private String orderBy;
    private boolean orderByAsc = true;
    private int firstResult = -1;
    private int maxResult = 0;
    private List<T> result;

    public JpaHibFindByCriteriaAccessImpl(Class<T> persistentClass) {
        setPersistentClass(persistentClass);
    }

    public void setRestrictions(Map<String, Object> parameters) {
        this.restrictions = parameters;
    }

    protected Map<String, Object> getRestrictions() {
        return restrictions;
    }

    public void addRestriction(String name, Object value) {
        restrictions.put(name, value);
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
    public void performExecute() throws PersistenceException {
        final Criteria criteria = createCriteria();
        prepareCache(criteria);
        addFetch(criteria);
        addRestrictions(criteria);

        if (orderBy != null) {
            if (orderByAsc) {
                criteria.addOrder(Order.asc(orderBy));
            } else {
                criteria.addOrder(Order.desc(orderBy));
            }
        }

        if (firstResult >= 0) {
            criteria.setFirstResult(firstResult);
        }
        if (maxResult >= 1) {
            criteria.setMaxResults(maxResult);
        }

        addResultTransformer(criteria);

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

    /**
     * By default a DISTINCT_ROOT_ENTITY result transformer is set
     * on the criteria.
     * Can be overridden to define another transformer.
     */
    protected void addResultTransformer(final Criteria criteria) {
        criteria.setResultTransformer(Criteria.DISTINCT_ROOT_ENTITY);
    }

    protected Criteria createCriteria() {
        return HibernateSessionHelper.getHibernateSession(getEntityManager())
            .createCriteria(getPersistentClass());
    }

    /**
     * Add the restrictions to the criteria. Can be overridden
     * to build more advanced criterias.
     */
    protected void addRestrictions(Criteria criteria) {
        addSubCriterias(criteria);
        String[] names = getParameterNames();
        Object[] values = getParameterValues();
        for (int i = 0; i < names.length; i++) {
            if (values[i] == null) {
                criteria.add(Restrictions.isNull(names[i]));
            } else {
                criteria.add(Restrictions.eq(names[i], values[i]));
            }
        }
    }

    /**
     * Add the fetch modes to the criteria. Can be overridden
     * to build more advanced criterias.
     */
    protected void addFetch(Criteria criteria) {
        for (String associationPath : fetchAssociations) {
            criteria.setFetchMode(associationPath, getFetchMode(associationPath));
        }
    }

    /**
     * Default fetch mode is FetchMode.JOIN.
     * Can be overridden.
     */
    protected FetchMode getFetchMode(String associationPath) {
        return FetchMode.JOIN;
    }

    protected void addSubCriterias(Criteria criteria) {
        List<String> subCriteriaNames = getSubCriteriaNames();
        for (String criteriaPath : subCriteriaNames) {
            criteria.createCriteria(criteriaPath, criteriaPath);
        }
    }

    protected List<String> getSubCriteriaNames() {
        String[] names = getParameterNames();
        Set<String> allNames = new HashSet<String>();
        for (String s : names) {
            allNames.addAll(subCriteriaNames(s));
        }

        // sort by name length to make sure the criterias are added in the right order
        List<String> namesList = new ArrayList<String>(allNames);
        sortByStringLength(namesList);

        return namesList;
    }

    @SuppressWarnings("unchecked")
    protected Set<String> subCriteriaNames(String name) {
        if (name.indexOf('.') == -1) {
            return Collections.EMPTY_SET;
        } else {
            String[] split = name.split("\\.");
            Set<String> subCriteriaNames = new HashSet<String>();
            String currentName = null;
            // don't add the last
            for (int i = 0; i < (split.length - 1); i++) {
                currentName = (currentName == null ? "" : currentName + ".") + split[i];
                subCriteriaNames.add(currentName);
            }
            return subCriteriaNames;
        }
    }

    private void sortByStringLength(List<String> list) {
        Collections.sort(list, new StringLengthComparator());
    }

    protected String[] getParameterNames() {
        if (restrictions == null) {
            return new String[0];
        } else {
            String[] names = new String[restrictions.size()];
            names = restrictions.keySet().toArray(names);
            return names;
        }
    }

    protected Object[] getParameterValues() {
        if (restrictions == null) {
            return new String[0];
        } else {
            Object[] values = restrictions.values().toArray();
            return values;
        }
    }

    private static class StringLengthComparator implements Comparator<String> {
        public int compare(String s1, String s2) {
            return (s1.length() < s2.length() ? -1 : (s1.length()==s2.length() ? 0 : 1));
        }
    }
}