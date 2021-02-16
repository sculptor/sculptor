package org.sculptor.dddsample.carrier.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertThrows;
import static org.junit.jupiter.api.Assertions.fail;

public class CarrierMovementIdTest {

    @Test
    public void testConstructor() throws Exception {
        assertThrows(NullPointerException.class, () -> {
            new CarrierMovementId(null);
            fail("Should not accept null constructor argument");
        });
    }

}
