package org.helloworld.milkyway.serviceapi;

import static org.junit.Assert.assertEquals;

import java.util.List;

import org.helloworld.milkyway.domain.Planet;
import org.junit.Test;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

import javassist.NotFoundException;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PlanetServiceTest extends AbstractDbUnitJpaTests implements PlanetServiceTestBase {

	@Autowired
	protected PlanetService planetService;

	@Test
	public void testFindById() throws Exception {
		Planet earth = planetService.findById(getServiceContext(), 1L).orElseThrow(() -> new NotFoundException("Planet"));
		assertEquals("Earth", earth.getName());
	}

	@Test
	public void testFindByName() throws Exception {
		Planet mars = planetService.findByName(getServiceContext(), "Mars");
		assertEquals("Mars", mars.getName());
	}

	@Test
	public void testFindByDiameter() throws Exception {
		Planet mars = planetService.findByDiameter(getServiceContext(), 500);
		assertEquals("Mars", mars.getName());
	}

	@Test
	public void testFindAll() throws Exception {
		List<Planet> result = planetService.findAll(getServiceContext());
		assertEquals(2, result.size());
	}

	@Test
	public void testSave() throws Exception {
		Planet earth = planetService.findById(getServiceContext(), 1L).orElseThrow(() -> new NotFoundException("Planet"));
		int diameterBefore = earth.getDiameter();
		earth.setDiameter(diameterBefore + 100);
		planetService.save(getServiceContext(), earth);
		earth = planetService.findById(getServiceContext(), 1L).orElseThrow(() -> new NotFoundException("Planet"));
		assertEquals(diameterBefore + 100, earth.getDiameter());
	}

	@Test
	public void testDelete() throws Exception {
		int planetsBefore = countRowsInTable(Planet.class);
		Planet earth = planetService.findById(getServiceContext(), 1L).orElseThrow(() -> new NotFoundException("Planet"));
		planetService.delete(getServiceContext(), earth);
		int planetsAfter = countRowsInTable(Planet.class);
		assertEquals(planetsBefore - 1, planetsAfter);
	}

	@Test
	public void testFindLargest() throws Exception {
		Planet mars = planetService.findLargest(getServiceContext());
		assertEquals("Mars", mars.getName());
	}

	@Test
	public void testFindSmallest() throws Exception {
		Planet earth = planetService.findSmallest(getServiceContext());
		assertEquals("Earth", earth.getName());
	}

	@Test
	public void testGetLongestName() throws Exception {
		String name = planetService.getLongestName(getServiceContext());
		assertEquals("Earth", name);
	}

}
