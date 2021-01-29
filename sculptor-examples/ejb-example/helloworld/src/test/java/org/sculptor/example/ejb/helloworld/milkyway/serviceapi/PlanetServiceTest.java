package org.sculptor.example.ejb.helloworld.milkyway.serviceapi;

import java.util.List;

import javax.ejb.EJB;

import org.junit.jupiter.api.Test;
import org.sculptor.example.ejb.helloworld.milkyway.domain.Planet;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.PlanetService;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.PlanetServiceTestBase;
import org.sculptor.framework.test.AbstractOpenEJBDbUnitTest;

import static org.junit.jupiter.api.Assertions.assertEquals;
import static org.junit.jupiter.api.Assertions.assertNotNull;

/**
 * JUnit test with OpenEJB support.
 */
public class PlanetServiceTest extends AbstractOpenEJBDbUnitTest implements PlanetServiceTestBase {

	@EJB
	private PlanetService planetService;

	@Test
	public void testFindById() throws Exception {
		Planet earth = planetService.findById(getServiceContext(), 1L);
		assertNotNull(earth);
		assertEquals("Earth", earth.getName());
	}

	@Test
	public void testFindAll() throws Exception {
		List<Planet> planets = planetService.findAll(getServiceContext());
		assertEquals(2, planets.size());
	}

	@Test
	public void testSave() throws Exception {
		int planetsBefore = countRowsInTable(Planet.class);
		Planet jupiter = new Planet("Jupiter");
		jupiter.setMessage("Hello from Jupiter");
		planetService.save(getServiceContext(), jupiter);
		int planetsAfter = countRowsInTable(Planet.class);
		assertEquals(planetsBefore + 1, planetsAfter);
	}

	@Test
	public void testDelete() throws Exception {
		int planetsBefore = countRowsInTable(Planet.class);
		Planet earth = planetService.findById(getServiceContext(), 1L);
		planetService.delete(getServiceContext(), earth);
		int planetsAfter = countRowsInTable(Planet.class);
		assertEquals(planetsBefore - 1, planetsAfter);
	}

}
