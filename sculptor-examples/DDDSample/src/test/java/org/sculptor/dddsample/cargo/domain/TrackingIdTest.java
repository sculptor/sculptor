package org.sculptor.dddsample.cargo.domain;

import static junit.framework.Assert.fail;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;

import org.junit.Test;

public class TrackingIdTest {

    @Test(expected = IllegalArgumentException.class)
    public void constructorShouldRejectNullIdentifier() throws Exception {
        new TrackingId(null);
        fail("Should not accept null constructor arguments");
    }

    @Test(expected = IllegalArgumentException.class)
    public void factoryMethodShouldRejectNullIdentifier() throws Exception {
        trackingId(null);
        fail("Should not accept null constructor arguments");
    }

}
