package org.sculptor.examples.library.person.domain;

import static org.junit.jupiter.api.Assertions.*;
import static org.sculptor.examples.library.person.domain.PersonName.personName;
import static org.sculptor.examples.library.person.domain.PersonProperties.name;
import static org.sculptor.examples.library.person.domain.PersonProperties.sex;
import static org.sculptor.examples.library.person.domain.PersonProperties.ssn;
import static org.sculptor.examples.library.person.domain.Ssn.ssn;
import static org.sculptor.framework.accessapi.ConditionalCriteriaBuilder.criteriaFor;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.apache.commons.lang3.time.DateUtils;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.sculptor.examples.library.person.exception.PersonNotFoundException;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessimpl.mongodb.DbManager;
import org.sculptor.framework.domain.PagedResult;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.framework.errorhandling.UnexpectedRuntimeException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit.jupiter.SpringExtension;

@ExtendWith(SpringExtension.class)
@ContextConfiguration(locations = { "classpath:applicationContext-test.xml" })
public class PersonRepositoryTest {

	private static final String[] DATE_PATTERNS = { "yyyy-MM-dd" };

	@Autowired
	private PersonRepository personRepository;

	@Autowired
	private DbManager dbManager;

	@BeforeEach
	public void initialData() throws Exception {
		Person p1 = new Person(Gender.MALE, ssn("123456", Country.DENMARK));
		p1.setBirthDate(DateUtils.parseDate("1963-01-01", DATE_PATTERNS));
		p1.setName(personName("Aaaa", "Bbbb"));
		p1 = personRepository.save(p1);

		Person p2 = new Person(Gender.FEMALE, ssn("123456", Country.SWEDEN));
		p2.setBirthDate(DateUtils.parseDate("1964-01-01", DATE_PATTERNS));
		p2.setName(personName("Xxxx", "Yyyy"));
		p2 = personRepository.save(p2);

		Person p3 = new Person(Gender.FEMALE, ssn("987654", Country.DENMARK));
		p3.setBirthDate(DateUtils.parseDate("1965-01-01", DATE_PATTERNS));
		p3.setName(personName("Cccc", "Dddd"));
		p3 = personRepository.save(p3);

		createInitiaData("999999", "Zzzz1");
		createInitiaData("999998", "Zzzz2");
		createInitiaData("999997", "Zzzz3");
		createInitiaData("999996", "Zzzz4");
		createInitiaData("999995", "Zzzz5");
		createInitiaData("999994", "Zzzz6");
		createInitiaData("999993", "Zzzz7");
	}

	private void createInitiaData(String ssnNumber, String firstName) throws Exception {
		Person p = new Person(Gender.MALE, ssn(ssnNumber, Country.NORWAY));
		p.setBirthDate(DateUtils.parseDate("1966-01-01", DATE_PATTERNS));
		p.setName(personName(firstName, "Zzzz"));
		p = personRepository.save(p);
	}

	@AfterEach
	public void dropDatabase() {
		dbManager.getDB().dropDatabase();
	}

