package org.sculptor.examples.library.person.domain;

import java.util.Calendar;

/**
 * Entity representing Person. This class is responsible for the domain object
 * related business logic for Person. Properties and associations are
 * implemented in the generated base class {@link PersonBase}.
 */
public class Person extends PersonBase {
	private static final long serialVersionUID = 1L;

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
