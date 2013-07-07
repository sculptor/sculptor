package org.sculptor.dddsample.location.exception;

import org.sculptor.framework.errorhandling.ApplicationException;

import java.io.Serializable;

public class LocationNotFoundException extends ApplicationException {
    private static final long serialVersionUID = 1L;
    private static final String ERROR_CODE =
        LocationNotFoundException.class.getName();

    public LocationNotFoundException(String m) {
        super(ERROR_CODE, m);
    }

    public LocationNotFoundException(String m, Serializable messageParameter) {
        super(ERROR_CODE, m);
        setMessageParameters(new Serializable[] { messageParameter });
    }

    public LocationNotFoundException(String m, Serializable[] messageParameters) {
        super(ERROR_CODE, m);
        setMessageParameters(messageParameters);
    }
}
