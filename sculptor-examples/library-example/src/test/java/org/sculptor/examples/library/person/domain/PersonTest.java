package org.sculptor.examples.library.person.domain;

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
        Calendar cal = Calendar.getInstance();
        cal.add(Calendar.YEAR, -17);
        cal.add(Calendar.MONTH, 1);
        p.setBirthDate(cal.getTime());
        assertEquals(new Integer(16), p.getAge());
    }

}
