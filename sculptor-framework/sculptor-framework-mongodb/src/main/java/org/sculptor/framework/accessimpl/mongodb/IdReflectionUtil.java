/*
 * Copyright 2010 The Fornax Project Team, including the original
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
package org.sculptor.framework.accessimpl.mongodb;

import java.io.Serializable;
import java.lang.reflect.Field;

import org.apache.commons.beanutils.PropertyUtils;
import org.sculptor.framework.domain.Identifiable;

public class IdReflectionUtil {

    public static Serializable internalGetId(Object domainObject) {
        if (domainObject instanceof Identifiable) {
            return ((Identifiable) domainObject).getId();
        }

        if (PropertyUtils.isReadable(domainObject, "id")) {
            try {
                return (Serializable) PropertyUtils.getProperty(domainObject, "id");
            } catch (Exception e) {
                throw new IllegalArgumentException("Can't get id property of domainObject: " + domainObject);
            }
        } else {

            // no id property, don't know if it is new
            throw new IllegalArgumentException("No id property in domainObject: " + domainObject);
        }
    }

    public static void internalSetId(Object domainObject, Serializable id) {
        internalSet(domainObject, "id", id);
    }

    public static void internalSetUuid(Object domainObject, String uuid) {
        internalSet(domainObject, "uuid", uuid);
    }

    public static void internalSetVersion(Object domainObject, Long version) {
        internalSet(domainObject, "version", version);
    }

    public static void internalSet(Object domainObject, String fieldName, Object value) {
        try {
            Field field = findField(domainObject.getClass(), fieldName);
            field.setAccessible(true);
            field.set(domainObject, value);
        } catch (Exception e) {
            throw new IllegalArgumentException("Can't get " + fieldName + " field of domainObject: " + domainObject);
        }
    }

    private static Field findField(Class<?> clazz, String fieldName) throws NoSuchFieldException {
        try {
            return clazz.getDeclaredField(fieldName);
        } catch (NoSuchFieldException e) {
            if (clazz.getSuperclass() == null) {
                throw e;
            } else {
                return findField(clazz.getSuperclass(), fieldName);
            }
        }
    }

}
