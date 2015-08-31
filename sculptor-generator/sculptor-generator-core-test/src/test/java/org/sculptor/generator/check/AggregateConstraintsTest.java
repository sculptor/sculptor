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
package org.sculptor.generator.check;

import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertTrue;

import org.junit.Before;
import org.junit.Test;
import org.sculptor.generator.check.AggregateConstraints;

import sculptormetamodel.Application;
import sculptormetamodel.Entity;
import sculptormetamodel.Module;
import sculptormetamodel.Reference;
import sculptormetamodel.SculptormetamodelFactory;
import sculptormetamodel.impl.SculptormetamodelFactoryImpl;

public class AggregateConstraintsTest {

	private SculptormetamodelFactory factory;

	private Application app;
	private Entity a;
	private Entity b;
	private Entity c;
	private Entity d;

	@Before
	public void setUp() {
		factory = SculptormetamodelFactoryImpl.eINSTANCE;
		app = factory.createApplication();
		Module m1 = factory.createModule();
		m1.setApplication(app);
		Module m2 = factory.createModule();
		m2.setApplication(app);
		a = factory.createEntity();
		a.setModule(m1);
		b = factory.createEntity();
		b.setModule(m2);
		c = factory.createEntity();
		c.setModule(m2);
		d = factory.createEntity();
		d.setModule(m2);
	}

	@Test
	public void testOkReferences() {
		Reference refAB = factory.createReference();
		refAB.setTo(b);
		b.getReferences().add(refAB);
		Reference refBC = factory.createReference();
		refBC.setTo(c);
		b.getReferences().add(refBC);

		assertTrue(AggregateConstraints.checkAggregateReferences(app));
	}

	@Test
	public void testOkReferencesFromAggregate() {
		b.setAggregateRoot(false);
		Reference refAB = factory.createReference();
		refAB.setTo(b);
		b.getReferences().add(refAB);
		Reference refBC = factory.createReference();
		refBC.setTo(c);
		b.getReferences().add(refBC);
		Reference refCA = factory.createReference();
		refCA.setTo(a);
		c.getReferences().add(refCA);

		assertTrue(AggregateConstraints.checkAggregateReferences(app));
	}

	@Test
	public void testInvalidReferencesToAggregate() {
		b.setAggregateRoot(false);
		Reference refAB = factory.createReference();
		refAB.setTo(b);
		a.getReferences().add(refAB);
		Reference refBC = factory.createReference();
		refBC.setTo(c);
		b.getReferences().add(refBC);
		Reference refCB = factory.createReference();
		refCB.setTo(b);
		c.getReferences().add(refCB);

		assertFalse(AggregateConstraints.checkAggregateReferences(app));
	}

	@Test
	public void testInvalidReferencesToDeepAggregate() {
		b.setAggregateRoot(false);
		c.setAggregateRoot(false);
		Reference refAB = factory.createReference();
		refAB.setTo(b);
		a.getReferences().add(refAB);
		Reference refBC = factory.createReference();
		refBC.setTo(c);
		b.getReferences().add(refBC);
		Reference refCA = factory.createReference();
		refCA.setTo(a);
		c.getReferences().add(refCA);
		Reference refDC = factory.createReference();
		refDC.setTo(c);
		d.getReferences().add(refDC);

		assertFalse(AggregateConstraints.checkAggregateReferences(app));
	}

	@Test
	public void testOkCycleReferences() {
		Reference refAB = factory.createReference();
		refAB.setTo(b);
		b.getReferences().add(refAB);
		Reference refBC = factory.createReference();
		refBC.setTo(c);
		b.getReferences().add(refBC);
		Reference refCA = factory.createReference();
		refCA.setTo(a);
		c.getReferences().add(refCA);

		assertTrue(AggregateConstraints.checkAggregateReferences(app));
	}

}
