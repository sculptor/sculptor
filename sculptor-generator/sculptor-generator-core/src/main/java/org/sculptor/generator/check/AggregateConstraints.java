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

import java.util.ArrayList;
import java.util.Collection;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import sculptormetamodel.Application;
import sculptormetamodel.BasicType;
import sculptormetamodel.DomainObject;
import sculptormetamodel.Entity;
import sculptormetamodel.Module;
import sculptormetamodel.Reference;
import sculptormetamodel.ValueObject;

/**
 * This class checks constraints for DomainObject Aggregates, according to DDD.
 */
public class AggregateConstraints {

	private static final Logger LOG = LoggerFactory
			.getLogger(AggregateConstraints.class);

	/**
	 * According to DDD the aggregate root is the only member of the aggregate
	 * that objects outside the aggregate boundary may hold references to.
	 */
	public static boolean checkAggregateReferences(Application app) {
		Map<DomainObject, Set<DomainObject>> aggregateGroups = getAggregateGroups(app);
		for (Set<DomainObject> group1 : aggregateGroups.values()) {
			for (Set<DomainObject> group2 : aggregateGroups.values()) {
				if (group1 == group2) {
					continue;
				}
				// find only the elements common to both sets, i.e. the
				// intersection
				Set<DomainObject> intersection = new HashSet<DomainObject>(
						group1);
				intersection.retainAll(group2);
				if (!intersection.isEmpty()) {
					// found two groups with some non-root objects in common,
					// i.e. reference directly to a non-root from outside the
					// aggregate boundary
					LOG.warn("checkAggregateReferences failed with intersection: "
							+ intersection);
					return false;
				}
			}
		}
		// everything alright
		return true;
	}

	private static Map<DomainObject, Set<DomainObject>> getAggregateGroups(
			Application app) {
		Map<DomainObject, Set<DomainObject>> groups = new HashMap<DomainObject, Set<DomainObject>>();
		for (DomainObject root : getAllAggregatesRoots(app)) {
			Set<DomainObject> group = new HashSet<DomainObject>();
			groups.put(root, group);
			collectAggregateGroup(root, group);
		}
		return groups;
	}

	private static void collectAggregateGroup(DomainObject domainObject,
			Set<DomainObject> group) {
		for (Reference ref : (List<Reference>) domainObject.getReferences()) {
			if (!isAggregateRoot(ref.getTo())
					&& isEntityOrPersistentValueObject(ref.getTo())
					&& !group.contains(ref.getTo())) {
				group.add(ref.getTo());
				// follow reference and collect other objects in same aggregate
				// group
				collectAggregateGroup(ref.getTo(), group); // recursive call
			}
		}
	}

	private static Collection<DomainObject> getAllAggregatesRoots(
			Application app) {
		List<DomainObject> all = new ArrayList<DomainObject>();
		for (Module m : (List<Module>) app.getModules()) {
			for (DomainObject d : (List<DomainObject>) m.getDomainObjects()) {
				if (isEntityOrPersistentValueObject(d) && d.isAggregateRoot()) {
					all.add(d);
				}
			}
		}
		return all;
	}

	private static boolean isAggregateRoot(DomainObject d) {
		return (isEntityOrPersistentValueObject(d) && d.isAggregateRoot());
	}

	public static boolean isEntityOrPersistentValueObject(DomainObject d) {
		if ((d instanceof BasicType) || (d instanceof sculptormetamodel.Enum)) {
			return false;
		}
		return isPersistent(d);
	}

	public static boolean isPersistent(DomainObject domainObject) {
		if (domainObject instanceof Entity) {
			return true;
		} else if (domainObject instanceof ValueObject) {
			ValueObject vo = (ValueObject) domainObject;
			return vo.isPersistent();
		} else {
			return false;
		}
	}

}
