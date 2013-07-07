package org.sculptor.dddsample.common;

public interface Specification<T> {

  boolean isSatisfiedBy(T t);
    
}
