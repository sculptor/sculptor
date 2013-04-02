package org.sculptor.framework.domain;

import org.junit.Assert;
import org.junit.Test;
import org.sculptor.framework.domain.LeafProperty;
import org.sculptor.framework.domain.Property;


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
		Assert.assertEquals(firstNameProp.hashCode(), firstNameProp.hashCode());
		Assert.assertEquals(secondNameProp.hashCode(), secondNameProp.hashCode());

		// Return for equals objects
		Assert.assertEquals(myFirstNameProp.hashCode(), firstNameProp.hashCode());
		Assert.assertEquals(mySecondNameProp.hashCode(), secondNameProp.hashCode());

		// Inheritance test
		Assert.assertFalse(myFirstName1.hashCode() == firstNameProp.hashCode());
		Assert.assertFalse(myFirstName2.hashCode() == firstNameProp.hashCode());
		Assert.assertFalse(myFirstName3.hashCode() == firstNameProp.hashCode());
	}

	@Test
	public void testEquals() {
		// Equals
		Assert.assertFalse(firstNameProp.equals(null));
		Assert.assertFalse(firstNameProp.equals("asdf"));
		Assert.assertFalse(firstNameProp.equals(secondNameProp));
		Assert.assertTrue(firstNameProp.equals(firstNameProp));
		Assert.assertTrue(firstNameProp.equals(myFirstNameProp));

		Assert.assertFalse(firstNameProp.equals(myFirstName1));
		Assert.assertFalse(firstNameProp.equals(myFirstName2));
		Assert.assertFalse(firstNameProp.equals(myFirstName3));
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