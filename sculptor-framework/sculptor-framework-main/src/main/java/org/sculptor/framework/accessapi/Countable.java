package org.sculptor.framework.accessapi;

/**
 * Access Objects with result that can be counted may implement this interface.
 *
 *
 */
public interface Countable {

    /**
     * Count of rows
     */
    void executeResultCount();

    Long getResultCount();
}
