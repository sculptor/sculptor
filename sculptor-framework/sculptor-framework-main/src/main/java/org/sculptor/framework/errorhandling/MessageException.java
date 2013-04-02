package org.sculptor.framework.errorhandling;

/**
 * JMS messaging problems such {@link javax.jms.JMSException}
 * are caught and wrapped by this exception.
 *  
 */
public class MessageException extends SystemException {
    
    private static final long serialVersionUID = 3135547990705348919L;
    
    /**
     * The errorCode is the same as the fully qualified classname of this exception.
     */
    public static final String ERROR_CODE = MessageException.class.getName();
    

    public MessageException(Exception cause) {
        this(cause.getMessage(), cause);
    }
    
    /**
     * @param message Technical message. Used for debugging purpose, not intended for
     *   end users.
     */
    public MessageException(String message) {
        this(message, null);
    }
    
    /**
     * @param message Technical message. Used for debugging purpose, not intended for
     *   end users.
     * @param cause Original cause of the exception, use with caution since clients
     *   must include the class of the cause also (e.g. a vendor specific database 
     *   exception should not be exposed to clients).  
     */
    public MessageException(String message, Throwable cause) {
        super(ERROR_CODE, message, cause);
    }
    
}
