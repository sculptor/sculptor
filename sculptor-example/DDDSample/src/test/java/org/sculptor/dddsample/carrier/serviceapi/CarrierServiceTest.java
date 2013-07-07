package org.sculptor.dddsample.carrier.serviceapi;

import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.sculptor.dddsample.carrier.domain.CarrierMovement;
import org.sculptor.dddsample.carrier.domain.CarrierMovementId;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class CarrierServiceTest extends AbstractDbUnitJpaTests implements CarrierServiceTestBase {
    private CarrierService carrierService;

    @Autowired
    public void setCarrierService(CarrierService carrierService) {
        this.carrierService = carrierService;
    }

    @Override
    protected String getDataSetFile() {
        return "dbunit/TestData.xml";
    }

    @Test
    public void testFind() throws Exception {
        CarrierMovement found = carrierService.find(getServiceContext(), new CarrierMovementId("CAR_001"));
        assertNotNull(found);
    }

    public void testSave() throws Exception {
    }
}
