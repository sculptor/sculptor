package org.sculptor.framework.accessimpl.jpa2;

import java.util.ArrayList;
import java.util.List;

/**
 * Holds the configuration of the query
 *
 * @author Oliver Ringel
 *
 */
public interface QueryConfig {

    boolean isIgnoreCase();
    QueryConfig setIgnoreCase(boolean ignoreCase);
    boolean isExcludeZeroes();
    QueryConfig setExcludeZeroes(boolean excludeZeroes);
    boolean isEnableLike();
    QueryConfig setEnableLike(boolean enableLike);
    List<String> getExcludeProperties();
    QueryConfig setExcludeProperties(List<String> excludeProperties);

    int getFirstResult();
    QueryConfig setFirstResult(int firstResult);
    int getMaxResults();
    QueryConfig setMaxResults(int maxResults);
    boolean isPagedQuery();
    boolean isResultCountNeeded();

    boolean isDisjunction();
    QueryConfig setDisjunction(boolean disjunction);
    boolean isDistinct();
    QueryConfig setDistinct(boolean distinct);
    boolean isSingleResult();
    QueryConfig setSingleResult(boolean singleResult);

    boolean throwExceptionOnConfigurationError();

    QueryConfig setResultType(Class<?> resultType);
    Class<?> getResultType();

    /**
     * default values
     */
    static class Default implements QueryConfig {

        private List<String> orders = new ArrayList<String>();

        private int firstResult = -1;
        private int maxResults = 0;

        private boolean ignoreCase = true;
        private boolean excludeZeroes = true;
        private boolean enableLike = true;
        private List<String> excludeProperties = new ArrayList<String>();

        private Class<?> resultType = null;
        private boolean singleResult = false;
        private boolean distinct = true;
        private boolean disjunction = false;

        private boolean throwExceptionOnConfigurationError = false;

        public boolean isIgnoreCase() {
            return ignoreCase;
        }

        public QueryConfig setIgnoreCase(boolean ignoreCase) {
            this.ignoreCase = ignoreCase;
            return this;
        }

        public boolean isExcludeZeroes() {
            return excludeZeroes;
        }

        public QueryConfig setExcludeZeroes(boolean excludeZeroes) {
            this.excludeZeroes = excludeZeroes;
            return this;
        }

        public boolean isEnableLike() {
            return enableLike;
        }

        public QueryConfig setEnableLike(boolean enableLike) {
            this.enableLike = enableLike;
            return this;
        }

        public List<String> getExcludeProperties() {
            return excludeProperties;
        }

        public QueryConfig setExcludeProperties(List<String> excludeProperties) {
            this.excludeProperties = excludeProperties;
            return this;
        }

        public List<String> getOrders() {
            return orders;
        }

        public String getOrderBy() {
            return JpaHelper.toSeparatedString(orders, ",");
        }

        public QueryConfig setOrderBy(String orderBy) {
            addOrders(orderBy);
            return this;
        }

        public void addOrders(String orders) {
            String[] ord = orders.split(",");
            for (int i = 0; i < ord.length; i++) {
                this.orders.add(ord[i].trim());
            }
        }

        public void addOrders(String... orders) {
            for (int i = 0; i < orders.length; i++) {
                this.orders.add(orders[i].trim());
            }
        }

        public void addOrderBy(String order) {
            this.orders.add(order);
        }

        public boolean hasOrders() {
            if (orders != null && !orders.isEmpty()) {
                return true;
            }
            return false;
        }

        public int getFirstResult() {
            return firstResult;
        }

        public QueryConfig setFirstResult(int firstResult) {
            this.firstResult = firstResult;
            return this;
        }

        public int getMaxResults() {
            return maxResults;
        }

        public QueryConfig setMaxResults(int maxResults) {
            this.maxResults = maxResults;
            return this;
        }

        public boolean isDisjunction() {
            return disjunction;
        }

        public QueryConfig setDisjunction(boolean disjunction) {
            this.disjunction = disjunction;
            return this;
        }

        public QueryConfig setDistinct(boolean distinct) {
            this.distinct = distinct;
            return this;
        }

        public boolean isDistinct() {
            return distinct;
        }

        public QueryConfig setSingleResult(boolean singleResult) {
            this.singleResult = singleResult;
            return this;
        }

        public boolean isSingleResult() {
            return singleResult;
        }

        public Class<?> getResultType() {
            return resultType;
        }

        public QueryConfig setResultType(Class<?> resultType) {
            this.resultType = resultType;
            return this;
        }

        public boolean throwExceptionOnConfigurationError() {
            return throwExceptionOnConfigurationError;
        }

        public QueryConfig setThrowExceptionOnConfigurationError(boolean throwExceptionOnConfigurationError) {
            this.throwExceptionOnConfigurationError = throwExceptionOnConfigurationError;
            return this;
        }

        @Override
        public boolean isPagedQuery() {
            if (getFirstResult() != -1 && getMaxResults() != 0) {
                return true;
            }
            return false;
        }

        @Override
        public boolean isResultCountNeeded() {
            return isPagedQuery() && !isSingleResult();
        }
    }
}