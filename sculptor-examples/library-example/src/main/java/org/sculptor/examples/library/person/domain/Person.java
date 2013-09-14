package org.sculptor.examples.library.person.domain;

import java.util.Calendar;

import javax.persistence.Entity;
import javax.persistence.NamedQueries;
import javax.persistence.NamedQuery;
import javax.persistence.QueryHint;
import javax.persistence.Table;
import javax.persistence.UniqueConstraint;

import org.sculptor.examples.library.person.domain.Gender;
import org.sculptor.examples.library.person.domain.PersonBase;
import org.sculptor.examples.library.person.domain.Ssn;

/**
 *
 * Entity representing Person. This class is responsible for the domain object
 * related business logic for Person. Properties and associations are
 * implemented in the generated base class
 * {@link org.sculptor.examples.library.person.domain.PersonBase}
 * .
 */
@Entity(name = "Person")
@Table(name = "PERSON", uniqueConstraints = @UniqueConstraint(columnNames = { "SSN_NUMBER", "SSN_COUNTRY" }))
@NamedQueries( {
        @NamedQuery(name = "Person.findByCountry", query = "select person from Person person where person.ssn.country = :country", hints = {
                @QueryHint(name = "org.hibernate.cacheable", value = "true"),
                @QueryHint(name = "org.hibernate.cacheRegion", value = "query.Person") }),
        @NamedQuery(name = "Person.countByCountry", query = "select count(person) from Person person where person.ssn.country = :country", hints = {
                @QueryHint(name = "org.hibernate.cacheable", value = "true"),
                @QueryHint(name = "org.hibernate.cacheRegion", value = "query.Person") }),
        @NamedQuery(name = "Person.findPersonByName", query = "select person from Person person where person.name.first in :names or person.name.last in :names") })

// datanucleus needs '(:names)' in where clause
// @NamedQuery(name = "Person.findPersonByName", query = "select person from Person person where person.name.first in (:names) or person.name.last in (:names)")

public class Person extends PersonBase {
    private static final long serialVersionUID = -3936470509835260676L;

    protected Person() {
	}

	public Person(Gender sex, Ssn ssn) {
		super(sex, ssn);
	}

	public Integer getAge() {
	    if (getBirthDate() == null) {
            return null;
        }
	    Calendar birth = Calendar.getInstance();
        birth.setTime(getBirthDate());

		Calendar today = Calendar.getInstance();
		// I wish we could use joda instead of this ugly
        int age = today.get(Calendar.YEAR) - birth.get(Calendar.YEAR);

        Calendar birthDay = Calendar.getInstance();
        birthDay.set(Calendar.YEAR, today.get(Calendar.YEAR));
        birthDay.set(Calendar.MONTH, birth.get(Calendar.MONTH));
        birthDay.set(Calendar.DAY_OF_MONTH, birth.get(Calendar.DAY_OF_MONTH));
        birthDay.set(Calendar.HOUR_OF_DAY, 0);
        birthDay.set(Calendar.MINUTE, 0);
        birthDay.set(Calendar.SECOND, 0);
        birthDay.set(Calendar.MILLISECOND, 0);
        boolean birthDayIsAfter = birthDay.compareTo(today) > 0;
        if (birthDayIsAfter) {
            age -= 1;
        }

        return age;
	}
}
