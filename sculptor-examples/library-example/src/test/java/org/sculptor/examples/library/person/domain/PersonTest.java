package org.sculptor.examples.library.person.domain;

import org.junit.jupiter.api.Test;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;

import static org.junit.jupiter.api.Assertions.assertEquals;

public class PersonTest {

    @Test
    public void testGetAge() {
        Person p = new Person(Gender.FEMALE, new Ssn("12345", Country.SWEDEN));
        LocalDate bd = LocalDate.now();
        bd = bd.minus(17, ChronoUnit.YEARS);
        bd = bd.plus(1, ChronoUnit.MONTHS);
        p.setBirthDate(bd);
        assertEquals(16, p.getAge().intValue());
    }

}
