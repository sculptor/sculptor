package org.sculptor.example.helloworld.milkyway.serviceapi;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;

import org.junit.Test;
import org.sculptor.example.helloworld.milkyway.domain.Moon;
import org.sculptor.example.helloworld.milkyway.domain.Planet;
import org.sculptor.example.helloworld.milkyway.exception.PlanetNotFoundException;
import org.sculptor.framework.domain.PagedResult;
import org.sculptor.framework.domain.PagingParameter;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;

/**
 * Spring based transactional test with DbUnit support.
 */
public class PlanetServiceTest extends AbstractDbUnitJpaTests implements PlanetServiceTestBase {

    @Autowired
    private PlanetService planetService;

    @Test(expected=PlanetNotFoundException.class)
    public void testSayHello() throws Exception {
        String greeting = planetService.sayHello(getServiceContext(), "Earth");
        assertEquals("Hello from Earth", greeting);
    }

    @Test
    public void testSayHelloError() throws Exception {
        planetService.sayHello(getServiceContext(), "Pluto");
    }

    @Test
    public void testGetPlanet() throws Exception {
        Planet earth = planetService.getPlanet(getServiceContext(), "Earth");
        assertNotNull(earth);
        assertEquals("Earth", earth.getName());
    }

    @Test
    public void testFindById() throws Exception {
        Planet earth = planetService.findById(getServiceContext(), 11L);
        assertEquals("Earth", earth.getName());
    }

    @Test
    public void testFindAll() throws Exception {
    	PagingParameter pagingParameter = PagingParameter.pageAccess(10);
        PagedResult<Planet> result = planetService.findAll(getServiceContext(), pagingParameter);
        assertEquals(2, result.getValues().size());
    }

    @Test
    public void testSave() throws Exception {
        int moonsBefore = countRowsInTable(Moon.class);
        Planet earth = planetService.getPlanet(getServiceContext(), "Earth");
        earth.addMoon(new Moon("Moon2"));
        planetService.save(getServiceContext(), earth);
        int moonsAfter = countRowsInTable(Moon.class);
        assertEquals(moonsBefore + 1, moonsAfter);
    }

    @Test
    public void testDeleteOrphan() throws Exception {
        int moonsBefore = countRowsInTable(Moon.class);
        Planet earth = planetService.getPlanet(getServiceContext(), "Earth");
        // delete orphan
        earth.removeAllMoons();
        planetService.save(getServiceContext(), earth);
        int moonsAfter = countRowsInTable(Moon.class);
        assertEquals(moonsBefore - 1, moonsAfter);
    }

    @Test
    public void testDelete() throws Exception {
        int planetsBefore = countRowsInTable(Planet.class);
        int moonsBefore = countRowsInTable(Moon.class);
        Planet earth = planetService.getPlanet(getServiceContext(), "Earth");
        planetService.delete(getServiceContext(), earth);
        int planetsAfter = countRowsInTable(Planet.class);
        int moonsAfter = countRowsInTable(Moon.class);
        assertEquals(planetsBefore - 1, planetsAfter);
        assertEquals(moonsBefore - 1, moonsAfter);
    }

    @Test
    public void testPopulateAssociations() throws Exception {
        // planet.moons has lazy="false", due to same aggregate
    }

}
