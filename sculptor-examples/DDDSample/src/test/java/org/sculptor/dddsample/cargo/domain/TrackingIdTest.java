package org.sculptor.dddsample.cargo.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.fail;
import static org.sculptor.dddsample.cargo.domain.TrackingId.trackingId;

public class TrackingIdTest {

    @Test
    public void constructorShouldRejectNullIdentifier() throws Exception {
        assertThrows(IllegalArgumentException.class, () -> {
            new TrackingId(null);
            fail("Should not accept null constructor arguments");
        });
    }

    @Test
    public void factoryMethodShouldRejectNullIdentifier() throws Exception {
        assertThrows(IllegalArgumentException.class, () -> {
            trackingId(null);
            fail("Should not accept null constructor arguments");
        });
    }

}
