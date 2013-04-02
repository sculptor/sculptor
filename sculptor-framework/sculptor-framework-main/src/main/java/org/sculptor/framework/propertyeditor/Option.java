package org.sculptor.framework.propertyeditor;

import java.io.Serializable;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

import org.apache.commons.beanutils.PropertyUtils;


/**
 * Options are used in select lists.
 * It is a simple holder for a DomainObject
 * and its id. It is used together with a
 * {@link org.sculptor.framework.propertyeditor.OptionEditor}.
 */
public class Option<T> implements java.io.Serializable {
    private static final long serialVersionUID = -6569913608783178399L;
    
    private String id;
    private T value;
    
    /**
     * Factory method to create a list of Options from a list of
     * DomainObjects. It is expected that the DomainObjects has 
     */
    public static <T> List<Option<T>> createOptions(Collection<T> domainObjects) { 
        List<Option<T>> options = new ArrayList<Option<T>>();
    
        for (T value : domainObjects) {
            String id = String.valueOf(getId(value));
            options.add(new Option<T>(id, value));
        }
    
        return options;
    }
    
    private static Serializable getId(Object domainObject) {
        if (PropertyUtils.isReadable(domainObject, "id")) {
            try {
                return (Serializable) PropertyUtils.getProperty(domainObject, "id");
            } catch (Exception e) {
                throw new IllegalArgumentException("Can't get id property of domainObject: " + domainObject);
            } 
        } else {
            // no id property, don't know if it is new
            throw new IllegalArgumentException("No id property in domainObject: " + domainObject);
        }
    }

    public Option(String id, T value) {
        this.id = id;
        this.value = value;
    }

    public String getId() {
        return id;
    }

    public T getValue() {
        return value;
    }
    
    
}