	@Test
	public void shouldFindBySimplePropertyCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).withProperty(sex()).eq(Gender.FEMALE)
				.build();
		List<Person> persons = personRepository.findByCondition(conditionalCriteria);
		assertEquals(2, persons.size());
	}

	@Test
	public void shouldFindByNestedPropertyCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).withProperty(ssn().country())
				.eq(Country.SWEDEN).orderBy(name().last()).build();
		List<Person> persons = personRepository.findByCondition(conditionalCriteria);
		assertEquals(1, persons.size());
		assertEquals(Country.SWEDEN, persons.get(0).getSsn().getCountry());
	}

	@Test
	public void shouldFindByOrCondition() throws Exception {
		assertThrows(UnexpectedRuntimeException.class, () -> {
			List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).withProperty(name().first())
					.eq("Aaaa").or().withProperty(name().last()).eq("Dddd").orderBy(name().last()).build();
			personRepository.findByCondition(conditionalCriteria);
		});
	}

	@Test
	public void shouldFindByGroupedCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).withProperty(sex()).eq(Gender.FEMALE)
				.and().lbrace().withProperty(name().first()).eq("Xxxx").and().withProperty(name().last()).eq("Yyyy")
				.rbrace().orderBy(name().last()).build();
		List<Person> persons = personRepository.findByCondition(conditionalCriteria);
		assertEquals(1, persons.size());
		assertEquals("123456", persons.get(0).getSsn().getNumber());
		assertEquals(Country.SWEDEN, persons.get(0).getSsn().getCountry());
	}

	@Test
	public void shouldFindByNotCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).not().withProperty(sex())
				.eq(Gender.MALE).build();
		List<Person> persons = personRepository.findByCondition(conditionalCriteria);
		assertEquals(2, persons.size());
	}

	@Test
	public void shouldFindByGroupedNotCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).withProperty(sex()).eq(Gender.MALE)
				.and().not().lbrace().withProperty(ssn().country()).eq(Country.NORWAY).and()
				.withProperty(name().last()).eq("Dddd").rbrace().orderBy(name().last()).build();
		List<Person> persons = personRepository.findByCondition(conditionalCriteria);
		assertEquals(1, persons.size());
		assertEquals("123456", persons.get(0).getSsn().getNumber());
		assertEquals(Country.DENMARK, persons.get(0).getSsn().getCountry());
	}

	@Test
	public void shouldOrderByCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).withProperty(ssn().country())
				.eq(Country.NORWAY).orderBy(name().first()).build();
		List<Person> persons = personRepository.findByCondition(conditionalCriteria);
		String previous = null;
		for (Person each : persons) {
			if (previous != null) {
				assertTrue(each.getName().getFirst().compareTo(previous) >= 0, "Expected " + each.getName().getFirst() + " >= " + previous);
			}
			previous = each.getName().getFirst();
		}
	}

	@Test
	public void shouldFindByInCondition() throws Exception {
		List<ConditionalCriteria> conditionalCriteria = criteriaFor(Person.class).withProperty(name().first())
				.in("Zzzz1", "Zzzz3", "Zzzz5").build();
		List<Person> persons = personRepository.findByCondition(conditionalCriteria);
		assertEquals(3, persons.size());
	}

	@Test
	public void shouldFindByKey() throws Exception {
		Person found = personRepository.findByKey(ssn("123456", Country.DENMARK));
		assertNotNull(found);
		assertEquals(Country.DENMARK, found.getSsn().getCountry());
	}

	@Test
	public void shouldNotFindByKey() throws Exception {
		assertThrows(PersonNotFoundException.class, () -> {
			personRepository.findByKey(ssn("123456", Country.NORWAY));
		});
	}

	@Test
	public void shouldFindByNaturalKeys() throws Exception {
		Set<Ssn> keys = new HashSet<Ssn>();
		Ssn ssn1 = new Ssn("123456", Country.DENMARK);
		keys.add(ssn1);
		Ssn ssn2 = new Ssn("987654", Country.DENMARK);
		keys.add(ssn2);
		Ssn ssn3 = new Ssn("999999", Country.SWEDEN);
		keys.add(ssn3);
		Map<Ssn, Person> persons = personRepository.findByNaturalKeys(keys);
		assertEquals(2, persons.size());
		assertNull(persons.get(ssn3));
		assertEquals("Aaaa", persons.get(ssn1).getName().getFirst());
		assertEquals(Gender.MALE, persons.get(ssn1).getSex());
		assertEquals("Cccc", persons.get(ssn2).getName().getFirst());
		assertEquals(Gender.FEMALE, persons.get(ssn2).getSex());
	}

	@Test
	public void shouldFindAllFirstPage() throws Exception {
		// thera are 10 persons
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 1, true);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(1, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(3, pagedResult.getValues().size());
		assertTrue(pagedResult.isTotalCounted());
		assertEquals(4, pagedResult.getTotalPages());
		assertEquals(10, pagedResult.getTotalRows());
	}

	@Test
	public void shouldFindAllSecondPage() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 2);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(2, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(3, pagedResult.getValues().size());
		assertFalse(pagedResult.isTotalCounted());
	}

	@Test
	public void shouldFindAllThirdPage() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 3);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(3, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(3, pagedResult.getValues().size());
		assertFalse(pagedResult.isTotalCounted());
	}

	@Test
	public void shouldFindAllLastPage() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 4);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(4, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(1, pagedResult.getValues().size());
		// when end reached last page we get the total, even though we didn't
		// ask for it
		assertTrue(pagedResult.isTotalCounted());
		assertEquals(4, pagedResult.getTotalPages());
		assertEquals(10, pagedResult.getTotalRows());
	}

	@Test
	public void shouldNotFindAllWhenPageNumberTooBig() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 17);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(17, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(0, pagedResult.getValues().size());
		// when end reached last page we get the total, even though we didn't
		// ask for it
		// but only if it's really last page (some rows was fetched)
		assertFalse(pagedResult.isTotalCounted());
	}

	@Test
	public void shouldFindAllFillAddionalResultRows() throws Exception {
		PagingParameter pagingParameter = PagingParameter.rowAccess(4, 6, 3);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(-1, pagedResult.getPage());
		assertEquals(-1, pagedResult.getPageSize());
		assertEquals(2, pagedResult.getValues().size());

		assertFalse(pagedResult.isTotalCounted());
		assertEquals(-1, pagedResult.getTotalPages());
		assertEquals(-1, pagedResult.getTotalRows());

		assertTrue(pagedResult.isAddionalResultCounted());
		assertEquals(-1, pagedResult.getAdditionalResultPages());
		assertEquals(3, pagedResult.getAdditionalResultRows());
	}

	@Test
	public void shouldFindAllFillAddionalResultPage2() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 2, 2);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(2, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(3, pagedResult.getValues().size());

		assertFalse(pagedResult.isTotalCounted());
		assertEquals(-1, pagedResult.getTotalPages());
		assertEquals(-1, pagedResult.getTotalRows());

		assertTrue(pagedResult.isAddionalResultCounted());
		assertEquals(2, pagedResult.getAdditionalResultPages());
		assertEquals(4, pagedResult.getAdditionalResultRows());
	}

	@Test
	public void shouldFindAllFillCountPage3() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 3, 2);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(3, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(3, pagedResult.getValues().size());

		// when end reached last page we get the total, even though we didn't
		// ask for it
		assertTrue(pagedResult.isTotalCounted());
		assertEquals(4, pagedResult.getTotalPages());
		assertEquals(10, pagedResult.getTotalRows());

		assertTrue(pagedResult.isAddionalResultCounted());
		assertEquals(1, pagedResult.getAdditionalResultPages());
		assertEquals(1, pagedResult.getAdditionalResultRows());
	}

	@Test
	public void shouldFindAllFillCountPage4() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 4, 2);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(4, pagedResult.getPage());
		assertEquals(3, pagedResult.getPageSize());
		assertEquals(1, pagedResult.getValues().size());

		// when end reached last page we get the total, even though we didn't
		// ask for it
		assertTrue(pagedResult.isTotalCounted());
		assertEquals(4, pagedResult.getTotalPages());
		assertEquals(10, pagedResult.getTotalRows());

		assertTrue(pagedResult.isAddionalResultCounted());
		assertEquals(0, pagedResult.getAdditionalResultPages());
		assertEquals(0, pagedResult.getAdditionalResultRows());
	}

	@Test
	public void shouldCalculateMaxPagesWhenSmallPageSize() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(3, 1, true);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(4, pagedResult.getTotalPages());
	}

	@Test
	public void shouldCalculateMaxPagesWhenPageSizeEqualToCount() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(10, 1, true);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(1, pagedResult.getTotalPages());
	}

	@Test
	public void shouldCalculateMaxPagesWhenHalfPageSizeToCount() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(5, 1, true);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(2, pagedResult.getTotalPages());
	}

	@Test
	public void shouldCalculateMaxPagesWhenLargePageSize() throws Exception {
		PagingParameter pagingParameter = PagingParameter.pageAccess(100, 1, true);
		PagedResult<Person> pagedResult = personRepository.findAll(pagingParameter);
		assertEquals(1, pagedResult.getTotalPages());
	}

	@Test
	public void shouldFetchAllWithRowAccess() throws Exception {
		Set<Person> all = new HashSet<Person>();
		int row = 0;
		while (row < 20) {
			PagingParameter pagingParameter = PagingParameter.rowAccess(row, row + 3, 1);
			PagedResult<Person> result = personRepository.findAll(pagingParameter);
			all.addAll(result.getValues());
			if (result.getAdditionalResultRows() <= 0) {
				break;
			}
			row = result.getEndRow();
		}

		assertEquals(10, all.size());
	}

	@Test
	public void shouldFetchAllWithPageAccess() throws Exception {
		Set<Person> all = new HashSet<Person>();
		for (int page = 1; page < 20; page++) {
			PagingParameter pagingParameter = PagingParameter.pageAccess(3, page, 1);
			PagedResult<Person> result = personRepository.findAll(pagingParameter);
			all.addAll(result.getValues());
			if (result.getAdditionalResultPages() <= 0) {
				break;
			}
		}

		assertEquals(10, all.size());
	}

	@Test
	@Disabled
	// not implemented yet
	public void shouldFetchAllWithNextPageAccess() throws Exception {
		Set<Person> all = new HashSet<Person>();
		PagedResult<Person> result = null;
		while (true) {
			PagingParameter pagingParameter;
			if (result == null) {
				pagingParameter = PagingParameter.pageAccess(3, 1);
			} else {
				pagingParameter = PagingParameter.getNextPage(result);
			}
			result = personRepository.findAll(pagingParameter);
			if (result.getValues().isEmpty()) {
				break;
			}
			all.addAll(result.getValues());
		}

		assertEquals(10, all.size());
	}

}
