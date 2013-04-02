package org.sculptor.framework.errorhandling;

import java.io.Serializable;
import java.sql.SQLException;

public class ExceptionHelper {

    private ExceptionHelper() {
    }

    /**
     * Looks for SQLException in the cause chain.
     * 
     * @return Found SQLException in the cause chain, or null if none found
     */
    public static SQLException unwrapSQLException(Throwable throwable) {
        if (throwable == null) {
            return null;
        } else if (throwable instanceof SQLException) {
            return (SQLException) throwable;
        } else if (throwable.getCause() != null) {
            // recursive call to unwrap the cause
            return unwrapSQLException(throwable.getCause());
        } else {
            // didn't find any SQLException in the cause stack
            return null;
        }
    }

    public static String excMessage(Throwable e) {
        // null message is useless, e.g. NullPointerException
        return e.getMessage() == null ? e.toString() : e.getMessage();
    }

    public static boolean isJmsRedelivered() {
        ServiceContext serviceContext = ServiceContextStore.get();
        if (serviceContext == null) {
            return true;
        }
        Serializable jmsRedelivered = serviceContext.getProperty("jmsRedelivered");
        if (jmsRedelivered == null) {
            return true;
        }
        return Boolean.TRUE.equals(jmsRedelivered);
    }

    public static boolean isJmsContext() {
        ServiceContext serviceContext = ServiceContextStore.get();
        if (serviceContext == null) {
            return false;
        }
        return Boolean.TRUE.equals(serviceContext.getProperty("jms"));
    }

}
