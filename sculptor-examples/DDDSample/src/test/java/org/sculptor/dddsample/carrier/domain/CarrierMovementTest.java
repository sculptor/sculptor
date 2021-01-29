package org.sculptor.dddsample.carrier.domain;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertFalse;
import static org.junit.jupiter.api.Assertions.assertTrue;
import static org.sculptor.dddsample.location.domain.SampleLocations.HAMBURG;
import static org.sculptor.dddsample.location.domain.SampleLocations.STOCKHOLM;

public class CarrierMovementTest {

    @Test
    public void testSameValueAsEqualsHashCode() throws Exception {
        CarrierMovementId id1 = new CarrierMovementId("CAR1");
        CarrierMovementId id2a = new CarrierMovementId("CAR2");
        CarrierMovementId id2b = new CarrierMovementId("CAR2");

        CarrierMovement cm1 = new CarrierMovement(id1, STOCKHOLM, HAMBURG);
        CarrierMovement cm2 = new CarrierMovement(id1, STOCKHOLM, HAMBURG);
        CarrierMovement cm3 = new CarrierMovement(id2a, HAMBURG, STOCKHOLM);
        CarrierMovement cm4 = new CarrierMovement(id2b, HAMBURG, STOCKHOLM);

        assertTrue(cm1.equals(cm2));
        assertFalse(cm2.equals(cm3));
        assertTrue(cm3.equals(cm4));

        assertTrue(cm1.hashCode() == cm2.hashCode());
        assertFalse(cm2.hashCode() == cm3.hashCode());
        assertTrue(cm3.hashCode() == cm4.hashCode());
    }

}
