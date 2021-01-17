package org.sculptor.dddsample.relation.serviceapi;

import org.joda.time.DateTime;
import org.junit.Test;
import org.sculptor.dddsample.relation.domain.*;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
import org.sculptor.framework.domain.JpaFunction;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.framework.domain.expression.Expression;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Tuple;
import java.math.BigDecimal;
import java.math.BigInteger;
import java.sql.Date;
import java.sql.Time;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Collection;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.Assert.*;
import static org.sculptor.dddsample.relation.domain.PersonProperties.*;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PersonServiceTest extends AbstractDbUnitJpaTests implements PersonServiceTestBase {

	@Autowired
	private PersonService personService;

	@Autowired
	private PersonRepository personRepository;

	@PersistenceContext(unitName = "DDDSampleEntityManagerFactory")
	private EntityManager entityManager;

	@Override
	protected String getDataSetFile() {
		return "dbunit/TestData.xml";
	}

	@Test
	public void testFindById() throws Exception {
		Person feromon = personService.findById(getServiceContext(), 103l);
		assertEquals("Feromon", feromon.getFirst());
		assertEquals("Smradoch", feromon.getSecondName());
	}

	@Test
	public void testFindAll() throws Exception {
		List<Person> all = personService.findAll(getServiceContext());
		assertEquals(5, all.size());
		boolean was101 = false;
		for (Person p : all) {
			if (p.getId().equals(101l)) {
				Collection<House> owningNoRel = p.getOwningUni();
				assertEquals(3, owningNoRel.size());
				Collection<House> relatedNoRel = p.getRelatedUni();
				// Should be 0 no 3
				assertEquals(3, relatedNoRel.size());
				Collection<House> otherNoRel = p.getOtherUni();
				// Should be 0 no 3
				assertEquals(3, otherNoRel.size());
				was101 = true;
			}
		}
		assertTrue(was101);
	}

	@Test
	@Override
	public void testSave() throws Exception {
		House firstHouse = new House();
		firstHouse.setName("Vyrocnik");
		firstHouse.setStreet("Atomic");
		firstHouse.setNumber("1123");
		firstHouse.setTown("Plymouth");
		firstHouse.setZipCode("A-923754");
		firstHouse.setState("Small Britain");

		House secondHouse = new House();
		secondHouse.setName("Kukacnik");
		secondHouse.setStreet("Quark");
		secondHouse.setNumber("893");
		secondHouse.setTown("Cardiff");
		secondHouse.setState("Small Britain");
		secondHouse.setZipCode("B-3478");
		secondHouse.setNumberOfFloors(1);
		secondHouse.setHouseFootprint(947);
		secondHouse.setLandFieldSize(1837);

		Person p = new Person();
		p.setFirst("Newman");
		p.setSecondName("Elemental");
		p.addOwningUni(firstHouse);
		p.addOwningUni(secondHouse);
		Person stored = personService.save(getServiceContext(), p);
		entityManager.clear();

		// All will have 2 items not only OwningNoRel
		Person fetched = personService.findById(getServiceContext(), stored.getId());

		Collection<House> owningUni = fetched.getOwningUni();
		assertEquals(2, owningUni.size());

		// This is WRONG - should be 0
		Collection<House> relatedUni = fetched.getRelatedUni();
		assertEquals(2, relatedUni.size());

		// This is WRONG - should be 0
		Collection<House> otherUni = fetched.getOtherUni();
		assertEquals(2, otherUni.size());
	}

	@Test
	@Override
	public void testDelete() throws Exception {
		int personCount = countRowsInTable(Person.class);
		Person person = personService.findById(getServiceContext(), 103l);
		personService.delete(getServiceContext(), person);
		int personCount2 = countRowsInTable(Person.class);
		assertEquals("Person with ID 103 not removed", 1, personCount - personCount2);
	}

	@Test
	public void testReadOnly() throws Exception {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(id()).greaterThan(0)
				.build();
		List<Person> persons = personService.findByCondition(getServiceContext(), condition, PagingParameter.noLimits()).getValues();
		persons.stream().forEach(p -> p.setSecondName("READ_WRITE"));
		entityManager.flush();
		entityManager.clear();

		List<ConditionalCriteria> conditionRo = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(id()).greaterThan(0)
				.readOnly()
				.build();
		List<Person> personsRo = personService.findByCondition(getServiceContext(), conditionRo, PagingParameter.noLimits()).getValues();
		personsRo.stream().forEach(p -> p.setSecondName("NEW_VALUE"));
		entityManager.flush();
		entityManager.clear();

		List<Person> allPersons = personService.findAll(getServiceContext());
		allPersons.stream().forEach(p -> assertEquals("READ_WRITE", p.getSecondName()));
	}

	@Test
	public void testScrolleable() throws Exception {
		// Scroll only
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(id()).greaterThan(0)
				.orderBy(id())
				.scroll()
				.build();
		List<Person> persons = personService.findByCondition(getServiceContext(), condition, PagingParameter.rowAccess(0, 2)).getValues();
		try {
			persons.size();
			fail("Exception not thrown");
		} catch (UnsupportedOperationException uoe) {
			assertTrue(uoe instanceof UnsupportedOperationException);
		}
		persons.stream().forEach(p -> p.setSecondName("SCROLL"));
		entityManager.flush();
		entityManager.clear();

		// Scroll only with readOnly
		List<ConditionalCriteria> conditionRo = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.withProperty(id()).greaterThan(0)
				.orderBy(id())
				.readOnly()
				.scroll()
				.build();
		List<Person> personsRo = personService.findByCondition(getServiceContext(), conditionRo, PagingParameter.rowAccess(0, 2)).getValues();
		try {
			persons.size();
			fail("Exception not thrown");
		} catch (UnsupportedOperationException uoe) {
			assertTrue(uoe instanceof UnsupportedOperationException);
		}
		personsRo.stream().forEach(p -> p.setSecondName("NEW_VALUE"));
		entityManager.flush();
		entityManager.clear();

		List<Person> allPersons = personService.findAll(getServiceContext());
		long countScroll = allPersons.stream().filter(p -> p.getSecondName().equals("SCROLL")).count();
		assertEquals(2, countScroll);

		long countNew = allPersons.stream().filter(p -> p.getSecondName().equals("NEW_VALUE")).count();
		assertEquals(0, countNew);
	}

	@Test
	@Override
	public void testFindByCondition() {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id().expr().add(12))
				.select(id().expr().mod(12).substract(1000).abs())
				.select(secondName())
				.select(secondName().expr().left(4))
				.select(secondName().expr().right(3))
				.select(secondName().expr().append("-").append(12).append(" ").append(first()).append(id()))
				.select(Expression.currentDate())
				.select(Expression.currentTime())
				.select(Expression.currentTimestamp())
				.select(createdDate())
				.select(createdDate().expr().second())
				.select(createdDate().expr().minute())
				.select(createdDate().expr().hour())
				.select(createdDate().expr().day())
				.select(createdDate().expr().month())
				.select(createdDate().expr().year())
				.select(createdDate().expr().week())
				.select(createdDate().expr().quarter())
				.select(createdDate().expr().dayOfWeek())
				.select(createdDate().expr().dayOfYear())
				.select(createdDate().expr().year().asString().left(3).asInteger())
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);
		Object[][] expected = new Object[][] {
				{113l, 995, "Merkvicko", "Merk", "cko", "Merkvicko-12 Jozef101", "SKIP", "SKIP", "SKIP"
						, "2008-12-07 02:02:03", 3, 2, 1, 7, 12, 2008, 49, 4, 1, 342, 200},
				{114l, 994, "Gandhi", "Gand", "dhi", "Gandhi-12 Mahatutma102", "SKIP", "SKIP", "SKIP"
						, "2008-12-07 05:05:06", 6, 5, 4, 7, 12, 2008, 49, 4, 1, 342, 200},
				{115l, 993, "Smradoch", "Smra", "och", "Smradoch-12 Feromon103", "SKIP", "SKIP", "SKIP"
						, "2009-08-07 02:00:00", 0, 0, 0, 7, 8, 2009, 32, 3, 6, 219, 200},
				{116l, 992, "Gabrielson", "Gabr", "son", "Gabrielson-12 Peterson104", "SKIP", "SKIP", "SKIP"
						, "2009-09-20 09:08:09", 9, 8, 7, 20, 9, 2009, 38, 3, 1, 263, 200},
				{117l, 991, "Sablinson", "Sabl", "son", "Sablinson-12 Gerthrude105", "SKIP", "SKIP", "SKIP"
						, "2013-02-18 00:59:59", 59, 59, 23, 17, 2, 2013, 7, 1, 1, 48, 201}
		};
		assertEquals("Some comparison skipped", 18 * 5, assertTuple(expected, result));
	}

	@Test
	public void testFindByConditionHaving() {
		List<ConditionalCriteria> condition2 = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id()).max()
				.select(id().expr().max())
				.select(id()).sum()
				.select(id().expr().sum())
				.select(id().expr().count())
				.select(id().expr().countDistinct())
				.select(createdDate().expr().year())
				.select(createdDate().expr().dayOfYear().min())
				.where(id()).greaterThanOrEqual(8).where(secondName()).isNotNull().or().where(secondName()).isNull()
				.groupBy(createdDate().expr().year())
				.having(createdDate().expr().dayOfYear().min()).lessThanOrEqual(300)
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition2);
		Object[][] expected = new Object[][] {
				{104l, 104l, 207l, 207l, 2l, 2l, 2009, 219},
				{105l, 105l, 105l, 105l, 1l, 1l, 2013, 48}
		};
		assertEquals("Some comparison skipped", 8 * 2, assertTuple(expected, result));
	}

	private JpaFunction myCustomLpad12(String padChar) {
		return (builder, left, converter) -> {
			javax.persistence.criteria.Expression[] expr = new javax.persistence.criteria.Expression[]{
					left,
					builder.literal(12),
					builder.literal(padChar)
			};
			return builder.function("lpad", String.class, expr);
		};
	}

	private JpaFunction myCustomLpad15(String padChar) {
		return (builder, left, converter) ->
			builder.function("lpad", String.class, converter.convertObjectArray(left, 15, padChar));
	}

	@Test
	public void testFindByConditionAs() throws Exception {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
			.select(id())
			.select(secondName())
			.select(first())
			.select(createdDate())
			.where(first()).greaterThanOrEqual("H")
			.where(id()).lessThan(105)
			.orderBy(createdDate().expr().year())
			.orderBy(id())
			.build();
		List<MiniPerson> result = personRepository.findByConditionAs(condition, MiniPerson.class);
		testFindByConditionAsResult(result);
	}

	@Test
	public void testFindByConditionAsPaging() throws Exception {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id())
				.select(secondName())
				.select(first())
				.select(createdDate())
				.where(first()).greaterThanOrEqual("H")
				.where(id()).lessThan(105)
				.orderBy(createdDate().expr().year())
				.orderBy(id())
				.build();
		List<MiniPerson> result = personRepository.findByConditionAs(condition, PagingParameter.noLimits(), MiniPerson.class).getValues();
		testFindByConditionAsResult(result);
	}

	private void testFindByConditionAsResult(List<MiniPerson> result) throws Exception {
		assertEquals("Result size", 3, result.size());
		assertEquals(101l, result.get(0).getId().longValue());
		assertEquals(102l, result.get(1).getId().longValue());
		assertEquals(104l, result.get(2).getId().longValue());
	}

	@Test
	public void testFindByConditionExpr() throws Exception {
		Expression<Person> firtst2Upper = first().expr().substring(2).toUpper();
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id().expr().max())
				.select(id().expr().multiply(3).max())
				.select(id().expr().multiply(version()).max())
				.select(id().expr().append(" * ").append(version()).append(" = ").append(id().expr().multiply(version())).maxAsString())
				.select(id().expr().divide(version()).max())
				.select(secondName().expr().min())
