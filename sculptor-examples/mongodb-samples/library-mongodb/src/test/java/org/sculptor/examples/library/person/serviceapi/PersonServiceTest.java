package org.sculptor.examples.library.person.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.sculptor.examples.library.person.domain.PersonName.personName;
import static org.sculptor.examples.library.person.domain.Ssn.ssn;
import static org.sculptor.framework.context.SimpleJUnitServiceContextFactory.getServiceContext;

import java.util.Calendar;
import java.util.List;
import java.util.Set;

import org.apache.commons.lang.time.DateUtils;
import org.junit.After;
import org.junit.Before;
import org.junit.Ignore;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.sculptor.examples.library.person.domain.Country;
import org.sculptor.examples.library.person.domain.Gender;
import org.sculptor.examples.library.person.domain.Person;
import org.sculptor.examples.library.person.domain.PersonName;
import org.sculptor.examples.library.person.domain.Ssn;
import org.sculptor.examples.library.person.exception.PersonNotFoundException;
import org.sculptor.examples.library.person.mapper.PersonMapper;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.framework.domain.PagedResult;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.framework.errorhandling.ValidationException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.AbstractJUnit4SpringContextTests;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;

@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class PersonServiceTest extends AbstractJUnit4SpringContextTests implements PersonServiceTestBase {

	private static final String[] DATE_PATTERNS = { "yyyy-MM-dd" };

	@Autowired
	private PersonService personService;
	private String id1;
	@Autowired
	private DbManager dbManager;

	@Before
	public void initialData() throws Exception {
		Person p1 = new Person(Gender.MALE, ssn("123456", Country.SWEDEN));
		p1.setBirthDate(DateUtils.parseDate("1951-06-13", DATE_PATTERNS));
		p1.setName(personName("Stellan", "Skarsgård"));
		p1 = personService.save(getServiceContext(), p1);
		id1 = p1.getId();

		Person p2 = new Person(Gender.MALE, ssn("123457", Country.SWEDEN));
		p2.setBirthDate(DateUtils.parseDate("1976-08-25", DATE_PATTERNS));
		p2.setName(personName("Alexander", "Skarsgård"));
		p2 = personService.save(getServiceContext(), p2);

		Person p3 = new Person(Gender.MALE, ssn("123458", Country.SWEDEN));
		p3.setBirthDate(DateUtils.parseDate("1952-12-12", DATE_PATTERNS));
		p3.setName(personName("Peter", "Haber"));
		p3 = personService.save(getServiceContext(), p3);
	}

	@After
	public void dropDatabase() {
		Set<String> names = dbManager.getDB().getCollectionNames();
		for (String each : names) {
			if (!each.startsWith("system")) {
				dbManager.getDB().getCollection(each).drop();
			}
		}
		// dbManager.getDB().dropDatabase();
	}

	private int countRowsInDBCollection(String name) {
		return (int) dbManager.getDBCollection(name).getCount();
	}

	private int countRowsInPersonCollection() {
		return countRowsInDBCollection(PersonMapper.getInstance().getDBCollectionName());
	}

	@Override
	@Test
	public void testFindById() throws Exception {
		Person person = personService.findById(getServiceContext(), id1);
		assertNotNull(person);
	}

	@Test(expected=PersonNotFoundException.class)
	public void testFindByIdWithNotFoundException() throws Exception {
		personService.findById(getServiceContext(), "zzz");
	}

	@Test
	public void testCreate() throws Exception {
		int before = countRowsInPersonCollection();
		Person person = new Person(Gender.FEMALE, new Ssn("12345", Country.DENMARK));
		PersonName name = new PersonName("New", "Person");
		person.setName(name);

		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.YEAR, -1);
		person.setBirthDate(cal.getTime());
		personService.save(getServiceContext(), person);
		assertEquals(before + 1, countRowsInPersonCollection());
	}

	@Test(expected=ValidationException.class)
	@Ignore
	// validation not supported yet, need JSR-303 first
	public void testCreateThrowingValidationExceptionForBirthDate() throws Exception {
		Person person = new Person(Gender.FEMALE, new Ssn("12345", Country.DENMARK));
		PersonName name = new PersonName("New", "Person");
		person.setName(name);

		Calendar cal = Calendar.getInstance();
		cal.add(Calendar.YEAR, 1);
		person.setBirthDate(cal.getTime());
		personService.save(getServiceContext(), person);
	}

	@Test(expected=ValidationException.class)
	@Ignore
	// validation not supported yet, need JSR-303 first
	public void testCreateThrowingValidationException() throws Exception {
		Person person = new Person(Gender.FEMALE, new Ssn("0815", Country.DENMARK));
		PersonName name = new PersonName("New", "Person");
		person.setName(name);
		person.setBirthDate(null);
		personService.save(getServiceContext(), person);
	}

	@Override
	@Test
	public void testSave() throws Exception {
		Person person = personService.findById(getServiceContext(), id1);
		assertNotNull(person);
		PersonName name = new PersonName("First", "Last");
		person.setName(name);
		personService.save(getServiceContext(), person);
		Person person2 = personService.findById(getServiceContext(), id1);
		assertEquals("First", person2.getName().getFirst());
	}

	@Test
	public void testIncreaseVersion() throws Exception {
		Person p0 = new Person(Gender.MALE, ssn("780101", Country.SWEDEN));
		p0.setName(personName("P0", "P"));
		Person p1 = personService.save(getServiceContext(), p0);
		assertEquals(new Long(1), p1.getVersion());

		p1.setName(personName("P1", "P"));
		Person p2 = personService.save(getServiceContext(), p1);
		assertEquals(new Long(2), p2.getVersion());

		p2.setName(personName("P3", "P"));
		Person p3 = personService.save(getServiceContext(), p2);
		assertEquals(new Long(3), p3.getVersion());
	}

	@Override
	@Test
	public void testDelete() throws Exception {
		int before = countRowsInPersonCollection();
		Person person = personService.findById(getServiceContext(), id1);
		assertNotNull(person);
		personService.delete(getServiceContext(), person);
		assertEquals(before - 1, countRowsInPersonCollection());
	}

	@Override
	@Test
	public void testFindPersonByName() throws Exception {
		List<Person> persons = personService.findPersonByName(getServiceContext(), "Skarsgård");
		assertEquals(2, persons.size());
	}

	@Override
	@Test
	public void testFindAll() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(PagingParameter.DEFAULT_PAGE_SIZE);
		PagedResult<Person> pagedResult = personService.findAll(getServiceContext(), pagingParameter);
		assertEquals(3, pagedResult.getValues().size());
	}
}
