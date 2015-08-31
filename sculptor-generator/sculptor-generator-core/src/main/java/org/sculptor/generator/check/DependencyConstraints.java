/*
 * Copyright 2007 The Fornax Project Team, including the original 
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

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import sculptormetamodel.Consumer;
import sculptormetamodel.DomainObject;
import sculptormetamodel.DomainObjectTypedElement;
import sculptormetamodel.Module;
import sculptormetamodel.Parameter;
import sculptormetamodel.Reference;
import sculptormetamodel.Repository;
import sculptormetamodel.RepositoryOperation;
import sculptormetamodel.Service;
import sculptormetamodel.ServiceOperation;

/**
 * This class checks circular dependency constraints between Modules.
 * 
 */
public class DependencyConstraints {

	public static boolean checkCyclicDependencies(Module module) {
		Set<Module> dependencies = new HashSet<Module>();
		collectDependencies(module, dependencies);
		boolean cycleFound = dependencies.contains(module);
		return !cycleFound;
	}

	public static List<Module> getModulesDependingOn(Module module) {
		Set<Module> result = new HashSet<Module>();
		List<Module> all = module.getApplication().getModules();
		for (Module each : all) {
			if (each == module) {
				result.add(each);
			} else {
				Set<Module> dependencies = new HashSet<Module>();
				collectDependencies(each, dependencies);
				if (dependencies.contains(module)) {
					result.add(each);
				}
			}
		}

		return new ArrayList<Module>(result);
	}

	static void collectDependencies(Module module, Set<Module> dependencies) {
		List<DomainObject> domainObjects = module.getDomainObjects();
		for (DomainObject d : domainObjects) {
			addDependencies(module, d, dependencies);
		}

		List<Service> services = module.getServices();
		for (Service s : services) {
			addDependencies(module, s, dependencies);
		}

		List<Consumer> consumers = module.getConsumers();
		for (Consumer c : consumers) {
			addDependencies(module, c, dependencies);
		}
	}

	private static void addDependencies(Module fromModule, Service service, Set<Module> dependencies) {
		for (Service delegate : delegateServices(service)) {
			Module m = delegate.getModule();
			addDependency(fromModule, m, dependencies);
		}
		List<ServiceOperation> operations = service.getOperations();
		for (ServiceOperation op : operations) {
			addDependency(fromModule, op, dependencies);
		}
	}

	private static void addDependencies(Module fromModule, Consumer consumer, Set<Module> dependencies) {
		for (Service delegate : (List<Service>) consumer.getServiceDependencies()) {
			Module m = delegate.getModule();
			addDependency(fromModule, m, dependencies);
		}
	}

	private static void addDependencies(Module fromModule, DomainObject domainObject, Set<Module> dependencies) {
		if (domainObject.getExtends() != null) {
			Module m = domainObject.getExtends().getModule();
			addDependency(fromModule, m, dependencies);
		}
		List<Reference> references = domainObject.getReferences();
		for (Reference r : references) {
			addDependencies(fromModule, r, dependencies);
		}
		if (domainObject.getRepository() != null) {
			addDependency(fromModule, domainObject.getRepository(), dependencies);
		}
	}

	private static void addDependency(Module fromModule, Repository repository, Set<Module> dependencies) {
		List<RepositoryOperation> operations = repository.getOperations();
		for (RepositoryOperation op : operations) {
			addDependency(fromModule, op, dependencies);
		}
	}

	private static void addDependencies(Module fromModule, Reference ref, Set<Module> dependencies) {
		if (ref.getTo() == null) {
			return;
		}
		Module m = ref.getTo().getModule();
		addDependency(fromModule, m, dependencies);
	}

	private static void addDependency(Module fromModule, ServiceOperation op, Set<Module> dependencies) {
		addDependency(fromModule, (DomainObjectTypedElement) op, dependencies);
		List<Parameter> parameters = op.getParameters();
		for (Parameter p : parameters) {
			addDependency(fromModule, p, dependencies);
		}
	}

	private static void addDependency(Module fromModule, DomainObjectTypedElement type, Set<Module> dependencies) {
		DomainObject to = type.getDomainObjectType();
		if (to != null) {
			addDependency(fromModule, to.getModule(), dependencies);
		}

	}

	private static void addDependency(Module fromModule, Module toModule, Set<Module> dependencies) {
		if (!toModule.equals(fromModule)) {
			if (dependencies.add(toModule)) {
				// recursive call, when m not used before
				collectDependencies(toModule, dependencies);
			}
		}
	}

	private static Set<Service> delegateServices(Service service) {
		Set<Service> dependencies = new HashSet<Service>();
		List<ServiceOperation> operations = service.getOperations();
		for (ServiceOperation op : operations) {
			if (op.getServiceDelegate() != null) {
				dependencies.add(op.getServiceDelegate().getService());
			}
		}
		return dependencies;
	}

}
