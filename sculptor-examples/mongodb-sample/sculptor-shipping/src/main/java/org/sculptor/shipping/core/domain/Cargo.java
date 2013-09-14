package org.sculptor.shipping.core.domain;

/**
 * 
 * Entity representing Cargo. This class is responsible for the domain object
 * related business logic for Cargo. Properties and associations are implemented
 * in the generated base class
 * {@link org.sculptor.shipping.core.domain.CargoBase}.
 */
public class Cargo extends CargoBase {
    private static final long serialVersionUID = 1L;

    protected Cargo() {
    }

    public Cargo(String cargoId) {
        super(cargoId);
    }

}
