package org.sculptor.example.ejb.helloworld.milkyway.serviceapi;

import static org.junit.Assert.assertEquals;

import java.util.List;

import javax.ejb.EJB;

import org.junit.Test;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.PlanetDto;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.PlanetWebService;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.PlanetWebServiceTestBase;
import org.sculptor.framework.test.AbstractOpenEJBDbUnitTest;

/**
 * JUnit test with OpenEJB support.
 */
public class PlanetWebServiceTest extends AbstractOpenEJBDbUnitTest implements PlanetWebServiceTestBase {

	@EJB
	private PlanetWebService planetWebService;

	@Test
	public void testGetAllPlanets() throws Exception {
		List<PlanetDto> allPlanets = planetWebService.getAllPlanets();
		assertEquals(2, allPlanets.size());
	}
}
