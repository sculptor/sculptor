package org.sculptor.example.ejb.helloworld.milkyway.serviceapi;

import static org.junit.Assert.assertEquals;

import javax.ejb.EJB;

import org.junit.Test;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.InternalPlanetService;
import org.sculptor.example.ejb.helloworld.milkyway.serviceapi.InternalPlanetServiceTestBase;
import org.sculptor.framework.test.AbstractOpenEJBDbUnitTest;

/**
 * JUnit test with OpenEJB support.
 */
public class InternalPlanetServiceTest extends AbstractOpenEJBDbUnitTest implements InternalPlanetServiceTestBase {

	@EJB
	private InternalPlanetService internalPlanetService;

	@Test
	public void testSayHello() throws Exception {
		assertEquals("Hello", internalPlanetService.sayHello(getServiceContext()));
	}
}
