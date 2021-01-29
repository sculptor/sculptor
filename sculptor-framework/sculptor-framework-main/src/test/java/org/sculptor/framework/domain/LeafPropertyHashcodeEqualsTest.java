package org.sculptor.framework.domain;

import org.junit.jupiter.api.Test;
import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.Property;

import static org.junit.jupiter.api.Assertions.*;


public class LeafPropertyHashcodeEqualsTest {
	Property<Person> firstNameProp = PersonProperties.firstName();
	Property<Person> secondNameProp = PersonProperties.secondName();

	Property<Person> myFirstNameProp = new LeafProperty<Person>("firstName", Person.class);
	Property<Person> mySecondNameProp = new LeafProperty<Person>("secondName", Person.class);

	Property<Person1> myFirstName1 = new LeafProperty<Person1>("firstName", Person1.class);
	Property<Person2> myFirstName2 = new LeafProperty<Person2>("firstName", Person2.class);
	Property<Person3> myFirstName3 = new LeafProperty<Person3>("firstName", Person3.class);

	@Test
	public void testHashcode() {
		// Always return same value
		assertEquals(firstNameProp.hashCode(), firstNameProp.hashCode());
		assertEquals(secondNameProp.hashCode(), secondNameProp.hashCode());

		// Return for equals objects
		assertEquals(myFirstNameProp.hashCode(), firstNameProp.hashCode());
		assertEquals(mySecondNameProp.hashCode(), secondNameProp.hashCode());

		// Inheritance test
		assertFalse(myFirstName1.hashCode() == firstNameProp.hashCode());
		assertFalse(myFirstName2.hashCode() == firstNameProp.hashCode());
		assertFalse(myFirstName3.hashCode() == firstNameProp.hashCode());
	}

	@Test
	public void testEquals() {
		// Equals
		assertFalse(firstNameProp.equals(null));
		assertFalse(firstNameProp.equals("asdf"));
		assertFalse(firstNameProp.equals(secondNameProp));
		assertTrue(firstNameProp.equals(firstNameProp));
		assertTrue(firstNameProp.equals(myFirstNameProp));

		assertFalse(firstNameProp.equals(myFirstName1));
		assertFalse(firstNameProp.equals(myFirstName2));
		assertFalse(firstNameProp.equals(myFirstName3));
	}
}

class Person1 {
}

class Person extends Person1 {
	String firstName;
	String secondName;

	public String getFirstName() {
		return firstName;
	}
	public void setFirstName(String firstName) {
		this.firstName = firstName;
	}
	public String getSecondName() {
		return secondName;
	}
	public void setSecondName(String secondName) {
		this.secondName = secondName;
	}	
}

class PersonProperties {
	public static Property<Person> firstName() {
		return new LeafProperty<Person>("firstName", Person.class);
	}

	public static Property<Person> secondName() {
		return new LeafProperty<Person>("secondName", Person.class);
	}
}

class Person2 extends Person {
}

class Person3 extends Person1 {
}