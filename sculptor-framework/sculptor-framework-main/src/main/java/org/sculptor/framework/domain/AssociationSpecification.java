/*
 * Copyright 2009 The Fornax Project Team, including the original
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
package org.sculptor.framework.domain;

import java.util.HashSet;
import java.util.Set;

/**
 * Specification of the associations to be populated on request by a client.
 */
public class AssociationSpecification extends AbstractDomainObject {
    private static final long serialVersionUID = -8048504029628479107L;

    private final Set<String> associationNames = new HashSet<String>();

    public AssociationSpecification() {
    }

    public AssociationSpecification(String associationName) {
        addAssociationName(associationName);
    }

    public void addAssociationName(String associationName) {
        associationNames.add(associationName);
    }

    public Set<String> getAssociationNames() {
        return associationNames;
    }

}
