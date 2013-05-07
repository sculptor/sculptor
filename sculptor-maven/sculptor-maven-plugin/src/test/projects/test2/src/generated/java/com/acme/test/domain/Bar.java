package com.acme.test.domain;

import java.io.Serializable;

/**
 * Enum for Bar
 */
public enum Bar implements Serializable {
    ONE,
    TWO,
    THREE;

    /**
     */
    private Bar() {
    }

    public String getName() {
        return name();
    }
}
