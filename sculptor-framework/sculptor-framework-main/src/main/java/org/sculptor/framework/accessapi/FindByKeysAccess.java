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

import java.util.Map;
import java.util.Set;


public interface FindByKeysAccess<T> extends Cacheable {

    /**
     * The name of the natural key property of the Domain Object,
     * i.e. the natural key attribute or natural key object.
     */
    public void setKeyPropertyName(String keyPropertyName);

    /**
     * When the natural key is a single simple attribute this
     * restrictionPropertyName should not be defined. When
     * it is a composite key or when it is a key object this
     * must be defined. It is the name of the property to use
     * in the the restriction criteria.
     */
    public void setRestrictionPropertyName(String restrictionPropertyName);

    /**
     * The keys to search for.
     */
    public void setKeys(Set<?> keys);

    public void execute();

    /**
     * The result as a Map with keys and domain objects.
     */
    public Map<Object, T> getResult();

    public void setPersistentClass(Class<? extends T> persistentClass);

}
