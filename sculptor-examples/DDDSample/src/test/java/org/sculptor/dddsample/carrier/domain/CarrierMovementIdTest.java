package org.sculptor.dddsample.carrier.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.fail;

public class CarrierMovementIdTest {

    @Test
    public void testConstructor() throws Exception {
        try {
            new CarrierMovementId(null);
            fail("Should not accept null constructor argument");
        } catch (IllegalArgumentException expected) {
        }
    }

}
