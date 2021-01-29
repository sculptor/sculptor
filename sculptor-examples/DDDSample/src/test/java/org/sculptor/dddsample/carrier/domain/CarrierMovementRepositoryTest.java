package org.sculptor.dddsample.carrier.domain;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;
import static org.sculptor.dddsample.location.domain.SampleLocations.HELSINKI;
import static org.sculptor.dddsample.location.domain.SampleLocations.STOCKHOLM;

import org.junit.jupiter.api.Test;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

public class CarrierMovementRepositoryTest extends AbstractDbUnitJpaTests {

    private CarrierMovementRepository carrierMovementRepository;

    @Autowired
    public void setCarrierMovementRepository(CarrierMovementRepository carrierMovementRepository) {
        this.carrierMovementRepository = carrierMovementRepository;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testFind() throws Exception {
        CarrierMovement carrierMovement = carrierMovementRepository.find(new CarrierMovementId("CAR_001"));
        assertNotNull(carrierMovement);
        assertEquals("CAR_001", carrierMovement.getCarrierMovementId().getIdentifier());
        assertEquals(STOCKHOLM, carrierMovement.getFrom());
        assertEquals(HELSINKI, carrierMovement.getTo());
    }

}
