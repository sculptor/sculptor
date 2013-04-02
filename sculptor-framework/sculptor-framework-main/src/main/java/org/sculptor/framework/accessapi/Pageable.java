package org.sculptor.framework.accessapi;

/**
 * Access Objects with result that can be paginated may implement this
 * interface.
 *
 */
public interface Pageable {

    /**
     * Set the first row to retrieve. If not set, rows will be retrieved
     * beginnning from row <tt>0</tt>.
     */
    void setFirstResult(int firstResult);

    /**
     * Set the maximum number of rows to retrieve.
     */
    void setMaxResult(int maxResult);

}
