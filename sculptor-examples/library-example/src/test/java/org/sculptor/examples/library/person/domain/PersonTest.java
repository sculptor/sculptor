package org.sculptor.examples.library.person.domain;

import java.time.LocalDate;
import java.time.temporal.ChronoUnit;
import java.util.Calendar;

import junit.framework.TestCase;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.BlockJUnit4ClassRunner;

@RunWith(BlockJUnit4ClassRunner.class)
public class PersonTest extends TestCase {

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
