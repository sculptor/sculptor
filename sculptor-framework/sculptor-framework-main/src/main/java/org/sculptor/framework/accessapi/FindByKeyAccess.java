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

package org.sculptor.framework.accessapi;


/**
 * Find domain object with specified natural key.
 *
 * @param <T> domain object type
 */
public interface FindByKeyAccess<T> extends Cacheable {

    /**
     * The name of the natural key properties of the Domain Object.
     * When the key is a single attribute or BasicType it will only
     * be one property name. When composite keys it will be several.
     */
    public void setKeyPropertyNames(String... keyPropertyNames);

    /**
     * The keys to search for. Must be the same number of values
     * as the number of property names defined in {@link #setKeyPropertyNames}.
     * When the key is a single attribute or BasicType it will only
     * be one property value. When composite keys it will be several.
     */
    public void setKeyPropertyValues(Object... keyValues);

    public void execute();

    /**
     * The result of the command. null if not found.
     */
    public T getResult();

    public void setPersistentClass(Class<? extends T> persistentClass);

}
