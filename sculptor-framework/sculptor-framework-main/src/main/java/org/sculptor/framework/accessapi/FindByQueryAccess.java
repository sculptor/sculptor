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


/**
 * <p>
 * Access command for finding objects by query..
 * </p>
 * <p>
 * Command design pattern.
 * </p>
 *
 */
public interface FindByQueryAccess<T> extends Cacheable, Pageable {

    void setQuery(String aQuery);

    void setParameters(Map<String, Object> parameters);

    /**
     * Define if it is a named query or direct executable query string, default
     * is true
     */
    void setNamedQuery(boolean namedQuery);

    void setUseSingleResult(boolean singleResult);

    void execute();

    /**
     * The result of the command.
     */
    List<T> getResult();

    /**
     * Result when singleResult is used.
     */
    Object getSingleResult();

}