package org.sculptor.framework.accessapi;

/**
 * Access Objects that support query caching may implement
 * this interface. 
 */
public interface Cacheable {
    
    /**
     * When true query cache will be used, with the default 
     * cache region. The default cache region is "query." + 
     * class name of &lt;T&gt;
     * @see #setCacheRegion
     */
    void setCache(boolean cache);
    
    /**
     * Specify that query cache is used with this query 
     * cache region. 
     * @see #setCache
     */
    void setCacheRegion(String cacheRegion);

}
