package org.sculptor.framework.accessimpl.jpahibernate;

import javax.persistence.EntityManager;

import org.hibernate.Session;

public class HibernateSessionHelper {
	private HibernateSessionHelper() {
	}
	
    /**
     * Hibernate Session to be used in AccessObject for convenience
     *
     * @return the Hibernate Session object
     */
    public static Session getHibernateSession(EntityManager entityManager) {
    	Object delegate = entityManager.getDelegate();
    	
    	if (delegate instanceof EntityManager) {
    		delegate = ((EntityManager) delegate).getDelegate();
    	}
    	if (delegate instanceof Session) {
    		return (Session) delegate;
    	} else {
    		throw new IllegalStateException("Couldn't cast the EntityManager " +
    				"delegate to Hibernate Session. Delegate is: " + 
    				(delegate == null ? "null" : delegate.getClass().getName()));
    	}
	}
}
