/*
 * Copyright 2014 The Sculptor Project Team, including the original 
 * author or authors.
 * 
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 * 
 *      http://www.apache.org/licenses/LICENSE-2.0
 * 
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.sculptor.examples.boot.milkyway.serviceapi;

import static org.junit.Assert.assertEquals;

import java.util.List;

import org.junit.Test;
import org.sculptor.examples.boot.milkyway.domain.Planet;
import org.sculptor.framework.test.AbstractDbUnitJpaTests;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.test.context.ActiveProfiles;

/**
 * Spring based transactional test with DbUnit support.
 */
@ActiveProfiles("test")
public class PlanetServiceTest extends AbstractDbUnitJpaTests implements PlanetServiceTestBase {

	@Autowired
	protected PlanetService planetService;

	@Test
	public void testFindById() throws Exception {
		Planet earth = planetService.findById(getServiceContext(), 1L);
		assertEquals("Earth", earth.getName());
	}

	@Test
	public void testFindAll() throws Exception {
		List<Planet> result = planetService.findAll(getServiceContext());
		assertEquals(2, result.size());
	}

	@Test
	public void testSave() throws Exception {
		Planet earth = planetService.findById(getServiceContext(), 1L);
		int diameterBefore = earth.getDiameter();
		earth.setDiameter(diameterBefore + 100);
		planetService.save(getServiceContext(), earth);
		earth = planetService.findById(getServiceContext(), 1L);
		assertEquals(diameterBefore + 100, earth.getDiameter());
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