//				.select(secondName(), substring(3), append(" aha"), initCap()).min()
				.select(secondName().expr().substring(3).append(" aha").minAsString())
				.select(secondName().expr().append(" ").append(first()).minAsString())
				.select(secondName().expr().join("-", first(), createdBy(), version()).minAsString())
				.select(secondName().expr().append("_").append(firtst2Upper).minAsString())
				.select(secondName().expr().rightPad(15, "#-").leftPad(20, "%").minAsString())
				.select(secondName().expr().left(5).right(3).minAsString())
				.select(secondName().expr().length().min())
				.select(secondName().expr().substring(2, 4).minAsString())
				.select(secondName().expr().toLower().minAsString())
				.select(secondName().expr().length().add(15).substract(first().expr().length()).min())
				.select(secondName().expr().indexOf("a").asString().append(" <- index of 'a' in \"").append(secondName()).append("\"").minAsString())
				.select(secondName().expr().function("rpad", String.class, Expression.PREVIOUS_RESULT, 20, "#").min())
				.select(secondName().expr().function(myCustomLpad12("+")).min())
				.select(secondName().expr().function(myCustomLpad15("-")).min())
				.select(secondName().expr().prepend("   @@@").trimLeading().trimLeading('@').trimLeading('G').minAsString())
				.select(secondName().expr().append("@@   ").trimTrailing().trimTrailing('@').trimTrailing('n').minAsString())
				.select(secondName().expr().prepend("      @@").append("@@@   ").trimBoth().trimBoth('@').trimBoth('n').minAsString())
				.select(secondName().expr().count())
				.select(secondName().expr().left(4)
					.caseExpr()
					.when(id()).lessThanOrEqual(102).than("ABC")
					.when().lessThanOrEqual("F").or().when(secondName()).lessThan("K").than("DEF")
					.when(createdBy()).isNull().than("GHI")
					.when(createdBy()).greaterThan("p").and().when(id()).greaterThanOrEqual(103).than("JKL")
					.otherwise("OTHER").trimBoth()
				).min()
				.where(createdDate().expr().year()).greaterThan(2004)
				.where(first().expr().length()).greaterThan(5)
				.groupBy(createdDate().expr().year())
				.having(createdDate().expr().year()).greaterThan(10)
				.orderBy(createdDate().expr().year())
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);
		printTuple(result);

		Object[][] expected = new Object[][] {
			{102l, 306l, 306l, "102 * 3 = 306", 34l, "Gandhi", "ndhi aha", "Gandhi Mahatutma", "Gandhi-Mahatutma-3"
				, "Gandhi_AHATUTMA", "%%%%%Gandhi#-#-#-#-#", "ndh", 6, "andh", "gandhi", 12
				, "2 <- index of 'a' in \"Gandhi\"", "Gandhi##############", "++++++Gandhi", "---------Gandhi"
				, "andhi", "Gandhi", "Gandhi", 1l, "ABC"},
			{104l, 312l, 416l, "104 * 4 = 416", 51l, "Gabrielson", "brielson aha", "Gabrielson Peterson", "Gabrielson-Peterson-4"
				, "Gabrielson_ETERSON", "%%%%%Gabrielson#-#-#", "bri", 8, "abri", "gabrielson", 16
				, "2 <- index of 'a' in \"Gabrielson\"", "Gabrielson##########", "++++Smradoch", "-------Smradoch"
				, "Smradoch", "Gabrielso", "Gabrielso", 2l, "DEF"},
			{105l, 315l, 420l, "105 * 4 = 420", 26l, "Sablinson", "blinson aha", "Sablinson Gerthrude", "Sablinson-Gerthrude-prizdisral-4"
				, "Sablinson_ERTHRUDE", "%%%%%Sablinson#-#-#-", "bli", 9, "abli", "sablinson", 15
				, "2 <- index of 'a' in \"Sablinson\"", "Sablinson###########", "+++Sablinson", "------Sablinson"
				, "Sablinson", "Sablinso", "Sablinso", 1l, "JKL"}
		};
		assertEquals("Number of result rows", 3, result.size());
		assertEquals("Some comparison skipped", 25 * 3, assertTuple(expected, result));
	}

	@Test
	public void testFindByConditionGroupByYear() throws Exception {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id().expr().count())
				.select(id().expr().countDistinct())
				.select(version().expr().count())
				.select(version().expr().countDistinct())
				.select(createdDate().expr().count())
				.select(createdDate().expr().countDistinct())
