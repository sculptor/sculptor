/* (c) Sculptor Project Team, 2013-2021 including the original author or authors.
 */
package org.sculptorgenerator.examples.examplemodule.serviceapi;

import org.hamcrest.MatcherAssert;
import org.hamcrest.Matchers;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.Test;
import org.sculptor.framework.accessapi.ConditionalCriteria;
import org.sculptor.framework.accessapi.ConditionalCriteriaBuilder;
import org.sculptor.framework.domain.expression.Expression;
import org.sculptor.framework.domain.expression.ExpressionBuilder;
import org.sculptor.framework.domain.expression.fts.ExpressionFtsQuery;
import org.sculptor.framework.domain.expression.fts.ExpressionFtsVector;
import org.sculptor.framework.domain.expression.fts.HighlightOptions;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.sculptorgenerator.examples.examplemodule.domain.Person;
import org.sculptorgenerator.examples.examplemodule.domain.PersonProperties;
import org.sculptorgenerator.examples.examplemodule.domain.Sex;
import org.sculptorgenerator.examples.examplemodule.serviceapi.PersonService;
import org.springframework.beans.factory.annotation.Autowired;

import javax.persistence.Tuple;
import java.math.BigDecimal;
import java.math.MathContext;
import java.math.RoundingMode;
import java.time.LocalDate;
import java.time.Month;
import java.util.List;
import java.util.stream.Collectors;

