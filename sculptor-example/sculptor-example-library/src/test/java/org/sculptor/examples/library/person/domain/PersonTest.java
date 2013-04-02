package org.sculptor.examples.library.person.domain;

import java.util.Calendar;
import java.util.Map;

import javax.validation.ConstraintViolation;

import junit.framework.TestCase;

import org.sculptor.examples.library.person.domain.Country;
import org.sculptor.examples.library.person.domain.Gender;
import org.sculptor.examples.library.person.domain.Ssn;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.junit.runners.BlockJUnit4ClassRunner;
import org.sculptor.examples.library.person.domain.Person;
import org.sculptor.framework.errorhandling.ValidationException;
import org.sculptor.framework.validation.validator.DomainObjectValidator;

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

    @Test(expected = ValidationException.class)
    public void testValidationThrowingValidationException() {
        DomainObjectValidator<Person> validator = new DomainObjectValidator<Person>();
        Person person = new Person(Gender.FEMALE, new Ssn("0815", Country.DENMARK));
        validator.validate(person);
    }
  
    @Test
    public void testValidation() {
        DomainObjectValidator<Person> validator = new DomainObjectValidator<Person>();
        Person person = new Person(Gender.FEMALE, new Ssn("0815", Country.DENMARK));
        Map<String, ConstraintViolation<Person>> violations = validator.getConstraintViolationsAsMap(person);
        assertEquals(2, violations.size());
        assertEquals(true, violations.containsKey("birthDate"));
        assertEquals(true, violations.containsKey("name"));
    }
}
