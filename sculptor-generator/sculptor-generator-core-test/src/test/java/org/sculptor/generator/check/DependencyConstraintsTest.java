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

import static org.junit.jupiter.api.Assertions.*;

import java.util.HashSet;
import java.util.Set;

import org.junit.jupiter.api.Test;
import org.sculptor.generator.check.DependencyConstraints;

import sculptormetamodel.Application;
import sculptormetamodel.Entity;
import sculptormetamodel.Module;
import sculptormetamodel.Reference;
import sculptormetamodel.SculptormetamodelFactory;
import sculptormetamodel.Service;
import sculptormetamodel.ServiceOperation;
import sculptormetamodel.impl.SculptormetamodelFactoryImpl;

public class DependencyConstraintsTest {

	/**
	 * m2 -> m1 via m2.b -> m1.a m2.d -> m1.c
	 */
	@Test
	public void testNoCycle() {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Application app = factory.createApplication();
		Module m1 = factory.createModule();
		m1.setApplication(app);
		Module m2 = factory.createModule();
		m2.setApplication(app);
		Entity a = factory.createEntity();
		a.setModule(m1);
		Entity b = factory.createEntity();
		b.setModule(m2);
		b.setExtends(a); // dependency from m2 to m1
		Entity c = factory.createEntity();
		c.setModule(m1);
		Entity d = factory.createEntity();
		d.setModule(m2);
		d.setExtends(c); // dependency from m2 to m1

		Set<Module> dependencies1 = new HashSet<Module>();
		DependencyConstraints.collectDependencies(m1, dependencies1);
		assertEquals(0, dependencies1.size());

		assertTrue(DependencyConstraints.checkCyclicDependencies(m1));

		Set<Module> dependencies2 = new HashSet<Module>();
		DependencyConstraints.collectDependencies(m2, dependencies2);
		assertEquals(1, dependencies2.size());
		assertTrue(dependencies2.contains(m1));

		assertTrue(DependencyConstraints.checkCyclicDependencies(m2));
	}

	/**
	 * m2 <-> m1 via m2.b -> m1.a m1.c -> m2.d
	 */
	@Test
	public void testSimpleCycle() {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Application app = factory.createApplication();
		Module m1 = factory.createModule();
		m1.setApplication(app);
		Module m2 = factory.createModule();
		m2.setApplication(app);
		Entity a = factory.createEntity();
		a.setModule(m1);
		Entity b = factory.createEntity();
		b.setModule(m2);
		b.setExtends(a); // dependency from m2 to m1
		Entity c = factory.createEntity();
		c.setModule(m1);
		Entity d = factory.createEntity();
		d.setModule(m2);
		Reference ref = factory.createReference();
		ref.setTo(d);
		c.getReferences().add(ref); // dependency from m1 to m2

		Set<Module> dependencies1 = new HashSet<Module>();
		DependencyConstraints.collectDependencies(m1, dependencies1);
		assertEquals(2, dependencies1.size());
		assertTrue(dependencies1.contains(m1));
		assertTrue(dependencies1.contains(m2));

		assertFalse(DependencyConstraints.checkCyclicDependencies(m1));

		Set<Module> dependencies2 = new HashSet<Module>();
		DependencyConstraints.collectDependencies(m2, dependencies2);
		assertEquals(2, dependencies2.size());
		assertTrue(dependencies2.contains(m1));
		assertTrue(dependencies2.contains(m2));

		assertFalse(DependencyConstraints.checkCyclicDependencies(m2));
	}

	/**
	 * m1 -> m2 -> m3 -> m1 via m1.a -> m2.b m2.b -> m3.c m3.c -> m1.a
	 */
	@Test
	public void testComplexCycle() {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Application app = factory.createApplication();
		Module m1 = factory.createModule();
		m1.setApplication(app);
		Module m2 = factory.createModule();
		m2.setApplication(app);
		Module m3 = factory.createModule();
		m3.setApplication(app);
		Entity a = factory.createEntity();
		a.setModule(m1);
		Entity b = factory.createEntity();
		b.setModule(m2);
		Reference ref1 = factory.createReference();
		ref1.setTo(b);
		a.getReferences().add(ref1);
		Entity c = factory.createEntity();
		c.setModule(m3);
		b.setExtends(c); // dependency from m2 to m3
		Reference ref2 = factory.createReference();
		ref2.setTo(a);
		c.getReferences().add(ref2); // dependency from m3 to m1

		Set<Module> dependencies1 = new HashSet<Module>();
		DependencyConstraints.collectDependencies(m1, dependencies1);
		assertEquals(3, dependencies1.size());
		assertTrue(dependencies1.contains(m1));
		assertTrue(dependencies1.contains(m2));
		assertTrue(dependencies1.contains(m3));

		assertFalse(DependencyConstraints.checkCyclicDependencies(m1));
	}

	/**
	 * m2 <-> m1 via m2.s2.op21 -> m1.s1.op11 m1.s1.op12 -> m2.s2.op22
	 */
	@Test
	public void testServiceCycle() {
		SculptormetamodelFactory factory = SculptormetamodelFactoryImpl.eINSTANCE;
		Application app = factory.createApplication();
		Module m1 = factory.createModule();
		m1.setApplication(app);
		Module m2 = factory.createModule();
		m2.setApplication(app);
		Service s1 = factory.createService();
		s1.setModule(m1);
		Service s2 = factory.createService();
		s2.setModule(m2);
		ServiceOperation op11 = factory.createServiceOperation();
		op11.setService(s1);
		ServiceOperation op12 = factory.createServiceOperation();
		op12.setService(s1);
		ServiceOperation op21 = factory.createServiceOperation();
		op21.setService(s2);
		ServiceOperation op22 = factory.createServiceOperation();
		op22.setService(s2);
		op21.setServiceDelegate(op11); // dependency from m2 to m1
		op12.setServiceDelegate(op22); // dependency from m1 to m2

		Set<Module> dependencies1 = new HashSet<Module>();
		DependencyConstraints.collectDependencies(m1, dependencies1);
		assertEquals(2, dependencies1.size());
		assertTrue(dependencies1.contains(m1));
		assertTrue(dependencies1.contains(m2));

		assertFalse(DependencyConstraints.checkCyclicDependencies(m1));

		Set<Module> dependencies2 = new HashSet<Module>();
		DependencyConstraints.collectDependencies(m2, dependencies2);
		assertEquals(2, dependencies2.size());
		assertTrue(dependencies2.contains(m1));
		assertTrue(dependencies2.contains(m2));

		assertFalse(DependencyConstraints.checkCyclicDependencies(m2));
	}

}
