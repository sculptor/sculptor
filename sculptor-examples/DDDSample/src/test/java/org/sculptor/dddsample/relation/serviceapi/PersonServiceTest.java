package org.sculptor.dddsample.relation.serviceapi;

import org.junit.Test;
import org.sculptor.dddsample.relation.domain.House;
import org.sculptor.dddsample.relation.domain.Person;
import org.sculptor.dddsample.relation.domain.PersonRepository;
import org.sculptor.dddsample.relation.serviceapi.PersonService;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import static org.junit.Assert.*;

import java.util.Collection;
import java.util.List;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PersonServiceTest extends AbstractDbUnitJpaTests implements PersonServiceTestBase {

	@Autowired
	private PersonService personService;

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
		assertEquals(4, all.size());
		boolean was101 = false;
		for (Person p : all) {
			if (p.getId().equals(101l)) {
				Collection<House> owningNoRel = p.getOwningNoRel();
				assertEquals(3, owningNoRel.size());
				Collection<House> relatedNoRel = p.getRelatedNoRel();
				assertEquals(3, relatedNoRel.size());
				Collection<House> otherNoRel = p.getOtherNoRel();
				assertEquals(3, otherNoRel.size());
				was101 = true;
			}
		}
		assertTrue(was101);
	}

	@Test
	@Override
	public void testSave() throws Exception {
		Person p = new Person();
		p.setFirst("Newman");
		p.setSecondName("Elemental");
		House firstHouse = new House();
		firstHouse.setStreet("Atomic");
		firstHouse.setNumber("1123");
		firstHouse.setNumberOfFloors(2);
		firstHouse.setOwner(p);
		firstHouse.setRelation(p);
		firstHouse.setSomething(p);
		firstHouse.setTown("Plymouth");
		firstHouse.setZipCode("A-923754");
		firstHouse.setState("Small Britain");
		firstHouse.setHouseFootprint(123);
		firstHouse.setLandFieldSize(432);
		House secondHouse = new House();
		secondHouse.setStreet("Quark");
		secondHouse.setNumber("893");
		secondHouse.setNumberOfFloors(1);
		secondHouse.setOwner(p);
		secondHouse.setRelation(p);
		secondHouse.setSomething(p);
		secondHouse.setTown("Cardiff");
		secondHouse.setZipCode("B-3478");
		secondHouse.setState("Small Britain");
		secondHouse.setHouseFootprint(947);
		secondHouse.setLandFieldSize(1837);

		p.addOwningNoRel(firstHouse);
		p.addOwningNoRel(secondHouse);
		Person stored = personService.save(getServiceContext(), p);
		entityManager.clear();

		// All will have 2 items not only OwningNoRel
		Person fetched = personService.findById(getServiceContext(), stored.getId());

		Collection<House> owningNoRel = fetched.getOwningNoRel();
		assertEquals(2, owningNoRel.size());

		// This is WRONG - should be 0
		Collection<House> relatedNoRel = fetched.getRelatedNoRel();
		assertEquals(2, relatedNoRel.size());

		// This is WRONG - should be 0
		Collection<House> otherNoRel = fetched.getOtherNoRel();
		assertEquals(2, otherNoRel.size());
	}

	@Override
	public void testDelete() throws Exception {
	}
}
