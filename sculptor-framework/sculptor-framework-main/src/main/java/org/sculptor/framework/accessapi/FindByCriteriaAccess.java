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

package org.sculptor.framework.accessapi;

import java.util.List;
import java.util.Map;
import java.util.Set;



/**
 * <p>
 * Access command for finding objects by simple restrictions
 * of a criteria. The specified {@link #setRestrictions restrictions}
 * are used to build the restrictions with simple equals conditions.
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 *
 */
public interface FindByCriteriaAccess<T> extends Cacheable, Ordered, Pageable {
    /**
     * These restriction parameters are used to build the restrictions
     * with simple equals conditions. The map contains
     * property names and values.
     * {@link #addRestriction} is an alternative way to
     * define the restrictions.
     */
    void setRestrictions(Map<String, Object> restrictions);

    /**
     * Add a restriction parameter.
     * {@link #setRestrictions} is an alternative way to
     * define the restrictions.
     * @param name property name
     * @param value property value
     */
    void addRestriction(String name, Object value);

    /**
     * These association paths will be fetched with
     * fetch mode join.
     */
    void setFetchAssociations(Set<String> associationPaths);

    /**
     * Add an association path, which will be fetched with
     * fetch mode join.
     */
    void addFetchAssociation(String associationPath);


    void execute();

    /**
     * The result of the command.
     */
    List<T> getResult();

}