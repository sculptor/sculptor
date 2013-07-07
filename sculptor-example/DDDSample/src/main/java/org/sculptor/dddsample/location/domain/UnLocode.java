package org.sculptor.dddsample.location.domain;

import java.util.regex.Pattern;

import javax.persistence.Embeddable;

import org.apache.commons.lang.Validate;


/**
 * United nations location code.
 */
@Embeddable
public class UnLocode extends UnLocodeBase {
    private static final long serialVersionUID = 2570930174447147245L;
    // Country code is exactly two letters.
    // Location code is usually three letters, but may contain the numbers 2-9 as well
    private static final Pattern VALID_PATTERN = Pattern.compile("[a-zA-Z]{2}[a-zA-Z2-9]{3}");

    protected UnLocode() {
    }

    public UnLocode(String countryAndLocation) {
        super(validateCountryAndLocation(countryAndLocation).toUpperCase());
    }

    private static String validateCountryAndLocation(String countryAndLocation) {
        Validate.notNull(countryAndLocation, "Country and location may not be null");
        Validate.isTrue(VALID_PATTERN.matcher(countryAndLocation).matches(),
                countryAndLocation + " is not a valid UN/LOCODE (does not match pattern)");
        return countryAndLocation;
    }
}
