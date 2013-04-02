package org.sculptor.framework.errorhandling;

import java.io.Serializable;

/**
 * Failed validation of JMS messages should be throw as this exception (or subclass).
 *
 */
public class InvalidMessageException extends ApplicationException {

    private static final long serialVersionUID = -5202730440147874036L;

    public static final String ERROR_CODE = InvalidMessageException.class.getName();
    
    public InvalidMessageException(String message) {
        super(ERROR_CODE, message);
    }
    
    public InvalidMessageException(String errorCode, String message, Throwable cause) {
        super(errorCode, message, cause);
    }

    public InvalidMessageException(String errorCode, String message) {
        super(errorCode, message);
    }
    
    public InvalidMessageException(String errorCode, String message, Serializable[] params) {
        super(errorCode, message);
        setMessageParameters(params);
    }
}