//				.select(createdDate().expr().year()).count()	// Runtime error - JPQL doesn't support expression inside count
				.select(version().expr().sum())
				.select(version().expr().sumAsLong())
				.select(version().expr().avg())
				.select(version().expr().min().asInteger())
				.select(version().expr().max().asInteger())
				.select(secondName().expr().min())
				.select(secondName().expr().max())
				.select(createdDate().expr().year().min())
				.select(createdDate().expr().year().max())
				.groupBy(createdDate().expr().year().asLong().mod(2))
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);

		Object[][] expected = new Object[][] {
				{2l, 2l, 2l, 1l, 2l, 2l, 6l, 6l, 3d, 3, 3, "Gandhi", "Merkvicko", 2008, 2008},
				{3l, 3l, 3l, 2l, 3l, 3l, 10l, 10l, 3.333d, 2, 4, "Gabrielson", "Smradoch", 2009, 2013},
		};

		assertEquals("Number of result rows", 2, result.size());
		assertEquals("Some comparison skipped", 15 * 2, assertTuple(expected, result));
	}

	@Test
	public void testFindByConditionCast() throws Exception {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id().expr().asInteger())
				.select(id().expr().asLong())
				.select(id().expr().asFloat())
				.select(id().expr().asDouble())
				.select(id().expr().asBigInteger())
				.select(id().expr().asBigDecimal())
				.select(createdDate().expr().asString())
				.select(createdDate().expr().asDate())
				.select(createdDate().expr().asTime())
				.select(createdDate().expr().asTimestamp())
				.select(createdDate().expr().asString().substring(5).prepend("2009").asTimestamp())
