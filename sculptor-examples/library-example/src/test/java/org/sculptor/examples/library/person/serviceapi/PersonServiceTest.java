/*
 * Copyright 2013 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package org.sculptor.examples.library.person.serviceapi;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;
import java.time.temporal.TemporalUnit;
import java.util.Calendar;
import java.util.List;

import org.junit.jupiter.api.Assumptions;
import org.junit.jupiter.api.Test;
import org.sculptor.examples.library.person.domain.Country;
import org.sculptor.examples.library.person.domain.Gender;
import org.sculptor.examples.library.person.domain.Person;
import org.sculptor.examples.library.person.domain.PersonName;
import org.sculptor.examples.library.person.domain.PersonProperties;
import org.sculptor.examples.library.person.domain.Ssn;
import org.sculptor.examples.library.person.exception.PersonNotFoundException;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
import org.sculptor.framework.accessimpl.jpa.JpaHelper;
import org.sculptor.framework.domain.PagedResult;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.framework.errorhandling.ValidationException;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import static org.junit.jupiter.api.Assertions.*;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PersonServiceTest extends AbstractDbUnitJpaTests implements PersonServiceTestBase {
	private PersonService personService;

	@Autowired
	public void setPersonService(PersonService personService) {
		this.personService = personService;
	}

	@Override
	@Test
	public void testFindById() throws Exception {
		Person person = personService.findById(getServiceContext(), 1L);
		assertNotNull(person);
	}

	@Test
	public void testFindByIdWithNotFoundException() throws Exception {
		assertThrows(PersonNotFoundException.class, () -> {
			personService.findById(getServiceContext(), -1L);
		});
	}

	@Test
	public void testCreate() throws Exception {
		int before = countRowsInTable(Person.class);
		Person person = new Person(Gender.FEMALE, new Ssn("12345", Country.DENMARK));
		PersonName name = new PersonName("New", "Person");
		person.setName(name);

		LocalDate now = LocalDate.now();
		LocalDate bd = now.minusYears(1);
		person.setBirthDate(bd);
		personService.save(getServiceContext(), person);
		assertEquals(before + 1, countRowsInTable(Person.class));
	}

	@Test
	public void testCreateThrowingValidationExceptionForBirthDate() throws Exception {
		assertThrows(ValidationException.class, () -> {
			Person person = new Person(Gender.FEMALE, new Ssn("12345", Country.DENMARK));
			PersonName name = new PersonName("New", "Person");
			person.setName(name);

			LocalDate now = LocalDate.now();
			LocalDate bd = now.plusYears(1);
			person.setBirthDate(bd);
			personService.save(getServiceContext(), person);
		});
	}

	@Test
	public void testCreateThrowingValidationExceptionForMissinBirthDate() throws Exception {
		assertThrows(ValidationException.class, () -> {
			Person person = new Person(Gender.FEMALE, new Ssn("0815", Country.DENMARK));
			PersonName name = new PersonName("New", "Person");
			person.setName(name);
			person.setBirthDate(null);
			personService.save(getServiceContext(), person);
		});
	}

	@Override
	@Test
	public void testSave() throws Exception {
		Person person = personService.findById(getServiceContext(), 1L);
		assertNotNull(person);
		PersonName name = new PersonName("First", "Last");
		person.setName(name);
		personService.save(getServiceContext(), person);
		Person person2 = personService.findById(getServiceContext(), 1L);
		assertEquals("First", person2.getName().getFirst());
	}

	@Override
	@Test
	public void testDelete() throws Exception {
		int before = countRowsInTable(Person.class);
		Person person = personService.findById(getServiceContext(), 1L);
		assertNotNull(person);
		personService.delete(getServiceContext(), person);
		assertEquals(before - 1, countRowsInTable(Person.class));
	}

	@Override
	@Test
	public void testFindPersonByName() throws Exception {
		// NamedQuery needs '()', see comments in Person class
		Assumptions.assumeTrue(!JpaHelper.isJpaProviderDataNucleus(getEntityManager()));
		List<Person> persons = personService.findPersonByName(getServiceContext(), "Skarsgård");
		assertEquals(2, persons.size());
	}

	@Override
	@Test
	public void testFindAll() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(PagingParameter.DEFAULT_PAGE_SIZE);
		PagedResult<Person> pagedResult = personService.findAll(getServiceContext(), pagingParameter);

		// Due to missing DbUnit tear-down database operation (locking issues) we are left with
		// data from other tests like PersonRepositoryTest
		assertTrue(pagedResult.getValues().size() >= 3);
	}

	@Override
	@Test
	public void testFindByCondition() throws Exception {
		List<ConditionalCriteria> criteria = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(PersonProperties.ssn().country()).eq(Country.SWEDEN)
				.orderBy(PersonProperties.contact().personName().first()).build();
		List<Person> personHaber = personService.findByCondition(getServiceContext(), criteria);
		assertEquals(3, personHaber.size());
		assertEquals(2, personHaber.get(0).getId().longValue());
		assertEquals(3, personHaber.get(1).getId().longValue());
		assertEquals(1, personHaber.get(2).getId().longValue());

		// Values in DB for addresses are [{adress="Makova" city="London"}, {adress="Crievkova" city="Paris"}]
		// Simulate bug #174
		
		// Combined OR query
		criteria = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(PersonProperties.contact().addresses().city()).eq("London")
				.or()
				.withProperty(PersonProperties.contact().addresses().adress()).eq("Crievkova")
				.or()
				.withProperty(PersonProperties.contact().addresses().city()).eq("Berlin")
				.build();
		personHaber = personService.findByCondition(getServiceContext(), criteria);
		assertEquals(2, personHaber.size());
		assertEquals(3, personHaber.get(0).getId().longValue());
		assertEquals(3, personHaber.get(1).getId().longValue());

		// Combined OR query with distinctRoot()
		criteria = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(PersonProperties.contact().addresses().city()).eq("London")
				.or()
				.withProperty(PersonProperties.contact().addresses().adress()).eq("Crievkova")
				.or()
				.withProperty(PersonProperties.contact().addresses().city()).eq("Berlin")
				.distinctRoot()
				.build();
		personHaber = personService.findByCondition(getServiceContext(), criteria);
		assertEquals(1, personHaber.size());
		assertEquals(3, personHaber.get(0).getId().longValue());

		// Combined AND query
		criteria = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(PersonProperties.contact().addresses().city()).in("London", "Berlin")
				.withProperty(PersonProperties.contact().addresses().adress()).eq("Makova")
				.build();
		personHaber = personService.findByCondition(getServiceContext(), criteria);
		assertEquals(1, personHaber.size());
		assertEquals(3, personHaber.get(0).getId().longValue());
	}
}