import static org.junit.jupiter.api.Assertions.*;
import static org.sculptor.framework.domain.expression.ExpressionBuilder.ftsPlainQuery;
import static org.sculptor.framework.domain.expression.ExpressionBuilder.ftsQuery;
import static org.sculptor.framework.domain.expression.fts.ExpressionFtsVector.*;
import static org.sculptorgenerator.examples.examplemodule.domain.PersonProperties.*;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PersonServiceTest extends AbstractDbUnitJpaTests implements PersonServiceTestBase {

	@Autowired
	protected PersonService personService;

	@Override
	protected String getDataSetFile() {
		return "dbunit/TestData.xml";
	}

	@Test
	public void testFindById() throws Exception {
		Person person = personService.findById(getServiceContext(), 102l);
		Assertions.assertEquals(102l, person.getId());
	}

	@Test
	public void testFindAll() throws Exception {
		List<Person> all = personService.findAll(getServiceContext());
		List<Long> ids = all.stream().map(e -> e.getId()).collect(Collectors.toList());
		assertEquals(8, all.size());
		MatcherAssert.assertThat(ids, Matchers.containsInAnyOrder(100l, 101l, 102l, 103l, 104l, 105l, 106l, 107l));
	}

	@Test
	public void testFindByCondition() throws Exception {
		ExpressionFtsVector<Person> firstNameFts = firstName().expr().asFtsVector();
		List<ConditionalCriteria> cond = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.where(firstNameFts).ftsEq(
						ftsQuery("lukas & tobias")
						.andFtsQuery("leon")
						.andFtsQuery(ftsQuery("jonas"))
						.orFtsQuery("marc & alex & eric")
						.orFtsQuery(ftsQuery("julia & hannah & laura"))
						.orFtsQuery("veronika & dorota").andFtsQuery(ftsQuery("perla").notFtsQuery())
//						.orFtsQuery("veronika & dorota & !perla")
//						.orFtsQuery(ftsQuery("Perla").notFtsQuery().andFtsQuery("veronika & dorota"))
				)
				.build();
		List<Person> result = personService.findByCondition(getServiceContext(), cond);
		List<Long> ids = result.stream().map(e -> e.getId()).collect(Collectors.toList());
		assertEquals(3, result.size());
		MatcherAssert.assertThat(ids, Matchers.containsInAnyOrder(104l, 106l, 107l));
	}

	@Test
	public void testFindByConditionTuple() throws Exception {
		ExpressionFtsVector<Person> firstNameFts = firstName().expr().asFtsVector();
		ExpressionFtsQuery<Object> alexAndHugoOrMarc = ftsQuery("alex & hugo | marc");
		List<ConditionalCriteria> cond = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(PersonProperties.id())
				.select(firstName().expr().asFtsVector())
				.select(firstName().expr().asFtsVector("english"))
				.select(firstName().expr().asFtsVector("spanish"))
				.select(firstName().expr().asFtsVector("german"))
				.select(ExpressionBuilder.<Person>ftsQuery("(alex & hugo) | marc").ftsNumNode())
				.select(firstName().expr().asFtsVector().ftsLength())
				.select(firstName().expr().asFtsVector().ftsSetWeightA())
				.select(secondName().expr().asFtsVector().ftsSetWeightB().ftsConcat(emailAddress().expr().asFtsVector().ftsSetWeightC()))
				.select(secondName().expr().asFtsVector().ftsSetWeightB().ftsConcat(emailAddress().expr().asFtsVector().ftsSetWeightC()).ftsStrip())
				.select(secondName().expr().asFtsVector().ftsSetWeightD())
				.select(firstName().expr().asFtsVector().ftsRank(alexAndHugoOrMarc))
				.select(firstName().expr().asFtsVector().ftsRank(alexAndHugoOrMarc, NORM_LENGTH))
				.select(firstName().expr().asFtsVector().ftsRank(alexAndHugoOrMarc, 1f, 0.9f, 0.8f, 0.7f))
				.select(firstName().expr().asFtsVector().ftsRank(alexAndHugoOrMarc, 1f, 0.9f, 0.8f, 0.7f, NORM_ITSELF))
				.select(firstName().expr().asFtsVector().ftsRankCd(alexAndHugoOrMarc))
				.select(firstName().expr().asFtsVector().ftsRankCd(alexAndHugoOrMarc, NORM_LENGTH))
				.select(firstName().expr().asFtsVector().ftsRankCd(alexAndHugoOrMarc, 1f, 0.9f, 0.8f, 0.7f, NORM_ITSELF))
				.select(firstName().expr().asFtsVector().ftsRankCd(alexAndHugoOrMarc, 1f, 0.9f, 0.8f, 0.7f))
				.select(firstName().expr().asFtsVector().ftsRankCd(alexAndHugoOrMarc, 1f, 0.9f, 0.8f, 0.7f, NORM_ITSELF))
				.select(firstName().expr().asFtsVector().ftsSetWeightA().ftsRank(alexAndHugoOrMarc, 1f, 0.8f, 0.5f, 0.2f))
				.select(firstName().expr().asFtsVector().ftsSetWeightB().ftsRank(alexAndHugoOrMarc, 1f, 0.8f, 0.5f, 0.2f))
				.select(firstName().expr().asFtsVector().ftsSetWeightC().ftsRank(alexAndHugoOrMarc, 1f, 0.8f, 0.5f, 0.2f))
				.select(firstName().expr().asFtsVector().ftsSetWeightD().ftsRank(alexAndHugoOrMarc, 1f, 0.8f, 0.5f, 0.2f))
				.where(firstNameFts).ftsEq("anna")
				.or()
				.where(firstNameFts).ftsEq(ftsQuery("anna"))
				.or()
				.where(firstNameFts).ftsEq(ftsQuery("english", "anna"))
				.or()
				.where(firstNameFts).ftsEq(ExpressionBuilder.ftsPlainQuery("hugo"))
				.or()
				.where(firstNameFts).ftsEq(ExpressionBuilder.ftsPlainQuery("english", "hugo"))
				.or()
				.where(firstNameFts).ftsEq(ExpressionBuilder.ftsPhraseQuery("leah"))
				.or()
				.where(firstNameFts).ftsEq(ExpressionBuilder.ftsPhraseQuery("german", "leah"))
				.or()
				.where(firstNameFts).ftsEq(ExpressionBuilder.ftsWebQuery("finn"))
				.or()
				.where(firstNameFts).ftsEq(ExpressionBuilder.ftsWebQuery("spanish", "finn"))
				.orderBy(PersonProperties.id())
				.build();
		List<Tuple> result = personService.findByConditionTuple(getServiceContext(), cond);
		// printTuple(result);

		testOneRow(result.get(0), 102l
			, "'daniel':5 'firstname102':2 'hugo':3 'luca':1 'martín':4 'pablo':6"
			, "'daniel':5 'firstname102':2 'hug':3 'luc':1 'martin':4 'pabl':6"
			, "'daniel':5 'firstname102':2 'hugo':3 'lucas':1 'martín':4 'pablo':6"
			, 5, 6
			, "'muller':1B 'muller@gmail.com':3C 'secondname102':2B"
			, "'muller' 'muller@gmail.com' 'secondname102'"
			, "'muller':1 'secondname102':2"
			, 0.0203, 0.0034, 0.1418, 0.1242, 0.0, 0.0, 0.0, 0.0, 0.0
			, 0.2026, 0.1621, 0.1013, 0.0405
		);
		testOneRow(result.get(1), 103l
				, "'adassa':10 'anna':2 'carmen':3 'dolor':4 'firstname103':5 'idaira':7 'maria':1 'may':9 'naira':6 'yurena':8"
				, "'adass':10 'anna':2 'carm':3 'dolor':4 'firstname103':5 'idair':7 'mari':1 'may':9 'nair':6 'yuren':8"
				, "'adassa':10 'anna':2 'carm':3 'dolor':4 'firstname103':5 'idaira':7 'maria':1 'may':9 'naira':6 'yurena':8"
				, 5, 10
				, "'jensen':1B 'jensen@malymakky.org':3C 'secondname103':2B"
				, "'jensen' 'jensen@malymakky.org' 'secondname103'"
				, "'jensen':1 'secondname103':2"
				, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
				, 0.0, 0.0, 0.0, 0.0
		);
		testOneRow(result.get(2), 104l
				, "'alex':3 'arna':9 'biel':7 'didac':10 'eric':4 'firstname104':1 'hugo':8 'marc':2 'pau':6 'pol':5"
				, "'alex':3 'arna':9 'biel':7 'didac':10 'eric':4 'firstname104':1 'hug':8 'marc':2 'pau':6 'pol':5"
				, "'alex':3 'arna':9 'biel':7 'didac':10 'eric':4 'firstname104':1 'hugo':8 'marc':2 'pau':6 'pol':5"
				, 5, 10
				, "'rossi':1B 'rossi@gmail.com':3C 'secondname104':2B"
				, "'rossi' 'rossi@gmail.com' 'secondname104'"
				, "'rossi':1 'secondname104':2"
				, 0.0608, 0.0061, 0.4255, 0.2985, 0.12, 0.012, 0.4565, 0.84, 0.4565
				, 0.6079, 0.4863, 0.304, 0.1216
		);
		testOneRow(result.get(3), 106l
				, "'ben':7 'elia':8 'finn':3 'firstname106':6 'jona':5 'leon':2 'luka':1 'tobia':4"
				, "'ben':7 'eli':8 'finn':3 'firstname106':6 'jon':5 'leon':2 'luk':1 'tobi':4"
				, "'ben':7 'elias':8 'finn':3 'firstname106':6 'jonas':5 'leon':2 'lukas':1 'tobias':4"
				, 5, 8
				, "'secondname106':2B 'silva':1B 'silva@oracule.org':3C"
				, "'secondname106' 'silva' 'silva@oracule.org'"
				, "'secondname106':2 'silva':1"
				, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
				, 0.0, 0.0, 0.0, 0.0
		);
		testOneRow(result.get(4), 107l
				, "'ana':2 'emma':1 'firstname107':6 'hannah':5 'julia':3 'laura':7 'leah':4 'lena':8 'mia':9"
				, "'ana':2 'emma':1 'firstname107':6 'hannah':5 'juli':3 'laur':7 'leah':4 'len':8 'mia':9"
				, "'ana':2 'emma':1 'firstname107':6 'hannah':5 'julia':3 'laura':7 'leah':4 'lena':8 'mia':9"
				, 5, 9
				, "'korhonen':1B 'korhonen@korhonen.com':3C 'secondname107':2B"
				, "'korhonen' 'korhonen@korhonen.com' 'secondname107'"
				, "'korhonen':1 'secondname107':2"
				, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0
				, 0.0, 0.0, 0.0, 0.0
		);
	}

	private void testOneRow(Tuple t, long l, String s0, String s1, String s2, int i0, int i1, String s4
			, String s5, String s6, double v0, double v1, double v2, double v3, double v4, double v5, double v6
			, double v7, double v8, double v9, double v10, double v11, double v12) {
		Object[] row = t.toArray();
		String s0A = s0.replaceAll(" ", "A ") + "A";
		assertEquals(l, (Long) row[0]);
		assertEquals(s0, row[1]);
		assertEquals(s0, row[2]);
		assertEquals(s1, row[3]);
		assertEquals(s2, row[4]);
		assertEquals(i0, (int) row[5]);
		assertEquals(i1, (int) row[6]);
		assertEquals(s0A, row[7]);
		assertEquals(s4, row[8]);
		assertEquals(s5, row[9]);
		assertEquals(s6, row[10]);
		assertDouble(v0, row[11]);
		assertDouble(v1, row[12]);
		assertDouble(v2, row[13]);
		assertDouble(v3, row[14]);
		assertDouble(v4, row[15]);
		assertDouble(v5, row[16]);
		assertDouble(v6, row[17]);
		assertDouble(v7, row[18]);
		assertDouble(v8, row[19]);
		assertDouble(v9, row[20]);
		assertDouble(v10, row[21]);
		assertDouble(v11, row[22]);
		assertDouble(v12, row[23]);
	}

	private void assertDouble(double expected, Object value) {
		BigDecimal ex = new BigDecimal(expected);
		ex = ex.setScale(4, RoundingMode.HALF_UP);
		BigDecimal val = new BigDecimal(Float.valueOf((float) value).doubleValue());
		val = val.setScale(4, RoundingMode.HALF_UP);
		assertEquals(ex.doubleValue(), val.doubleValue());
	}

	@Test
	public void testFindByConditionHighlight() throws Exception {
		HighlightOptions optA = HighlightOptions.builder()
				.withMinWords(1)
				.withMaxWords(3)
				.withShortWord(1)
				.withStartMark("<Q>")
				.withStopMark("</Q>")
				.withDelimiter("***")
				.withMaxFragments(3);
		HighlightOptions optB = HighlightOptions.builder()
				.withHighlightAll()
				.withStartMark("{{{")
				.withStopMark("}}}")
				.withDelimiter("___")
				.withMaxFragments(3);
		List<ConditionalCriteria> cond = ConditionalCriteriaBuilder.criteriaFor(Person.class)
				.select(PersonProperties.id())
				.select(firstName().expr().ftsHighlight("dolores | idaira"))
				.select(firstName().expr().ftsHighlight(ftsQuery("carmen")))
				.select(firstName().expr().ftsHighlight("dolores | idaira", optA))
				.select(firstName().expr().ftsHighlight(ftsQuery("carmen"), optA))
				.select(firstName().expr().ftsHighlight("spanish", "dolores | idaira"))
				.select(firstName().expr().ftsHighlight("spanish", ftsQuery("spanish", "carmen")))
				.select(firstName().expr().ftsHighlight("spanish", "dolores | idaira", optB))
				.select(firstName().expr().ftsHighlight("spanish", ftsQuery("spanish", "carmen"), optB))
				.where(id()).eq(103)
				.orderBy(PersonProperties.id())
				.build();
		List<Tuple> result = personService.findByConditionTuple(getServiceContext(), cond);
		// printTuple(result);

		Object[] row = result.get(0).toArray();
		assertEquals(9, row.length);
		assertEquals(103l, (Long) row[0]);
		assertEquals("Maria Anna Carmen <b>Dolores</b> #FIRSTNAME103 Naira <b>Idaira</b> Yurena May Adassa", (String) row[1]);
		assertEquals("Maria Anna <b>Carmen</b> Dolores #FIRSTNAME103 Naira Idaira Yurena May Adassa", (String) row[2]);
		assertEquals("Carmen <Q>Dolores</Q> #FIRSTNAME103***Naira <Q>Idaira</Q> Yurena", (String) row[3]);
		assertEquals("Anna <Q>Carmen</Q> Dolores", (String) row[4]);
		assertEquals("Maria Anna Carmen <b>Dolores</b> #FIRSTNAME103 Naira <b>Idaira</b> Yurena May Adassa", (String) row[5]);
		assertEquals("Maria Anna <b>Carmen</b> Dolores #FIRSTNAME103 Naira Idaira Yurena May Adassa", (String) row[6]);
		assertEquals("Maria Anna Carmen {{{Dolores}}} #FIRSTNAME103 Naira {{{Idaira}}} Yurena May Adassa", (String) row[7]);
		assertEquals("Maria Anna {{{Carmen}}} Dolores #FIRSTNAME103 Naira Idaira Yurena May Adassa", (String) row[8]);
	}

	@Test
	public void testSave() throws Exception {
		Person person = new Person();
		person.setFirstName("Aaa");
		person.setSecondName("Bbb");
		person.setEmailAddress("ccc@ccc.com");
		person.setBirthDate(LocalDate.of(1988, Month.MARCH, 22));
		person.setSex(Sex.MAN);
		person = personService.save(getServiceContext(), person);
		assertNotNull(person.getId());
		assertNotNull(person.getVersion());
		assertNotNull(person.getUuid());
		assertNotNull(person.getCreatedDate());
		assertNotNull(person.getCreatedBy());
		assertEquals(person.getCreatedDate(), person.getLastUpdated());
		assertEquals(person.getCreatedBy(), person.getLastUpdatedBy());
		assertEquals("Aaa", person.getFirstName());
		assertEquals("Bbb", person.getSecondName());
		assertEquals("ccc@ccc.com", person.getEmailAddress());
		LocalDate birthDate = person.getBirthDate();
		assertEquals(1988, birthDate.getYear());
		assertEquals(Month.MARCH, birthDate.getMonth());
		assertEquals(22, birthDate.getDayOfMonth());
		assertEquals(Sex.MAN, person.getSex());
	}

	@Test
	public void testDelete() throws Exception {
		int personBefore = countRowsInTable("PERSON");
		personService.delete(getServiceContext(), personService.findById(getServiceContext(), 102l));
		int personAfter = countRowsInTable("PERSON");
		assertEquals(personBefore, personAfter + 1);
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