//				.select(id().expr().asDouble().mod(23)) // This crash at runtime
				.select(id().expr().mod(23))
				.where(id()).eq(101)
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);
		printTuple(result);

		Object[][] expected = new Object[][] {
			{101, 101l, 101f, 101d, 101, 101d, "2008-12-07 01:02:03.456000", "2008-12-07", "01:02:03"
				, "2008-12-07 01:02:03", "2009-12-07 01:02:03", 9},
		};

		assertEquals("Number of result rows", 1, result.size());
		assertEquals("Some comparison skipped", 12, assertTuple(expected, result));
	}

	@Test
	public void testFindByConditionGroupByMonth() throws Exception {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id().expr().count())
				.select(id().expr().countDistinct())
				.select(version().expr().count())
				.select(version().expr().countDistinct())
				.select(createdDate().expr().count())
				.select(createdDate().expr().countDistinct())
				.select(createdDate().expr().month().min())
				.select(createdDate().expr().month().max())
				.groupBy(createdDate().expr().month().asString().asInteger().mod(2))
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);

		Object[][] expected = new Object[][] {
				{4l, 4l, 4l, 3l, 4l, 4l, 2, 12},
				{1l, 1l, 1l, 1l, 1l, 1l, 9, 9},
		};

		assertEquals("Number of result rows", 2, result.size());
		assertEquals("Some comparison skipped", 8 * 2, assertTuple(expected, result));
	}

	@Test
	public void testFindByConditionGroupByDay() throws Exception {
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id().expr().count())
				.select(id().expr().countDistinct())
				.select(version().expr().count())
				.select(version().expr().countDistinct())
				.select(createdDate().expr().count())
				.select(createdDate().expr().countDistinct())
				.groupBy(createdDate().expr().day())
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);

		Object[][] expected = new Object[][] {
				{3l, 3l, 3l, 2l, 3l, 3l},
				{1l, 1l, 1l, 1l, 1l, 1l},
				{1l, 1l, 1l, 1l, 1l, 1l},
		};

		assertEquals("Number of result rows", 3, result.size());
		assertEquals("Some comparison skipped", assertTuple(expected, result), 6 * 3);
	}

	@Test
	public void testFindByConditionCaseInGroupBy() throws Exception {
		Expression<Person> firtst2Upper = first().expr().substring(2).toUpper();
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id()).min()
				.select(id()).max()
				.select(id()).count()
				.select(first().expr().left(4).toUpper().minAsString())
				.select(createdDate().expr().year().multiply(100).add(createdDate().expr().month())).min()
				.select(createdDate().expr().year().multiply(100).add(createdDate().expr().month())
						.caseExpr()
						.when().lessThan(200901).than("OLD")
						.when().lessThan(201001).than("NEW")
						.otherwise(createdDate().expr().asString())
				)
				.select(id().expr().add(1000).sum())
				.where(createdDate().expr().year()).greaterThan(2004)
				.groupBy(createdDate().expr().year().multiply(100).add(createdDate().expr().month())
						.caseExpr()
						.when().lessThan(200901).than("OLD")
						.when().lessThan(201001).than("NEW")
						.otherwise(createdDate().expr().asString())
				)
				.having(id().expr().add(1000).sum()).greaterThan(1100)
				.orderBy(id().expr().min())
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);

		Object[][] expected = new Object[][] {
				{101l, 102l, 2l, "JOZE", 200812, "OLD", 2203l},
				{103l, 104l, 2l, "FERO", 200908, "NEW", 2207l},
				{105l, 105l, 1l, "GERT", 201302, "2013-02-17 23:59:59.000000", 1105l},
		};
		assertEquals("Number of result rows", 3, result.size());
		assertEquals("Some comparison skipped", 7 * 3, assertTuple(expected, result));
	}
	@Test
	public void testFindByConditionCase() throws Exception {
		Expression<Person> firtst2Upper = first().expr().substring(2).toUpper();
		List<ConditionalCriteria> condition = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(id())
				.select(first().expr().left(4).toUpper()
					.caseExpr()
						.when(id()).lessThanOrEqual(101).than("ABC")
						// Default when() - using original expression where caseExpr() was started
						// in this case first().expr().left(4).toUpper()
						.when().lessThanOrEqual("G").or().when(secondName()).lessThan("G").than("DEF")
						.when(createdBy()).isNull().than("GHI")
						// Default than() - using original expression
						.when(createdBy()).greaterThan("P").and().when(id()).greaterThanOrEqual(103).than()
					.otherwise("OTHER")
					.trimBoth()
				)
				.select(createdDate().expr().year().multiply(100).add(createdDate().expr().month())
					.caseExpr()
						.when().lessThan(200901).than("OLD")
						.when().lessThan(200909).than("NEW")
						.when(id()).lessThanOrEqual(104).than("<=104")
						// Convert to string - all results have to be of same type otherwise SQL exception from server
					.otherwise(createdDate().expr().asString())
				)
				.select(createdDate().expr().year().multiply(100).add(createdDate().expr().month())
					.caseExpr()
						.when().lessThan(200901).than("OLD")
						.when().lessThan(200909).than("NEW")
						.when(id()).lessThanOrEqual(104).than("<=104")
						// Without otherwise - have to return NULL
					.end()
					.trimTrailing()
				)
				.where(createdDate().expr().year()).greaterThan(2004)
				.orderBy(id())
				.build();
		List<Tuple> result = personRepository.findByConditionTuple(condition);

		Object[][] expected = new Object[][] {
				{101l, "ABC", "OLD", "OLD"},
				{102l, "GHI", "OLD", "OLD"},
				{103l, "DEF", "NEW", "NEW"},
				{104l, "GHI", "<=104", "<=104"},
				{105l, "GERT", "2013-02-17 23:59:59.000000", null},
		};
		assertEquals("Number of result rows", 5, result.size());
		assertEquals("Some comparison skipped", 4 * 5, assertTuple(expected, result));
	}

	private int assertTuple(Object[][] expected, List<Tuple> result) {
		int n=0;
		for (int row = 0; row < expected.length; row++) {
			Object[] exRow = expected[row];
			Object[] resRow = result.get(row).toArray();
			for (int i = 0; i < exRow.length; i++) {
				Object exElem = exRow[i];
				if (exElem == null) {
				} else if (exElem.equals("SKIP")) {
					continue;
				} else if (resRow[i] instanceof Date) {
					try {
						SimpleDateFormat dateParser = new SimpleDateFormat("yyyy-MM-dd");
						java.util.Date parsed = dateParser.parse((String) exElem);
						exElem = new Date(parsed.getTime());
					} catch (ParseException e) {
						fail("Can not create java.sql.Date from value " + exElem + " in row " + row + " element " + i);
					}
				} else if (resRow[i] instanceof Time) {
					try {
						SimpleDateFormat dateParser = new SimpleDateFormat("HH:mm:ss");
						java.util.Date parsed = dateParser.parse((String) exElem);
						exElem = new Time(parsed.getTime());
					} catch (ParseException e) {
						fail("Can not create java.sql.Time from value " + exElem + " in row " + row + " element " + i);
					}
				} else if (resRow[i] instanceof Timestamp) {
					try {
						SimpleDateFormat dateParser = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						java.util.Date parsed = dateParser.parse((String) exElem);
						exElem = new Timestamp(parsed.getTime());
					} catch (ParseException e) {
						fail("Can not create java.sql.Timestamp from value " + exElem + " in row " + row + " element " + i);
					}
				} else if (resRow[i] instanceof DateTime) {
					try {
						SimpleDateFormat dateParser = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
						java.util.Date parsed = dateParser.parse((String) exElem);
						exElem = new DateTime(parsed.getTime());
					} catch (ParseException e) {
						fail("Can not parse DateTime from value " + exElem + " in row " + row + " element " + i);
					}
				}
				n++;

				if (exElem == null) {
					assertNull("Item in row " + row + " element " + i + " is not NULL", resRow[i]);
				} else if (resRow[i] instanceof Double) {
					double exElemDouble = (double) exElem;
					double resRowDouble = (double) resRow[i];
					assertEquals("Item in row " + row + " element " + i + " doesnt' match", exElemDouble, resRowDouble, 0.001);
				} else if (resRow[i] instanceof BigInteger) {
					int exElemInt = (int) exElem;
					int resRowInt = ((BigInteger) resRow[i]).intValue();
					assertEquals("Item in row " + row + " element " + i + " doesnt' match", exElemInt, resRowInt);
				} else if (resRow[i] instanceof BigDecimal) {
					double exElemDouble = (double) exElem;
					double resRowDouble = ((BigDecimal) resRow[i]).doubleValue();
					assertEquals("Item in row " + row + " element " + i + " doesnt' match", exElemDouble, resRowDouble, 0.001);
				} else if (resRow[i] instanceof Time) {
					Time resRowTime = (Time) resRow[i];
					Time exRowTime = (Time) exElem;
					String error = " in " + exRowTime + " doesn't match with " + resRowTime;
					assertEquals("Hour" + error, exRowTime.getHours(), resRowTime.getHours());
					assertEquals("Minute" + error, exRowTime.getMinutes(), resRowTime.getMinutes());
					assertEquals("Second" + error, exRowTime.getSeconds(), resRowTime.getSeconds());
				} else if (resRow[i] instanceof Timestamp) {
					Timestamp resRowTime = (Timestamp) resRow[i];
					Timestamp exRowTime = (Timestamp) exElem;
					String error = " in " + exRowTime + " doesn't match with " + resRowTime;
					assertEquals("Year" + error, exRowTime.getYear(), resRowTime.getYear());
					assertEquals("Month" + error, exRowTime.getMonth(), resRowTime.getMonth());
					assertEquals("Day" + error, exRowTime.getDay(), resRowTime.getDay());
					assertEquals("Hour" + error, exRowTime.getHours(), resRowTime.getHours());
					assertEquals("Minute" + error, exRowTime.getMinutes(), resRowTime.getMinutes());
					assertEquals("Second" + error, exRowTime.getSeconds(), resRowTime.getSeconds());
				} else if (resRow[i] instanceof DateTime) {
					DateTime resRowTime = (DateTime) resRow[i];
					DateTime exRowTime = (DateTime) exElem;
					String error = " in " + exRowTime + " doesn't match with " + resRowTime;
					assertEquals("Year" + error, exRowTime.getYear(), resRowTime.getYear());
					assertEquals("Month" + error, exRowTime.getMonthOfYear(), resRowTime.getMonthOfYear());
					assertEquals("Day" + error, exRowTime.getDayOfMonth(), resRowTime.getDayOfMonth());
					assertEquals("Hour" + error, exRowTime.getHourOfDay(), resRowTime.getHourOfDay());
					assertEquals("Minute" + error, exRowTime.getMinuteOfHour(), resRowTime.getMinuteOfHour());
					assertEquals("Second" + error, exRowTime.getSecondOfMinute(), resRowTime.getSecondOfMinute());
				} else {
					assertEquals("Item in row " + row + " element " + i + " type mismatch", exElem.getClass().getName(), resRow[i].getClass().getName());
					assertEquals("Item in row " + row + " element " + i + " doesnt' match", exElem, resRow[i]);
				}
			}
		}
		return n;
	}

	private void printTuple(List<Tuple> result) {
		result.forEach(t -> {
			System.out.println(">>>>> ROW >>>>>");
			Object[] arr = t.toArray();
			for (int i = 0; i < arr.length; i++) {
				if (arr[i] == null) {
					System.out.printf("    col[%02d] = NULL\n", i);
				} else {
					System.out.printf("    col[%02d] = %-8s :: %s\n", i, arr[i].toString(), arr[i].getClass().getName());
				}
			}
		});

	}
}
