package org.sculptor.framework.util;

import java.lang.reflect.Constructor;
import java.lang.reflect.InvocationTargetException;

/**
 * Factory to create "empty" instances with the 
 * default constructor. The constructor doesn't
 * have to be public.
 * 
 * @param <T> the type of the object to create
 */
public class FakeObjectInstantiator<T> {
    private Constructor<T> defaultConstructor;
    
    /**
     * 
     * @param clazz the class of the object to create
     */
    public FakeObjectInstantiator(Class<T> clazz) {
        try {
            defaultConstructor = clazz.getDeclaredConstructor();
            defaultConstructor.setAccessible(true);
        } catch (Exception e) {
           throw new RuntimeException(clazz.getName() + " has no default constructor");
        }
    }
    
    /**
     * Create the fake object.
     */
    public T createFakeObject() {
        try {
            return defaultConstructor.newInstance(new Object[0]);
        } catch (InstantiationException e) {
            throw new RuntimeException(e.getMessage(), e);
        } catch (IllegalAccessException e) {
            throw new RuntimeException(e.getMessage(), e);
        } catch (InvocationTargetException e) {
            throw new RuntimeException(e.getMessage(), e);
        }
    }

}
