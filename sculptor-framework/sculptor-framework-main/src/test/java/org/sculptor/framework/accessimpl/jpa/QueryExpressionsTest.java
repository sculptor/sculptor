package org.sculptor.framework.accessimpl.jpa;

import static org.junit.Assert.assertEquals;

import org.junit.Test;
import org.sculptor.framework.accessimpl.jpa.QueryExpressions;

/**
 * Holds the expressions of the query
 * 
 * @author Oliver Ringel
 * 
 */
public class QueryExpressionsTest {

	@Test
	public void testAddSelections() {
		QueryExpressions<Person> qe = new QueryExpressions<Person>(Person.class);
		qe.addSelections(PersonDto.class);
		assertEquals(2, qe.getSelections().size());
		assertEquals("name", qe.getSelections().get(0));
		assertEquals("counter", qe.getSelections().get(1));
	}

	public static class Person {
		@SuppressWarnings("unused")
		private String name;

		@SuppressWarnings("unused")
		private Long sal;

		@SuppressWarnings("unused")
		private int counter;
	}

	public static class PersonDto {
		@SuppressWarnings("unused")
		private String name;

		@SuppressWarnings("unused")
		private Long salary;

		@SuppressWarnings("unused")
		private int counter;
	}
}