package com.acme.test.domain;

import java.util.Date;

import javax.persistence.Embeddable;

/**
 * BasicType representing Foo.
 * <p>
 * This class is responsible for the domain object related
 * business logic for Foo. Properties and associations are
 * implemented in the generated base class {@link com.acme.test.domain.FooBase}.
 */
@Embeddable
public class Foo extends FooBase {
    private static final long serialVersionUID = 1L;

    protected Foo() {
    }

    public Foo(String name, Date timestamp) {
        super(name, timestamp);
    }
}
